/**
 * Senior Dev Utility: Client-side Image Optimization
 * Reduces image size and compresses before upload to save Supabase storage (Free Tier)
 */
export async function optimizeImage(file: File, maxWidth = 1000, quality = 0.7): Promise<File> {
    return new Promise((resolve, reject) => {
        const reader = new FileReader()
        reader.readAsDataURL(file)
        reader.onload = (event) => {
            const img = new Image()
            img.src = event.target?.result as string
            img.onload = () => {
                const canvas = document.createElement('canvas')
                let width = img.width
                let height = img.height

                // Calculate dimensions while maintaining aspect ratio
                if (width > maxWidth) {
                    height = Math.round((height * maxWidth) / width)
                    width = maxWidth
                }

                canvas.width = width
                canvas.height = height

                const ctx = canvas.getContext('2d')
                if (!ctx) {
                    reject(new Error('Canvas Context Error'))
                    return
                }

                // High quality image smoothing
                ctx.imageSmoothingEnabled = true
                ctx.imageSmoothingQuality = 'high'
                ctx.drawImage(img, 0, 0, width, height)

                // Export to WebP (most efficient) or JPEG fallback
                canvas.toBlob(
                    (blob) => {
                        if (!blob) {
                            reject(new Error('Optimization Failed'))
                            return
                        }
                        const optimizedFile = new File([blob], file.name.replace(/\.[^/.]+$/, "") + ".webp", {
                            type: 'image/webp',
                            lastModified: Date.now(),
                        })
                        resolve(optimizedFile)
                    },
                    'image/webp',
                    quality
                )
            }
            img.onerror = (err) => reject(err)
        }
        reader.onerror = (err) => reject(err)
    })
}
