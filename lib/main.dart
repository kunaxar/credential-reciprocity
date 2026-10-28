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
class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int tab = 0;
  String? filterCred;
  final search = TextEditingController();

  void showJobsFor(String credId) {
    setState(() {
      tab = 1;
      filterCred = credId;
      search.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          demoBanner(),
          Expanded(
            child: tab == 0
                ? WalletTab(onShowJobs: showJobsFor)
                : JobsTab(search: search, filterCred: filterCred, onFilter: (v) => setState(() => filterCred = v), onShowJobs: showJobsFor),
          ),
        ]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        backgroundColor: Colors.white,
        indicatorColor: g100,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.badge_outlined), selectedIcon: Icon(Icons.badge), label: 'My credentials'),
          NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: 'Jobs'),
        ],
      ),
    );
  }
}

// ---------- wallet ----------
class WalletTab extends StatelessWidget {
  final void Function(String) onShowJobs;
  const WalletTab({super.key, required this.onShowJobs});
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      sectionTitle('Marcus\'s credentials', sub: 'Tap one to see where it works. Sample worker, Tulsa OK.'),
      for (final c in creds)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CredDetail(cred: c, onShowJobs: onShowJobs))),
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

// ---------- credential detail (entry 1) ----------
class CredDetail extends StatefulWidget {
  final Cred cred;
  final String? initialPlace;
  final void Function(String) onShowJobs;
  const CredDetail({super.key, required this.cred, required this.onShowJobs, this.initialPlace});
  @override
  State<CredDetail> createState() => _CredDetailState();
}

class _CredDetailState extends State<CredDetail> {
  String? open;
  @override
  void initState() {
    super.initState();
    open = widget.initialPlace;
  }

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
          sectionTitle('Where can I use this?', sub: 'Tap a place. "Valid proof" means the credential is real, not that every employer accepts it. "Not confirmed" means we do not know.'),
          for (final p in places) _placeRow(c, p),
          _elsewhereRow(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: FilledButton.icon(
              onPressed: () {
                widget.onShowJobs(c.id);
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
              icon: const Icon(Icons.work_outline),
              label: Text('Jobs where this counts'),
            ),
          ),
          if (c.id == 'okjm')
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
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

// ---------- jobs (entry 2) ----------
Status? worst(Iterable<Status> ss) {
  Status? w;
  for (final s in ss) {
    if (w == null || s.index > w.index) w = s;
  }
  return w;
}

// Best verdict among your credentials that could meet a requirement.
({Cred cred, Verdict v})? bestFor(Req r, String placeId) {
  ({Cred cred, Verdict v})? best;
  for (final id in r.okIds) {
    final v = verdictFor(id, placeId);
    if (best == null || v.status.index < best.v.status.index) best = (cred: credById(id), v: v);
  }
  return best;
}

bool jobMatches(Job j, String q) {
  if (q.isEmpty) return true;
  final t = q.toLowerCase();
  final hay = [j.title, j.company, j.city, ...j.reqs.map((r) => r.label), ...j.reqs.expand((r) => r.okIds.map((i) => credById(i).name))].join(' ').toLowerCase();
  return t.split(RegExp(r'\s+')).every(hay.contains);
}

class JobsTab extends StatefulWidget {
  final TextEditingController search;
  final String? filterCred;
  final void Function(String?) onFilter;
  final void Function(String) onShowJobs;
  const JobsTab({super.key, required this.search, required this.filterCred, required this.onFilter, required this.onShowJobs});
  @override
  State<JobsTab> createState() => _JobsTabState();
}

class _JobsTabState extends State<JobsTab> {
  @override
  Widget build(BuildContext context) {
    final q = widget.search.text.trim();
    final fc = widget.filterCred;
    final list = jobs.where((j) {
      if (!jobMatches(j, q)) return false;
      if (fc != null) {
        final counts = j.reqs.any((r) => r.okIds.contains(fc) && verdictFor(fc, j.placeId).status.index <= Status.steps.index);
        if (!counts) return false;
      }
      return true;
    }).toList();
    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: TextField(
          controller: widget.search,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search a job or a credential, e.g. OSHA 10',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: q.isEmpty ? null : IconButton(icon: const Icon(Icons.close), onPressed: () => setState(widget.search.clear)),
          ),
        ),
      ),
      SizedBox(
        height: 46,
        child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: [
          Padding(padding: const EdgeInsets.only(right: 8), child: Pill('All jobs', on: fc == null, onTap: () => widget.onFilter(null))),
          for (final c in creds)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Pill('My ${c.name.split(' ').take(2).join(' ')}', on: fc == c.id, icon: Icons.badge_outlined, onTap: () => widget.onFilter(fc == c.id ? null : c.id)),
            ),
        ]),
      ),
      if (fc != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Text('Showing jobs where your ${credById(fc).name} is valid proof or needs extra steps. Matches are demo matches, not verified acceptance.', style: const TextStyle(color: g600, fontSize: 13)),
        ),
      if (list.isEmpty)
        const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No jobs match. Try a different word.', style: TextStyle(color: g500)))),
      for (final j in list) _jobCard(context, j, q),
    ]);
  }

  Widget _jobCard(BuildContext context, Job j, String q) {
    final statuses = [for (final r in j.reqs) bestFor(r, j.placeId)?.v.status ?? Status.notSure];
    final works = statuses.where((s) => s == Status.works).length;
    final steps = statuses.where((s) => s == Status.steps).length;
    final other = statuses.length - works - steps;
    // If the search matches a requirement, show how your credential counts for that requirement.
    Req? hit;
    if (q.isNotEmpty) {
      final t = q.toLowerCase();
      for (final r in j.reqs) {
        final h = ('${r.label} ${r.okIds.map((i) => credById(i).name).join(' ')}').toLowerCase();
        if (t.split(RegExp(r'\s+')).every(h.contains)) {
          hit = r;
          break;
        }
      }
    }
    final b = hit == null ? null : bestFor(hit, j.placeId);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => JobDetail(job: j))),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border.all(color: g200), borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(j.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text('${j.company} · ${j.city}', style: const TextStyle(color: g500, fontSize: 13)),
            const SizedBox(height: 2),
            Text(j.pay, style: const TextStyle(fontSize: 13, color: g600)),
            if (b != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: bgOf(b.v.status), borderRadius: BorderRadius.circular(10)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(iconOf(b.v.status), size: 16, color: fgOf(b.v.status)),
                  const SizedBox(width: 8),
                  Expanded(child: Text('${hit!.employerNote != null ? 'Demo match' : 'Needs'}: ${hit.label}. You hold ${b.cred.name}: ${b.v.headline.toLowerCase()}.', style: TextStyle(color: fgOf(b.v.status), fontSize: 13, height: 1.35, fontWeight: FontWeight.w600))),
                ]),
              ),
            ] else ...[
              const SizedBox(height: 10),
              Wrap(spacing: 6, runSpacing: 6, children: [
                if (works > 0) Tag('$works valid proof', green, greenBg, icon: Icons.check_circle),
                if (steps > 0) Tag('$steps need extra steps', amber, amberBg, icon: Icons.alt_route),
                if (other > 0) Tag('$other not confirmed or no', g600, g100, icon: Icons.help),
              ]),
            ],
          ]),
        ),
      ),
    );
  }
}

