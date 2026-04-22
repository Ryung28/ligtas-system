'use client';

import { ReactNode, useEffect, useState, useTransition } from 'react';
import { 
    Loader2,
    Package,
    Maximize2,
    MapPin,
    UserCircle2,
    ClipboardCheck,
    Send,
    Wrench,
    Shield,
    Box,
    Cross
} from 'lucide-react';

import { Button } from '@/components/ui/button';
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
} from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import Image from 'next/image';
import { createClient } from '@/lib/supabase-browser';
import { getInventoryImageUrl } from '@/lib/supabase';
import { InventoryImagePreviewDialog } from '@/components/ui/inventory-image-preview-dialog';
import { useUser } from '@/providers/auth-provider';

// V3 API Bridge
import { releaseReservedItem } from '../actions/transaction.actions';
import { toast } from 'sonner';
import { cn } from '@/lib/utils';

interface HandoffCommandSheetProps {
    logId: number;
    itemName: string;
    borrowerName: string;
    quantity: number;
    inventoryId: number | null;
    borrowedFrom?: string | null;
    triggerLabel?: string;
    triggerClassName?: string;
    children?: ReactNode;
    onActionSuccess?: () => void;
}

export function HandoffCommandSheet({
    logId,
    itemName,
    borrowerName,
    quantity,
    inventoryId,
    borrowedFrom,
    triggerLabel,
    triggerClassName,
    children,
    onActionSuccess
}: HandoffCommandSheetProps) {
    const { user } = useUser();
    const [open, setOpen] = useState(false);
    const [isPending, startTransition] = useTransition();
    const [expandedImage, setExpandedImage] = useState<{ url: string; name: string } | null>(null);
    
    // Identity State
    const [releasedBy, setReleasedBy] = useState('Officer Name');
    const [receivedBy, setReceivedBy] = useState(borrowerName); // 🛡️ Audit State
    
    const [itemDetails, setItemDetails] = useState<{
        item_name?: string;
        category?: string;
        image_url?: string | null;
        storage_location?: string | null;
    } | null>(null);
    
    const imageUrl = getInventoryImageUrl(itemDetails?.image_url || null);

    useEffect(() => {
        if (!open) return;
        let active = true;

        const loadItemDetails = async () => {
            try {
                const supabase = createClient();
                if (inventoryId) {
                    const { data } = await supabase
                        .from('inventory')
                        .select('item_name, category, image_url, storage_location')
                        .eq('id', inventoryId)
                        .single();
                    if (active) {
                        setItemDetails(data || null);
                    }
                }
            } finally {}
        };

        loadItemDetails();

        return () => {
            active = false;
        };
    }, [open, inventoryId]);

    useEffect(() => {
        if (open) {
            setReceivedBy(borrowerName); // Sync on open so stale state never persists
        }
    }, [open, borrowerName]);

    useEffect(() => {
        if (!open) return;
        const fullName = user?.full_name || user?.user_metadata?.full_name || user?.email?.split('@')[0] || '';
        if (fullName && (!releasedBy || releasedBy === 'Officer Name')) {
            setReleasedBy(fullName);
        }
    }, [open, user, releasedBy]);

    const handleUseMyName = () => {
        const fullName = user?.full_name || user?.user_metadata?.full_name || user?.email?.split('@')[0];
        if (fullName) {
            setReleasedBy(fullName);
            return;
        }
        toast.error('Could not resolve your profile name.');
    };

    const getCategoryIcon = (category?: string | null) => {
        const cat = (category || '').toLowerCase();
        if (cat.includes('medical')) return Cross;
        if (cat.includes('tool')) return Wrench;
        if (cat.includes('rescue')) return Shield;
        if (cat.includes('ppe')) return Shield;
        return Box;
    };

    const handleHandoff = async (e: React.FormEvent) => {
        e.preventDefault();
        
        startTransition(async () => {
            const result = await releaseReservedItem(logId, { 
                handedBy: releasedBy, 
                physicallyReceivedBy: receivedBy 
            });
            if (result.success) {
                toast.success('Handoff confirmed.');
                setOpen(false);
                onActionSuccess?.();
            } else {
                toast.error(result.error || 'Failed to release item.');
            }
        });
    };

    return (
        <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
                {children || (
                    <Button
                        size="sm"
                        variant="outline"
                        className={cn(
                            "h-8 gap-2 text-amber-600 hover:text-amber-700 hover:bg-amber-50 border-amber-100 rounded-lg font-bold text-[10px] uppercase tracking-widest transition-all active:scale-95 shadow-sm",
                            triggerClassName
                        )}
                    >
                        <Package className="h-3.5 w-3.5" /> {triggerLabel || 'Release Item'}
                    </Button>
                )}
            </DialogTrigger>
            <DialogContent className="sm:max-w-[860px] p-0 border-none bg-white rounded-3xl overflow-hidden shadow-2xl">
                <form onSubmit={handleHandoff}>
                    <DialogHeader className="p-8 pb-4">
                        <DialogTitle className="text-2xl font-bold text-slate-900 flex items-center gap-2">
                            📦 Process Handoff
                        </DialogTitle>
                        <DialogDescription className="text-slate-500 font-medium pt-1">
                            Confirm the physical release of <strong>{itemName}</strong> to the requester.
                        </DialogDescription>
                    </DialogHeader>

                    <div className="px-8 pb-8 space-y-6">
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            {/* Left Summary Panel */}
                            <div className="bg-slate-50/70 p-6 rounded-2xl border border-slate-100 space-y-5">
                                <div className="flex items-center gap-2 pb-1 border-b border-slate-200/80">
                                    <Send className="h-4 w-4 text-amber-500" />
                                    <span className="text-[11px] font-black text-slate-600 uppercase tracking-widest">Release Info</span>
                                </div>

                                <div className="space-y-3">
                                    <div className="flex items-start gap-3">
                                        <button
                                            type="button"
                                            onClick={() => {
                                                if (imageUrl) setExpandedImage({ url: imageUrl, name: itemDetails?.item_name || itemName || 'Item' });
                                            }}
                                            className="h-20 w-20 rounded-xl border border-slate-200 bg-white overflow-hidden relative shrink-0 group"
                                        >
                                            {imageUrl ? (
                                                <>
                                                    <Image
                                                        src={imageUrl}
                                                        alt={itemDetails?.item_name || itemName || 'Item'}
                                                        fill
                                                        unoptimized
                                                        className="object-cover"
                                                    />
                                                    <span className="absolute bottom-1 right-1 rounded bg-black/60 p-1 text-white opacity-0 group-hover:opacity-100 transition-opacity">
                                                        <Maximize2 className="h-3 w-3" />
                                                    </span>
                                                </>
                                            ) : (
                                                <span className="h-full w-full flex items-center justify-center text-slate-400">
                                                    <Package className="h-6 w-6" />
                                                </span>
                                            )}
                                        </button>
                                        <div className="min-w-0">
                                            <span className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1 block">Equipment</span>
                                            <span className="text-sm font-bold text-slate-900 block truncate">
                                                {itemDetails?.item_name || itemName}
                                            </span>
                                            {(itemDetails?.category || 'Uncategorized') && (
                                                <span className="inline-flex items-center gap-1 text-xs text-slate-500 mt-0.5">
                                                    {(() => {
                                                        const CategoryIcon = getCategoryIcon(itemDetails?.category || 'Uncategorized');
                                                        return <CategoryIcon className="h-3.5 w-3.5" />;
                                                    })()}
                                                    {itemDetails?.category || 'Uncategorized'}
                                                </span>
                                            )}
                                        </div>
                                    </div>
                                    <div className="flex flex-col">
                                        <span className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Item</span>
                                        <span className="text-sm font-bold text-slate-900">{itemName}</span>
                                    </div>
                                    <div className="flex flex-col">
                                        <span className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Requester</span>
                                        <span className="text-sm font-bold text-slate-900">{borrowerName}</span>
                                    </div>
                                    <div className="flex flex-col">
                                        <span className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Pickup Location</span>
                                        <div className="flex items-center gap-1.5 text-amber-600 font-bold">
                                            <MapPin className="h-3.5 w-3.5" />
                                            <span className="text-sm">{borrowedFrom || itemDetails?.storage_location || 'Not Specified'}</span>
                                        </div>
                                    </div>
                                    <div className="flex flex-col">
                                        <span className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Quantity</span>
                                        <span className="text-sm font-bold text-amber-600">{quantity} units</span>
                                    </div>
                                </div>

                                <p className="text-[11px] font-semibold text-slate-600 bg-slate-100/80 border border-slate-200 rounded-xl px-3 py-2">
                                    Auto-recorded handoff time when you confirm release.
                                </p>

                            </div>

                            {/* Right Form Panel */}
                            <div className="p-7 md:p-8 border border-slate-100 rounded-2xl bg-white space-y-6 shadow-sm">
                                <div className="flex items-center gap-2 pb-2 border-b border-slate-100">
                                    <ClipboardCheck className="h-4 w-4 text-amber-500" />
                                    <span className="text-[11px] font-black text-slate-600 uppercase tracking-widest">Audit Trail</span>
                                </div>

                                <div className="space-y-2">
                                    <div className="flex justify-between items-center">
                                        <Label className="text-[13px] font-bold text-slate-700">Physically Received By <span className="text-red-500">*</span></Label>
                                        <Button
                                            type="button"
                                            variant="ghost"
                                            size="sm"
                                            onClick={() => setReceivedBy(borrowerName)}
                                            className="h-7 px-2 text-[9px] font-black uppercase text-slate-400 hover:text-amber-600"
                                        >
                                            Same as requester
                                        </Button>
                                    </div>
                                    <div className="relative">
                                        <Input 
                                            placeholder="Name of person receiving item" 
                                            value={receivedBy} 
                                            onChange={e => setReceivedBy(e.target.value)} 
                                            className="h-12 bg-white border-slate-200 rounded-xl pl-10" 
                                        />
                                        <UserCircle2 className="absolute left-3.5 top-3.5 h-5 w-5 text-slate-400" />
                                    </div>
                                </div>

                                <div className="space-y-2">
                                    <Label className="text-[13px] font-bold text-slate-700">Releasing Officer <span className="text-red-500">*</span></Label>
                                    <div className="relative">
                                        <Input 
                                            placeholder="Full name of releaser" 
                                            value={releasedBy} 
                                            onChange={e => setReleasedBy(e.target.value)} 
                                            className="h-12 bg-white border-slate-200 rounded-xl pr-28" 
                                        />
                                        <Button
                                            type="button"
                                            variant="ghost"
                                            size="sm"
                                            onClick={handleUseMyName}
                                            className="absolute right-1.5 top-1.5 h-9 px-2 text-[10px] font-bold text-amber-600 hover:text-amber-700 rounded-md"
                                        >
                                            Use my name
                                        </Button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <DialogFooter className="px-8 pb-8 pt-2 flex items-center justify-between gap-4">
                        <Button
                            type="button"
                            variant="ghost"
                            onClick={() => setOpen(false)}
                            className="text-slate-900 font-bold text-sm"
                        >
                            Cancel
                        </Button>
                        <Button
                            type="submit"
                            disabled={isPending || !receivedBy || !releasedBy} 
                            className="h-14 px-8 bg-amber-600 hover:bg-amber-700 text-white rounded-2xl font-bold gap-3 shadow-lg shadow-amber-500/20 flex-1 sm:flex-none transition-all"
                        >
                            {isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Package className="h-5 w-5" />}
                            Confirm Handoff
                        </Button>
                    </DialogFooter>
                </form>
            </DialogContent>

            <InventoryImagePreviewDialog
                image={expandedImage}
                onOpenChange={(open) => !open && setExpandedImage(null)}
            />
        </Dialog>
    );
}
