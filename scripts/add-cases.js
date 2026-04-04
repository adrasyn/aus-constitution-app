const fs = require('fs');
const cases = require('../content/cases/cases.json');

const newCases = [
  {
    id: 'demden-v-pedder-1904',
    name: "D'Emden v Pedder",
    shortName: "D'Emden v Pedder",
    year: 1904,
    court: 'High Court of Australia',
    citation: '(1904) 1 CLR 91',
    principle: 'Established the doctrine of intergovernmental immunities, holding that Commonwealth instrumentalities were immune from State laws',
    outcome: 'majority',
    relatedSections: [],
    relatedCases: ['engineers-case-1920'],
    content: "The first landmark constitutional case decided by the High Court. Drawing on the US precedent of McCulloch v Maryland, the Court held that a Tasmanian stamp duty could not apply to the salary of a Commonwealth officer. This established the implied intergovernmental immunities doctrine, which held that neither level of government could interfere with the other's instrumentalities. The doctrine was later rejected by the Engineers' Case in 1920."
  },
  {
    id: 'strickland-v-rocla-1971',
    name: 'Strickland v Rocla Concrete Pipes Ltd',
    shortName: 'Concrete Pipes Case',
    year: 1971,
    court: 'High Court of Australia',
    citation: '(1971) 124 CLR 468',
    principle: 'Broadened the corporations power (s 51(xx)) by overruling Huddart Parker, allowing Commonwealth regulation of the activities of trading corporations',
    outcome: 'majority',
    relatedSections: ['51(xx)'],
    relatedCases: ['huddart-parker-v-moorehead-1909', 'work-choices-case-2006'],
    content: 'This case overruled the narrow reading of the corporations power established in Huddart Parker v Moorehead (1909). The Court held that s 51(xx) empowered the Commonwealth to regulate the trading activities of constitutional corporations, not merely their incorporation. This opened the way for extensive Commonwealth regulation of corporate conduct and was the critical stepping stone to the Work Choices Case (2006).'
  },
  {
    id: 'chu-kheng-lim-1992',
    name: 'Chu Kheng Lim v Minister for Immigration',
    shortName: 'Lim',
    year: 1992,
    court: 'High Court of Australia',
    citation: '(1992) 176 CLR 1',
    principle: 'Executive detention of aliens must be non-punitive; punitive detention is exclusively a judicial function under Chapter III',
    outcome: 'majority',
    relatedSections: ['51(xix)', '71'],
    relatedCases: ['al-kateb-v-godwin-2004', 'nzyq-2023'],
    content: "Established the 'Lim principle' \u2014 that the executive power to detain aliens under the aliens power (s 51(xix)) is limited to detention that is reasonably necessary for purposes such as processing or deportation. Punitive detention can only be imposed by the judiciary under Chapter III. This principle became the foundation for all subsequent constitutional challenges to immigration detention, including Al-Kateb and NZYQ."
  },
  {
    id: 'sykes-v-cleary-1992',
    name: 'Sykes v Cleary',
    shortName: 'Sykes v Cleary',
    year: 1992,
    court: 'High Court of Australia',
    citation: '(1992) 176 CLR 77',
    principle: 'Leading case on s 44 disqualification \u2014 defined requirements for renouncing foreign citizenship and the scope of office of profit under the Crown',
    outcome: 'majority',
    relatedSections: ['44'],
    relatedCases: ['sue-v-hill-1999'],
    content: 'Phil Cleary was elected to the House of Representatives but was found to hold an office of profit under the Crown as a State school teacher on leave without pay. Two other candidates were found disqualified under s 44(i) for holding foreign citizenship without taking reasonable steps to renounce it. This case established the foundational principles for s 44 disqualification and became directly relevant during the 2017 parliamentary eligibility crisis.'
  },
  {
    id: 're-wakim-1999',
    name: 'Re Wakim; Ex parte McNally',
    shortName: 'Re Wakim',
    year: 1999,
    court: 'High Court of Australia',
    citation: '(1999) 198 CLR 511',
    principle: 'State Parliaments cannot confer State jurisdiction on federal courts; the cooperative cross-vesting scheme was partially invalid',
    outcome: 'majority',
    relatedSections: ['71', '75', '76'],
    relatedCases: ['boilermakers-case-1956'],
    content: 'The Court held that Chapter III of the Constitution exhaustively defines the jurisdiction that federal courts may exercise, and that State Parliaments cannot confer State jurisdiction on federal courts. This invalidated key parts of the national cross-vesting scheme that had been operating cooperatively since 1987. The decision demonstrated the rigid limits of Chapter III and that cooperative federalism cannot supply constitutional power that does not exist.'
  },
  {
    id: 'sue-v-hill-1999',
    name: 'Sue v Hill',
    shortName: 'Sue v Hill',
    year: 1999,
    court: 'High Court of Australia',
    citation: '(1999) 199 CLR 462',
    principle: "The United Kingdom is a foreign power for the purposes of s 44(i); dual citizens with the UK are disqualified from sitting in Parliament",
    outcome: 'majority',
    relatedSections: ['44'],
    relatedCases: ['sykes-v-cleary-1992'],
    content: "Senator Heather Hill was found to be a subject of a foreign power (the United Kingdom) under s 44(i) because she held British citizenship. The Court held that following the Australia Acts 1986, the UK is a 'foreign power' within the meaning of the Constitution. This confirmed Australia's full constitutional independence and became hugely practically significant during the 2017 parliamentary eligibility crisis."
  },
  {
    id: 'al-kateb-v-godwin-2004',
    name: 'Al-Kateb v Godwin',
    shortName: 'Al-Kateb',
    year: 2004,
    court: 'High Court of Australia',
    citation: '(2004) 219 CLR 562',
    principle: 'Indefinite detention of a stateless person held constitutionally valid where removal from Australia was not reasonably practicable',
    outcome: 'majority',
    relatedSections: ['51(xix)', '71'],
    relatedCases: ['chu-kheng-lim-1992', 'nzyq-2023'],
    content: 'In a controversial 4-3 decision, the Court held that the mandatory detention of a stateless Palestinian man was constitutionally valid even though there was no real prospect of his removal from Australia. The majority held that detention for the purpose of removal did not become punitive merely because removal was not practicable. This decision was widely criticised and was overturned by NZYQ v Minister for Immigration in 2023.'
  },
  {
    id: 'wurridjal-v-commonwealth-2009',
    name: 'Wurridjal v Commonwealth',
    shortName: 'Wurridjal',
    year: 2009,
    court: 'High Court of Australia',
    citation: '(2009) 237 CLR 309',
    principle: 'The just terms guarantee in s 51(xxxi) applies to acquisitions of property under the territories power (s 122)',
    outcome: 'majority',
    relatedSections: ['51(xxxi)', '122'],
    relatedCases: [],
    content: 'The Court held that the just terms requirement of s 51(xxxi) constrains the exercise of the territories power in s 122, overturning the 1969 decision in Teori Tau. The case arose from the Northern Territory National Emergency Response (the Intervention), which involved five-year leases over Aboriginal land. The decision was significant for the property rights of Territory residents, particularly Aboriginal landholders.'
  },
  {
    id: 'kirk-v-industrial-court-2010',
    name: 'Kirk v Industrial Court of NSW',
    shortName: 'Kirk',
    year: 2010,
    court: 'High Court of Australia',
    citation: '(2010) 239 CLR 531',
    principle: 'State Supreme Courts possess a constitutionally entrenched minimum jurisdiction to review jurisdictional errors of inferior courts and tribunals',
    outcome: 'unanimous',
    relatedSections: ['71', '73'],
    relatedCases: ['kable-v-dpp-1996', 'plaintiff-s157-2003'],
    content: 'The Court unanimously held that just as the Commonwealth Parliament cannot strip the High Court of jurisdiction to review federal jurisdictional errors (per Plaintiff S157), State Parliaments cannot strip their Supreme Courts of supervisory jurisdiction over jurisdictional errors of inferior courts and tribunals. This constitutionalised judicial review at the State level and was described as breathing new life into the Kable principle.'
  },
  {
    id: 'rowe-v-electoral-commissioner-2010',
    name: 'Rowe v Electoral Commissioner',
    shortName: 'Rowe',
    year: 2010,
    court: 'High Court of Australia',
    citation: '(2010) 243 CLR 1',
    principle: 'The Constitution embeds a right to vote; early closure of electoral rolls after writs are issued was invalid',
    outcome: 'majority',
    relatedSections: ['7', '24'],
    relatedCases: ['roach-v-electoral-commissioner-2007'],
    content: 'Extending the reasoning in Roach v Electoral Commissioner (2007), the Court held that amendments shortening the period for closing the electoral roll after writs were issued were invalid. The majority held that the constitutional requirement that members be directly chosen by the people implies a constitutionally protected franchise that Parliament cannot unjustifiably restrict.'
  },
  {
    id: 'unions-nsw-v-nsw-2013',
    name: 'Unions NSW v New South Wales',
    shortName: 'Unions NSW',
    year: 2013,
    court: 'High Court of Australia',
    citation: '(2013) 252 CLR 530',
    principle: 'NSW electoral donation restrictions held to impermissibly burden the implied freedom of political communication',
    outcome: 'majority',
    relatedSections: ['7', '24'],
    relatedCases: ['mccloy-v-nsw-2015', 'actv-v-commonwealth-1992'],
    content: 'The Court struck down provisions of the NSW Election Funding, Expenditure and Disclosures Act that prohibited political donations by entities other than individuals on the electoral roll. This was the first law struck down for breaching the implied freedom of political communication since the original ACTV and Nationwide News decisions in 1992, demonstrating the freedom\'s continuing vitality.'
  },
  {
    id: 'mccloy-v-nsw-2015',
    name: 'McCloy v New South Wales',
    shortName: 'McCloy',
    year: 2015,
    court: 'High Court of Australia',
    citation: '(2015) 257 CLR 178',
    principle: 'Introduced structured proportionality testing (suitability, necessity, adequacy in balance) into the implied freedom of political communication',
    outcome: 'majority',
    relatedSections: ['7', '24'],
    relatedCases: ['lange-v-abc-1997', 'unions-nsw-v-nsw-2013', 'brown-v-tasmania-2017'],
    content: 'The Court upheld NSW caps on political donations and bans on donations by property developers. In doing so, the majority introduced a structured proportionality test replacing the reasonableness standard from Lange v ABC. The new test requires that a law burdening political communication be suitable, necessary, and adequate in its balance of the competing interests. This fundamentally changed the analytical framework for all implied freedom cases.'
  },
  {
    id: 'brown-v-tasmania-2017',
    name: 'Brown v Tasmania',
    shortName: 'Brown v Tasmania',
    year: 2017,
    court: 'High Court of Australia',
    citation: '(2017) 261 CLR 328',
    principle: 'Anti-protest legislation held invalid as an impermissible burden on the implied freedom of political communication; protest is constitutionally protected',
    outcome: 'majority',
    relatedSections: ['7', '24'],
    relatedCases: ['mccloy-v-nsw-2015', 'clubb-v-edwards-2019'],
    content: 'The Court struck down provisions of the Tasmanian Workplaces (Protection from Protesters) Act 2014 that created offences for protesting on business premises. Applying the McCloy structured proportionality test, the majority held the laws were not reasonably necessary and placed a disproportionate burden on political communication. The case confirmed that peaceful protest is a form of political communication protected by the implied freedom.'
  },
  {
    id: 'clubb-v-edwards-2019',
    name: 'Clubb v Edwards',
    shortName: 'Clubb v Edwards',
    year: 2019,
    court: 'High Court of Australia',
    citation: '(2019) 267 CLR 171',
    principle: 'Confirmed and refined the structured proportionality test; abortion clinic safe-zone laws upheld as valid',
    outcome: 'unanimous',
    relatedSections: ['7', '24'],
    relatedCases: ['mccloy-v-nsw-2015', 'brown-v-tasmania-2017'],
    content: 'The Court unanimously upheld Victorian and Tasmanian laws creating safe access zones around abortion clinics, prohibiting certain communications within 150 metres. While the justices were divided on methodology, all agreed the laws were valid. The case refined the application of structured proportionality after McCloy and Brown, confirming the current state of the implied freedom doctrine.'
  },
  {
    id: 'palmer-v-western-australia-2021',
    name: 'Palmer v Western Australia',
    shortName: 'Palmer v WA',
    year: 2021,
    court: 'High Court of Australia',
    citation: '(2021) 272 CLR 505',
    principle: 'COVID-19 border closures upheld under s 92; reunified the trade/commerce and intercourse limbs and applied structured proportionality to s 92',
    outcome: 'majority',
    relatedSections: ['92'],
    relatedCases: ['cole-v-whitfield-1988'],
    content: "The most significant s 92 case since Cole v Whitfield (1988). Clive Palmer challenged Western Australia's hard border closure during the COVID-19 pandemic. The Court upheld the closure, holding that s 92 does not guarantee absolute freedom but rather freedom from discriminatory or protectionist burdens. The Court reunified the 'trade and commerce' and 'intercourse' limbs of s 92 and applied structured proportionality analysis for the first time."
  },
  {
    id: 'nzyq-2023',
    name: 'NZYQ v Minister for Immigration',
    shortName: 'NZYQ',
    year: 2023,
    court: 'High Court of Australia',
    citation: '[2023] HCA 37',
    principle: 'Indefinite immigration detention is unconstitutional; overturned Al-Kateb v Godwin',
    outcome: 'unanimous',
    relatedSections: ['51(xix)', '71'],
    relatedCases: ['chu-kheng-lim-1992', 'al-kateb-v-godwin-2004'],
    content: 'In a unanimous decision, the Court overturned Al-Kateb v Godwin (2004) and held that the indefinite detention of a person with no real prospect of removal from Australia is unconstitutional. The Court reaffirmed the Lim principle that executive detention under the aliens power must be for a legitimate non-punitive purpose and cannot continue when that purpose can no longer be fulfilled. The decision resulted in the immediate release of approximately 149 immigration detainees.'
  }
];

cases.push(...newCases);
cases.sort((a, b) => a.year - b.year);

fs.writeFileSync('content/cases/cases.json', JSON.stringify(cases, null, 2));
console.log('Total cases:', cases.length);
console.log('Added:', newCases.map(c => c.shortName + ' (' + c.year + ')').join(', '));