class JobDetail extends StatelessWidget {
  final Job job;
  const JobDetail({super.key, required this.job});
  @override
  Widget build(BuildContext context) {
    final todo = <(String, String)>[];
    for (final r in job.reqs) {
      final b = bestFor(r, job.placeId);
      if (b != null && b.v.status != Status.works) {
        for (final n in b.v.next) {
          todo.add((r.label, n));
        }
      }
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Job', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.only(bottom: 32), children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(job.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text('${job.company} · ${job.city}', style: const TextStyle(color: g500, fontSize: 13)),
              const SizedBox(height: 2),
              Text('${job.pay} · ${job.blurb}', style: const TextStyle(color: g600, fontSize: 13)),
            ]),
          ),
          sectionTitle('Do your credentials count here?', sub: 'In ${placeById(job.placeId).name}. Tap a credential for the full answer.'),
          for (final r in job.reqs) _reqCard(context, r),
          if (todo.isNotEmpty) ...[
            sectionTitle('Before you apply'),
            for (final t in todo)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.check_box_outline_blank, size: 18, color: g500),
                  const SizedBox(width: 8),
                  Expanded(child: Text.rich(TextSpan(children: [TextSpan(text: t.$2), TextSpan(text: '  (${t.$1})', style: const TextStyle(color: g500, fontSize: 12))]), style: const TextStyle(height: 1.35))),
                ]),
              ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: FilledButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demo only. Nothing was sent.'))),
              child: const Text('Apply (demo)'),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _reqCard(BuildContext context, Req r) {
    final b = bestFor(r, job.placeId);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: b == null
            ? null
            : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CredDetail(cred: b.cred, initialPlace: job.placeId, onShowJobs: (_) {}))),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(border: Border.all(color: g200), borderRadius: BorderRadius.circular(14)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Needs: ${r.label}', style: const TextStyle(fontWeight: FontWeight.w700)),
            if (r.employerNote != null) Text(r.employerNote!, style: const TextStyle(color: g500, fontSize: 12)),
            const SizedBox(height: 8),
            if (b == null)
              const Text('You do not hold this yet.', style: TextStyle(color: g600))
            else ...[
              Row(children: [
                Expanded(child: Text('Your ${b.cred.name}', style: const TextStyle(color: g600, fontSize: 13))),
                statusTag(b.v.status),
              ]),
              const SizedBox(height: 6),
              if (r.employerNote != null && b.v.status != Status.no && b.v.status != Status.notSure)
                const Padding(padding: EdgeInsets.only(bottom: 4), child: Text('Demo match: this fictional job lists it as accepted', style: TextStyle(color: slate, fontSize: 12, fontWeight: FontWeight.w600))),
              Text(b.v.headline, style: TextStyle(color: fgOf(b.v.status), fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(b.v.why, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: g600, fontSize: 13, height: 1.35)),
            ],
          ]),
        ),
      ),
    );
  }
}
