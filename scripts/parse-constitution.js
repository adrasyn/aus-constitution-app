const fs = require('fs');
const raw = fs.readFileSync('scripts/constitution-raw.txt', 'utf-8');

const sections = [];

function addSection(number, title, chapter, content, notes = '') {
  sections.push({
    number,
    title: title.trim(),
    chapter,
    content: content.trim().replace(/\r\n/g, '\n').replace(/\n{3,}/g, '\n\n'),
    relatedCases: [],
    relatedReferendums: [],
    relatedDocuments: [],
    notes
  });
}

// Find the start of the actual Constitution text
// Look for "An Act to constitute the Commonwealth of Australia"
const actStart = raw.indexOf('An Act to constitute the Commonwealth of Australia');
if (actStart === -1) {
  console.error('Could not find start of Constitution text');
  process.exit(1);
}

// Find the preamble
const preambleStart = raw.indexOf('WHEREAS the people of');
const constitutionStart = raw.indexOf('Chapter I.', preambleStart);

// Extract preamble
const preambleText = raw.substring(preambleStart, constitutionStart).trim();
addSection(0, 'Preamble', 0, preambleText);

// Now parse sections from Chapter I onwards
const bodyText = raw.substring(constitutionStart);

// Split into lines
const lines = bodyText.split(/\r?\n/);

let currentChapter = 0;
let collectingSection = false;
let currentNum = null;
let currentTitle = '';
let currentContent = [];

// Chapter mapping
function detectChapter(line) {
  const t = line.trim();
  if (t.match(/^Chapter\s+I\b.*Parliament/i)) return 1;
  if (t.match(/^Chapter\s+II\b.*Executive/i)) return 2;
  if (t.match(/^Chapter\s+III\b.*Judicature/i)) return 3;
  if (t.match(/^Chapter\s+IV\b.*Finance/i)) return 4;
  if (t.match(/^Chapter\s+V\b.*The States/i) && !t.match(/New States/i)) return 5;
  if (t.match(/^Chapter\s+VI\b.*New States/i)) return 6;
  if (t.match(/^Chapter\s+VII\b.*Miscellaneous/i)) return 7;
  if (t.match(/^Chapter\s+VIII\b.*Alteration/i)) return 8;
  return null;
}

function flushSection() {
  if (currentNum !== null && currentTitle) {
    const content = currentContent.join('\n').trim();
    if (content.length > 0) {
      let notes = '';
      const numStr = String(currentNum);
      if (numStr === '15') notes = 'Section 15 was substituted by the Constitution Alteration (Senate Casual Vacancies) 1977.';
      if (numStr === '13') notes = 'Section 13 was amended by the Constitution Alteration (Senate Elections) 1906.';
      if (numStr === '51') notes = 'Section 51 was amended by the Constitution Alteration (Social Services) 1946 (adding paragraph xxiiiA) and the Constitution Alteration (Aboriginals) 1967 (amending paragraph xxvi).';
      if (numStr === '72') notes = 'Section 72 was amended by the Constitution Alteration (Retirement of Judges) 1977.';
      if (numStr === '105') notes = 'Section 105 was amended by the Constitution Alteration (State Debts) 1909.';
      if (numStr === '105A') notes = 'Section 105A was added by the Constitution Alteration (State Debts) 1929.';
      if (numStr === '128') notes = 'Section 128 was amended by the Constitution Alteration (Referendums) 1977, extending voting rights to Territory electors.';
      addSection(currentNum, currentTitle, currentChapter, content, notes);
    }
  }
  currentNum = null;
  currentTitle = '';
  currentContent = [];
  collectingSection = false;
}

// Track whether we've seen the endnotes (stop parsing there)
let inEndnotes = false;

