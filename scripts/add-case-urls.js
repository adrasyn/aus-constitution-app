const fs = require('fs');
const cases = require('../content/cases/cases.json');

// AustLII URLs for High Court cases
const urls = {
  'demden-v-pedder-1904': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/1904/1.html',
  'huddart-parker-v-moorehead-1909': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/1909/36.html',
  'engineers-case-1920': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/1920/54.html',
  'first-uniform-tax-case-1942': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/1942/14.html',
  'melbourne-corporation-v-commonwealth-1947': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/1947/26.html',
  'bank-nationalisation-case-1948': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/1948/7.html',
  'communist-party-case-1951': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/1951/5.html',
  'boilermakers-case-1956': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/1956/10.html',
  'second-uniform-tax-case-1957': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/1957/54.html',
  'strickland-v-rocla-1971': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/1971/36.html',
  'koowarta-v-bjelke-petersen-1982': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/1982/27.html',
  'tasmanian-dam-case-1983': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/1983/21.html',
  'cole-v-whitfield-1988': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/1988/18.html',
  'street-v-qld-bar-assoc-1989': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/1989/53.html',
  'actv-v-commonwealth-1992': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/1992/45.html',
  'nationwide-news-v-wills-1992': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/1992/46.html',
  'mabo-v-queensland-no2-1992': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/1992/23.html',
  'chu-kheng-lim-1992': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/1992/64.html',
  'sykes-v-cleary-1992': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/1992/60.html',
  'kable-v-dpp-1996': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/1996/24.html',
  'ha-v-nsw-1997': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/1997/34.html',
  'lange-v-abc-1997': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/1997/25.html',
  're-wakim-1999': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/1999/27.html',
  'sue-v-hill-1999': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/1999/30.html',
  'plaintiff-s157-2003': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/2003/2.html',
  'al-kateb-v-godwin-2004': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/2004/37.html',
  'work-choices-case-2006': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/2006/52.html',
  'roach-v-electoral-commissioner-2007': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/2007/43.html',
  'pape-v-commissioner-2009': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/2009/23.html',
  'wurridjal-v-commonwealth-2009': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/2009/2.html',
  'kirk-v-industrial-court-2010': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/2010/1.html',
  'rowe-v-electoral-commissioner-2010': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/2010/46.html',
  'williams-v-commonwealth-2012': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/2012/23.html',
  'unions-nsw-v-nsw-2013': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/2013/58.html',
  'mccloy-v-nsw-2015': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/2015/34.html',
  'brown-v-tasmania-2017': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/2017/43.html',
  'clubb-v-edwards-2019': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/2019/11.html',
  'love-v-commonwealth-2020': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/2020/3.html',
  'palmer-v-western-australia-2021': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/2021/31.html',
  'nzyq-2023': 'https://www.austlii.edu.au/cgi-bin/viewdoc/au/cases/cth/HCA/2023/37.html',
};

let count = 0;
cases.forEach(c => {
  if (urls[c.id]) {
    c.sourceUrl = urls[c.id];
    count++;
  }
});

fs.writeFileSync('content/cases/cases.json', JSON.stringify(cases, null, 2));
console.log(`Added source URLs to ${count} of ${cases.length} cases`);

// Check for any without URLs
const missing = cases.filter(c => !c.sourceUrl);
if (missing.length) {
  console.log('Missing URLs:', missing.map(c => c.id).join(', '));
} else {
  console.log('All cases have source URLs');
}
