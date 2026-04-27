/**
 * 🎨 ResQTrack Mobile Design Tokens
 *
 * Single source of truth for the `/m` PWA surface. Consume these class-strings
 * from components instead of hand-rolling `bg-red-600` / `rounded-2xl` etc.
 * Keeping this in a TS module (not just Tailwind config) lets us compose
 * variants and keep semantic intent ("danger", "surface") readable in JSX.
 *
 * Do NOT import this into desktop `/dashboard` code — mobile tokens are tuned
 * for touch density and small viewports.
 */

export const mColor = {
    // Brand / semantic
    brand: 'text-red-600',
    brandBg: 'bg-red-600',
    brandBgSoft: 'bg-red-50',
    brandBorder: 'border-red-600',
    brandRing: 'focus:ring-red-500/20',

    command: 'text-blue-900',
    commandBg: 'bg-blue-900',
    commandBgSoft: 'bg-blue-50',

    // Status
    success: 'text-emerald-600',
    successBg: 'bg-emerald-50',
    successBorder: 'border-emerald-200',

    warning: 'text-amber-600',
    warningBg: 'bg-amber-50',
    warningBorder: 'border-amber-200',

    danger: 'text-rose-600',
    dangerBg: 'bg-rose-50',
    dangerBorder: 'border-rose-200',

    info: 'text-blue-600',
    infoBg: 'bg-blue-50',
    infoBorder: 'border-blue-100',

    // Surfaces
    surface: 'bg-white',
    surfaceMuted: 'bg-gray-50/50',
    surfaceElevated: 'bg-white',
    surfaceInverse: 'bg-gray-900 text-white',

    // Text
    textPrimary: 'text-gray-900',
    textSecondary: 'text-gray-600',
    textMuted: 'text-gray-500',
    textSubtle: 'text-gray-400',
    textOnBrand: 'text-white',

    // Borders
    border: 'border-gray-100',
    borderStrong: 'border-gray-200',
    borderMuted: 'border-gray-50',
} as const

export const mRadius = {
    chip: 'rounded-xl',      // inputs, chips, small buttons
    card: 'rounded-2xl',     // cards, action tiles
    hero: 'rounded-3xl',     // hero panels, full-bleed banners
    pill: 'rounded-full',    // avatars, status dots
} as const

export const mElevation = {
    flat: '',
    card: 'shadow-sm',
    floating: 'shadow-md',
    sheet: 'shadow-xl',
    heroRed: 'shadow-lg shadow-red-200',
    heroBlue: 'shadow-xl shadow-blue-900/20',
} as const

export const mSpacing = {
    pagePad: 'p-4',
    sectionGap: 'space-y-6',
    stackGap: 'space-y-3',
    inlineGap: 'gap-3',
    touchTarget: 'min-h-[44px] min-w-[44px]',
} as const

export const mType = {
    // Eyebrow labels (uppercase small caps feel)
    eyebrow: 'text-[10px] font-bold uppercase tracking-widest',
    // Meta / helper
    meta: 'text-xs text-gray-500',
    // Body
    body: 'text-sm text-gray-700',
    bodyBold: 'text-sm font-semibold text-gray-900',
    // Titles
    titleSm: 'text-sm font-bold text-gray-900',
    titleMd: 'text-base font-bold text-gray-900',
    titleLg: 'text-lg font-bold text-gray-900',
    // Display (hero)
    display: 'font-display font-black italic uppercase tracking-tight',
} as const

export const mMotion = {
    // Respect reduced-motion users automatically via `motion-safe:`.
    pressScale: 'motion-safe:transition-transform motion-safe:active:scale-[0.98]',
    pressScaleTight: 'motion-safe:transition-transform motion-safe:active:scale-95',
    fadeIn: 'motion-safe:animate-in motion-safe:fade-in motion-safe:duration-300',
} as const

export const mFocus =
    'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-red-500/40 focus-visible:ring-offset-2 focus-visible:ring-offset-white'

/**
 * Role → visible navigation map. Source of truth for what each role can see
 * in the MoreSheet / nav. Keep in sync with middleware + dashboard layout.
 */
export type AppRole = 'admin' | 'staff' | 'viewer' | string

export const roleCan = {
    manageUsers: (role?: AppRole) => role === 'admin',
    viewReports: (role?: AppRole) => role === 'admin' || role === 'staff',
    manageInventory: (role?: AppRole) => role === 'admin' || role === 'staff',
    viewBorrowers: (role?: AppRole) => role === 'admin' || role === 'staff',
    useChat: (_role?: AppRole) => true,
}
