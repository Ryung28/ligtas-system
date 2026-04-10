'use client'

import React, { useState } from 'react'
import { Plus, LayoutGrid, Trash2 } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import {
    CommandDialog,
} from "@/components/ui/command"

interface CategoryManagerProps {
    onCategoryCreate: (name: string) => void
    onCategoryDelete: (name: string) => void
    allCategories: string[]
    items: any[]
}

export function CategoryManager({ onCategoryCreate, onCategoryDelete, allCategories = [], items = [] }: CategoryManagerProps) {
    const [open, setOpen] = useState(false)
    const [newCategoryName, setNewCategoryName] = useState('')

    return (
        <div className="flex items-center">
            <Button
                variant="outline"
                size="sm"
                onClick={() => setOpen(true)}
                className="h-10 px-3 bg-white border-zinc-200 text-gray-700 hover:bg-zinc-50 rounded-lg font-bold group border-dashed"
            >
                <Plus className="h-4 w-4 mr-1.5 text-blue-600 transition-transform group-hover:rotate-90" />
                Manage Categories
            </Button>

            <CommandDialog open={open} onOpenChange={setOpen}>
                <div className="p-0 border-b bg-zinc-50/50">
                    <div className="px-6 pt-6 pb-4">
                        <div className="flex items-center gap-3 mb-1">
                            <div className="h-8 w-8 rounded-lg bg-blue-600 flex items-center justify-center shadow-lg shadow-blue-200">
                                <LayoutGrid className="h-4 w-4 text-white" />
                            </div>
                            <h2 className="text-[14px] font-black tracking-tight text-zinc-900">
                                Inventory Categories
                            </h2>
                        </div>
                        <p className="text-[11px] text-zinc-400 font-medium ml-11">
                            Create new categories to organize your equipment.
                        </p>
                    </div>
                </div>

                <div className="p-6 space-y-8">
                    {/* Define New Category */}
                    <div className="space-y-3">
                        <h3 className="text-[11px] font-bold text-zinc-400 uppercase tracking-[0.15em] px-1">Define New Category</h3>
                        <div className="flex gap-2 p-1.5 bg-zinc-50 rounded-2xl border border-zinc-100 shadow-sm focus-within:ring-2 focus-within:ring-blue-100 transition-all">
                            <Input 
                                placeholder="e.g., Forensic Gear, Drone Tech..." 
                                value={newCategoryName}
                                onChange={(e) => setNewCategoryName(e.target.value)}
                                className="h-11 text-[14px] flex-1 bg-white border-zinc-200 rounded-xl font-medium focus-visible:ring-0"
                                onKeyDown={(e) => {
                                    if (e.key === 'Enter' && newCategoryName.trim()) {
                                        onCategoryCreate(newCategoryName.trim())
                                        setNewCategoryName('')
                                    }
                                }}
                            />
                            <Button 
                                onClick={() => {
                                    if (newCategoryName.trim()) {
                                        onCategoryCreate(newCategoryName.trim())
                                        setNewCategoryName('')
                                    }
                                }}
                                className="h-11 bg-zinc-900 hover:bg-black text-white px-6 font-bold rounded-xl shadow-lg shadow-zinc-200 active:scale-95 transition-all"
                            >
                                <Plus className="h-4 w-4 mr-1.5" />
                                Create
                            </Button>
                        </div>
                    </div>

                    {/* Active Categories List */}
                    <div className="space-y-4">
                        <div className="flex items-center justify-between px-1">
                            <h3 className="text-[11px] font-bold text-zinc-400 uppercase tracking-[0.15em]">Current Categories</h3>
                            <span className="text-[10px] font-bold text-zinc-300 bg-zinc-50 px-2 py-0.5 rounded-full uppercase italic">Master Registry</span>
                        </div>
                        <div className="grid grid-cols-1 gap-2 max-h-[320px] overflow-y-auto pr-2 custom-scrollbar">
                            {allCategories.map(cat => {
                                const count = items.filter(i => (i.category || 'Uncategorized') === cat).length
                                return (
                                    <div 
                                        key={cat} 
                                        className="flex items-center justify-between p-4 bg-white border border-zinc-100 rounded-2xl group hover:border-blue-100 hover:shadow-md hover:shadow-blue-50/50 transition-all cursor-default"
                                    >
                                        <div className="flex items-center gap-4">
                                            <div className="h-10 w-10 rounded-xl bg-zinc-50 border border-zinc-100 flex items-center justify-center text-zinc-400 group-hover:bg-blue-50 group-hover:text-blue-600 transition-colors">
                                                <LayoutGrid className="h-5 w-5" />
                                            </div>
                                            <div className="flex flex-col">
                                                <span className="font-black text-zinc-900 text-[15px] leading-none mb-1">{cat}</span>
                                                <span className="text-[11px] text-zinc-400 font-medium tracking-tight">
                                                    Contains <span className="text-zinc-600 font-bold">{count}</span> items
                                                </span>
                                            </div>
                                        </div>
                                        <Button 
                                            variant="ghost" 
                                            size="icon" 
                                            onClick={() => onCategoryDelete(cat)}
                                            className="h-10 w-10 text-zinc-300 hover:text-red-600 hover:bg-red-50 transition-all opacity-0 group-hover:opacity-100 rounded-xl border border-transparent hover:border-red-100"
                                        >
                                            <Trash2 className="h-5 w-5" />
                                        </Button>
                                    </div>
                                )
                            })}
                        </div>
                    </div>
                </div>
            </CommandDialog>
        </div>
    )
}
