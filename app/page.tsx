import Link from "next/link";
import chaptersData from "@/content/constitution/chapters.json";
import styles from "./page.module.css";

interface Chapter {
  number: number;
  title: string;
  slug: string;
  parts: { number: number; title: string; sections: number[] }[];
  sections: number[];
}

function getSectionCount(chapter: Chapter): number {
  if (chapter.parts.length > 0) {
    return chapter.parts.reduce((sum, part) => sum + part.sections.length, 0);
  }
  return chapter.sections.length;
}

export default function HomePage() {
  const chapters = chaptersData as Chapter[];

  return (
    <div className={styles.container}>
      <div className={styles.hero}>
        <div className={styles.coatOfArms}>
          {/* Placeholder for coat of arms PNG */}
        </div>
        <h1 className={styles.heading}>The Constitution</h1>
        <p className={styles.subtitle}>
          Commonwealth of Australia Constitution Act 1900
        </p>
      </div>

      <div className={styles.pills}>
        <Link href="/referendums" className={styles.pill}>
          Referendums
        </Link>
        <Link href="/constitution/preamble/s0" className={styles.pill}>
          Preamble
        </Link>
        <Link href="/constitution/chapter-1-the-parliament/s51" className={styles.pill}>
          s 51 Powers
        </Link>
        <Link href="/constitution/chapter-5-the-states/s116" className={styles.pill}>
          s 116 Religion
        </Link>
        <Link href="/constitution/chapter-8-alteration-of-the-constitution/s128" className={styles.pill}>
          s 128 Amendment
        </Link>
      </div>

      <div className={styles.chapterList}>
        {chapters.map((chapter) => {
          if (chapter.number === 9) return null; // Schedule — handle separately if needed
          const sectionCount = getSectionCount(chapter);
          const label =
            chapter.number === 0
              ? ""
              : `Chapter ${chapter.number === 8 ? "VIII" : chapter.number === 7 ? "VII" : chapter.number === 6 ? "VI" : chapter.number === 5 ? "V" : chapter.number === 4 ? "IV" : chapter.number === 3 ? "III" : chapter.number === 2 ? "II" : "I"}`;

          return (
            <Link
              key={chapter.slug}
              href={`/constitution/${chapter.slug}`}
              className={styles.chapterCard}
            >
              <div className={styles.chapterHeader}>
                {label && <span className={styles.chapterLabel}>{label}</span>}
                <h2 className={styles.chapterTitle}>{chapter.title}</h2>
              </div>
              <div className={styles.chapterMeta}>
                {sectionCount > 0 && (
                  <span className={styles.sectionCount}>
                    {sectionCount} {sectionCount === 1 ? "section" : "sections"}
                  </span>
                )}
                {chapter.parts.length > 0 && (
                  <span className={styles.partCount}>
                    {chapter.parts.length} parts
                  </span>
                )}
              </div>
            </Link>
          );
        })}
      </div>
    </div>
  );
}
