// Demo "today" is fixed so everything reads the same on every visit.
final today = DateTime(2026, 10, 28);

enum Status { works, steps, notSure, no }

class Place {
  final String id, name, short;
  const Place(this.id, this.name, this.short);
}

const places = <Place>[
  Place('tx', 'Texas', 'TX'),
  Place('fl', 'Florida', 'FL'),
  Place('nyc', 'New York City', 'NYC'),
  Place('ca', 'California', 'CA'),
];

class Source {
  final String label, url;
  const Source(this.label, this.url);
}

class Verdict {
  final Status status;
  final String headline, why;
  final List<String> next;
  final List<Source> sources;
  const Verdict(this.status, this.headline, this.why, this.next, this.sources);
}

class Cred {
  final String id, name, issuer, kind, held, summary;
  const Cred(this.id, this.name, this.issuer, this.kind, this.held, this.summary);
}

const creds = <Cred>[
  Cred('okjm', 'Journeyman Electrician license', 'Oklahoma (state license)', 'State license', 'Held since 2024',
      'A state license. Each state decides if it accepts another state\'s license.'),
  Cred('osha30', 'OSHA 30-Hour Construction', 'OSHA Outreach card', 'Safety card', 'Completed 2023',
      'A federal course card. It does not expire. Some cities, states and employers add their own rules.'),
  Cred('nccer', 'NCCER Core', 'NCCER (training credential)', 'Training credential', 'Completed 2022',
      'Proof of training you can share from your NCCER record. It is not a license.'),
  Cred('forklift', 'Forklift operator', 'Example Employer (fictional)', 'Employer-issued', 'Evaluated Mar 2025',
      'Issued by your employer after training and an evaluation on their trucks.'),
  Cred('cpr', 'First Aid / CPR', 'Example Red Cross-style class (fictional)', 'Course card', 'Expires Nov 2026',
      'A short course card. Providers and renewal rules vary by employer.'),
];

Cred credById(String id) => creds.firstWhere((c) => c.id == id);
Place placeById(String id) => places.firstWhere((p) => p.id == id);

const _tdlr = Source('Texas TDLR: transfer an out-of-state electrician license', 'https://www.tdlr.texas.gov/electricians/out-of-state.htm');
const _flBoard = Source('Florida Electrical Contractors Board: reciprocity and endorsement list', 'https://www2.myfloridalicense.com/pro/elboard/documents/10-year%5Fendorsement.pdf');
const _oshaFaq = Source('OSHA Outreach Training Program FAQ', 'http://www.osha.gov/training/outreach/faq');
const _nycSst = Source('NYC Buildings: Site Safety Training (SST)', 'https://www.nyc.gov/site/buildings/safety/training.page');
const _nccerCreds = Source('NCCER: industry-recognized credentials', 'https://www.nccer.org/credentials-certifications/industry-recognized-credentials/');
const _forkReg = Source('OSHA 29 CFR 1910.178(l): powered industrial truck operator training', 'http://www.osha.gov/laws-regs/regulations/standardnumber/1910/1910.178');


