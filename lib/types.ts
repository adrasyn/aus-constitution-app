export interface ChapterMeta {
  number: number;
  title: string;
  description: string;
  sections: string[];
}

export interface ConstitutionSection {
  id: string;
  title: string;
  chapter: number;
  sectionNumber: number;
  content: string;
  relatedCases: string[];
  relatedReferendums: string[];
  relatedDocuments: string[];
}

export interface Case {
  id: string;
  name: string;
  year: number;
  court: string;
  citation: string;
  principle: string;
  outcome: "majority" | "dissent";
  content: string;
  relatedSections: string[];
  relatedCases: string[];
}

export interface Referendum {
  id: string;
  year: number;
  question: string;
  outcome: "carried" | "defeated";
  yesPercentage: number;
  content: string;
  relatedSections: string[];
}

export interface HistoricalDocument {
  id: string;
  title: string;
  year: number;
  description: string;
  content: string;
  relatedSections: string[];
}
