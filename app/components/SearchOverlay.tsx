"use client";

import { useState, useEffect, useRef, useCallback } from "react";
import { useRouter } from "next/navigation";
import { buildSearchIndex, search, SearchResult } from "@/lib/search";
import sectionsData from "@/content/constitution/sections.json";
import casesData from "@/content/cases/cases.json";
import documentsData from "@/content/documents/documents.json";
import referendumsData from "@/content/referendums/referendums.json";
import styles from "./SearchOverlay.module.css";

interface Props {
  isOpen: boolean;
  onClose: () => void;
}

const TYPE_LABELS: Record<string, string> = {
  section: "Constitution",
  case: "Cases",
  document: "Documents",
  referendum: "Referendums",
};

export default function SearchOverlay({ isOpen, onClose }: Props) {
  const [query, setQuery] = useState("");
  const [results, setResults] = useState<SearchResult[]>([]);
  const [indexBuilt, setIndexBuilt] = useState(false);
  const inputRef = useRef<HTMLInputElement>(null);
  const router = useRouter();

  // Build index on first open
  useEffect(() => {
    if (isOpen && !indexBuilt) {
      buildSearchIndex({
        sections: sectionsData as { number: number; title: string; content: string; chapter: number }[],
        cases: casesData as { id: string; name: string; shortName?: string; principle: string; content: string; year: number }[],
        documents: documentsData as { id: string; title: string; description: string; content: string; year: number }[],
        referendums: referendumsData as { id: string; title: string; question: string; content: string; year: number; outcome: string }[],
      });
      setIndexBuilt(true);
    }
  }, [isOpen, indexBuilt]);

  // Focus input on open
  useEffect(() => {
    if (isOpen) {
      setTimeout(() => inputRef.current?.focus(), 100);
    } else {
      setQuery("");
      setResults([]);
    }
  }, [isOpen]);

  // Close on Escape
  useEffect(() => {
    function onKeyDown(e: KeyboardEvent) {
      if (e.key === "Escape") onClose();
    }
    if (isOpen) {
      document.addEventListener("keydown", onKeyDown);
      return () => document.removeEventListener("keydown", onKeyDown);
    }
  }, [isOpen, onClose]);

  const handleSearch = useCallback(
    (q: string) => {
      setQuery(q);
      if (q.trim().length < 2) {
        setResults([]);
        return;
      }
      setResults(search(q.trim()));
    },
    []
  );

  function handleResultClick(result: SearchResult) {
    onClose();
    router.push(result.href);
  }

  // Group results by type
  const grouped = results.reduce<Record<string, SearchResult[]>>((acc, r) => {
    if (!acc[r.type]) acc[r.type] = [];
    acc[r.type].push(r);
    return acc;
  }, {});

  if (!isOpen) return null;

  return (
    <div className={styles.overlay} onClick={onClose}>
      <div className={`${styles.panel} glass`} onClick={(e) => e.stopPropagation()}>
        <div className={styles.inputWrapper}>
          <svg
            className={styles.searchIcon}
            width="18"
            height="18"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
          >
            <circle cx="11" cy="11" r="8" />
            <line x1="21" y1="21" x2="16.65" y2="16.65" />
          </svg>
          <input
            ref={inputRef}
            type="text"
            value={query}
            onChange={(e) => handleSearch(e.target.value)}
            placeholder="Search the Constitution, cases, and documents..."
            className={styles.input}
          />
          <button onClick={onClose} className={styles.closeBtn}>
            <kbd className={styles.kbd}>ESC</kbd>
          </button>
        </div>

        <div className={styles.results}>
          {query.length > 0 && results.length === 0 && query.length >= 2 && (
            <div className={styles.noResults}>
              <p>No results for &ldquo;{query}&rdquo;</p>
              <p className={styles.noResultsHint}>Try broader search terms</p>
            </div>
          )}

          {query.length > 0 && query.length < 2 && (
            <div className={styles.noResults}>
              <p className={styles.noResultsHint}>Type at least 2 characters to search</p>
            </div>
          )}

          {Object.entries(grouped).map(([type, items]) => (
            <div key={type} className={styles.group}>
              <h3 className={styles.groupTitle}>{TYPE_LABELS[type] || type}</h3>
              {items.map((result) => (
                <button
                  key={result.id}
                  className={styles.resultItem}
                  onClick={() => handleResultClick(result)}
                >
                  <div className={styles.resultHeader}>
                    <span className={styles.resultTitle}>{result.title}</span>
                    {result.meta && (
                      <span className={styles.resultMeta}>{result.meta}</span>
                    )}
                  </div>
                  <p className={styles.resultSnippet}>{result.snippet}</p>
                </button>
              ))}
            </div>
          ))}

          {query.length === 0 && (
            <div className={styles.empty}>
              Search the Constitution, cases, and historical documents
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
