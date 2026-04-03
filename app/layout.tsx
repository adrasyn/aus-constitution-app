import type { Metadata, Viewport } from "next";
import Script from "next/script";
import AppShell from "./components/AppShell";
import ErrorBoundary from "./components/ErrorBoundary";
import "./globals.css";

export const metadata: Metadata = {
  title: "Australian Constitution",
  description:
    "Browse the Australian Constitution, landmark cases, historical documents, and referendum history.",
  manifest: "/manifest.json",
  appleWebApp: {
    capable: true,
    statusBarStyle: "default",
    title: "Constitution",
  },
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
      <head>
        <link rel="apple-touch-icon" href="/icon-192.png" />
      </head>
      <body>
        <ErrorBoundary>
          <AppShell>{children}</AppShell>
        </ErrorBoundary>
        <Script
          id="sw-register"
          strategy="lazyOnload"
          dangerouslySetInnerHTML={{
            __html: `
              if ('serviceWorker' in navigator) {
                navigator.serviceWorker.register('/sw.js');
              }
            `,
          }}
        />
      </body>
    </html>
  );
}
