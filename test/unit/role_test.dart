import 'package:ecotrack/domain/value_objects/role.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromApi is case-insensitive and fails safe to viewer', () {
    expect(Role.fromApi('OWNER'), Role.owner);
    expect(Role.fromApi('installer'), Role.installer);
    expect(Role.fromApi('nonsense'), Role.viewer);
  });

  group('effective role = narrower of tenant and site', () {
    test('no site row → tenant role applies', () {
      expect(Role.effective(Role.owner), Role.owner);
    });
    test('site role narrows an owner to viewer', () {
      expect(Role.effective(Role.owner, siteRole: Role.viewer), Role.viewer);
    });
    test('site role cannot widen a member to owner', () {
      expect(Role.effective(Role.member, siteRole: Role.owner), Role.member);
    });
    test('installer ranks equal to member', () {
      expect(
        Role.effective(Role.installer, siteRole: Role.member),
        Role.installer,
      );
    });
  });

  group('capabilities', () {
    test('owner can do everything', () {
      for (final p in Permission.values) {
        expect(Role.owner.can(p), isTrue, reason: '$p');
      }
    });
    test('viewer is read-only', () {
      expect(Role.viewer.can(Permission.viewDashboards), isTrue);
      expect(Role.viewer.can(Permission.controlDevices), isFalse);
      expect(Role.viewer.can(Permission.manageMembers), isFalse);
    });
    test('member controls devices but not members/subscription', () {
      expect(Role.member.can(Permission.controlDevices), isTrue);
      expect(Role.member.can(Permission.manageAutomation), isTrue);
      expect(Role.member.can(Permission.manageMembers), isFalse);
      expect(Role.member.can(Permission.manageSubscription), isFalse);
      expect(Role.member.can(Permission.deleteSite), isFalse);
    });
    test('installer commissions but does not manage automation', () {
      expect(Role.installer.can(Permission.commissionDevices), isTrue);
      expect(Role.installer.can(Permission.calibrateDevices), isTrue);
      expect(Role.installer.can(Permission.manageAutomation), isFalse);
    });
  });
}
