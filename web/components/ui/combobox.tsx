'use client'

import * as React from 'react'
import { Check, ChevronsUpDown, Search } from 'lucide-react'
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
                        'w-full justify-between rounded-lg border-gray-300',
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
                                            'mr-2 h-4 w-4',
                                            value === option.value ? 'opacity-100' : 'opacity-0'
                                        )}
                                    />
                                    <div className="flex flex-col">
                                        <span className="font-medium">{option.label}</span>
                                        {option.description && (
                                            <span className="text-xs text-gray-500">
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
