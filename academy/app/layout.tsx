import type { Metadata } from "next";
import "./globals.css";
export const metadata: Metadata = { title: "KMAutos Academy | Automotive Diagnostics Training", description: "Learn automotive diagnostics, vehicle electronics and practical fault-finding with KMAutos Academy." };
export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="en"><body>{children}</body></html>;
}