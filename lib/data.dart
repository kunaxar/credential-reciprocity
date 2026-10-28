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
      Status.works,
      'Valid proof. Acceptance is up to the employer or site',
      'OSHA 10/30 cards are federal and do not expire. OSHA does not require this training. Some states, cities and employers do, and they decide what they accept. We have not checked Texas rules or a specific employer, so a job\'s own listed requirement is what to match.',
      ['Keep your card or training certificate handy', 'Check what the employer lists as accepted'],
      [_oshaFaq],
    ),
    'fl': const Verdict(
      Status.works,
      'Valid proof. Acceptance is up to the employer or site',
      'OSHA 10/30 cards are federal and do not expire. OSHA does not require this training. Some states, cities and employers do, and they decide what they accept. We have not checked Florida rules or a specific employer, so a job\'s own listed requirement is what to match.',
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
      Status.works,
      'Valid proof. Acceptance is up to the employer or site',
      'OSHA 10/30 cards are federal and do not expire. OSHA does not require this training. Some states, cities and employers do, and they decide what they accept. We have not checked California rules or a specific employer, so a job\'s own listed requirement is what to match.',
      ['Keep your card or training certificate handy', 'Check what the employer lists as accepted'],
      [_oshaFaq],
    ),
  },
  'nccer': {
    for (final p in places)
      p.id: Verdict(
        Status.works,
        'Valid proof of training. Employer decides',
        'NCCER credentials are portable and can be checked online. They show what training you finished. They are not a state license. We have not checked any state rule or employer, and each employer decides how much weight to give them.',
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

class Req {
  final String label;
  final List<String> okIds; // your credential ids that could meet it
  final String? employerNote;
  const Req(this.label, this.okIds, {this.employerNote});
}

class Job {
  final String id, title, company, city, placeId, pay, blurb;
  final List<Req> reqs;
  const Job(this.id, this.title, this.company, this.city, this.placeId, this.pay, this.blurb, this.reqs);
}

const jobs = <Job>[
  Job('j1', 'Journeyman Electrician', 'Lone Star Electric (fictional)', 'Dallas, TX', 'tx', '\$34 - \$42 / hr',
      'Commercial tenant fit-outs. Day shift.', [
    Req('Journeyman electrician license (Texas or a reciprocal state)', ['okjm'], employerNote: 'Employer accepts reciprocal-state licenses'),
    Req('OSHA 10 or OSHA 30', ['osha30'], employerNote: 'Employer lists OSHA 10 or 30'),
  ]),
  Job('j2', 'Industrial Electrician', 'Gulf Plant Services (fictional)', 'Houston, TX', 'tx', '\$36 - \$44 / hr',
      'Plant maintenance and controls work.', [
    Req('NCCER Core', ['nccer']),
    Req('Forklift operator evaluation', ['forklift']),
    Req('OSHA 10 or OSHA 30', ['osha30'], employerNote: 'Employer lists OSHA 10 or 30'),
  ]),
  Job('j3', 'Residential Electrician', 'Sunrise Homes Electric (fictional)', 'Tampa, FL', 'fl', '\$28 - \$36 / hr',
      'New builds. Crew of 4.', [
    Req('Electrician license for the county', ['okjm']),
    Req('OSHA 10 or OSHA 30', ['osha30'], employerNote: 'Employer lists OSHA 10 or 30'),
    Req('First Aid / CPR', ['cpr']),
  ]),
  Job('j4', 'Commercial Electrician', 'Five Boroughs Build (fictional)', 'Brooklyn, NY', 'nyc', '\$45 - \$58 / hr',
      'Mid-rise residential. Site safety plan on every job.', [
    Req('Site Safety Training (SST) card', ['osha30']),
    Req('Electrician license', ['okjm']),
  ]),
  Job('j5', 'Electrician', 'Golden Valley Power (fictional)', 'Sacramento, CA', 'ca', '\$38 - \$46 / hr',
      'Solar and storage installs.', [
    Req('Electrician certification', ['okjm']),
    Req('First Aid / CPR', ['cpr']),
    Req('OSHA 30', ['osha30']),
  ]),
];
