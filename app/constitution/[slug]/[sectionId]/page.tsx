import Link from "next/link";
import { notFound } from "next/navigation";
import chaptersData from "@/content/constitution/chapters.json";
import sectionsData from "@/content/constitution/sections.json";
import casesData from "@/content/cases/cases.json";
import referendumsData from "@/content/referendums/referendums.json";
import styles from "./page.module.css";
import BookmarkButton from "./BookmarkButton";

interface Chapter {
  number: number;
  title: string;
  slug: string;
  parts: { number: number; title: string; sections: number[] }[];
  sections: number[];
}

interface Section {
  number: number;
  title: string;
  chapter: number;
  content: string;
  relatedCases: string[];
  relatedReferendums: string[];
  relatedDocuments: string[];
  notes?: string;
}

interface CaseItem {
  id: string;
  name: string;
  shortName?: string;
  year: number;
  principle: string;
  outcome: string;
  relatedSections: string[];
}

interface ReferendumItem {
  id: string;
  year: number;
  title: string;
  outcome: string;
  yesPercentage: number;
  relatedSections: string[];
}

export function generateStaticParams() {
  const chapters = chaptersData as Chapter[];
  const params: { slug: string; sectionId: string }[] = [];
  for (const ch of chapters) {
    const sectionNums =
      ch.parts.length > 0
        ? ch.parts.flatMap((p) => p.sections)
        : ch.sections;
    for (const sNum of sectionNums) {
      params.push({ slug: ch.slug, sectionId: `s${sNum}` });
    }
  }
  return params;
}

export default async function SectionPage({
  params,
}: {
  params: Promise<{ slug: string; sectionId: string }>;
}) {
  const { slug, sectionId } = await params;
  const chapter = (chaptersData as Chapter[]).find((ch) => ch.slug === slug);
  if (!chapter) return notFound();

  // Extract section number from "s51" format
  const sNum = sectionId.replace(/^s/, "");
  const sections = sectionsData as Section[];
  const section = sections.find((s) => String(s.number) === sNum);

  if (!section) {
    return notFound();
  }

  // Get related cases and referendums
  const allCases = casesData as CaseItem[];
  const allReferendums = referendumsData as ReferendumItem[];

  const relatedCases = allCases.filter(
    (c) =>
      section.relatedCases?.includes(c.id) ||
      c.relatedSections?.includes(sNum)
  );

  const relatedReferendums = allReferendums.filter(
    (r) =>
      section.relatedReferendums?.includes(r.id) ||
      r.relatedSections?.includes(sNum)
  );

  // Find prev/next sections in this chapter
  const chapterSections =
    chapter.parts.length > 0
      ? chapter.parts.flatMap((p) => p.sections)
      : chapter.sections;
  const currentIndex = chapterSections.indexOf(Number(sNum));
  const prevSection = currentIndex > 0 ? chapterSections[currentIndex - 1] : null;
  const nextSection =
    currentIndex < chapterSections.length - 1
      ? chapterSections[currentIndex + 1]
      : null;

  return (
    <div className={styles.container}>
      <nav className={styles.breadcrumb}>
        <Link href={`/constitution/${slug}`} className={styles.backLink} aria-label="Back">
          &larr;
        </Link>
        <Link href="/" className={styles.breadcrumbLink}>
          Constitution
        </Link>
        <span className={styles.breadcrumbSep}>/</span>
        <Link
          href={`/constitution/${slug}`}
          className={styles.breadcrumbLink}
        >
          {chapter.title}
        </Link>
        <span className={styles.breadcrumbSep}>/</span>
        <span className={styles.breadcrumbCurrent}>s {sNum}</span>
      </nav>

      <article className={styles.article}>
        <header className={styles.sectionHeader}>
          <div className={styles.sectionMeta}>
            <span className={styles.sectionLabel}>Section {sNum}</span>
            <BookmarkButton sectionId={sectionId} title={section.title} />
          </div>
          <h1 className={styles.sectionTitle}>{section.title}</h1>
        </header>

        <div className={styles.sectionContent}>
          {section.content.split("\n\n").map((paragraph, i) => (
            <p key={i}>{paragraph}</p>
          ))}
        </div>

        {section.notes && (
          <div className={styles.amendmentNote}>
            <span className={styles.noteLabel}>Note</span>
            <p>{section.notes}</p>
          </div>
        )}
      </article>

      {relatedCases.length > 0 && (
        <section className={styles.relatedSection}>
          <h3 className={styles.relatedHeading}>Related Cases</h3>
          <div className={styles.relatedList}>
            {relatedCases.map((c) => (
              <Link
                key={c.id}
                href={`/cases/${c.id}`}
                className={styles.relatedCard}
              >
                <span className={styles.yearBadge}>{c.year}</span>
                <span className={styles.relatedName}>
                  {c.shortName || c.name}
                </span>
                <span className={styles.relatedDesc}>{c.principle}</span>
              </Link>
            ))}
          </div>
        </section>
      )}

      {relatedReferendums.length > 0 && (
        <section className={styles.relatedSection}>
          <h3 className={styles.relatedHeading}>Related Referendums</h3>
          <div className={styles.relatedList}>
            {relatedReferendums.map((r) => (
              <Link
                key={r.id}
                href={`/referendums/${r.id}`}
                className={`${styles.relatedCard} ${
                  r.outcome === "carried"
                    ? styles.carried
                    : styles.defeated
                }`}
              >
                <span className={styles.yearBadge}>{r.year}</span>
                <span className={styles.relatedName}>{r.title}</span>
                <span className={styles.relatedDesc}>
                  {r.outcome === "carried" ? "Carried" : "Defeated"} —{" "}
                  {r.yesPercentage}% yes
                </span>
              </Link>
            ))}
          </div>
        </section>
      )}

      <nav className={styles.pagination}>
        {prevSection !== null ? (
          <Link
            href={`/constitution/${slug}/s${prevSection}`}
            className={styles.paginationLink}
          >
            <span className={styles.paginationArrow}>&larr;</span>
            <span>s {prevSection}</span>
          </Link>
        ) : (
          <span />
        )}
        {nextSection !== null ? (
          <Link
            href={`/constitution/${slug}/s${nextSection}`}
            className={styles.paginationLink}
          >
            <span>s {nextSection}</span>
            <span className={styles.paginationArrow}>&rarr;</span>
          </Link>
        ) : (
          <span />
        )}
      </nav>
    </div>
  );
}
