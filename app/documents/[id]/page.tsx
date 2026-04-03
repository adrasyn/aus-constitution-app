import Link from "next/link";
import { notFound } from "next/navigation";
import documentsData from "@/content/documents/documents.json";
import styles from "./page.module.css";

export function generateStaticParams() {
  return documentsData.map((d) => ({ id: d.id }));
}

export default async function DocumentDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const doc = documentsData.find((d) => d.id === id);
  if (!doc) return notFound();

  return (
    <div className={styles.container}>
      <nav className={styles.breadcrumb}>
        <Link href="/documents" className={styles.breadcrumbLink}>
          Documents
        </Link>
        <span className={styles.breadcrumbSep}>/</span>
        <span className={styles.breadcrumbCurrent}>{doc.title}</span>
      </nav>

      <article className={styles.article}>
        <span className={styles.yearBadge}>{doc.year}</span>
        <h1 className={styles.docTitle}>{doc.title}</h1>
        <p className={styles.description}>{doc.description}</p>

        <div className={styles.content}>
          {doc.content.split("\n\n").map((p, i) => (
            <p key={i}>{p}</p>
          ))}
        </div>

        {doc.relatedSections.length > 0 && (
          <div className={styles.relatedSection}>
            <h3 className={styles.relatedHeading}>Related Sections</h3>
            <div className={styles.sectionPills}>
              {doc.relatedSections.map((s) => (
                <Link key={s} href={`/constitution/preamble/s${s}`} className={styles.sectionPill}>
                  s {s}
                </Link>
              ))}
            </div>
          </div>
        )}
      </article>
    </div>
  );
}
