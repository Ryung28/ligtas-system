import { createBrowserClient } from '@supabase/ssr'

let client: ReturnType<typeof createBrowserClient> | null = null

/**
 * 🛰️ TACTICAL BROWSER CLIENT (SINGLETON)
 * 🛡️ SUPER SENIOR PROTOCOL: We cache the client instance to prevent
 * "Multiple GoTrueClient instances" warnings and auth session desync.
 */
export function createClient() {
  if (client) return client

  client = createBrowserClient(
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
          
          try {
            const decoded = decodeURIComponent(cookie)
            return decoded.startsWith('{') ? JSON.parse(decoded) : decoded
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
  return client
}
