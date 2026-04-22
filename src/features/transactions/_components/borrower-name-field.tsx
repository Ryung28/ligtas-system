'use client'

import * as React from 'react'
import useSWR from 'swr'
import { Check, ChevronsUpDown, Loader2, Search } from 'lucide-react'

import { Input } from '@/components/ui/input'
import {
    Popover,
    PopoverContent,
    PopoverTrigger,
} from '@/components/ui/popover'
import { cn } from '@/lib/utils'
import { useDebounce } from '@/hooks/use-debounce'
import {
    fetchBorrowerData,
    type BorrowerStats,
} from '@/hooks/use-borrower-registry'

const LIMIT = 20

export interface BorrowerNameFieldProps {
    id: string
    name?: string
    value: string
    onChange: (name: string) => void
    disabled?: boolean
    dialogOpen: boolean
    className?: string
    manual?: boolean
    onManualChange?: (manual: boolean) => void
    onSelect?: (borrower: BorrowerStats) => void
}

const inputLikeTrigger =
    'flex h-11 w-full items-center justify-between rounded-lg border border-gray-300 bg-background px-3 text-sm shadow-inner ring-offset-background transition-all focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-zinc-900/10 focus-visible:border-zinc-900 disabled:cursor-not-allowed disabled:opacity-50'

export function BorrowerNameField({
    id,
    name = 'borrower_name',
    value,
    onChange,
    disabled,
    dialogOpen,
    className,
    manual: manualProp,
    onManualChange,
    onSelect,
}: BorrowerNameFieldProps) {
    const [pickerOpen, setPickerOpen] = React.useState(false)
    const [internalManual, setInternalManual] = React.useState(false)

    const controlledManual = typeof manualProp === 'boolean'
    const manual = controlledManual ? manualProp : internalManual

    const setManual = React.useCallback(
        (next: boolean) => {
            if (controlledManual) {
                onManualChange?.(next)
            } else {
                setInternalManual(next)
            }
        },
        [controlledManual, onManualChange]
    )
    const [query, setQuery] = React.useState('')
    const debouncedQuery = useDebounce(query, 220)

    const swrKey =
        manual || !dialogOpen
            ? null
            : `borrower-stats|${debouncedQuery}|1|${LIMIT}`

    const { data, isLoading } = useSWR(swrKey, fetchBorrowerData, {
        revalidateOnFocus: false,
        keepPreviousData: true,
    })

    const borrowers = data?.data ?? []

    React.useEffect(() => {
        if (!dialogOpen) {
            setManual(false)
            setPickerOpen(false)
            setQuery('')
        }
    }, [dialogOpen, setManual])

    const handleSelect = (b: BorrowerStats) => {
        onChange(b.borrower_name)
        onSelect?.(b)
        setPickerOpen(false)
        setQuery('')
    }

    if (manual) {
        return (
            <Input
                id={id}
                name={name}
                placeholder="Full name of borrower"
                required
                disabled={disabled}
                value={value}
                onChange={(e) => onChange(e.target.value)}
                className={cn('h-11 rounded-lg border-gray-300', className)}
                autoComplete="off"
            />
        )
    }

    // Hidden input + trigger must share one wrapper: `space-y-*` / flex gap on a parent
    // would treat the trigger as a "second sibling" and add top margin (registry looked
    // lower than manual, which used a single visible Input as first child).
    return (
        <div className={cn('w-full min-w-0', className)}>
            <div className="w-full">
                <input type="hidden" name={name} value={value} readOnly />
                <Popover open={pickerOpen} onOpenChange={setPickerOpen} modal>
                    <PopoverTrigger asChild>
                        <button type="button" id={id} role="combobox" aria-expanded={pickerOpen} disabled={disabled} className={cn(inputLikeTrigger, !value && 'text-muted-foreground')}>
                            <span className="truncate text-left font-normal">{value || 'Search borrower name…'}</span>
                            <ChevronsUpDown className="ml-2 h-4 w-4 shrink-0 opacity-50" />
                        </button>
                    </PopoverTrigger>
                    <PopoverContent className="w-[var(--radix-popover-trigger-width)] p-0" align="start" sideOffset={4}>
                        <div className="flex items-center border-b px-3">
                            <Search className="mr-2 h-4 w-4 shrink-0 opacity-50" />
                            <input placeholder="Type name…" value={query} onChange={(e) => setQuery(e.target.value)} className="flex h-10 w-full rounded-md bg-transparent py-3 text-sm outline-none placeholder:text-gray-500" autoComplete="off" />
                        </div>
                        <div className="max-h-[220px] overflow-y-auto p-1">
                            {isLoading ? (
                                <div className="flex items-center justify-center gap-2 py-8 text-sm text-gray-500">
                                    <Loader2 className="h-4 w-4 animate-spin" />
                                    Loading…
                                </div>
                            ) : borrowers.length === 0 ? (
                                <div className="px-3 py-8 text-center text-sm text-gray-500">No matches.</div>
                            ) : (
                                borrowers.map((b) => (
                                    <button key={`${b.borrower_user_id}-${b.borrower_name}`} type="button" onClick={() => handleSelect(b)} className={cn('relative flex w-full cursor-pointer select-none items-center rounded-sm px-2 py-2 text-left text-sm outline-none transition-colors hover:bg-accent hover:text-accent-foreground', value === b.borrower_name && 'bg-accent/50')}>
                                        <Check className={cn('mr-2 h-4 w-4 shrink-0', value === b.borrower_name ? 'opacity-100' : 'opacity-0')} />
                                        <div className="min-w-0 flex-1">
                                            <div className="truncate font-medium">{b.borrower_name}</div>
                                            <div className="truncate text-[10px] text-gray-500">{[b.borrower_email, `Active: ${b.active_items}`].filter(Boolean).join(' · ')}</div>
                                        </div>
                                    </button>
                                ))
                            )}
                        </div>
                    </PopoverContent>
                </Popover>
            </div>
        </div>
    )
}
