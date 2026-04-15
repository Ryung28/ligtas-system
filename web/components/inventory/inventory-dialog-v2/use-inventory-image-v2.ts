"use client"

import { useState, useMemo, useRef } from 'react'
import { createBrowserClient } from '@supabase/ssr'
import { toast } from 'sonner'
import { optimizeImage } from '@/lib/image-optimizer'
import { getInventoryImageUrl } from '@/lib/supabase'

/**
 * LIGTAS V2 IMAGE HOOK
 * Handles asset photography, compression, and Supabase storage.
 * Optimized for "Path-Only" strategy to ensure single source of truth.
 */
export function useInventoryImageV2(initialValue?: string) {
    const [isUploading, setIsUploading] = useState(false)
    
    // Identity Lock: The storedPath is what goes into the DB (Relative Path)
    const [storedPath, setStoredPath] = useState<string | null>(initialValue || null)
    
    // Visual Proxy: The previewUrl is what the user sees
    const [previewUrl, setPreviewUrl] = useState<string | null>(getInventoryImageUrl(initialValue) || null)
    
    const fileInputRef = useRef<HTMLInputElement>(null)

    const supabase = useMemo(() => createBrowserClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    ), [])

    const handleUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0]
        if (!file) return

        try {
            setIsUploading(true)
            const optimized = await optimizeImage(file)
            
            // 🚀 Canonical Path Generation
            const fileName = `${Math.random().toString(36).substring(7)}-${Date.now()}.webp`
            const path = `items/${fileName}`
            
            // 🛡️ Strategic Upload: Committing to 'item-images' bucket
            const { error: uploadError } = await supabase.storage.from('item-images').upload(path, optimized)
            if (uploadError) throw uploadError

            // SUCCESS: Identity resolved to relative path
            setStoredPath(path)
            
            // UI Update: Resolve public CDN URL for preview
            const publicUrl = getInventoryImageUrl(path)
            setPreviewUrl(publicUrl)
            
            toast.success('Asset photo encoded and staged')
        } catch (err: any) {
            console.error('LIGTAS_PHOTO_SYNC_FAILURE:', err)
            toast.error(`Photo Sync Failed: ${err.message}`)
            setPreviewUrl(getInventoryImageUrl(initialValue) || null)
        } finally {
            setIsUploading(false)
        }
    }

    const removeImage = () => {
        setPreviewUrl(null)
        setStoredPath(null)
        if (fileInputRef.current) fileInputRef.current.value = ''
    }

    return { previewUrl, isUploading, storedPath, fileInputRef, handleUpload, removeImage }
}
