import Link from "next/link";
import { notFound, redirect } from "next/navigation";
import chaptersData from "@/content/constitution/chapters.json";
import sectionsJsonData from "@/content/constitution/sections.json";
import styles from "./page.module.css";

interface Chapter {
  number: number;
  title: string;
  slug: string;
  parts: { number: number; title: string; sections: number[] }[];
  coveringClauses?: string[];
  sections: number[];
}

function toRoman(num: number): string {
  const map: [number, string][] = [
    [8, "VIII"], [7, "VII"], [6, "VI"], [5, "V"],
    [4, "IV"], [3, "III"], [2, "II"], [1, "I"],
  ];
  for (const [val, roman] of map) {
    if (num === val) return roman;
  }
  return String(num);
}

export function generateStaticParams() {
  return (chaptersData as Chapter[]).map((ch) => ({ slug: ch.slug }));
}

export default async function ChapterPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const chapter = (chaptersData as Chapter[]).find((ch) => ch.slug === slug);
  if (!chapter) return notFound();

  // Single-section chapters: redirect directly to the section
  const allSections = chapter.parts.length > 0
    ? chapter.parts.flatMap((p) => p.sections)
    : chapter.sections;
  if (allSections.length === 1) {
    redirect(`/constitution/${slug}/s${allSections[0]}`);
  }

  const isPreamble = chapter.number === 0;

  const sectionTitles: Record<string, string> = {};
  for (const s of sectionsJsonData) {
    sectionTitles[String(s.number)] = s.title;
  }

  return (
    <div className={styles.container}>
      <nav className={styles.breadcrumb}>
        <Link href="/" className={styles.backLink} aria-label="Back">
          &larr;
        </Link>
        <Link href="/" className={styles.breadcrumbLink}>
          Constitution
        </Link>
        <span className={styles.breadcrumbSep}>/</span>
        <span className={styles.breadcrumbCurrent}>{chapter.title}</span>
      </nav>

      <div className={styles.heading}>
        {!isPreamble && (
          <span className={styles.chapterLabel}>
            Chapter {toRoman(chapter.number)}
          </span>
        )}
        <h1 className={styles.title}>{chapter.title}</h1>
      </div>

      {chapter.parts.length > 0 ? (
        <div className={styles.partsList}>
          {chapter.parts.map((part) => (
            <div key={part.number} className={styles.partGroup}>
              <h3 className={styles.partTitle}>
                Part {part.number} — {part.title}
              </h3>
              <div className={styles.sectionList}>
                {part.sections.map((sNum) => (
                  <Link
                    key={sNum}
                    href={`/constitution/${slug}/s${sNum}`}
                    className={styles.sectionCard}
                  >
                    <span className={styles.sectionNumber}>s {sNum}</span>
                    <span className={styles.sectionTitle}>
                      {sectionTitles[String(sNum)] || `Section ${sNum}`}
                    </span>
                  </Link>
                ))}
              </div>
            </div>
          ))}
        </div>
      ) : (
        <div className={styles.sectionList}>
          {chapter.sections.map((sNum) => (
            <Link
              key={sNum}
              href={`/constitution/${slug}/s${sNum}`}
              className={styles.sectionCard}
            >
              <span className={styles.sectionNumber}>
                {isPreamble ? "" : `s ${sNum}`}
              </span>
              <span className={styles.sectionTitle}>
                {sectionTitles[String(sNum)] || (isPreamble ? "Preamble" : `Section ${sNum}`)}
              </span>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}
