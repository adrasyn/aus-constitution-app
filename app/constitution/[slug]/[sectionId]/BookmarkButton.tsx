"use client";

import { useState, useEffect } from "react";
import styles from "./page.module.css";

interface Props {
  sectionId: string;
  title: string;
}

interface Bookmark {
  id: string;
  type: "section" | "case" | "document";
  title: string;
  savedAt: string;
}

export default function BookmarkButton({ sectionId, title }: Props) {
  const [saved, setSaved] = useState(false);

  useEffect(() => {
    const bookmarks: Bookmark[] = JSON.parse(
      localStorage.getItem("bookmarks") || "[]"
    );
    setSaved(bookmarks.some((b) => b.id === sectionId));
  }, [sectionId]);

  function toggle() {
    const bookmarks: Bookmark[] = JSON.parse(
      localStorage.getItem("bookmarks") || "[]"
    );
    if (saved) {
      const filtered = bookmarks.filter((b) => b.id !== sectionId);
      localStorage.setItem("bookmarks", JSON.stringify(filtered));
      setSaved(false);
    } else {
      bookmarks.push({
        id: sectionId,
        type: "section",
        title,
        savedAt: new Date().toISOString(),
      });
      localStorage.setItem("bookmarks", JSON.stringify(bookmarks));
      setSaved(true);
    }
  }

  return (
    <button
      onClick={toggle}
      className={styles.bookmarkBtn}
      aria-label={saved ? "Remove bookmark" : "Bookmark this section"}
      title={saved ? "Remove bookmark" : "Bookmark this section"}
    >
      <svg
        width="20"
        height="20"
        viewBox="0 0 24 24"
        fill={saved ? "var(--color-accent-secondary)" : "none"}
        stroke={saved ? "var(--color-accent-secondary)" : "var(--color-text-secondary)"}
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      >
        <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
      </svg>
    </button>
  );
}
