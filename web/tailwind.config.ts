import type { Config } from "tailwindcss"

const config = {
    darkMode: ["class"],
    content: [
        './pages/**/*.{ts,tsx}',
        './components/**/*.{ts,tsx}',
        './app/**/*.{ts,tsx}',
        './src/**/*.{ts,tsx}',
    ],
    prefix: "",
    theme: {
        container: {
            center: true,
            padding: {
                DEFAULT: '1rem',
                sm: '1.5rem',
                md: '2rem',
                lg: '3rem',
                xl: '4rem',
                '2xl': '5rem',
            },
            screens: {
                sm: '640px',
                md: '768px',
                lg: '1024px',
                xl: '1280px',
                '2xl': '1536px',
                '3xl': '1920px',
            },
        },
        // Custom breakpoints for precise responsive control
        screens: {
            'xs': '475px',     // Small phones
            'sm': '640px',     // Large phones
            'md': '768px',     // Tablets
            'lg': '1024px',    // 13" laptops (MacBook Air)
            '14in': '1366px',  // 14" laptops (MOST COMMON - 1366x768)
            'xl': '1440px',    // 15" laptops (1440x900)
            '2xl': '1680px',   // Large laptops / Small monitors
            '3xl': '1920px',   // Full HD monitors (24"+)
            '4xl': '2560px',   // 2K/QHD monitors (27"+)
        },
        extend: {
            fontFamily: {
                sans: ['var(--font-inter)', 'Inter', 'system-ui', '-apple-system', 'sans-serif'],
                heading: ['var(--font-outfit)', 'sans-serif'],
            },
            // Fluid typography that scales with viewport
            fontSize: {
                // Format: [fontSize, { lineHeight, letterSpacing }]
                // Using clamp for fluid scaling between breakpoints
                'xs': ['clamp(0.625rem, 0.6rem + 0.125vw, 0.75rem)', { lineHeight: '1rem' }],
                'sm': ['clamp(0.75rem, 0.7rem + 0.25vw, 0.875rem)', { lineHeight: '1.25rem' }],
                'base': ['clamp(0.875rem, 0.8rem + 0.375vw, 1rem)', { lineHeight: '1.5rem' }],
                'lg': ['clamp(1rem, 0.95rem + 0.25vw, 1.125rem)', { lineHeight: '1.75rem' }],
                'xl': ['clamp(1.125rem, 1rem + 0.625vw, 1.25rem)', { lineHeight: '1.75rem' }],
                '2xl': ['clamp(1.25rem, 1.1rem + 0.75vw, 1.5rem)', { lineHeight: '2rem' }],
                '3xl': ['clamp(1.5rem, 1.3rem + 1vw, 1.875rem)', { lineHeight: '2.25rem' }],
                '4xl': ['clamp(1.875rem, 1.6rem + 1.375vw, 2.25rem)', { lineHeight: '2.5rem' }],
            },
            // Responsive spacing scale
            spacing: {
                'safe-top': 'env(safe-area-inset-top)',
                'safe-bottom': 'env(safe-area-inset-bottom)',
                'safe-left': 'env(safe-area-inset-left)',
                'safe-right': 'env(safe-area-inset-right)',
            },
            colors: {
                border: "hsl(var(--border))",
                input: "hsl(var(--input))",
                ring: "hsl(var(--ring))",
                background: "hsl(var(--background))",
                foreground: "hsl(var(--foreground))",
                primary: {
                    DEFAULT: "hsl(var(--primary))",
                    foreground: "hsl(var(--primary-foreground))",
                },
                secondary: {
                    DEFAULT: "hsl(var(--secondary))",
                    foreground: "hsl(var(--secondary-foreground))",
                },
                destructive: {
                    DEFAULT: "hsl(var(--destructive))",
                    foreground: "hsl(var(--destructive-foreground))",
                },
                muted: {
                    DEFAULT: "hsl(var(--muted))",
                    foreground: "hsl(var(--muted-foreground))",
                },
                accent: {
                    DEFAULT: "hsl(var(--accent))",
                    foreground: "hsl(var(--accent-foreground))",
                },
                popover: {
                    DEFAULT: "hsl(var(--popover))",
                    foreground: "hsl(var(--popover-foreground))",
                },
                card: {
                    DEFAULT: "hsl(var(--card))",
                    foreground: "hsl(var(--card-foreground))",
                },
            },
            borderRadius: {
                lg: "var(--radius)",
                md: "calc(var(--radius) - 2px)",
                sm: "calc(var(--radius) - 4px)",
            },
            keyframes: {
                "accordion-down": {
                    from: { height: "0" },
                    to: { height: "var(--radix-accordion-content-height)" },
                },
                "accordion-up": {
                    from: { height: "var(--radix-accordion-content-height)" },
                    to: { height: "0" },
                },
                "gradient": {
                    "0%, 100%": {
                        "background-size": "200% 200%",
                        "background-position": "left center"
                    },
                    "50%": {
                        "background-size": "200% 200%",
                        "background-position": "right center"
                    },
                },
            },
            animation: {
                "accordion-down": "accordion-down 0.2s ease-out",
                "accordion-up": "accordion-up 0.2s ease-out",
                "gradient": "gradient 3s ease infinite",
            },
        },
    },
    plugins: [require("tailwindcss-animate")],
} satisfies Config

export default config
