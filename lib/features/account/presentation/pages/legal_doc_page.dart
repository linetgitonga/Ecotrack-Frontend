import 'package:flutter/material.dart';

import '../../../../app/themes/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Renders one of the in-app legal documents. Content is a template, not legal
/// advice — have it reviewed before launch and keep `version` in step with the
/// `policy_version` recorded against each consent.
class LegalDocPage extends StatelessWidget {
  const LegalDocPage({super.key, required this.doc});
  final LegalDoc doc;

  @override
  Widget build(BuildContext context) {
    final d = _docs[doc]!;
    return Scaffold(
      appBar: AppBar(title: Text(d.title)),
      body: ListView(
        padding: const EdgeInsets.all(EcoSpacing.lg),
        children: [
          Text(
            'Version ${d.version} · Last updated ${d.updated}',
            style: context.textTheme.labelMedium,
          ),
          const SizedBox(height: EcoSpacing.lg),
          for (final s in d.sections) ...[
            Text(s.$1, style: context.textTheme.titleMedium),
            const SizedBox(height: EcoSpacing.xs),
            Text(s.$2, style: context.textTheme.bodyMedium),
            const SizedBox(height: EcoSpacing.lg),
          ],
        ],
      ),
    );
  }
}

enum LegalDoc { privacy, terms }

class _Doc {
  const _Doc({
    required this.title,
    required this.version,
    required this.updated,
    required this.sections,
  });
  final String title;
  final String version;
  final String updated;
  final List<(String, String)> sections;
}

const _docs = <LegalDoc, _Doc>{
  LegalDoc.privacy: _Doc(
    title: 'Privacy Policy',
    version: '1.0',
    updated: '2026-09-08',
    sections: [
      (
        'Who we are',
        'EcoTrack is an energy management service for households and premises in '
            'Kenya. We act as the data controller for the personal data described '
            'below and process it under the Data Protection Act, 2019.',
      ),
      (
        'What we collect',
        'Account data: your phone number, name, email (optional), and the sites '
            'you manage. Energy data: readings from your smart plugs, meters and '
            'hub, including power, energy, device state and estimated cost. '
            'Technical data: app version, device model, IP address and session '
            'information used for security. We do not collect location data.',
      ),
      (
        'Why we use it',
        'To provide the service (show your usage, control your devices, run '
            'schedules and alerts), to bill and support you, and to keep your '
            'account secure. Optional uses — occupancy analytics, appliance-level '
            'breakdown, anonymous research, marketing and partner sharing — only '
            'happen if you switch them on in Privacy & data.',
      ),
      (
        'Occupancy',
        'Household energy patterns can reveal when your home is empty. We treat '
            'this as sensitive. Occupancy-based features are off until you enable '
            'them, and we never sell this data.',
      ),
      (
        'Who we share with',
        'Our SMS provider (to send one-time codes), our cloud hosting provider, '
            'and payment processors for M-Pesa. Each is bound by a data-processing '
            'agreement. We share with partners only with your explicit consent, '
            'and with authorities where the law requires it.',
      ),
      (
        'How long we keep it',
        'Raw device readings: 30 days. Hourly summaries: about 2 years. Daily '
            'summaries and billing records: as required by law. Account data: '
            'until you delete your account, then a short grace period before a '
            'hard purge.',
      ),
      (
        'Your rights',
        'You can access, correct, download or delete your data, object to or '
            'restrict processing, and withdraw consent at any time from '
            'Privacy & data in the app. You can also complain to the Office of '
            'the Data Protection Commissioner.',
      ),
      (
        'Security',
        'Data is encrypted in transit and at rest. Your login uses one-time '
            'codes, and high-risk actions require a second verification. Your hub '
            'talks to us over mutually authenticated TLS and never accepts '
            'inbound connections.',
      ),
      ('Contact', 'Data protection queries: privacy@ecotrack.co.ke.'),
    ],
  ),
  LegalDoc.terms: _Doc(
    title: 'Terms of Service',
    version: '1.0',
    updated: '2026-09-08',
    sections: [
      (
        'Using EcoTrack',
        'By creating an account you agree to these terms. You must be able to '
            'enter into a contract and be authorised to manage the sites and '
            'devices you add.',
      ),
      (
        'Your account',
        'Keep your phone and account secure. You are responsible for actions '
            'taken through your account. Tell us promptly if you think it has '
            'been compromised — you can end all sessions from the app.',
      ),
      (
        'The service',
        'EcoTrack monitors and controls connected devices and estimates energy '
            'cost. Cost figures are estimates, especially on prepaid meters, and '
            'are clearly labelled as such. They are not a bill from your utility.',
      ),
      (
        'Automation and safety',
        'Rules, schedules and modes act on your devices automatically. Appliances '
            'you mark as critical are never switched off by automation. You are '
            'responsible for how you configure automation.',
      ),
      (
        'Availability',
        'Local control works without internet through your hub. Remote features '
            'depend on connectivity and may be unavailable during maintenance or '
            'outages. We aim for high availability but do not guarantee it.',
      ),
      (
        'Payments',
        'Paid plans are billed via M-Pesa as shown at checkout. See the Refund '
            'Policy below for cancellations.',
      ),
      (
        'Refunds',
        'Subscriptions can be cancelled at any time and remain active until the '
            'end of the paid period; we do not refund partial periods. If a paid '
            'feature is unavailable for an extended time due to our fault, contact '
            'support@ecotrack.co.ke for a pro-rata credit.',
      ),
      (
        'Liability',
        'We provide the service with reasonable care but are not liable for '
            'indirect losses, or for losses arising from your device '
            'configuration, third-party hardware, or utility supply. Nothing here '
            'limits liability that cannot be limited by law.',
      ),
      (
        'Changes and termination',
        'We may update these terms and will notify you of material changes. You '
            'can stop using the service and delete your account at any time.',
      ),
      ('Governing law', 'These terms are governed by the laws of Kenya.'),
    ],
  ),
};
