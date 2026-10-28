import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'data.dart';
import 'ui.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Where can I use this?',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        builder: (c, child) => Container(
          color: g100,
          child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480), child: ClipRect(child: child))),
        ),
        home: const Shell(),
      );
}

// ---------- status helpers ----------
Color fgOf(Status s) => switch (s) { Status.works => green, Status.steps => amber, Status.notSure => g600, Status.no => red };
Color bgOf(Status s) => switch (s) { Status.works => greenBg, Status.steps => amberBg, Status.notSure => g100, Status.no => redBg };
IconData iconOf(Status s) => switch (s) { Status.works => Icons.check_circle, Status.steps => Icons.alt_route, Status.notSure => Icons.help, Status.no => Icons.block };
String labelOf(Status s) => switch (s) { Status.works => 'Valid proof', Status.steps => 'Extra steps', Status.notSure => 'Not confirmed', Status.no => 'Won\'t carry over' };
Widget statusTag(Status s) => Tag(labelOf(s), fgOf(s), bgOf(s), icon: iconOf(s));

Verdict verdictFor(String credId, String placeId) => matrix[credId]![placeId]!;

Future<void> openUrl(String u) async => launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication);

// ---------- shell ----------
class Shell extends StatelessWidget {
  const Shell({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          demoBanner(),
          const Expanded(child: WalletTab()),
        ]),
      ),
    );
  }
}

// ---------- wallet ----------
class WalletTab extends StatelessWidget {
  const WalletTab({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      sectionTitle('Marcus\'s credentials', sub: 'Tap one to see where it works. Sample worker, Tulsa OK.'),
      for (final c in creds)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CredDetail(cred: c))),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border.all(color: g200), borderRadius: BorderRadius.circular(16)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(c.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
                  const Icon(Icons.chevron_right, color: g500),
                ]),
                const SizedBox(height: 2),
                Text('${c.issuer} · ${c.held}', style: const TextStyle(color: g500, fontSize: 13)),
                const SizedBox(height: 12),
                const Text('Where can I use this?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: g600)),
                const SizedBox(height: 6),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  for (final p in places) _placeChip(p, verdictFor(c.id, p.id).status),
                ]),
              ]),
            ),
          ),
        ),
    ]);
  }
}

Widget _placeChip(Place p, Status s) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: bgOf(s), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(iconOf(s), size: 13, color: fgOf(s)),
        const SizedBox(width: 4),
        Text(p.short, style: TextStyle(color: fgOf(s), fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
    );

// ---------- credential detail ----------
class CredDetail extends StatefulWidget {
  final Cred cred;
  const CredDetail({super.key, required this.cred});
  @override
  State<CredDetail> createState() => _CredDetailState();
}

class _CredDetailState extends State<CredDetail> {
  String? open;

  @override
  Widget build(BuildContext context) {
    final c = widget.cred;
    return Scaffold(
      appBar: AppBar(title: const Text('Credential', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.only(bottom: 32), children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Tag(c.kind, g600, g100),
              const SizedBox(height: 8),
              Text(c.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text('${c.issuer} · ${c.held}', style: const TextStyle(color: g500, fontSize: 13)),
              const SizedBox(height: 10),
              Text(c.summary, style: const TextStyle(color: g600, height: 1.4)),
            ]),
          ),
          const Divider(height: 24),
          sectionTitle('Where can I use this?', sub: 'Tap a place. "Valid proof" means the credential proves the training or exam it claims. It does not mean a state or employer accepts it. "Not confirmed" means we do not know.'),
          for (final p in places) _placeRow(c, p),
          _elsewhereRow(),
          if (c.id == 'okjm')
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: OutlinedButton(onPressed: () => openUrl('https://www.nccer.org/programs-crafts/reciprocity-map'), child: const Text('NCCER map of state licensing bodies')),
            ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text('Rules change and employers can ask for more. This is guidance from the sources shown, read on 28 Oct 2026. Confirm with the licensing office or employer before you rely on it.',
                style: TextStyle(color: g500, fontSize: 12, height: 1.4)),
          ),
        ]),
      ),
    );
  }

  Widget _placeRow(Cred c, Place p) {
    final v = verdictFor(c.id, p.id);
    final isOpen = open == p.id;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: isOpen ? fgOf(v.status) : g200, width: isOpen ? 1.5 : 1), borderRadius: BorderRadius.circular(14)),
        child: Column(children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => open = isOpen ? null : p.id),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Expanded(child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
                statusTag(v.status),
                Icon(isOpen ? Icons.expand_less : Icons.expand_more, color: g500),
              ]),
            ),
          ),
          if (isOpen) _verdictBody(v),
        ]),
      ),
    );
  }

  Widget _verdictBody(Verdict v) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(v.headline, style: TextStyle(fontWeight: FontWeight.w700, color: fgOf(v.status))),
          const SizedBox(height: 6),
          Text(v.why, style: const TextStyle(height: 1.45, color: g600)),
          const SizedBox(height: 12),
          const Text('What to do next', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 6),
          for (var i = 0; i < v.next.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${i + 1}.  ', style: const TextStyle(color: g500, fontWeight: FontWeight.w600)),
                Expanded(child: Text(v.next[i], style: const TextStyle(height: 1.35))),
              ]),
            ),
          if (v.sources.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('Source', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            for (final s in v.sources)
              InkWell(
                onTap: () => openUrl(s.url),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    const Icon(Icons.open_in_new, size: 14, color: slate),
                    const SizedBox(width: 6),
                    Expanded(child: Text(s.label, style: const TextStyle(color: slate, fontSize: 13, decoration: TextDecoration.underline))),
                  ]),
                ),
              ),
          ] else
            const Padding(padding: EdgeInsets.only(top: 8), child: Text('No official source checked for this place yet.', style: TextStyle(color: g500, fontSize: 12))),
        ]),
      );

  Widget _elsewhereRow() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(border: Border.all(color: g200), borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            const Expanded(child: Text('Somewhere else', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
            Tag('Not checked yet', g600, g100, icon: Icons.help),
          ]),
        ),
      );
}
