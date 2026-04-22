"use client"

import { useEffect, useRef } from "react"
import { useRouter, usePathname } from "next/navigation"

/**
 * 🛰️ ResQTrack ADAPTIVE ROUTING SENTRY
 * Handles genuine viewport resizes only.
 * FIXED: No longer triggers router.replace on every navigation click.
 */
export function AdaptiveRoutingSentry() {
    const router = useRouter()
    const pathname = usePathname()
    // Store pathname in a ref so the resize listener always has the latest value
    // without needing to be re-registered on every navigation
    const pathnameRef = useRef(pathname)
    pathnameRef.current = pathname

    useEffect(() => {
        const redirectIfNeeded = (width: number) => {
            const currentPath = pathnameRef.current
            const isDesktopRoute = currentPath.startsWith('/dashboard')
            const isMobileRoute = currentPath.startsWith('/m')

            if (width < 1024 && isDesktopRoute) {
                const isSymmetrical =
                    currentPath.includes('/inventory') ||
                    currentPath.includes('/logs') ||
                    currentPath.includes('/approvals')

                const target = isSymmetrical
                    ? currentPath.replace('/dashboard', '/m')
                    : '/m'

                router.replace(target)
            } else if (width >= 1024 && isMobileRoute) {
                const target = currentPath.replace('/m', '/dashboard')
                router.replace(target)
            }
        }

        // Only check on actual resize events — not on every navigation
        const handleResize = () => redirectIfNeeded(window.innerWidth)

        window.addEventListener('resize', handleResize)
        return () => window.removeEventListener('resize', handleResize)

        // ✅ FIXED: Empty dep array — registers ONCE, reads latest pathname via ref
    }, [router])

    return null
}
