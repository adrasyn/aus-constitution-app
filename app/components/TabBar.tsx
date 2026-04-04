"use client";

import { usePathname } from "next/navigation";
import Link from "next/link";
import styles from "./TabBar.module.css";

const tabs = [
  { href: "/", label: "Constitution", icon: "/icons/constitution.svg" },
  { href: "/documents", label: "Documents", icon: "/icons/documents.svg" },
  { href: "/cases", label: "Cases", icon: "/icons/cases.svg" },
  { href: "/saved", label: "Saved", icon: "/icons/saved.svg" },
] as const;

export default function TabBar() {
  const pathname = usePathname();

  function isActive(href: string) {
    if (href === "/") return pathname === "/";
    return pathname.startsWith(href);
  }

  return (
    <nav className={`${styles.tabBar} glass`}>
      {tabs.map((tab) => {
        const active = isActive(tab.href);
        return (
          <Link
            key={tab.href}
            href={tab.href}
            className={`${styles.tab} ${active ? styles.active : ""}`}
          >
            <span
              className={styles.icon}
              style={{
                WebkitMaskImage: `url(${tab.icon})`,
                maskImage: `url(${tab.icon})`,
              }}
            />
            <span className={styles.label}>{tab.label}</span>
          </Link>
        );
      })}
    </nav>
  );
}
