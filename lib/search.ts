import { Index } from "flexsearch";
import { getSectionHref } from "./section-links";

export interface SearchResult {
  type: "section" | "case" | "document" | "referendum";
  id: string;
  title: string;
  snippet: string;
  href: string;
  meta?: string;
}

interface SearchEntry {
  id: string;
  type: SearchResult["type"];
  title: string;
  content: string;
  href: string;
  meta?: string;
}

let index: Index | null = null;
let entries: SearchEntry[] = [];

function getIndex(): Index {
  if (!index) {
    index = new Index({
      tokenize: "forward",
      resolution: 9,
    });
  }
  return index;
}

export function buildSearchIndex(data: {
  sections: { number: number; title: string; content: string; chapter: number }[];
  cases: { id: string; name: string; shortName?: string; principle: string; content: string; year: number }[];
  documents: { id: string; title: string; description: string; content: string; year: number }[];
  referendums: { id: string; title: string; question: string; content: string; year: number; outcome: string }[];
}) {
  const idx = getIndex();
  entries = [];
  let counter = 0;

  // Index sections
  for (const s of data.sections) {
    const entry: SearchEntry = {
      id: `s${s.number}`,
      type: "section",
      title: s.number === 0 ? "Preamble" : `s ${s.number} — ${s.title}`,
      content: s.content,
      href: getSectionHref(String(s.number)),
      meta: `Section ${s.number}`,
    };
    entries.push(entry);
    idx.add(counter, `${entry.title} ${entry.content}`);
    counter++;
  }

  // Index cases
  for (const c of data.cases) {
    const entry: SearchEntry = {
      id: c.id,
      type: "case",
      title: c.shortName || c.name,
      content: `${c.name} ${c.principle} ${c.content}`,
      href: `/cases/${c.id}`,
      meta: String(c.year),
    };
    entries.push(entry);
    idx.add(counter, `${c.name} ${c.shortName || ""} ${c.principle} ${c.content}`);
    counter++;
  }

  // Index documents
  for (const d of data.documents) {
    const entry: SearchEntry = {
      id: d.id,
      type: "document",
      title: d.title,
      content: `${d.description} ${d.content}`,
      href: `/documents/${d.id}`,
      meta: String(d.year),
    };
    entries.push(entry);
    idx.add(counter, `${d.title} ${d.description} ${d.content}`);
    counter++;
  }

  // Index referendums
  for (const r of data.referendums) {
    const entry: SearchEntry = {
      id: r.id,
      type: "referendum",
      title: r.title,
      content: `${r.question} ${r.content}`,
      href: `/referendums`,
      meta: `${r.year} — ${r.outcome}`,
    };
    entries.push(entry);
    idx.add(counter, `${r.title} ${r.question} ${r.content}`);
    counter++;
  }

  return entries.length;
}

export function search(query: string, limit = 20): SearchResult[] {
  const idx = getIndex();
  const resultIds = idx.search(query, limit) as number[];

  return resultIds.map((id) => {
    const entry = entries[id];
    // Extract a snippet around the match
    const lowerContent = entry.content.toLowerCase();
    const lowerQuery = query.toLowerCase();
    const matchIndex = lowerContent.indexOf(lowerQuery);
    let snippet = "";
    if (matchIndex >= 0) {
      const start = Math.max(0, matchIndex - 60);
      const end = Math.min(entry.content.length, matchIndex + query.length + 60);
      snippet =
        (start > 0 ? "..." : "") +
        entry.content.slice(start, end).trim() +
        (end < entry.content.length ? "..." : "");
    } else {
      snippet = entry.content.slice(0, 120).trim() + "...";
    }

    return {
      type: entry.type,
      id: entry.id,
      title: entry.title,
      snippet,
      href: entry.href,
      meta: entry.meta,
    };
  });
}
