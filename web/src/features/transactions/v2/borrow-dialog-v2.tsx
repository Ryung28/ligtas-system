'use client';

import { useState } from 'react';
import { ClipboardList, ShoppingCart, CheckCircle2, Package } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { 
    Dialog, 
    DialogContent, 
    DialogDescription, 
    DialogHeader, 
    DialogTitle, 
    DialogTrigger 
} from '@/components/ui/dialog';
import { Combobox } from '@/components/ui/combobox';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';

// V2 Domain Architecture
import { useAvailableCatalog } from '../hooks/use-available-catalog';
import { useBorrowCart } from '../hooks/use-borrow-cart';
import { LogisticsPreviewCard } from '../_components/logistics-preview-card';
import { BorrowerIdentityForm, IdentityFormValues } from '../_components/borrower-identity-form';
import { createBatchBorrow } from '../api/transaction-repository';
import { toast } from 'sonner';
import { useCallback } from 'react';
import { cn } from '@/lib/utils';

/**
 * BorrowDialogV2 (The Orchestrator)
 * 
 * Pattern: Atomic Assembly
 * Constraints: Locked to 150 lines. Handles zero business logic internally.
 */
export function BorrowDialogV2() {
    const [open, setOpen] = useState(false);
    const { items, isLoading } = useAvailableCatalog(open);
    const { cart, addToCart, removeFromCart, clearCart, isEmpty } = useBorrowCart();
    
    // Selection state
    const [selectedId, setSelectedId] = useState<string>('');
    const [selectedVariantId, setSelectedVariantId] = useState<number | null>(null);
    const [qty, setQty] = useState(1);
    const [identity, setIdentity] = useState<IdentityFormValues | null>(null);

    // Stable handler to prevent Infinite Render Loops
    const handleIdentityChange = useCallback((values: IdentityFormValues) => {
        setIdentity(values);
    }, []);

    const activeItem = items.find(i => i.id.toString() === selectedId) || null;

    const handleConfirm = async () => {
        if (!identity || isEmpty) return;
        
        const logs = cart.map(c => {
            const isConsumable = c.item.item_type === 'consumable'
            return {
                inventory_id: c.item.id,
                inventory_variant_id: c.selectedVariantId || null,
                item_name: c.item.item_name,
                quantity: c.quantity,
                borrower_name: identity.borrower_name,
                borrower_contact: identity.contact_number,
                borrower_organization: identity.office_department,
                purpose: identity.purpose,
                released_by_name: identity.released_by,
                transaction_type: isConsumable ? 'dispense' : 'borrow',
                status: isConsumable ? 'dispensed' : 'borrowed'
            }
        });

        const result = await createBatchBorrow(logs);
        if (result.success) {
            toast.success(`LOGISTICS SYNC: Successfully dispatched ${cart.length} line items.`);
            setOpen(false);
            clearCart();
            setSelectedId('');
        } else {
            toast.error(result.error);
        }
    };

    return (
        <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
                <Button className="h-10 bg-blue-600 hover:bg-blue-700 text-white shadow-xl shadow-blue-600/20 text-xs font-semibold px-5 rounded-xl gap-2 transition-all active:scale-95">
                    <ClipboardList className="h-4 w-4" /> Dispatch V2
                </Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[700px] max-h-[90vh] overflow-y-auto border-none shadow-2xl">
                <DialogHeader>
                    <div className="flex items-center gap-2 mb-1">
                        <Package className="w-5 h-5 text-blue-600" />
                        <DialogTitle className="text-xl font-bold tracking-tight text-slate-900">EQUIPMENT DISPATCH</DialogTitle>
                    </div>
                    <DialogDescription className="text-slate-500 font-medium">Assign emergency resources to personnel and update operational registry.</DialogDescription>
                </DialogHeader>

                <div className="space-y-6 pt-4">
                    {/* Item Selection Section (The Selector) */}
                    <div className="bg-slate-50/80 rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
                        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 items-end p-4">
                            <div className="md:col-span-2 space-y-2">
                                <Label className="text-[10px] font-black uppercase tracking-widest text-slate-400 ml-1">Asset Search</Label>
                                <Combobox 
                                    options={items.map(i => ({ value: i.id.toString(), label: i.item_name, description: i.category }))}
                                    value={selectedId}
                                    onValueChange={(val) => {
                                        setSelectedId(val);
                                        setSelectedVariantId(null); // Reset variant on item change
                                    }}
                                    placeholder="Scan or search equipment..."
                                />
                            </div>
                            <div className="space-y-2">
                                <Label className="text-[10px] font-black uppercase tracking-widest text-slate-400 ml-1">Quantity</Label>
                                <Input type="number" value={qty} onChange={e => setQty(Number(e.target.value))} className="h-11 font-bold text-center" min={1} />
                            </div>
                            <Button 
                                onClick={() => {
                                    if (activeItem) {
                                        const vName = activeItem.variants?.find(v => v.id === selectedVariantId)?.storage_location || activeItem.storage_location || 'Primary';
                                        addToCart(activeItem, qty, selectedVariantId, vName);
                                    }
                                }} 
                                disabled={!activeItem} 
                                className="h-11 bg-slate-900 text-white hover:bg-slate-800 rounded-lg shadow-sm"
                            >
                                Queue Item
                            </Button>
                        </div>

                        {/* SITE SELECTOR (The Source Registry) */}
                        {activeItem && (
                            <div className="px-4 pb-4 border-t border-slate-100 pt-3 animate-in fade-in slide-in-from-top-1 bg-white/50">
                                <Label className="text-[9px] font-black uppercase tracking-widest text-slate-400 ml-1 mb-2 block">Source Registry</Label>
                                <div className="flex flex-wrap gap-2">
                                    {/* PRIMARY LOCATION */}
                                    <button 
                                        type="button"
                                        onClick={() => setSelectedVariantId(null)}
                                        className={cn(
                                            "px-4 py-2.5 rounded-xl text-[10px] font-bold border-2 transition-all flex flex-col items-start gap-0.5",
                                            selectedVariantId === null 
                                                ? "bg-blue-600 border-blue-600 text-white shadow-md shadow-blue-100" 
                                                : "bg-white border-slate-200 text-slate-600 hover:border-blue-300"
                                        )}
                                    >
                                        <span className="text-[12px] font-black">{activeItem.storage_location || 'Warehouse'}</span>
                                        <span className={cn("text-[9px] uppercase tracking-tighter opacity-70", selectedVariantId === null ? "text-blue-100" : "text-slate-400")}>
                                            Main Entry ({activeItem.primary_stock_available} Left)
                                        </span>
                                    </button>

                                    {/* VARIANT LOCATIONS */}
                                    {activeItem.variants?.map((v) => (
                                        <button
                                            key={v.id}
                                            type="button"
                                            onClick={() => setSelectedVariantId(v.id)}
                                            disabled={v.stock_available <= 0}
                                            className={cn(
                                                "px-4 py-2.5 rounded-xl text-[10px] font-bold border-2 transition-all flex flex-col items-start gap-0.5",
                                                selectedVariantId === v.id 
                                                    ? "bg-blue-600 border-blue-600 text-white shadow-md shadow-blue-100" 
                                                    : v.stock_available <= 0 
                                                        ? "bg-slate-50 border-slate-100 text-slate-300 cursor-not-allowed opacity-50"
                                                        : "bg-white border-slate-200 text-slate-600 hover:border-blue-300"
                                            )}
                                        >
                                            <span className="text-[12px] font-black">{v.storage_location}</span>
                                            <span className={cn("text-[9px] uppercase tracking-tighter opacity-70", selectedVariantId === v.id ? "text-blue-100" : "text-slate-400")}>
                                                Distributed ({v.stock_available} Left)
                                            </span>
                                        </button>
                                    ))}
                                </div>
                            </div>
                        )}
                    </div>

                    {/* LOGISTICS PREVIEW (The Discovery Card) */}
                    <LogisticsPreviewCard item={activeItem} isLoading={isLoading} />

                    {/* OPERATIONAL QUEUE (The Cart) */}
                    {!isEmpty && (
                        <div className="bg-blue-50/50 border border-blue-100/50 rounded-xl p-3 animate-in fade-in slide-in-from-bottom-2">
                           <div className="flex items-center gap-2 mb-2 px-1">
                                <ShoppingCart className="w-3 h-3 text-blue-600" />
                                <span className="text-[10px] font-black uppercase tracking-widest text-blue-800">Dispatch Queue ({cart.length})</span>
                           </div>
                           <div className="flex flex-wrap gap-2">
                                {cart.map(c => (
                                    <div key={c.item.id} className="bg-white border text-[10px] font-bold px-2 py-1.5 rounded-lg flex items-center gap-2 shadow-sm">
                                        <span className="text-blue-600 bg-blue-50 px-1 rounded">{c.quantity}x</span> {c.item.item_name}
                                        <button onClick={() => removeFromCart(c.item.id)} className="text-slate-300 hover:text-red-500 transition-colors">×</button>
                                    </div>
                                ))}
                           </div>
                        </div>
                    )}

                    {/* RESPONDER IDENTITY (Zod-Protected) */}
                    <BorrowerIdentityForm defaultValues={{}} onChange={handleIdentityChange} />

                    <Button onClick={handleConfirm} disabled={isEmpty || !identity} className="w-full h-14 bg-blue-600 hover:bg-blue-700 text-white rounded-2xl font-black uppercase tracking-widest shadow-xl shadow-blue-500/30 gap-3 text-sm transition-all hover:-translate-y-0.5 active:translate-y-0">
                        <CheckCircle2 className="w-5 h-5" /> Execute Dispatch
                    </Button>
                </div>
            </DialogContent>
        </Dialog>
    );
}
