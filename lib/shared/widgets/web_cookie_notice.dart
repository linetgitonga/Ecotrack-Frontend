import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/extensions/context_extensions.dart';

/// One-time "essential cookies only" strip, shown on web at the bottom of the
/// screen until dismissed. The app sets no non-essential cookies; this is a
/// courtesy notice. No-op on mobile.
class WebCookieNotice extends StatefulWidget {
  const WebCookieNotice({super.key, required this.child});
  final Widget child;

  @override
  State<WebCookieNotice> createState() => _WebCookieNoticeState();
}

class _WebCookieNoticeState extends State<WebCookieNotice> {
  static const _key = 'web.cookie_notice_seen';
  bool _show = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) _check();
  }

  Future<void> _check() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!(prefs.getBool(_key) ?? false) && mounted) {
        setState(() => _show = true);
      }
    } catch (_) {}
  }

  Future<void> _dismiss() async {
    setState(() => _show = false);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, true);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_show)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Material(
              color: context.colors.inverseSurface,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'EcoTrack uses only the storage needed to keep you '
                          'signed in and remember your preferences. No tracking '
                          'or advertising cookies.',
                          style: TextStyle(
                            color: context.colors.onInverseSurface,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: _dismiss,
                        child: const Text('Got it'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