for (let i = 0; i < lines.length; i++) {
  const line = lines[i];
  const trimmed = line.trim();

  // Stop at endnotes/schedule oath
  if (trimmed === 'Endnotes' || trimmed.match(/^Endnote \d/)) {
    flushSection();
    inEndnotes = true;
    continue;
  }
  if (inEndnotes) continue;

  // Detect chapter changes
  const ch = detectChapter(trimmed);
  if (ch !== null) {
    flushSection();
    currentChapter = ch;
    continue;
  }

  // Skip Part headers
  if (trimmed.match(/^Part\s+[IVX]+\.?\s*[\u2014\-]/)) continue;
  if (trimmed.match(/^Part\s+[IVX]+\.?\s*$/)) continue;

  // Detect section headers
  // Pattern: "NUMBER.  TITLE." or "NUMBER.\tTITLE" or just "NUMBER." for spent sections
  // e.g. "1.  Legislative Power." or "105A.  Agreements with respect to State debts."
  const sectionMatch = trimmed.match(/^(\d+[A-Z]?)\.\s+(.+?)\.?\s*$/) || trimmed.match(/^(\d+[A-Z]?)\.\t+(.+?)\.?\s*$/);

  // Also match bare section numbers (spent provisions like 86. and 87.)
  const bareMatch = !sectionMatch && trimmed.match(/^(\d+[A-Z]?)\.$/);

  if (sectionMatch) {
    const num = sectionMatch[1];
    const title = sectionMatch[2].replace(/\.$/, '').trim();

    // Validate it looks like a section header (title should be short-ish, not content)
    if (title.length < 100) {
      flushSection();
      currentNum = num.match(/[A-Z]/) ? num : parseInt(num);
      currentTitle = title;
      currentContent = [];
      collectingSection = true;
      continue;
    }
  }

  if (bareMatch) {
    const num = parseInt(bareMatch[1]);
    // Only treat as section if it's a known spent provision (86, 87)
    if (num === 86 || num === 87) {
      flushSection();
      currentNum = num;
      currentTitle = num === 86 ? '[Spent]' : '[Spent]';
      currentContent = [];
      collectingSection = true;
      continue;
    }
  }

  // Collect content for current section
  if (collectingSection && trimmed.length > 0) {
    currentContent.push(trimmed);
  } else if (collectingSection && trimmed.length === 0 && currentContent.length > 0) {
    currentContent.push('');
  }
}

// Flush last section
flushSection();

// Handle section 127 (repealed - not in the document)
const has127 = sections.find(s => s.number === 127);
if (!has127) {
  addSection(127, 'Aborigines not to be counted in reckoning population', 7,
    '[Repealed]',
    'Section 127 was repealed by the Constitution Alteration (Aboriginals) 1967. The original text provided: "In reckoning the numbers of the people of the Commonwealth, or of a State or other part of the Commonwealth, aboriginal natives shall not be counted."'
  );
}

// Sort sections by number
sections.sort((a, b) => {
  if (a.number === 0) return -1;
  if (b.number === 0) return 1;
  const aNum = typeof a.number === 'string' ? parseFloat(a.number) + 0.5 : a.number;
  const bNum = typeof b.number === 'string' ? parseFloat(b.number) + 0.5 : b.number;
  return aNum - bNum;
});

// Write output
fs.writeFileSync('content/constitution/sections.json', JSON.stringify(sections, null, 2));

console.log(`Generated ${sections.length} sections`);
console.log('Section numbers:', sections.map(s => typeof s.number === 'string' ? s.number : s.number).join(', '));

// Validate
const expected = [0, ...Array.from({length: 128}, (_, i) => i + 1)];
const missing = expected.filter(n => !sections.find(s => s.number === n));
const extra = sections.filter(s => typeof s.number === 'string').map(s => s.number);
console.log('Missing:', missing.length > 0 ? missing.join(', ') : 'none');
console.log('Extra (string keys):', extra.length > 0 ? extra.join(', ') : 'none');

// Show some samples
console.log('\n--- Sample sections ---');
[1, 51, 92, 109, 116, 127, 128].forEach(n => {
  const sec = sections.find(s => s.number === n);
  if (sec) {
    console.log(`s${n}: "${sec.title}" (${sec.content.length} chars, ch${sec.chapter})`);
  } else {
    console.log(`s${n}: MISSING`);
  }
});
