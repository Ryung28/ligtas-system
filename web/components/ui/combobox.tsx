'use client'

import * as React from 'react'
import { Check, ChevronsUpDown, Search, Package } from 'lucide-react'
import { cn } from '@/lib/utils'
import { Button } from '@/components/ui/button'

import {
    Popover,
    PopoverContent,
    PopoverTrigger,
} from '@/components/ui/popover'

export interface ComboboxOption {
    value: string
    label: string
    description?: string
    imageUrl?: string
    metadata?: Record<string, any>
}

interface ComboboxProps {
    options: ComboboxOption[]
    value?: string
    onValueChange: (value: string) => void
    placeholder?: string
    searchPlaceholder?: string
    emptyText?: string
    disabled?: boolean
    className?: string
    onSearchChange?: (query: string) => void
}

export function Combobox({
    options,
    value,
    onValueChange,
    placeholder = 'Select option...',
    searchPlaceholder = 'Search...',
    emptyText = 'No results found.',
    disabled = false,
    className,
    onSearchChange,
}: ComboboxProps) {
    const [open, setOpen] = React.useState(false)
    const [searchQuery, setSearchQuery] = React.useState('')

    // Notify parent of search changes
    React.useEffect(() => {
        onSearchChange?.(searchQuery)
    }, [searchQuery, onSearchChange])

    const selectedOption = React.useMemo(
        () => options.find((option) => option.value === value),
        [options, value]
    )

    const filteredOptions = React.useMemo(() => {
        if (!searchQuery) return options

        const query = searchQuery.toLowerCase()
        return options.filter(
            (option) =>
                option.label.toLowerCase().includes(query) ||
                option.description?.toLowerCase().includes(query)
        )
    }, [options, searchQuery])

    return (
        <Popover open={open} onOpenChange={setOpen} modal={true}>
            <PopoverTrigger asChild>
                <Button
                    variant="outline"
                    role="combobox"
                    type="button"
                    aria-expanded={open}
                    disabled={disabled}
                    className={cn(
                        'w-full h-11 justify-between rounded-lg border-slate-300 shadow-inner',
                        !selectedOption && 'text-gray-500',
                        className
                    )}
                >
                    <span className="truncate">
                        {selectedOption ? selectedOption.label : placeholder}
                    </span>
                    <ChevronsUpDown className="ml-2 h-4 w-4 shrink-0 opacity-50" />
                </Button>
            </PopoverTrigger>
            <PopoverContent
                className="w-[var(--radix-popover-trigger-width)] p-0"
                align="start"
                sideOffset={4}
            >
                <div className="flex flex-col">
                    {/* Search Input */}
                    <div className="flex items-center border-b px-3">
                        <Search className="mr-2 h-4 w-4 shrink-0 opacity-50" />
                        <input
                            placeholder={searchPlaceholder}
                            value={searchQuery}
                            onChange={(e) => setSearchQuery(e.target.value)}
                            className="flex h-10 w-full rounded-md bg-transparent py-3 text-sm outline-none placeholder:text-gray-500 disabled:cursor-not-allowed disabled:opacity-50"
                            autoComplete="off"
                        />
                    </div>

                    {/* Options List */}
                    <div className="max-h-[200px] overflow-y-auto p-1">
                        {filteredOptions.length === 0 ? (
                            <div className="py-6 text-center text-sm text-gray-500">
                                {emptyText}
                            </div>
                        ) : (
                            filteredOptions.map((option) => (
                                <div
                                    key={option.value}
                                    onClick={() => {
                                        onValueChange(option.value)
                                        setOpen(false)
                                        setSearchQuery('')
                                    }}
                                    className={cn(
                                        "relative flex cursor-pointer select-none items-center rounded-sm px-2 py-1.5 text-sm outline-none transition-colors hover:bg-accent hover:text-accent-foreground",
                                        value === option.value && "bg-accent/50"
                                    )}
                                >
                                    <Check
                                        className={cn(
                                            'mr-2 h-4 w-4 shrink-0',
                                            value === option.value ? 'opacity-100' : 'opacity-0'
                                        )}
                                    />
                                    
                                    {/* Equipment Thumbnail */}
                                    <div className="mr-3 h-10 w-10 shrink-0 overflow-hidden rounded-md border border-slate-200 bg-slate-50 flex items-center justify-center relative">
                                        <ImageWithFallback 
                                            src={option.imageUrl} 
                                            alt={option.label}
                                            fallback={<Package className="h-5 w-5 text-slate-300" />}
                                        />
                                    </div>

                                    <div className="flex flex-col min-w-0">
                                        <span className="font-medium truncate">{option.label}</span>
                                        {option.description && (
                                            <span className="text-[10px] text-gray-500 truncate">
                                                {option.description}
                                            </span>
                                        )}
                                    </div>
                                </div>
                            ))
                        )}
                    </div>
                </div>
            </PopoverContent>
        </Popover>
    )
}

function ImageWithFallback({ src, alt, fallback }: { src?: string, alt: string, fallback: React.ReactNode }) {
    const [error, setError] = React.useState(false)

    if (!src || error) {
        return <>{fallback}</>
    }

    return (
        <img
            src={src}
            alt={alt}
            loading="lazy"
            decoding="async"
            className="h-full w-full object-cover transition-opacity duration-300 ease-in-out"
            onError={() => setError(true)}
        />
    )
}
