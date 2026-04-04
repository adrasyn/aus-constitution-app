import chaptersData from "@/content/constitution/chapters.json";

interface Chapter {
  number: number;
  slug: string;
  parts: { sections: number[] }[];
  sections: number[];
}

const chapters = chaptersData as Chapter[];

/**
 * Given a section reference (e.g. "51", "s51", "51(xx)", "s92"),
 * return the correct app URL for that section.
 */
export function getSectionHref(ref: string): string {
  // Strip leading "s" prefix if present
  const bare = ref.replace(/^s/, "");
  // Extract base section number (e.g. "51" from "51(xx)")
  const baseMatch = bare.match(/^(\d+[A-Z]?)/);
  if (!baseMatch) return "/";
  const baseNum = parseInt(baseMatch[1]);

  // Find which chapter contains this section
  for (const ch of chapters) {
    const allSections =
      ch.parts.length > 0
        ? ch.parts.flatMap((p) => p.sections)
        : ch.sections;
    if (allSections.includes(baseNum)) {
      return `/constitution/${ch.slug}/s${baseNum}`;
    }
  }

  // Fallback
  return `/constitution/preamble/s${baseNum}`;
}

/**
 * Format a section reference for display (e.g. "51(xx)" -> "s 51(xx)")
 */
export function formatSectionRef(ref: string): string {
  const bare = ref.replace(/^s/, "");
  return `s ${bare}`;
}
