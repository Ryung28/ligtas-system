'use client'

import { useRef, useState, useEffect } from 'react'
import { Button } from '@/components/ui/button'
import { FileText, Loader2 } from 'lucide-react'
import { InventoryItem } from '@/lib/supabase'
import { QRCodeSVG } from 'qrcode.react'
import { fetchInventory } from '@/lib/queries/inventory'
import { toast } from 'sonner'

interface InventoryPrintCatalogProps {
    items: InventoryItem[]
}

export function InventoryPrintCatalog({ items }: InventoryPrintCatalogProps) {
    const [isSyncing, setIsSyncing] = useState(false)
    const [syncItems, setSyncItems] = useState<InventoryItem[]>([])
    const [printWindow, setPrintWindow] = useState<Window | null>(null)
    const printRef = useRef<HTMLDivElement>(null)

    // SENIOR HANDSHAKE: Listen for sync completion to inject HTML
    useEffect(() => {
        if (!isSyncing && syncItems.length > 0 && printWindow) {
            const printContent = printRef.current?.innerHTML || ''
            
            printWindow.document.open()
            printWindow.document.write(`
                <!DOCTYPE html>
                <html>
                <head>
                    <title>ResQTrack Technical Catalog</title>
                    <style>
                        @media print {
                            @page { size: A4 landscape; margin: 10mm; }
                            body { -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }
                        }
                        
                        * { margin: 0; padding: 0; box-sizing: border-box; }
                        body { font-family: 'Inter', system-ui, -apple-system, sans-serif; background: white; color: #0f172a; padding: 5mm; }
                        
                        .catalog-header { 
                            text-align: center; 
                            margin-bottom: 8mm; 
                            border-bottom: 2px solid #0f172a; 
                            padding-bottom: 6mm; 
                            display: flex;
                            flex-direction: column;
                            align-items: center;
                        }
                        .branding-tag { 
                            font-size: 8pt; 
                            font-weight: 800; 
                            letter-spacing: 0.4em; 
                            color: #3b82f6; 
                            margin-bottom: 2mm; 
                            text-transform: uppercase;
                        }
                        .catalog-title { 
                            font-size: 28pt; 
                            font-weight: 950; 
                            letter-spacing: -0.04em;
                            text-transform: uppercase;
                            font-style: italic;
                            color: #0f172a;
                        }
                        .catalog-meta { 
                            font-size: 9pt; 
                            color: #64748b; 
                            margin-top: 2mm; 
                            font-weight: 600;
                            letter-spacing: 1px;
                        }
                        
                        .category-group { margin-bottom: 10mm; break-inside: auto; }
                        .category-label { 
                            font-size: 11pt; 
                            font-weight: 900; 
                            margin-bottom: 5mm; 
                            display: flex;
                            align-items: center;
                            gap: 4mm;
                            text-transform: uppercase;
                            letter-spacing: 2px;
                            color: #1e293b;
                        }
                        .category-label::after {
                            content: '';
                            flex: 1;
                            height: 2px;
                            background: #f1f5f9;
                        }
                        
                        /* Tactical Landscape Grid: 6-Column High-Density Layout */
                        .grid-container { 
                            display: grid; 
                            grid-template-columns: repeat(6, 1fr); 
                            gap: 3.5mm; 
                        }
                        
                        /* Restaurant Menu Aesthetic Card (Landscape Optimized) */
                        .menu-card { 
                            border: 1px solid #e2e8f0; 
                            padding: 12px; 
                            break-inside: avoid; 
                            display: flex; 
                            flex-direction: column; 
                            align-items: center; 
                            text-align: center;
                            background: white;
                            border-radius: 4px;
                        }
                        
                        .qr-frame { 
                            aspect-ratio: 1 / 1; 
                            width: 34mm; 
                            margin-bottom: 4mm; 
                            display: flex; 
                            align-items: center; 
                            justify-content: center;
                            background: #fff;
                        }
                        
                        .item-name-bold { 
                            font-size: 9.5pt; 
                            font-weight: 800; 
                            line-height: 1.1;
                            margin-bottom: 3mm; 
                            display: -webkit-box;
                            -webkit-line-clamp: 2;
                            -webkit-box-orient: vertical;
                            overflow: hidden;
                            height: 2.2em;
                            color: #1e293b;
                        }
                        
                        .serial-footer { 
                            font-size: 7pt; 
                            font-weight: 700; 
                            color: #64748b; 
                            font-family: 'JetBrains Mono', 'Courier New', monospace;
                            padding-top: 1.5mm;
                            border-top: 1px dashed #f1f5f9;
                            width: 100%;
                            text-transform: uppercase;
                        }
                    </style>
                </head>
                <body>
                    ${printContent}
                    <script>
                        window.onload = function() {
                            setTimeout(() => {
                                window.print();
                                window.close();
                            }, 800); // Sufficient buffer for QR render
                        }
                    </script>
                </body>
                </html>
            `)
            printWindow.document.close()
            setPrintWindow(null)
            setSyncItems([])
        }
    }, [isSyncing, syncItems, printWindow])

    const handlePrint = async () => {
        if (items.length === 0) {
            toast.error('No items to print.')
            return
        }

        // Open window immediately — must happen synchronously inside user gesture
        const win = window.open('', '_blank')
        if (!win) {
            toast.error('Please allow pop-ups to print the catalog.')
            return
        }

        win.document.write(`
            <html>
                <head><title>Preparing Catalog...</title></head>
                <body style="display:flex; flex-direction:column; align-items:center; justify-content:center; height:100vh; font-family:sans-serif; color:#64748b; background:#f8fafc;">
                    <div style="width:40px; height:40px; border:3px solid #f1f5f9; border-top-color:#3b82f6; border-radius:50%; animation:spin 1s linear infinite;"></div>
                    <p style="margin-top:16px; font-weight:600; letter-spacing:0.05em; font-size:14px;">FETCHING LIVE DATA...</p>
                    <style>@keyframes spin { to { transform: rotate(360deg); } }</style>
                </body>
            </html>
        `)

        setIsSyncing(true)
        setPrintWindow(win)

        try {
            // Point-in-time fresh fetch — bypasses the 30s SWR cache
            const freshItems = await fetchInventory()

            if ((freshItems as InventoryItem[]).length === 0) {
                win.close()
                setPrintWindow(null)
                setIsSyncing(false)
                toast.error('No inventory items found. Add items before printing.')
                return
            }

            setSyncItems(freshItems as InventoryItem[])
            setIsSyncing(false) // unblocks the useEffect handshake
        } catch (err) {
            console.error('[PrintCatalog] Fetch failed:', err)
            win.close()
            setPrintWindow(null)
            setIsSyncing(false)
            toast.error('Failed to fetch inventory data. Check your connection and try again.')
        }
    }

    // Group items for the hidden render
    const itemsByCategory = syncItems.reduce((acc: Record<string, InventoryItem[]>, item: InventoryItem) => {
        const category = item.category || 'Uncategorized'
        if (!acc[category]) acc[category] = []
        acc[category].push(item)
        return acc
    }, {})

    const sortedCategories = Object.keys(itemsByCategory).sort()

    return (
        <>
            <Button
                onClick={handlePrint}
                variant="outline"
                size="sm"
                disabled={items.length === 0 || isSyncing}
                className="h-9 border-gray-200 text-gray-700 hover:bg-gray-50 text-[13px] font-medium transition-colors rounded-lg px-3 disabled:opacity-50 disabled:cursor-not-allowed"
            >
                {isSyncing ? (
                    <Loader2 className="h-3.5 w-3.5 mr-1.5 animate-spin" />
                ) : (
                    <FileText className="h-3.5 w-3.5 mr-1.5" />
                )}
                {isSyncing ? 'Building Gallery...' : 'Print Catalog'}
            </Button>

            {/* Hidden content used for print capture */}
            <div ref={printRef} style={{ display: 'none' }}>
                <div className="catalog-header">
                    <div className="branding-tag">ResQTrack RESOURCE MANAGEMENT</div>
                    <div className="catalog-title">Horizontal Catalog Grid</div>
                    <div className="catalog-meta">
                        OFFICIAL EQUIPMENT MANIFEST • ${new Date().toLocaleDateString('en-US', {
                            year: 'numeric', month: 'long', day: 'numeric'
                        })}
                    </div>
                </div>

                {sortedCategories.map(category => (
                    <div key={category} className="category-group">
                        <div className="category-label">{category}</div>
                        <div className="grid-container">
                            {itemsByCategory[category].map((item: InventoryItem) => (
                                <div key={item.id} className="menu-card">
                                    {/* Top: QR Code with Precision Tactical Containment */}
                                    <div className="qr-frame">
                                        <QRCodeSVG
                                            value={JSON.stringify({
                                                protocol: 'resqtrack',
                                                version: '1.0',
                                                action: 'view',
                                                itemId: item.id,
                                                itemName: item.item_name
                                            })}
                                            size={110}
                                            level="H"
                                            includeMargin={false}
                                        />
                                    </div>

                                    {/* Middle: Equipment Name (Bold/Large) */}
                                    <div className="item-name-bold">{item.item_name}</div>

                                    {/* Bottom: Serial Number */}
                                    <div className="serial-footer">
                                        {item.serial_number || `REF-${item.id.toString().padStart(4, '0')}`}
                                    </div>
                                </div>
                            ))}
                        </div>
                    </div>
                ))}
            </div>
        </>
    )
}
