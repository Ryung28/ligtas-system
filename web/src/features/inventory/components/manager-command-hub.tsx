'use client'

import React, { useState } from 'react'
import { Plus, PackageSearch, CalendarRange, PackagePlus, Command } from 'lucide-react'
import { cn } from '@/lib/utils'
import { BottomSheet } from '@/components/mobile/primitives/bottom-sheet'
import { mFocus } from '@/lib/mobile/tokens'
import { BatchMode } from '../types'

interface ManagerCommandHubProps {
    mode: BatchMode
    onModeChange: (mode: BatchMode) => void
    onAdd: () => void
    disabled?: boolean
}

export function ManagerCommandHub({ mode, onModeChange, onAdd, disabled }: ManagerCommandHubProps) {
    const [open, setOpen] = useState(false)

    const actions = [
        {
            id: 'borrow',
            label: 'Hand Borrow',
            description: 'Immediate physical issue',
            icon: PackageSearch,
            color: 'text-blue-600',
            bgColor: 'bg-blue-50',
            borderColor: 'border-blue-100',
            onClick: () => {
                onModeChange('borrow')
                setOpen(false)
            }
        },
        {
            id: 'reserve',
            label: 'Reserve Gear',
            description: 'Stage for future pickup',
            icon: CalendarRange,
            color: 'text-amber-600',
            bgColor: 'bg-amber-50',
            borderColor: 'border-amber-100',
            onClick: () => {
                onModeChange('reserve')
                setOpen(false)
            }
        },
        {
            id: 'add',
            label: 'Register Item',
            description: 'Add new asset to ledger',
            icon: PackagePlus,
            color: 'text-emerald-600',
            bgColor: 'bg-emerald-50',
            borderColor: 'border-emerald-100',
            onClick: () => {
                onAdd()
                setOpen(false)
            }
        }
    ]

    return (
        <>
            <button
                type="button"
                onClick={() => setOpen(true)}
                disabled={disabled}
                className={cn(
                    'fixed right-4 z-40',
                    'bottom-[calc(72px+env(safe-area-inset-bottom)+16px)]',
                    'h-14 w-14 rounded-full bg-slate-950 text-white shadow-xl shadow-slate-900/40',
                    'flex items-center justify-center p-0 transition-all active:scale-90 disabled:opacity-50',
                    mFocus
                )}
                aria-label="Logistics Command Hub"
            >
                <Plus className="w-6 h-6" aria-hidden />
            </button>

            <BottomSheet
                open={open}
                onOpenChange={setOpen}
                title="Command Hub"
                description="Tactical logistics & inventory management"
                className="[&_h2]:text-[19px] [&_p]:text-[15px] [&_h2]:tracking-tight [&_p]:leading-relaxed"
            >
                <div className="grid grid-cols-1 gap-3 py-2">
                    {actions.map((action) => (
                        <button
                            key={action.id}
                            onClick={action.onClick}
                            className={cn(
                                "flex items-center gap-4 p-4 rounded-2xl border bg-white transition-all active:scale-[0.98]",
                                "hover:border-gray-300 shadow-sm"
                            )}
                        >
                            <div className={cn(
                                "w-12 h-12 rounded-xl flex items-center justify-center shrink-0 border",
                                action.bgColor,
                                action.borderColor
                            )}>
                                <action.icon className={cn("w-6 h-6", action.color)} />
                            </div>
                            <div className="flex-1 text-left">
                                <h4 className="font-bold text-gray-900 text-sm">{action.label}</h4>
                                <p className="text-xs text-gray-500">{action.description}</p>
                            </div>
                        </button>
                    ))}
                </div>
            </BottomSheet>
        </>
    )
}
