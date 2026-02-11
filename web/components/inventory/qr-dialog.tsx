'use client'

import { QRCodeCanvas } from 'qrcode.react'
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
} from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { QrCode, Download, Printer } from 'lucide-react'
import { InventoryItem } from '@/lib/supabase'
import { useRef } from 'react'

interface QRDialogProps {
    item: InventoryItem
    trigger?: React.ReactNode
}

export function QRDialog({ item, trigger }: QRDialogProps) {
    const qrRef = useRef<HTMLDivElement>(null)

    const qrValue = JSON.stringify({
        protocol: 'ligtas',
        version: '1.0',
        action: 'borrow',
        itemId: item.id,
        itemName: item.item_name
    })

    const handleDownload = () => {
        // Find the canvas element
        const canvas = qrRef.current?.querySelector('canvas')
        if (!canvas) return

        // Create a high-quality version for download
        const downloadCanvas = document.createElement('canvas')
        const size = 1000
        downloadCanvas.width = size
        downloadCanvas.height = size

        // We need to re-render the QR code at a larger size for high quality
        // But for simplicity, we can just grab the existing canvas data if it's large enough
        // or trigger a download of the current canvas.
        // To ensure the logo is there, we just use the rendered canvas directly.
        const pngFile = canvas.toDataURL('image/png')
        const downloadLink = document.createElement('a')
        downloadLink.download = `QR_${item.item_name.replace(/\s+/g, '_')}.png`
        downloadLink.href = pngFile
        downloadLink.click()
    }

    const handlePrint = () => {
        const canvas = qrRef.current?.querySelector('canvas')
        if (!canvas) return

        const imgData = canvas.toDataURL('image/png')
        const windowUrl = window.open('', '_blank')
        windowUrl?.document.write(`
            <html>
                <head>
                    <title>Print QR Label - ${item.item_name}</title>
                    <style>
                        body { display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100vh; font-family: sans-serif; margin: 0; }
                        .label { border: 2px solid #000; padding: 40px; text-align: center; border-radius: 20px; }
                        img { width: 300px; height: 300px; }
                        h1 { margin-top: 20px; font-size: 28px; color: #1e40af; }
                        p { margin: 5px 0; font-size: 18px; color: #4b5563; }
                        .brand { font-weight: bold; letter-spacing: 0.1em; color: #1e40af; }
                    </style>
                </head>
                <body>
                    <div class="label">
                        <img src="${imgData}" />
                        <h1 class="brand">LIGTAS SYSTEM</h1>
                        <p><strong>${item.item_name}</strong></p>
                        <p>Category: ${item.category}</p>
                        <p style="font-size: 12px; color: #9ca3af;">Internal ID: ${item.id}</p>
                    </div>
                    <script>
                        window.onload = function() {
                            window.print();
                            // window.close();
                        }
                    </script>
                </body>
            </html>
        `)
        windowUrl?.document.close()
    }

    return (
        <Dialog>
            <DialogTrigger asChild>
                {trigger || (
                    <Button variant="ghost" size="icon" className="h-8 w-8 text-purple-600 hover:text-purple-700 hover:bg-purple-50">
                        <QrCode className="h-4 w-4" />
                    </Button>
                )}
            </DialogTrigger>
            <DialogContent className="sm:max-w-md">
                <DialogHeader>
                    <DialogTitle>Item QR Code</DialogTitle>
                    <DialogDescription>
                        Scan this code with the LIGTAS mobile app to automatically borrow or return this item.
                    </DialogDescription>
                </DialogHeader>

                <div className="flex flex-col items-center justify-center space-y-6 py-6" ref={qrRef}>
                    <div className="p-4 bg-white rounded-2xl shadow-sm border border-gray-100">
                        <QRCodeCanvas
                            value={qrValue}
                            size={300} // Larger default size for better quality
                            level="H"
                            includeMargin={false}
                            imageSettings={{
                                src: "/ligtaslogo.png",
                                x: undefined,
                                y: undefined,
                                height: 60,
                                width: 60,
                                excavate: true,
                            }}
                        />
                    </div>

                    <div className="text-center">
                        <p className="font-bold text-lg text-gray-900">{item.item_name}</p>
                        <p className="text-sm text-gray-500">{item.category} • ID: ${item.id}</p>
                    </div>

                    <div className="flex gap-3 w-full pt-4">
                        <Button
                            variant="outline"
                            className="flex-1 gap-2 border-gray-200"
                            onClick={handleDownload}
                        >
                            <Download className="h-4 w-4" />
                            Download PNG
                        </Button>
                        <Button
                            className="flex-1 gap-2 bg-purple-600 hover:bg-purple-700 text-white shadow-md"
                            onClick={handlePrint}
                        >
                            <Printer className="h-4 w-4" />
                            Print Label
                        </Button>
                    </div>
                </div>
            </DialogContent>
        </Dialog>
    )
}
