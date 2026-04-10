"use client"

import Image from 'next/image'
import { Package, Grid, Camera, X, List, Loader2 } from 'lucide-react'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Checkbox } from '@/components/ui/checkbox'
import { Button } from '@/components/ui/button'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Tabs, TabsList, TabsTrigger } from '@/components/ui/tabs'

export function V2IdentityFields({
    name, onNameChange, categoryId, onCategoryChange, categories, isLoadingCategories,
    isSpecialVersion, onToggleSpecial, parentId, onParentChange, parentItems,
    itemType, onTypeChange, previewUrl, isUploading, onImageUpload, onRemoveImage, fileInputRef,
    variantLabel, onVariantLabelChange, customVariant, onCustomVariantChange
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
                            <TabsTrigger value="consumable" className="rounded-lg font-bold text-[11px] data-[state=active]:bg-white data-[state=active]:text-blue-600 uppercase">Supply</TabsTrigger>
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
                            <SelectTrigger className="h-11 rounded-2xl font-bold border-slate-200">
                                <SelectValue placeholder="Select type..." />
                            </SelectTrigger>
                            <SelectContent className="bg-white rounded-xl">
                                {categories.map((cat: any) => (
                                    <SelectItem key={cat.id} value={cat.id} className="font-bold py-3">{cat.category_name}</SelectItem>
                                ))}
                            </SelectContent>
                        </Select>
                    </div>

                    <div className="space-y-1.5">
                        <Label className="text-[10px] font-black text-slate-600 uppercase tracking-widest pl-1">Group with... (Optional)</Label>
                        <Select 
                            value={parentId || 'new'} 
                            onValueChange={(val) => {
                                onParentChange(val)
                                onToggleSpecial(val !== 'new')
                            }}
                        >
                            <SelectTrigger className="h-11 rounded-2xl font-bold border-slate-200 bg-slate-50/10"><SelectValue /></SelectTrigger>
                            <SelectContent className="bg-white rounded-xl shadow-2xl border-slate-100">
                                <SelectItem value="new" className="font-bold text-slate-400 italic">Standalone Item</SelectItem>
                                {parentItems.map((p: any) => <SelectItem key={p.id} value={p.id.toString()} className="font-bold">{p.item_name}</SelectItem>)}
                            </SelectContent>
                        </Select>
                    </div>
                </div>
            </div>

            {/* 3. Versioning (Managed Labels) */}
            {(parentId && parentId !== 'new') && (
                <div className="grid grid-cols-2 gap-4 animate-in slide-in-from-top-2">
                    <div className="space-y-1.5">
                        <div className="flex items-center justify-between px-1">
                            <Label className="text-[10px] font-black text-blue-600 uppercase tracking-widest">Property Label</Label>
                            <span className="text-[9px] font-bold text-blue-400 uppercase">Library</span>
                        </div>
                        <div className="flex gap-2">
                            <Select value={variantLabel} onValueChange={onVariantLabelChange}>
                                <SelectTrigger className="h-11 rounded-2xl font-bold border-blue-100 bg-blue-50/20 capitalize flex-1"><SelectValue /></SelectTrigger>
                                <SelectContent className="bg-white rounded-xl">
                                    <SelectItem value="size" className="font-bold">Size</SelectItem>
                                    <SelectItem value="color" className="font-bold">Color</SelectItem>
                                    <SelectItem value="voltage" className="font-bold">Voltage</SelectItem>
                                    <SelectItem value="custom" className="font-bold italic">Other...</SelectItem>
                                </SelectContent>
                            </Select>
                            <Button size="icon" variant="outline" className="h-11 w-11 rounded-2xl border-blue-100 flex-shrink-0 bg-blue-50/10">
                                <Grid className="h-4 w-4 text-blue-500" />
                            </Button>
                        </div>
                    </div>
                    {variantLabel === 'custom' && (
                        <div className="space-y-1.5 animate-in fade-in">
                            <Label className="text-[10px] font-black text-slate-600 uppercase tracking-widest pl-1">Custom Property</Label>
                            <Input 
                                value={customVariant} onChange={(e) => onCustomVariantChange(e.target.value)}
                                className="h-11 rounded-2xl font-bold border-slate-200" placeholder="e.g. Length" 
                            />
                        </div>
                    )}
                </div>
            )}
        </div>
    )
}
