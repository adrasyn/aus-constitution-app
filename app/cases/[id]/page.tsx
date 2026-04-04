import Link from "next/link";
import { notFound } from "next/navigation";
import allCasesData from "@/content/cases/cases.json";
import { getSectionHref, formatSectionRef } from "@/lib/section-links";
import styles from "./page.module.css";

interface CaseItem {
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

const cases = allCasesData as CaseItem[];

export function generateStaticParams() {
  return cases.map((c) => ({ id: c.id }));
}

export default async function CaseDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const caseItem = cases.find((c) => c.id === id);
  if (!caseItem) return notFound();

  const relatedCaseItems = cases.filter((c) =>
    caseItem.relatedCases?.includes(c.id)
  );

  return (
    <div className={styles.container}>
      <nav className={styles.breadcrumb}>
        <Link href="/cases" className={styles.backLink} aria-label="Back">
          &larr;
        </Link>
        <Link href="/cases" className={styles.breadcrumbLink}>
          Cases
        </Link>
        <span className={styles.breadcrumbSep}>/</span>
        <span className={styles.breadcrumbCurrent}>
          {caseItem.shortName || caseItem.name}
        </span>
      </nav>

      <article className={styles.article}>
        <span className={styles.yearBadge}>{caseItem.year}</span>
        <h1 className={styles.caseName}>{caseItem.name}</h1>
        <div className={styles.meta}>
          <span>{caseItem.court}</span>
          <span className={styles.citation}>{caseItem.citation}</span>
        </div>

        <div className={styles.principleBox}>
          <h3 className={styles.principleLabel}>Key Principle</h3>
          <p className={styles.principleText}>{caseItem.principle}</p>
        </div>

        <div className={styles.content}>
          {caseItem.content.split("\n\n").map((p, i) => (
            <p key={i}>{p}</p>
          ))}
        </div>

        {(caseItem as unknown as {sourceUrl?: string}).sourceUrl && (
          <a
            href={(caseItem as unknown as {sourceUrl: string}).sourceUrl}
            target="_blank"
            rel="noopener noreferrer"
            className={styles.sourceLink}
          >
            Read full judgment on AustLII &rarr;
          </a>
        )}

        {caseItem.relatedSections.length > 0 && (
          <div className={styles.relatedSection}>
            <h3 className={styles.relatedHeading}>
              Constitutional Sections
            </h3>
            <div className={styles.sectionPills}>
              {caseItem.relatedSections.map((s) => (
                <Link key={s} href={getSectionHref(s)} className={styles.sectionPill}>
                  {formatSectionRef(s)}
                </Link>
              ))}
            </div>
          </div>
        )}

        {relatedCaseItems.length > 0 && (
          <div className={styles.relatedSection}>
            <h3 className={styles.relatedHeading}>Related Cases</h3>
            <div className={styles.relatedList}>
              {relatedCaseItems.map((c) => (
                <Link key={c.id} href={`/cases/${c.id}`} className={styles.relatedCard}>
                  <span className={styles.relatedYear}>{c.year}</span>
                  <span className={styles.relatedName}>
                    {c.shortName || c.name}
                  </span>
                </Link>
              ))}
            </div>
          </div>
        )}
      </article>
    </div>
  );
}
