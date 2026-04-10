"use client"

import { useState, useMemo, useRef } from 'react'
import { createBrowserClient } from '@supabase/ssr'
import { toast } from 'sonner'
import { optimizeImage } from '@/lib/image-optimizer'

/**
 * LIGTAS V2 IMAGE HOOK
 * Handles asset photography, compression, and Supabase storage.
 */
export function useInventoryImageV2(initialUrl?: string) {
    const [isUploading, setIsUploading] = useState(false)
    const [previewUrl, setPreviewUrl] = useState<string | null>(initialUrl || null)
    const [storedPath, setStoredPath] = useState<string | null>(initialUrl || null)
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
            
            // Local preview
            const localUrl = URL.createObjectURL(optimized)
            setPreviewUrl(localUrl)

            const path = `items/${Math.random().toString(36).substring(7)}-${Date.now()}.webp`
            const { error: uploadError } = await supabase.storage.from('item-images').upload(path, optimized)
            if (uploadError) throw uploadError

            const { data } = await supabase.storage.from('item-images').createSignedUrl(path, 60 * 60 * 24)
            if (data?.signedUrl) {
                setPreviewUrl(data.signedUrl)
                setStoredPath(path)
                toast.success('Asset photo encoded')
            }
        } catch (err: any) {
            toast.error(`Photo Sync Failed: ${err.message}`)
            setPreviewUrl(initialUrl || null)
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
