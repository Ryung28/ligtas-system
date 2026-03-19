import type { Metadata } from "next";
import { Inter, Outfit, Inter_Tight, JetBrains_Mono, Syne, DM_Sans } from "next/font/google"; // Added Syne and DM Sans
import { Toaster } from "sonner";
import "./globals.css";
import { AudioPermissionWrapper } from "@/components/audio-permission-wrapper";

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

const interTight = Inter_Tight({
    subsets: ["latin"],
    display: "swap",
    variable: "--font-inter-tight",
});

const jetbrainsMono = JetBrains_Mono({
    subsets: ["latin"],
    display: "swap",
    variable: "--font-jetbrains-mono",
});

const syne = Syne({
    subsets: ["latin"],
    display: "swap",
    variable: "--font-syne",
});

const dmSans = DM_Sans({
    subsets: ["latin"],
    display: "swap",
    variable: "--font-dm-sans",
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
        <html lang="en" className={`${inter.variable} ${outfit.variable} ${interTight.variable} ${jetbrainsMono.variable} ${syne.variable} ${dmSans.variable}`}>
            <body className={`${dmSans.className} font-sans antialiased bg-gray-50/50`}>
                <AudioPermissionWrapper>
                    {children}
                </AudioPermissionWrapper>
                <Toaster position="top-right" richColors closeButton />
            </body>
        </html>
    );
}
