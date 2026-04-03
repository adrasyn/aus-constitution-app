import Link from "next/link";
import styles from "./not-found.module.css";

export default function NotFound() {
  return (
    <div className={styles.container}>
      <h1 className={styles.heading}>Section not found</h1>
      <Link href="/" className={styles.homeBtn}>
        Return home
      </Link>
      <div className={styles.searchHint}>
        <p>Or use the search to find what you&apos;re looking for.</p>
      </div>
    </div>
  );
}
