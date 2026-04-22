import { Loader2, ImageIcon, UploadCloud, X } from 'lucide-react'
import Image from 'next/image'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'

interface ImageUploadZoneProps {
    previewUrl: string | null
    isUploading: boolean
    fileInputRef: React.RefObject<HTMLInputElement | null>
    onImageChange: (e: React.ChangeEvent<HTMLInputElement>) => void
    onRemoveImage: () => void
}

export function ImageUploadZone({
    previewUrl,
    isUploading,
    fileInputRef,
    onImageChange,
    onRemoveImage
}: ImageUploadZoneProps) {
    return (
        <div className="relative group rounded-xl border-2 border-gray-200 bg-gradient-to-br from-gray-50 to-gray-100/50 flex items-center justify-center overflow-hidden transition-all duration-300 aspect-[21/9] hover:border-blue-300 hover:shadow-lg hover:shadow-blue-100/50">
            {previewUrl ? (
                <>
                    <div className="absolute inset-0 bg-gray-100/50 backdrop-blur-sm" />
                    <Image
                        src={previewUrl}
                        alt="Preview"
                        fill
                        unoptimized
                        className="relative z-10 object-contain p-2 hover:scale-105 transition-transform duration-500 cursor-zoom-in"
                        onClick={() => window.open(previewUrl, '_blank')}
                    />
                    <div className="absolute inset-0 bg-gray-900/40 opacity-0 group-hover:opacity-100 transition-all flex items-center justify-center gap-2 backdrop-blur-[2px] z-20">
                        <Button 
                            type="button" 
                            variant="secondary" 
                            size="sm" 
                            onClick={() => fileInputRef.current?.click()} 
                            className="h-7 rounded-lg text-[10px] font-semibold bg-white/90 shadow-sm"
                        >
                            <UploadCloud className="w-3 h-3 mr-1" /> Change
                        </Button>
                        <Button 
                            type="button" 
                            variant="destructive" 
                            size="icon" 
                            onClick={onRemoveImage} 
                            className="h-7 w-7 rounded-lg shadow-sm"
                        >
                            <X className="w-3.5 h-3.5" />
                        </Button>
                    </div>
                    <div className="absolute bottom-2 right-2 z-30 opacity-0 group-hover:opacity-100 transition-opacity">
                        <Badge className="bg-white/90 text-gray-900 text-[8px] border-none font-bold py-0 h-4 shadow-sm">
                            Full Detail Available
                        </Badge>
                    </div>
                </>
            ) : (
                <div
                    className="flex flex-col items-center gap-2 text-gray-400 w-full h-full justify-center cursor-pointer hover:bg-gray-100/80 transition-all duration-300 group/upload"
                    onClick={() => fileInputRef.current?.click()}
                >
                    {isUploading ? (
                        <Loader2 className="w-6 h-6 animate-spin text-blue-500" />
                    ) : (
                        <ImageIcon className="w-6 h-6 opacity-30 group-hover/upload:text-blue-500 group-hover/upload:opacity-100 group-hover/upload:scale-110 transition-all duration-300" />
                    )}
                    <span className="text-[9px] font-black uppercase tracking-[0.2em] group-hover/upload:text-blue-600 transition-colors duration-300">
                        {isUploading ? 'Encoding...' : 'Attach Visual Reference'}
                    </span>
                </div>
            )}
            <input 
                type="file" 
                ref={fileInputRef} 
                onChange={onImageChange} 
                className="hidden" 
                accept="image/*" 
            />
        </div>
    )
}
