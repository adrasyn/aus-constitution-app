"use client";

import { useState } from "react";
import Link from "next/link";
import allCasesData from "@/content/cases/cases.json";
import styles from "./page.module.css";

interface CaseItem {
  id: string;
  name: string;
  shortName?: string;
  year: number;
  citation: string;
  principle: string;
  outcome: string;
  relatedSections: string[];
}

type SortMode = "year" | "name";

export default function CasesPage() {
  const [sortBy, setSortBy] = useState<SortMode>("year");
  const cases = allCasesData as CaseItem[];

  const sorted = [...cases].sort((a, b) => {
    if (sortBy === "year") return b.year - a.year;
    return (a.shortName || a.name).localeCompare(b.shortName || b.name);
  });

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <h1 className={styles.title}>Cases</h1>
        <p className={styles.subtitle}>Landmark constitutional decisions</p>
      </div>

      <div className={styles.controls}>
        <button
          className={`${styles.sortBtn} ${sortBy === "year" ? styles.active : ""}`}
          onClick={() => setSortBy("year")}
        >
          By Year
        </button>
        <button
          className={`${styles.sortBtn} ${sortBy === "name" ? styles.active : ""}`}
          onClick={() => setSortBy("name")}
        >
          By Name
        </button>
      </div>

      {sorted.length === 0 ? (
        <p className={styles.empty}>Case data is loading...</p>
      ) : (
        <div className={styles.caseList}>
          {sorted.map((c) => (
            <Link
              key={c.id}
              href={`/cases/${c.id}`}
              className={`${styles.caseCard} ${
                c.outcome === "dissent" ? styles.dissent : ""
              }`}
            >
              <div className={styles.caseHeader}>
                <span className={styles.yearBadge}>{c.year}</span>
                <div className={styles.sectionPills}>
                  {c.relatedSections.slice(0, 3).map((s) => (
                    <span key={s} className={styles.sectionPill}>
                      s {s}
                    </span>
                  ))}
                </div>
              </div>
              <h2 className={styles.caseName}>
                {c.shortName || c.name}
              </h2>
              <p className={styles.principle}>{c.principle}</p>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}
