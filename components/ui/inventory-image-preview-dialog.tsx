'use client'

import Image from 'next/image'
import {
    Dialog as ShadinDialog,
    DialogContent as ShadinDialogContent,
    DialogHeader as ShadinDialogHeader,
    DialogTitle as ShadinDialogTitle
} from '@/components/ui/dialog'

interface InventoryImagePreviewDialogProps {
    image: { url: string; name: string } | null
    onOpenChange: (open: boolean) => void
}

export function InventoryImagePreviewDialog({ image, onOpenChange }: InventoryImagePreviewDialogProps) {
    return (
        <ShadinDialog open={!!image} onOpenChange={onOpenChange}>
            <ShadinDialogContent className="max-w-3xl border-none bg-black/95 p-0 overflow-hidden rounded-2xl shadow-2xl [&>button]:text-white [&>button]:opacity-100">
                <ShadinDialogHeader className="absolute top-4 left-4 z-50 pointer-events-none">
                    <ShadinDialogTitle className="text-white text-sm font-medium bg-black/60 backdrop-blur-md px-3 py-1.5 rounded-lg">
                        {image?.name}
                    </ShadinDialogTitle>
                </ShadinDialogHeader>
                <div className="relative w-full aspect-square md:aspect-video flex items-center justify-center p-8">
                    {image && (
                        <Image
                            src={image.url}
                            alt={image.name}
                            fill
                            unoptimized
                            className="object-contain rounded-lg animate-in zoom-in-95 duration-300"
                        />
                    )}
                </div>
            </ShadinDialogContent>
        </ShadinDialog>
    )
}
