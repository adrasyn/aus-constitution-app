"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import styles from "./page.module.css";

interface Bookmark {
  id: string;
  type: "section" | "case" | "document";
  title: string;
  savedAt: string;
}

export default function SavedPage() {
  const [bookmarks, setBookmarks] = useState<Bookmark[]>([]);

  useEffect(() => {
    const stored: Bookmark[] = JSON.parse(
      localStorage.getItem("bookmarks") || "[]"
    );
    setBookmarks(stored);
  }, []);

  function remove(id: string) {
    const updated = bookmarks.filter((b) => b.id !== id);
    localStorage.setItem("bookmarks", JSON.stringify(updated));
    setBookmarks(updated);
  }

  function getHref(bookmark: Bookmark): string {
    switch (bookmark.type) {
      case "section":
        return `/constitution/preamble/${bookmark.id}`;
      case "case":
        return `/cases/${bookmark.id}`;
      case "document":
        return `/documents/${bookmark.id}`;
      default:
        return "/";
    }
  }

  const sections = bookmarks.filter((b) => b.type === "section");
  const cases = bookmarks.filter((b) => b.type === "case");
  const documents = bookmarks.filter((b) => b.type === "document");
  const hasAny = bookmarks.length > 0;

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <h1 className={styles.title}>Saved</h1>
      </div>

      {!hasAny ? (
        <div className={styles.empty}>
          <svg
            width="48"
            height="48"
            viewBox="0 0 24 24"
            fill="none"
            stroke="var(--color-border)"
            strokeWidth="1"
            strokeLinecap="round"
            strokeLinejoin="round"
          >
            <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
          </svg>
          <p className={styles.emptyText}>No saved items yet</p>
          <p className={styles.emptyHint}>
            Tap the star icon on any section, case, or document to save it here
            for quick access.
          </p>
        </div>
      ) : (
        <div className={styles.groups}>
          {sections.length > 0 && (
            <div className={styles.group}>
              <h3 className={styles.groupTitle}>Sections</h3>
              {sections.map((b) => (
                <div key={b.id} className={styles.savedItem}>
                  <Link href={getHref(b)} className={styles.savedLink}>
                    <span className={styles.savedId}>{b.id}</span>
                    <span className={styles.savedTitle}>{b.title}</span>
                  </Link>
                  <button
                    onClick={() => remove(b.id)}
                    className={styles.removeBtn}
                    aria-label="Remove"
                  >
                    <svg
                      width="16"
                      height="16"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    >
                      <line x1="18" y1="6" x2="6" y2="18" />
                      <line x1="6" y1="6" x2="18" y2="18" />
                    </svg>
                  </button>
                </div>
              ))}
            </div>
          )}

          {cases.length > 0 && (
            <div className={styles.group}>
              <h3 className={styles.groupTitle}>Cases</h3>
              {cases.map((b) => (
                <div key={b.id} className={styles.savedItem}>
                  <Link href={getHref(b)} className={styles.savedLink}>
                    <span className={styles.savedTitle}>{b.title}</span>
                  </Link>
                  <button
                    onClick={() => remove(b.id)}
                    className={styles.removeBtn}
                    aria-label="Remove"
                  >
                    <svg
                      width="16"
                      height="16"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    >
                      <line x1="18" y1="6" x2="6" y2="18" />
                      <line x1="6" y1="6" x2="18" y2="18" />
                    </svg>
                  </button>
                </div>
              ))}
            </div>
          )}

          {documents.length > 0 && (
            <div className={styles.group}>
              <h3 className={styles.groupTitle}>Documents</h3>
              {documents.map((b) => (
                <div key={b.id} className={styles.savedItem}>
                  <Link href={getHref(b)} className={styles.savedLink}>
                    <span className={styles.savedTitle}>{b.title}</span>
                  </Link>
                  <button
                    onClick={() => remove(b.id)}
                    className={styles.removeBtn}
                    aria-label="Remove"
                  >
                    <svg
                      width="16"
                      height="16"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    >
                      <line x1="18" y1="6" x2="6" y2="18" />
                      <line x1="6" y1="6" x2="18" y2="18" />
                    </svg>
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
}
