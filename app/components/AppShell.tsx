"use client";

import Header from "./Header";
import TabBar from "./TabBar";
import styles from "./AppShell.module.css";

export default function AppShell({ children }: { children: React.ReactNode }) {
  return (
    <div className={styles.shell}>
      <Header />
      <main className={styles.main}>{children}</main>
      <TabBar />
    </div>
  );
}
