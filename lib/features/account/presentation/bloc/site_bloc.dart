import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/error_messages.dart';
import '../../../../core/error/result.dart';
import '../../../../data/local/preferences/app_preferences.dart';
import '../../../../data/repositories/site_repository.dart';
import '../../../../domain/entities/site.dart';
import '../../../../domain/value_objects/role.dart';

part 'site_event.dart';
part 'site_state.dart';

/// Global — owns the site list and the selected site. Every screen that shows
/// site data reads `selectedSiteId` from here; the `SiteSelector` widget
/// switches it.
@lazySingleton
class SiteBloc extends Bloc<SiteEvent, SiteState> {
  SiteBloc(this._repo, this._prefs) : super(const SiteState.initial()) {
    on<SitesSubscribed>(_onSubscribed, transformer: restartable());
    on<SiteSelected>(_onSelected);
    on<SiteCreated>(_onCreated, transformer: droppable());
    on<SiteUpdated>(_onUpdatedRequested, transformer: droppable());
    on<SitesRefreshed>((_, _) => _repo.refreshSites());
  }

  final SiteRepository _repo;
  final AppPreferences _prefs;

  /// Tenant-wide role of the signed-in user (set by the shell from AuthBloc).
  Role tenantRole = Role.viewer;

  Site? get selectedSite => state.selectedSite;

  /// Effective role on the selected site (no per-site membership data yet →
  /// tenant role applies; narrowed once members are loaded for that site).
  Role get effectiveRole =>
      Role.effective(tenantRole, siteRole: state.siteRole);

  Future<void> _onSubscribed(SitesSubscribed e, Emitter<SiteState> emit) async {
    if (state.status == SiteStatus.initial) {
      emit(state.copyWith(status: SiteStatus.loading));
    }
    await emit.forEach<Result<List<Site>>>(
      _repo.watchSites(),
      onData: (r) => r.when(
        ok: (sites) => state.copyWith(
          status: SiteStatus.loaded,
          sites: sites,
          selectedSiteId: _resolveSelected(sites),
          error: null,
        ),
        err: (f) => state.copyWith(
          status: state.sites.isEmpty ? SiteStatus.error : SiteStatus.loaded,
          error: ErrorMessages.forFailure(f),
        ),
      ),
    );
  }

  Future<void> _onSelected(SiteSelected e, Emitter<SiteState> emit) async {
    await _prefs.setLastSiteId(e.siteId);
    emit(state.copyWith(selectedSiteId: e.siteId, siteRole: null));
  }

  Future<void> _onCreated(SiteCreated e, Emitter<SiteState> emit) async {
    emit(state.copyWith(status: SiteStatus.saving));
    final r = await _repo.createSite(e.body);
    r.when(
      ok: (site) async {
        await _prefs.setLastSiteId(site.id);
        emit(
          state.copyWith(status: SiteStatus.loaded, selectedSiteId: site.id),
        );
      },
      err: (f) => emit(
        state.copyWith(
          status: SiteStatus.loaded,
          error: ErrorMessages.forFailure(f),
        ),
      ),
    );
  }

  Future<void> _onUpdatedRequested(
    SiteUpdated e,
    Emitter<SiteState> emit,
  ) async {
    emit(state.copyWith(status: SiteStatus.saving));
    final r = await _repo.updateSite(e.siteId, e.body);
    emit(
      state.copyWith(
        status: SiteStatus.loaded,
        error: r.isErr ? ErrorMessages.forFailure(r.failureOrNull!) : null,
      ),
    );
  }

  String? _resolveSelected(List<Site> sites) {
    if (sites.isEmpty) return null;
    final current = state.selectedSiteId;
    if (current != null && sites.any((s) => s.id == current)) return current;
    final stored = _prefs.lastSiteId;
    if (stored != null && sites.any((s) => s.id == stored)) return stored;
    return sites.first.id;
  }
}
