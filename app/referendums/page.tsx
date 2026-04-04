"use client";

import { useState } from "react";
import Link from "next/link";
import allRefData from "@/content/referendums/referendums.json";
import { getSectionHref, formatSectionRef } from "@/lib/section-links";
import styles from "./page.module.css";

interface ReferendumItem {
  id: string;
  year: number;
  date?: string;
  title: string;
  question: string;
  outcome: string;
  yesPercentage: number;
  statesFor?: number;
  statesAgainst?: number;
  relatedSections: string[];
  content: string;
}

type Filter = "all" | "carried" | "defeated";

export default function ReferendumsPage() {
  const [filter, setFilter] = useState<Filter>("all");
  const referendums = allRefData as ReferendumItem[];

  const filtered =
    filter === "all"
      ? referendums
      : referendums.filter((r) => r.outcome === filter);

  const carried = referendums.filter((r) => r.outcome === "carried").length;
  const defeated = referendums.filter((r) => r.outcome === "defeated").length;

  return (
    <div className={styles.container}>
      <nav className={styles.breadcrumb}>
        <Link href="/documents" className={styles.breadcrumbLink}>
          Documents
        </Link>
        <span className={styles.breadcrumbSep}>/</span>
        <span className={styles.breadcrumbCurrent}>Referendums</span>
      </nav>

      <div className={styles.header}>
        <h1 className={styles.title}>Referendums</h1>
        <p className={styles.subtitle}>
          {referendums.length} proposals — {carried} carried, {defeated} defeated
        </p>
      </div>

      <div className={styles.filters}>
        <button
          className={`${styles.filterBtn} ${filter === "all" ? styles.active : ""}`}
          onClick={() => setFilter("all")}
        >
          All ({referendums.length})
        </button>
        <button
          className={`${styles.filterBtn} ${filter === "carried" ? styles.carriedActive : ""}`}
          onClick={() => setFilter("carried")}
        >
          Carried ({carried})
        </button>
        <button
          className={`${styles.filterBtn} ${filter === "defeated" ? styles.defeatedActive : ""}`}
          onClick={() => setFilter("defeated")}
        >
          Defeated ({defeated})
        </button>
      </div>

      {filtered.length === 0 ? (
        <p className={styles.empty}>Referendum data is loading...</p>
      ) : (
        <div className={styles.refList}>
          {filtered.map((r) => (
            <div
              key={r.id}
              className={`${styles.refCard} ${
                r.outcome === "carried" ? styles.carried : styles.defeated
              }`}
            >
              <div className={styles.refHeader}>
                <span className={styles.yearBadge}>{r.year}</span>
                <span
                  className={`${styles.outcomeBadge} ${
                    r.outcome === "carried"
                      ? styles.outcomeCarried
                      : styles.outcomeDefeated
                  }`}
                >
                  {r.outcome === "carried" ? "Carried" : "Defeated"}
                </span>
              </div>
              <h2 className={styles.refTitle}>{r.title}</h2>
              <p className={styles.refQuestion}>{r.question}</p>
              <div className={styles.refStats}>
                <span className={styles.stat}>
                  {r.yesPercentage}% yes
                </span>
                {r.statesFor !== undefined && (
                  <span className={styles.stat}>
                    {r.statesFor}/{(r.statesFor || 0) + (r.statesAgainst || 0)}{" "}
                    states
                  </span>
                )}
              </div>
              {r.relatedSections.length > 0 && (
                <div className={styles.sectionPills}>
                  {r.relatedSections.map((s) => (
                    <Link
                      key={s}
                      href={getSectionHref(s)}
                      className={styles.sectionPill}
                    >
                      {formatSectionRef(s)}
                    </Link>
                  ))}
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
