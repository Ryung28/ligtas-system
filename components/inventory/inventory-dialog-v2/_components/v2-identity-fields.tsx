"use client"

import Image from 'next/image'
import { Package, LayoutGrid, Camera, X, Loader2 } from 'lucide-react'
import { resolveCategoryIcon } from '@/lib/category-icons'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Checkbox } from '@/components/ui/checkbox'
import { Button } from '@/components/ui/button'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Tabs, TabsList, TabsTrigger } from '@/components/ui/tabs'

export function V2IdentityFields({
    name, onNameChange, categoryId, onCategoryChange, categories, isLoadingCategories,
    itemType, onTypeChange, previewUrl, isUploading, onImageUpload, onRemoveImage, fileInputRef
}: any) {
    return (
        <div className="space-y-6 px-1">
            {/* 1. Class & Photo */}
            <div className="flex items-center gap-6">
                <div className="relative group h-28 w-28 shrink-0 border-2 border-dashed border-slate-200 rounded-3xl flex items-center justify-center overflow-hidden bg-slate-50">
                    {previewUrl ? (
                        <>
                            <Image 
                                src={previewUrl} 
                                fill
                                className="object-cover" 
                                alt="Asset Preview" 
                            />
                            <Button size="icon" variant="destructive" onClick={onRemoveImage} className="absolute top-1 right-1 h-6 w-6 rounded-full opacity-0 group-hover:opacity-100 transition-opacity z-10">
                                <X className="h-3 w-3" />
                            </Button>
                        </>
                    ) : (
                        <button onClick={() => fileInputRef.current?.click()} className="flex flex-col items-center gap-1 text-slate-500 hover:text-blue-500 transition-colors">
                            {isUploading ? <Loader2 className="h-5 w-5 animate-spin" /> : <Camera className="h-5 w-5" />}
                            <span className="text-[9px] font-black uppercase tracking-tighter">Photo</span>
                        </button>
                    )}
                </div>
                <div className="flex-1 space-y-3">
                    <Label className="text-[10px] font-black text-slate-600 uppercase tracking-widest pl-1">What type of item?</Label>
                    <Tabs value={itemType} onValueChange={(v: any) => onTypeChange(v)} className="w-full">
                        <TabsList className="w-full grid grid-cols-2 rounded-2xl bg-slate-100 p-1 h-12">
                            <TabsTrigger value="equipment" className="rounded-lg font-bold text-[11px] data-[state=active]:bg-white data-[state=active]:text-blue-600 uppercase">Equipment</TabsTrigger>
                            <TabsTrigger value="consumable" className="rounded-lg font-bold text-[11px] data-[state=active]:bg-white data-[state=active]:text-blue-600 uppercase">Disposable</TabsTrigger>
                        </TabsList>
                    </Tabs>
                </div>
                <input type="file" ref={fileInputRef} onChange={onImageUpload} accept="image/*" className="hidden" />
            </div>

            {/* 2. Core Identity */}
            <div className="space-y-4">
                <div className="space-y-1.5">
                    <Label className="text-[10px] font-black text-slate-600 uppercase tracking-widest pl-1">Item Name</Label>
                    <div className="relative">
                        <Package className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
                        <Input value={name} onChange={(e) => onNameChange(e.target.value)} className="h-11 pl-11 rounded-2xl font-bold border-slate-200" placeholder="e.g. Motorola Radio" />
                    </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-1.5">
                        <Label className="text-[10px] font-black text-slate-600 uppercase tracking-widest pl-1">Category</Label>
                        <Select value={categoryId} onValueChange={onCategoryChange}>
                            <SelectTrigger className="h-11 rounded-2xl border-slate-200 font-bold">
                                <div className="flex min-w-0 flex-1 items-center gap-2">
                                    {isLoadingCategories ? (
                                        <Loader2 className="h-4 w-4 shrink-0 animate-spin text-blue-500" />
                                    ) : (
                                        !categoryId && (
                                            <LayoutGrid className="h-4 w-4 shrink-0 text-slate-400" strokeWidth={2} />
                                        )
                                    )}
                                    <SelectValue placeholder={isLoadingCategories ? 'Loading...' : 'Select type...'} />
                                </div>
                            </SelectTrigger>
                            <SelectContent className="rounded-xl bg-white">
                                {isLoadingCategories ? (
                                    <div className="flex items-center justify-center gap-2 py-6 text-sm font-bold text-slate-400">
                                        <Loader2 className="h-5 w-5 animate-spin" />
                                        Loading categories…
                                    </div>
                                ) : (
                                    categories.map((cat: { id: string; category_name: string }) => {
                                        const CatIcon = resolveCategoryIcon(cat.category_name)
                                        return (
                                            <SelectItem key={cat.id} value={cat.id} className="py-3 font-bold">
                                                <span className="flex items-center gap-2.5">
                                                    <CatIcon className="h-4 w-4 shrink-0 text-slate-500" strokeWidth={2} />
                                                    {cat.category_name}
                                                </span>
                                            </SelectItem>
                                        )
                                    })
                                )}
                            </SelectContent>
                        </Select>
                    </div>
                </div>
            </div>
        </div>
    )
}
