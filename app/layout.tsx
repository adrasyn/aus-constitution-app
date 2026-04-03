import type { Metadata, Viewport } from "next";
import AppShell from "./components/AppShell";
import ErrorBoundary from "./components/ErrorBoundary";
import "./globals.css";

export const metadata: Metadata = {
  title: "Australian Constitution",
  description:
    "Browse the Australian Constitution, landmark cases, historical documents, and referendum history.",
};

export const viewport: Viewport = {
  themeColor: "#2E5A4A",
  width: "device-width",
  initialScale: 1,
  maximumScale: 1,
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>
        <ErrorBoundary>
          <AppShell>{children}</AppShell>
        </ErrorBoundary>
      </body>
    </html>
  );
}
