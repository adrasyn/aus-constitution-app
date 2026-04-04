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

function getAllSections(chapter: Chapter): number[] {
  if (chapter.parts.length > 0) {
    return chapter.parts.flatMap((p) => p.sections);
  }
  return chapter.sections;
}

function getSectionRange(chapter: Chapter): string {
  const sections = getAllSections(chapter);
  if (sections.length === 0) return "";
  if (sections.length === 1) return `Section ${sections[0]}`;
  return `Sections ${sections[0]} to ${sections[sections.length - 1]}`;
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

export default function HomePage() {
  const chapters = chaptersData as Chapter[];

  return (
    <div className={styles.container}>
      <div className={styles.hero}>
        <img
          src="/coat-of-arms.png"
          alt="Commonwealth Coat of Arms"
          className={styles.coatOfArms}
        />
        <h1 className={styles.heading}>The Constitution</h1>
        <p className={styles.subtitle}>
          Commonwealth of Australia Constitution Act 1900
        </p>
      </div>

      <div className={styles.pills}>
        <Link href="/referendums" className={styles.pill}>
          Referendums
        </Link>
        <Link href="/constitution/chapter-1-the-parliament/s51" className={styles.pill}>
          s 51 Powers
        </Link>
      </div>

      <div className={styles.chapterList}>
        {chapters.map((chapter) => {
          const isSchedule = chapter.number === 9;
          const isPreamble = chapter.number === 0;
          const sectionRange = getSectionRange(chapter);

          const label = isPreamble || isSchedule
            ? (isSchedule ? "Schedule" : "")
            : `Chapter ${toRoman(chapter.number)}`;

          const title = isSchedule ? "Schedule" : chapter.title;

          return (
            <Link
              key={chapter.slug}
              href={`/constitution/${chapter.slug}`}
              className={styles.chapterCard}
            >
              <div className={styles.chapterHeader}>
                {label && <span className={styles.chapterLabel}>{label}</span>}
                <h2 className={styles.chapterTitle}>{title}</h2>
              </div>
              <div className={styles.chapterMeta}>
                {sectionRange && (
                  <span className={styles.sectionCount}>{sectionRange}</span>
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

      <footer className={styles.footer}>
        <p>
          This site is a side project by{" "}
          <a href="https://x.com/jameswilson" target="_blank" rel="noopener noreferrer">
            James Wilson
          </a>{" "}
          &#127462;&#127482;
        </p>
      </footer>
    </div>
  );
}
