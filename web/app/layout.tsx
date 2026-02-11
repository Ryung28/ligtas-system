import type { Metadata } from "next";
import { Inter, Outfit } from "next/font/google"; // Added Outfit
import { Toaster } from "sonner";
import "./globals.css";

const inter = Inter({
    subsets: ["latin"],
    display: "swap",
    variable: "--font-inter",
});

const outfit = Outfit({
    subsets: ["latin"],
    display: "swap",
    variable: "--font-outfit",
});

export const metadata: Metadata = {
    title: "LIGTAS CDRRMO - Inventory Management System",
    description: "City Disaster Risk Reduction & Management Office Inventory System",
};

export default function RootLayout({
    children,
}: Readonly<{
    children: React.ReactNode;
}>) {
    return (
        <html lang="en" className={`${inter.variable} ${outfit.variable}`}>
            <body className={`${inter.className} font-sans antialiased bg-gray-50/50`}>
                {children}
                <Toaster position="top-right" richColors closeButton />
            </body>
        </html>
    );
}
