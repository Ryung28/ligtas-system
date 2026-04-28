import { createBrowserClient } from '@supabase/ssr'

/**
 * 🛰️ TACTICAL BROWSER CLIENT
 * Factory for instantiating the Supabase client in Client Components.
 * Used exclusively for Realtime and Session management on the edge.
 */
export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name: string) {
          if (typeof document === 'undefined') return undefined
          const cookie = document.cookie
            .split('; ')
            .find((row) => row.startsWith(`${name}=`))
            ?.split('=')[1]

          if (!cookie) return undefined
          
          // 🛡️ Factory Guard: De-poison corrupted session strings
          try {
            const decoded = decodeURIComponent(cookie)
            if (decoded.startsWith('{')) {
              return JSON.parse(decoded)
            }
            return decoded
          } catch {
            return cookie
          }
        },
        set(name: string, value: string, options: any) {
          if (typeof document === 'undefined') return
          let cookieString = `${name}=${encodeURIComponent(value)}`
          if (options.path) cookieString += `; path=${options.path}`
          if (options.maxAge) cookieString += `; max-age=${options.maxAge}`
          if (options.domain) cookieString += `; domain=${options.domain}`
          if (options.secure) cookieString += '; secure'
          if (options.sameSite) cookieString += `; samesite=${options.sameSite}`
          document.cookie = cookieString
        },
        remove(name: string, options: any) {
          if (typeof document === 'undefined') return
          document.cookie = `${name}=; path=${options.path || '/'}; expires=Thu, 01 Jan 1970 00:00:01 GMT`
        },
      },
    }
  )
}
