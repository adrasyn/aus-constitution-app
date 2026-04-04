import Link from "next/link";
import documentsData from "@/content/documents/documents.json";
import styles from "./page.module.css";

export default function DocumentsPage() {
  const sortedDocs = [...documentsData].sort((a, b) => a.year - b.year);

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <h1 className={styles.title}>Documents</h1>
        <p className={styles.subtitle}>
          Historical documents and constitutional history
        </p>
      </div>

      <Link href="/referendums" className={styles.referendumBanner}>
        <span className={styles.bannerTitle}>Referendums</span>
        <span className={styles.bannerDesc}>
          All 44 constitutional referendum proposals (1906-2023)
        </span>
        <span className={styles.bannerArrow}>&rarr;</span>
      </Link>

      <div className={styles.docList}>
        {sortedDocs.map((doc) => (
          <Link
            key={doc.id}
            href={`/documents/${doc.id}`}
            className={styles.docCard}
          >
            <span className={styles.yearBadge}>{doc.year}</span>
            <h2 className={styles.docTitle}>{doc.title}</h2>
            <p className={styles.docDesc}>{doc.description}</p>
            {doc.relatedSections.length > 0 && (
              <div className={styles.sectionPills}>
                {doc.relatedSections.slice(0, 4).map((s) => (
                  <span key={s} className={styles.sectionPill}>
                    s {s}
                  </span>
                ))}
              </div>
            )}
          </Link>
        ))}
      </div>
    </div>
  );
}
