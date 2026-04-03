import type {
  ChapterMeta,
  ConstitutionSection,
  Case,
  Referendum,
  HistoricalDocument,
} from '@/lib/types';

import chaptersData from '@/content/constitution/chapters.json';
import casesData from '@/content/cases/cases.json';
import referendumsData from '@/content/referendums/referendums.json';
import documentsData from '@/content/documents/documents.json';

import rawSectionsData from '@/content/constitution/sections.json';

const sectionsData = rawSectionsData as Record<string, unknown>[];

// ---------------------------------------------------------------------------
// Chapters
// ---------------------------------------------------------------------------

interface RawChapter {
  number: number;
  title: string;
  slug: string;
  parts: { number: number; title: string; sections: number[] }[];
  sections: number[];
}

function mapChapter(raw: RawChapter): ChapterMeta {
  const sectionNumbers: number[] = [];
  if (raw.parts.length > 0) {
    for (const part of raw.parts) {
      sectionNumbers.push(...part.sections);
    }
  }
  if (sectionNumbers.length === 0) {
    sectionNumbers.push(...raw.sections);
  }
  return {
    number: raw.number,
    title: raw.title,
    description: '',
    sections: sectionNumbers.map((n) => `s${n}`),
  };
}

export function getChapters(): ChapterMeta[] {
  return (chaptersData as unknown as RawChapter[]).map(mapChapter);
}

export function getChapter(slug: string): ChapterMeta | undefined {
  const raw = (chaptersData as unknown as RawChapter[]).find(
    (ch) => ch.slug === slug || `chapter-${ch.number}` === slug || String(ch.number) === slug,
  );
  return raw ? mapChapter(raw) : undefined;
}

// ---------------------------------------------------------------------------
// Sections
// ---------------------------------------------------------------------------

function mapSection(raw: Record<string, unknown>): ConstitutionSection {
  return {
    id: String(raw.id ?? ''),
    title: String(raw.title ?? ''),
    chapter: Number(raw.chapter ?? 0),
    sectionNumber: Number(raw.sectionNumber ?? raw.number ?? 0),
    content: String(raw.content ?? ''),
    relatedCases: Array.isArray(raw.relatedCases) ? (raw.relatedCases as string[]) : [],
    relatedReferendums: Array.isArray(raw.relatedReferendums) ? (raw.relatedReferendums as string[]) : [],
    relatedDocuments: Array.isArray(raw.relatedDocuments) ? (raw.relatedDocuments as string[]) : [],
  };
}

export function getSection(id: string): ConstitutionSection | undefined {
  const num = id.replace(/^s/, '');
  const raw = sectionsData.find(
    (s) => String(s.number) === num || String(s.id) === id || String(s.id) === num,
  );
  return raw ? mapSection(raw) : undefined;
}

export function getSectionsForChapter(chapterNumber: number): ConstitutionSection[] {
  return sectionsData
    .filter((s) => Number(s.chapter) === chapterNumber)
    .map(mapSection);
}

// ---------------------------------------------------------------------------
// Cases
// ---------------------------------------------------------------------------

interface RawCase {
  id: string;
  name: string;
  shortName?: string;
  year: number;
  court: string;
  citation: string;
  principle: string;
  outcome: string;
  content: string;
  relatedSections: string[];
  relatedCases: string[];
}

function mapCase(raw: RawCase): Case {
  return {
    id: raw.id,
    name: raw.name,
    year: raw.year,
    court: raw.court,
    citation: raw.citation,
    principle: raw.principle,
    outcome: (raw.outcome as Case['outcome']) ?? 'majority',
    content: raw.content,
    relatedSections: raw.relatedSections ?? [],
    relatedCases: raw.relatedCases ?? [],
  };
}

export function getCases(): Case[] {
  return (casesData as RawCase[]).map(mapCase);
}

export function getCase(id: string): Case | undefined {
  const raw = (casesData as RawCase[]).find((c) => c.id === id);
  return raw ? mapCase(raw) : undefined;
}

export function getCasesForSection(sectionId: string): Case[] {
  return (casesData as RawCase[])
    .filter((c) => c.relatedSections?.includes(sectionId))
    .map(mapCase);
}

// ---------------------------------------------------------------------------
// Referendums
// ---------------------------------------------------------------------------

interface RawReferendum {
  id: string;
  year: number;
  title: string;
  question: string;
  outcome: string;
  yesPercentage: number;
  content: string;
  relatedSections: string[];
}

function mapReferendum(raw: RawReferendum): Referendum {
  return {
    id: raw.id,
    year: raw.year,
    question: raw.question,
    outcome: (raw.outcome as Referendum['outcome']) ?? 'defeated',
    yesPercentage: raw.yesPercentage,
    content: raw.content,
    relatedSections: raw.relatedSections ?? [],
  };
}

export function getReferendums(): Referendum[] {
  return (referendumsData as RawReferendum[]).map(mapReferendum);
}

export function getReferendum(id: string): Referendum | undefined {
  const raw = (referendumsData as RawReferendum[]).find((r) => r.id === id);
  return raw ? mapReferendum(raw) : undefined;
}

export function getReferendumsForSection(sectionId: string): Referendum[] {
  return (referendumsData as RawReferendum[])
    .filter((r) => r.relatedSections?.includes(sectionId))
    .map(mapReferendum);
}

// ---------------------------------------------------------------------------
// Historical Documents
// ---------------------------------------------------------------------------

function mapDocument(raw: (typeof documentsData)[number]): HistoricalDocument {
  return {
    id: raw.id,
    title: raw.title,
    year: raw.year,
    description: raw.description,
    content: raw.content,
    relatedSections: raw.relatedSections,
  };
}

export function getDocuments(): HistoricalDocument[] {
  return documentsData.map(mapDocument);
}

export function getDocument(id: string): HistoricalDocument | undefined {
  const raw = documentsData.find((d) => d.id === id);
  return raw ? mapDocument(raw) : undefined;
}
