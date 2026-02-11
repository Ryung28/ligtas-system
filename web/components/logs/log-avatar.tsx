export function InitialsAvatar({ name }: { name: string }) {
    const initials = name
        .split(' ')
        .map(n => n[0])
        .slice(0, 2)
        .join('')
        .toUpperCase()

    const colors = [
        'bg-red-100 text-red-700',
        'bg-blue-100 text-blue-700',
        'bg-emerald-100 text-emerald-700',
        'bg-amber-100 text-amber-700',
        'bg-violet-100 text-violet-700',
        'bg-pink-100 text-pink-700'
    ]
    // Simple hash for consistent color
    const charCode = name.charCodeAt(0) || 0
    const colorClass = colors[charCode % colors.length]

    return (
        <div className={`h-9 w-9 shrink-0 rounded-full flex items-center justify-center text-xs font-bold ring-2 ring-white ${colorClass}`}>
            {initials}
        </div>
    )
}