// Verdicts for each credential in each place. Source-backed where a source is listed.
final Map<String, Map<String, Verdict>> matrix = {
  'okjm': {
    'tx': const Verdict(
      Status.steps,
      'Possible, with extra steps',
      'Texas lists Oklahoma as a reciprocal state for journeyman electricians. You do not get a Texas license automatically. You apply, and Texas checks your exam, how long you held the license and your supervised hours.',
      [
        'Check you have held your Oklahoma license for at least 1 year',
        'Check you have at least 8,000 hours under a master electrician',
        'Ask Oklahoma for a letter of good standing',
        'Apply to Texas TDLR with your license copy and the fee',
      ],
      [_tdlr],
    ),
    'fl': const Verdict(
      Status.notSure,
      'Not confirmed',
      'Florida\'s state electrical board says it has no reciprocal agreements with any state. Its endorsement list is for contractor licenses, not journeyman licenses, and journeyman rules can be set by the county or city. We could not confirm a route for your license.',
      [
        'Ask the county or city building department where you will work',
        'Ask the employer which license they need you to hold',
      ],
      [_flBoard],
    ),
    'nyc': const Verdict(
      Status.notSure,
      'Not confirmed',
      'We have not checked how New York City treats an Oklahoma journeyman license. Do not assume it carries over.',
      [
        'Ask the employer which license the job needs',
        'Ask NYC Department of Buildings about electrician licensing',
      ],
      [],
    ),
    'ca': const Verdict(
      Status.notSure,
      'Not confirmed',
      'We have not checked California\'s rules for an out-of-state journeyman license. Do not assume it carries over.',
      [
        'Ask the employer which license the job needs',
        'Ask the California licensing office for electrician certification rules',
      ],
      [],
    ),
  },
  'osha30': {
    'tx': const Verdict(
      Status.notSure,
      'Acceptance not confirmed',
      'Your card is valid proof of 30 hours of OSHA training and does not expire. OSHA does not require this training; some states, cities and employers do, and they decide what they accept. We have not checked Texas rules or a specific employer.',

      ['Keep your card or training certificate handy', 'Check what the employer lists as accepted'],
      [_oshaFaq],
    ),
    'fl': const Verdict(
      Status.notSure,
      'Acceptance not confirmed',
      'Your card is valid proof of 30 hours of OSHA training and does not expire. OSHA does not require this training; some states, cities and employers do, and they decide what they accept. We have not checked Florida rules or a specific employer.',

      ['Keep your card or training certificate handy', 'Check what the employer lists as accepted'],
      [_oshaFaq],
    ),
    'nyc': const Verdict(
      Status.steps,
      'Valid, but not enough on its own',
      'Many NYC construction sites need a Site Safety Training (SST) card. NYC says workers need 40 hours of safety training, and the card must come from a course provider registered with the Department of Buildings. Your OSHA card is not an SST card.',
      [
        'Check if your site needs a Site Safety Plan (the employer knows)',
        'Find a Department of Buildings registered SST course provider',
        'Complete the SST training and carry the SST card',
      ],
      [_nycSst, _oshaFaq],
    ),
    'ca': const Verdict(
      Status.notSure,
      'Acceptance not confirmed',
      'Your card is valid proof of 30 hours of OSHA training and does not expire. OSHA does not require this training; some states, cities and employers do, and they decide what they accept. We have not checked California rules or a specific employer.',

      ['Keep your card or training certificate handy', 'Check what the employer lists as accepted'],
      [_oshaFaq],
    ),
  },
  'nccer': {
    for (final p in places)
      p.id: Verdict(
        Status.notSure,
        'Acceptance not confirmed',
        'Your NCCER record is valid proof of the training you finished and can be checked online. It is not a state license. We have not checked any state rule or employer for this place, and each employer decides how much weight to give it.',

        [
          'Share your NCCER record with the employer',
          if (p.id == 'nyc') 'NYC sites may also need an SST card' else 'If the job needs a license, that is a separate check',
        ],
        [_nccerCreds],
      ),
  },
  'forklift': {
    for (final p in places)
      p.id: Verdict(
        Status.no,
        'Does not carry over automatically',
        'Your employer certified you on their trucks and site. OSHA says each employer must make sure operators are trained and evaluated. Earlier training can count if it fits the truck and the workplace, but the new employer still has to evaluate you.',
        [
          'Bring your training record to the new employer',
          'Expect a short evaluation on their trucks before you drive',
        ],
        [_forkReg],
      ),
  },
  'cpr': {
    for (final p in places)
      p.id: const Verdict(
        Status.notSure,
        'Not confirmed',
        'Employers and job sites choose which First Aid / CPR providers they accept, and cards expire. We have not confirmed a rule for this place.',
        ['Check your card\'s expiry date', 'Ask the employer which providers they accept'],
        [],
      ),
  },
};
