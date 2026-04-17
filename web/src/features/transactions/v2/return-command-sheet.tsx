'use client';

import { useEffect, useMemo, useState, useTransition } from 'react';
import { 
    RotateCcw, 
    AlertTriangle,
    Loader2,
    History,
    ClipboardCheck,
    Maximize2,
    Package,
    CheckCircle2,
    XCircle,
    Wrench,
    Cross,
    Shield,
    Box
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
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import Image from 'next/image';
import { createClient } from '@/lib/supabase-browser';
import { getInventoryImageUrl } from '@/lib/supabase';
import { InventoryImagePreviewDialog } from '@/components/ui/inventory-image-preview-dialog';
import { useUser } from '@/providers/auth-provider';

// V3 API Bridge
import { finalizeReturn } from '../api/transaction-repository';
import { toast } from 'sonner';
import { cn } from '@/lib/utils';

interface ReturnCommandSheetProps {
    logId?: number;
    itemName?: string;
    borrowerName: string;
    quantity?: number;
    inventoryId?: number;
    items?: Array<{
        logId: number;
        itemName: string;
        quantity: number;
        inventoryId: number;
        imageUrl?: string | null;
    }>;
    triggerLabel?: string;
    triggerClassName?: string;
}

/**
 * ReturnCommandSheet (Light/Soft-Boxed Sync)
 * 
 * Pattern: Clean Header + Soft Assessment Tray
 * Color Signature: Orange-Tactical
 */
export function ReturnCommandSheet({
    logId,
    itemName,
    borrowerName,
    quantity,
    inventoryId,
    items,
    triggerLabel,
    triggerClassName
}: ReturnCommandSheetProps) {
    const { user } = useUser();
    const [open, setOpen] = useState(false);
    const [isPending, startTransition] = useTransition();
    const [expandedImage, setExpandedImage] = useState<{ url: string; name: string } | null>(null);
    
    // Identity State (Matched to Image Aesthetic)
    const [returnCondition, setReturnCondition] = useState('Good');
    const [returnNotes, setReturnNotes] = useState('');
    const [receivedBy, setReceivedBy] = useState('Officer Name');
    const [itemDetails, setItemDetails] = useState<{
        item_name?: string;
        category?: string;
        image_url?: string | null;
    } | null>(null);
    const [batchItemDetails, setBatchItemDetails] = useState<Record<number, {
        item_name?: string;
        category?: string;
        image_url?: string | null;
    }>>({});
    const isBatchMode = Array.isArray(items) && items.length > 0;
    const targetItems = useMemo(
        () =>
            isBatchMode
                ? items
                : (logId && inventoryId && itemName && quantity
                    ? [{ logId, inventoryId, itemName, quantity, imageUrl: null }]
                    : []),
        [isBatchMode, items, logId, inventoryId, itemName, quantity]
    );
    const isDamaged = returnCondition === 'Damaged';
    const imageUrl = getInventoryImageUrl(itemDetails?.image_url || null);
    const [itemConditionOverrides, setItemConditionOverrides] = useState<Record<number, string>>({});
    const [batchResult, setBatchResult] = useState<{
        rows: Array<{ logId: number; itemName: string; success: boolean; error?: string }>;
        successCount: number;
        failureCount: number;
        returnedAtLabel: string;
    } | null>(null);

    useEffect(() => {
        if (!open) return;
        let active = true;

        const loadItemDetails = async () => {
            try {
                const supabase = createClient();
                if (isBatchMode) {
                    const inventoryIds = Array.from(new Set(targetItems.map((item) => item.inventoryId)));
                    const { data } = await supabase
                        .from('inventory')
                        .select('id, item_name, category, image_url')
                        .in('id', inventoryIds);
                    if (active) {
                        const mapped: Record<number, any> = {};
                        (data || []).forEach((row: any) => {
                            mapped[row.id] = row;
                        });
                        setBatchItemDetails(mapped);
                        setItemDetails(null);
                    }
                } else if (inventoryId) {
                    const { data } = await supabase
                        .from('inventory')
                        .select('item_name, category, image_url')
                        .eq('id', inventoryId)
                        .single();
                    if (active) {
                        setItemDetails(data || null);
                        setBatchItemDetails({});
                    }
                }
            } finally {}
        };

        loadItemDetails();

        return () => {
            active = false;
        };
    }, [open, inventoryId, isBatchMode, targetItems]);

    useEffect(() => {
        if (!open) {
            setBatchResult(null);
            setItemConditionOverrides({});
        }
    }, [open]);

    useEffect(() => {
        if (!open) return;
        const fullName = user?.full_name || user?.user_metadata?.full_name || user?.email?.split('@')[0] || '';
        if (fullName && (!receivedBy || receivedBy === 'Officer Name')) {
            setReceivedBy(fullName);
        }
    }, [open, user, receivedBy]);

    const handleUseMyName = () => {
        const fullName = user?.full_name || user?.user_metadata?.full_name || user?.email?.split('@')[0];
        if (fullName) {
            setReceivedBy(fullName);
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

    const runReturnForItems = async (itemsToReturn: typeof targetItems) => {
        let successCount = 0;
        let failureCount = 0;
        let latestReturnedAt: string | null = null;
        const rows: Array<{ logId: number; itemName: string; success: boolean; error?: string }> = [];

        for (const item of itemsToReturn) {
            const condition = (itemConditionOverrides[item.logId] || returnCondition).toLowerCase();
            const result = await finalizeReturn(
                item.logId,
                {
                    received_by_name: receivedBy,
                    return_condition: condition as any,
                    return_notes: returnNotes
                },
                item.quantity,
                item.inventoryId
            );

            if (result.success) {
                successCount += 1;
                latestReturnedAt = (result.data as any)?.returnedAt || latestReturnedAt;
                rows.push({ logId: item.logId, itemName: item.itemName, success: true });
            } else {
                failureCount += 1;
                rows.push({ logId: item.logId, itemName: item.itemName, success: false, error: result.error || 'Failed to return item.' });
            }
        }

        const returnedAt = latestReturnedAt ? new Date(latestReturnedAt) : new Date();
        const returnedAtLabel = returnedAt.toLocaleString('en-US', {
            month: 'short',
            day: 'numeric',
            year: 'numeric',
            hour: 'numeric',
            minute: '2-digit',
        });

        return { rows, successCount, failureCount, returnedAtLabel };
    };

    const handleReturn = async (e: React.FormEvent) => {
        e.preventDefault();
        
        startTransition(async () => {
            if (targetItems.length === 0) {
                toast.error('No return items selected.');
                return;
            }

            const { rows, successCount, failureCount, returnedAtLabel } = await runReturnForItems(targetItems);
            if (isBatchMode) {
                setBatchResult({ rows, successCount, failureCount, returnedAtLabel });
            }

            if (failureCount === 0) {
                toast.success(
                    isBatchMode
                        ? `${successCount} item(s) recovered at ${returnedAtLabel}.`
                        : `Recovery confirmed at ${returnedAtLabel}.`
                );
                setOpen(false);
            } else {
                toast.error(`Completed with issues: ${successCount} succeeded, ${failureCount} failed.`);
            }
        });
    };

    const retryFailedItems = async () => {
        if (!batchResult || batchResult.failureCount === 0) return;
        const failedLookup = new Set(batchResult.rows.filter((r) => !r.success).map((r) => r.logId));
        const failedItems = targetItems.filter((item) => failedLookup.has(item.logId));
        if (failedItems.length === 0) return;

        startTransition(async () => {
            const retried = await runReturnForItems(failedItems);
            setBatchResult(retried);
            if (retried.failureCount === 0) {
                toast.success(`Retry succeeded. ${retried.successCount} item(s) recovered.`);
            } else {
                toast.error(`Retry completed: ${retried.successCount} succeeded, ${retried.failureCount} failed.`);
            }
        });
    };

    const resolveImageUrl = (rawUrl?: string | null) => {
        if (!rawUrl) return null;
        return getInventoryImageUrl(rawUrl);
    };

    return (
        <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
                <Button
                    size="sm"
                    variant="outline"
                    className={cn(
                        "h-8 gap-2 text-blue-600 hover:text-blue-700 hover:bg-blue-50 border-blue-100 rounded-lg font-bold text-[10px] uppercase tracking-widest transition-all active:scale-95 shadow-sm",
                        triggerClassName
                    )}
                >
                    <RotateCcw className="h-3.5 w-3.5" /> {triggerLabel || (isBatchMode ? `Return Selected (${targetItems.length})` : 'Return Item')}
                </Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[860px] p-0 border-none bg-white rounded-3xl overflow-hidden shadow-2xl">
                <form onSubmit={handleReturn}>
                    <DialogHeader className="p-8 pb-4">
                        <DialogTitle className="text-2xl font-bold text-slate-900 flex items-center gap-2">
                            🔄 Process Return
                        </DialogTitle>
                        <DialogDescription className="text-slate-500 font-medium pt-1">
                            {isBatchMode
                                ? <>Review selected equipment and confirm return for <strong>{borrowerName}</strong>.</>
                                : <>Check item details and put <strong>{itemName}</strong> back in stock.</>}
                        </DialogDescription>
                    </DialogHeader>

                    <div className="px-8 pb-8 space-y-6">
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            {/* Left Summary Panel */}
                            <div className="bg-slate-50/70 p-6 rounded-2xl border border-slate-100 space-y-5">
                                <div className="flex items-center gap-2 pb-1 border-b border-slate-200/80">
                                    <History className="h-4 w-4 text-blue-500" />
                                    <span className="text-[11px] font-black text-slate-600 uppercase tracking-widest">Return Info</span>
                                </div>

                                <div className="space-y-3">
                                    {isBatchMode ? (
                                        <>
                                            <div className="flex flex-col">
                                                <span className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Borrower</span>
                                                <span className="text-sm font-bold text-slate-900">{borrowerName}</span>
                                            </div>
                                            <div className="flex flex-col">
                                                <span className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Selected Items</span>
                                                <span className="text-sm font-bold text-blue-600">{targetItems.length} items</span>
                                            </div>
                                            <div className="space-y-2 max-h-56 overflow-y-auto pr-1">
                                                {targetItems.map((item) => (
                                                    <div key={item.logId} className="rounded-xl border border-slate-200 bg-white p-2.5 flex items-center gap-2.5">
                                                        <button
                                                            type="button"
                                                            onClick={() => {
                                                                const resolvedUrl =
                                                                    resolveImageUrl(item.imageUrl || null) ||
                                                                    resolveImageUrl(batchItemDetails[item.inventoryId]?.image_url || null);
                                                                if (resolvedUrl) setExpandedImage({ url: resolvedUrl, name: item.itemName });
                                                            }}
                                                            className="h-10 w-10 rounded-lg bg-slate-50 border border-slate-100 overflow-hidden relative flex items-center justify-center shrink-0 group"
                                                        >
                                                            {(resolveImageUrl(item.imageUrl || null) || resolveImageUrl(batchItemDetails[item.inventoryId]?.image_url || null)) ? (
                                                                <>
                                                                    <Image
                                                                        src={resolveImageUrl(item.imageUrl || null) || resolveImageUrl(batchItemDetails[item.inventoryId]?.image_url || null)!}
                                                                        alt={item.itemName}
                                                                        fill
                                                                        unoptimized
                                                                        className="object-cover"
                                                                    />
                                                                    <span className="absolute inset-0 bg-black/35 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                                                                        <Maximize2 className="h-3 w-3 text-white" />
                                                                    </span>
                                                                </>
                                                            ) : (
                                                                <Package className="h-4 w-4 text-slate-300" />
                                                            )}
                                                        </button>
                                                        <div className="min-w-0">
                                                            <p className="text-xs font-bold text-slate-900 truncate">{item.itemName}</p>
                                                            <p className="text-[11px] text-slate-500">Qty: {item.quantity}</p>
                                                            {batchItemDetails[item.inventoryId]?.category && (
                                                                <span className="inline-flex items-center gap-1 text-[10px] font-semibold text-slate-500 mt-0.5">
                                                                    {(() => {
                                                                        const CategoryIcon = getCategoryIcon(batchItemDetails[item.inventoryId]?.category);
                                                                        return <CategoryIcon className="h-3 w-3" />;
                                                                    })()}
                                                                    {batchItemDetails[item.inventoryId]?.category}
                                                                </span>
                                                            )}
                                                        </div>
                                                    </div>
                                                ))}
                                            </div>
                                        </>
                                    ) : (
                                        <>
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
                                        <span className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Person</span>
                                        <span className="text-sm font-bold text-slate-900">{borrowerName}</span>
                                    </div>
                                    <div className="flex flex-col">
                                        <span className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Quantity</span>
                                        <span className="text-sm font-bold text-blue-600">{quantity} units</span>
                                    </div>
                                        </>
                                    )}
                                </div>

                                <p className="text-[11px] font-semibold text-slate-600 bg-slate-100/80 border border-slate-200 rounded-xl px-3 py-2">
                                    {isBatchMode
                                        ? 'Auto-recorded return time. This action only processes selected items in this borrower session.'
                                        : 'Auto-recorded return time when you confirm recovery.'}
                                </p>

                            </div>

                            {/* Right Form Panel */}
                            <div className="p-7 md:p-8 border border-slate-100 rounded-2xl bg-white space-y-6 shadow-sm">
                                <div className="flex items-center gap-2 pb-2 border-b border-slate-100">
                                    <ClipboardCheck className="h-4 w-4 text-blue-500" />
                                    <span className="text-[11px] font-black text-slate-600 uppercase tracking-widest">Check Details</span>
                                </div>

                                <div className="space-y-2">
                                    <Label className="text-[13px] font-bold text-slate-700">Receiving Officer <span className="text-red-500">*</span></Label>
                                    <div className="relative">
                                        <Input 
                                            placeholder="Full name of receiver" 
                                            value={receivedBy} 
                                            onChange={e => setReceivedBy(e.target.value)} 
                                            className="h-12 bg-white border-slate-200 rounded-xl pr-28" 
                                        />
                                        <Button
                                            type="button"
                                            variant="ghost"
                                            size="sm"
                                            onClick={handleUseMyName}
                                            className="absolute right-1.5 top-1.5 h-9 px-2 text-[10px] font-bold text-blue-600 hover:text-blue-700 rounded-md"
                                        >
                                            Use my name
                                        </Button>
                                    </div>
                                </div>

                                <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
                                    <div className="space-y-2">
                                        <Label className="text-[13px] font-bold text-slate-700">Condition State <span className="text-red-500">*</span></Label>
                                        <Select value={returnCondition} onValueChange={setReturnCondition}>
                                            <SelectTrigger className="h-12 bg-white border-slate-200 rounded-xl">
                                                <SelectValue />
                                            </SelectTrigger>
                                            <SelectContent>
                                                <SelectItem value="Good" className="text-green-600 font-bold">Good Condition</SelectItem>
                                                <SelectItem value="Maintenance" className="text-amber-600 font-bold">Needs Prep</SelectItem>
                                                <SelectItem value="Damaged" className="text-red-600 font-bold">Damaged</SelectItem>
                                                <SelectItem value="Lost" className="text-slate-500 font-bold">Lost</SelectItem>
                                            </SelectContent>
                                        </Select>
                                    </div>
                                    <div className="space-y-2">
                                        <Label className="text-[13px] font-bold text-slate-700">Audit Notes <span className="text-slate-400 font-normal">(Notes)</span></Label>
                                        <Input
                                            placeholder="Condition details..."
                                            className="h-12 bg-white border-slate-200 rounded-xl"
                                            value={returnNotes}
                                            onChange={(e) => setReturnNotes(e.target.value)}
                                        />
                                    </div>
                                </div>

                                {isBatchMode && (
                                    <div className="space-y-2">
                                        <Label className="text-[13px] font-bold text-slate-700">Item condition (optional)</Label>
                                        <p className="text-[11px] text-slate-500">Only change this if an item has a different condition.</p>
                                        <div className="space-y-2 max-h-48 overflow-y-auto pr-1">
                                            {targetItems.map((item) => (
                                                <div key={`condition-${item.logId}`} className="rounded-xl border border-slate-200 bg-slate-50/60 p-2.5 grid grid-cols-1 sm:grid-cols-2 gap-2 items-center">
                                                    <p className="text-xs font-bold text-slate-700 truncate">{item.itemName}</p>
                                                    <Select
                                                        value={itemConditionOverrides[item.logId] || returnCondition}
                                                        onValueChange={(value) =>
                                                            setItemConditionOverrides((prev) => ({ ...prev, [item.logId]: value }))
                                                        }
                                                    >
                                                        <SelectTrigger className="h-9 bg-white border-slate-200 rounded-lg text-left pl-3 pr-2 [&>span]:text-left [&>span]:w-full">
                                                            <SelectValue />
                                                        </SelectTrigger>
                                                        <SelectContent>
                                                            <SelectItem value="Good">Good</SelectItem>
                                                            <SelectItem value="Maintenance">Needs Prep</SelectItem>
                                                            <SelectItem value="Damaged">Damaged</SelectItem>
                                                            <SelectItem value="Lost">Lost</SelectItem>
                                                        </SelectContent>
                                                    </Select>
                                                </div>
                                            ))}
                                        </div>
                                    </div>
                                )}

                                {isBatchMode && batchResult && (
                                    <div className="rounded-xl border border-slate-200 bg-slate-50/60 p-3 space-y-2">
                                        <div className="flex items-center justify-between">
                                            <p className="text-[11px] font-black uppercase tracking-widest text-slate-600">
                                                Return Result ({batchResult.returnedAtLabel})
                                            </p>
                                            <p className="text-xs font-bold text-slate-700">
                                                {batchResult.successCount} success / {batchResult.failureCount} failed
                                            </p>
                                        </div>
                                        <div className="space-y-1 max-h-36 overflow-y-auto pr-1">
                                            {batchResult.rows.map((row) => (
                                                <div key={`result-${row.logId}`} className="text-xs rounded-lg bg-white border border-slate-200 px-2 py-1.5">
                                                    <div className="flex items-center justify-between">
                                                        <span className="font-semibold text-slate-700 truncate mr-2">{row.itemName}</span>
                                                        {row.success ? (
                                                            <span className="inline-flex items-center gap-1 text-emerald-600 font-bold">
                                                                <CheckCircle2 className="h-3.5 w-3.5" /> Returned
                                                            </span>
                                                        ) : (
                                                            <span className="inline-flex items-center gap-1 text-rose-600 font-bold">
                                                                <XCircle className="h-3.5 w-3.5" /> Failed
                                                            </span>
                                                        )}
                                                    </div>
                                                    {!row.success && row.error && (
                                                        <p className="mt-1 text-[11px] text-rose-700 leading-snug">
                                                            {row.error}
                                                        </p>
                                                    )}
                                                </div>
                                            ))}
                                        </div>
                                        {batchResult.failureCount > 0 && (
                                            <Button
                                                type="button"
                                                variant="outline"
                                                onClick={retryFailedItems}
                                                disabled={isPending}
                                                className="w-full h-9 rounded-xl border-rose-200 text-rose-700 hover:bg-rose-50"
                                            >
                                                Retry Failed Items
                                            </Button>
                                        )}
                                    </div>
                                )}
                            </div>
                        </div>

                        {isDamaged && (
                            <div className="p-4 bg-red-50 border border-red-100 rounded-xl flex items-center gap-3 animate-in fade-in slide-in-from-top-1">
                                <AlertTriangle className="w-5 h-5 text-red-600 shrink-0" />
                                <p className="text-[10px] font-bold text-red-800 uppercase tracking-tight leading-normal">
                                    Property Alert: Item will be flagged for quarantine and maintenance registry.
                                </p>
                            </div>
                        )}
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
                            disabled={isPending || !receivedBy} 
                            className="h-14 px-8 bg-blue-600 hover:bg-blue-700 text-white rounded-2xl font-bold gap-3 shadow-lg shadow-blue-500/20 flex-1 sm:flex-none transition-all"
                        >
                            {isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <ClipboardCheck className="h-5 w-5" />}
                            {isBatchMode ? `Confirm Return (${targetItems.length})` : 'Confirm Recovery'}
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
