'use client';

import { ReactNode, useEffect, useState, useTransition } from 'react';
import { 
    Loader2,
    Package,
    Maximize2,
    MapPin,
    UserCircle2,
    ClipboardCheck,
    CheckCircle2,
    Calendar,
    Zap,
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
import { approveRequest, completeHandoff } from '../actions/approval.actions';
import { toast } from 'sonner';
import { cn } from '@/lib/utils';
import { BorrowLog } from '@/lib/types/inventory';

interface ApprovalCommandSheetProps {
    request: BorrowLog;
    isReservationView: boolean;
    triggerLabel?: string;
    triggerClassName?: string;
    children?: ReactNode;
    onActionSuccess?: () => void;
}

export function ApprovalCommandSheet({
    request,
    isReservationView,
    triggerLabel,
    triggerClassName,
    children,
    onActionSuccess
}: ApprovalCommandSheetProps) {
    const { user } = useUser();
    const [open, setOpen] = useState(false);
    const [isPending, startTransition] = useTransition();
    const [expandedImage, setExpandedImage] = useState<{ url: string; name: string } | null>(null);
    
    const isStaged = request.status === 'staged';
    
    // Identity State
    const [adminName, setAdminName] = useState('Officer Name');
    const [handedTo, setHandedTo] = useState(request.borrower_name);
    
    const [itemDetails, setItemDetails] = useState<{
        item_name?: string;
        category?: string;
        image_url?: string | null;
        storage_location?: string | null;
        item_type?: 'equipment' | 'consumable';
    } | null>(null);
    
    const imageUrl = getInventoryImageUrl(itemDetails?.image_url || null);

    useEffect(() => {
        if (!open) return;
        let active = true;

        const loadItemDetails = async () => {
            try {
                const supabase = createClient();
                if (request.inventory_id) {
                    const { data } = await supabase
                        .from('inventory')
                        .select('item_name, category, image_url, storage_location, item_type')
                        .eq('id', request.inventory_id)
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
    }, [open, request.inventory_id]);

    useEffect(() => {
        if (open) {
            setHandedTo(request.borrower_name);
            const fullName = user?.full_name || user?.user_metadata?.full_name || user?.email?.split('@')[0] || '';
            if (fullName && (!adminName || adminName === 'Officer Name')) {
                setAdminName(fullName);
            }
        }
    }, [open, request.borrower_name, user, adminName]);

    const handleUseMyName = () => {
        const fullName = user?.full_name || user?.user_metadata?.full_name || user?.email?.split('@')[0];
        if (fullName) {
            setAdminName(fullName);
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

    const handleAction = async (e: React.FormEvent) => {
        e.preventDefault();
        
        startTransition(async () => {
            let result;
            if (isStaged) {
                // If already staged, this confirms the handoff
                result = await completeHandoff(request.id, adminName, user?.id, handedTo);
            } else {
                // Instant Dispatch (Skip Staging step)
                result = await approveRequest(request.id, adminName, true, {
                    handedBy: adminName,
                    physicallyReceivedBy: handedTo,
                    adminId: user?.id
                });
            }

            if (result.success) {
                toast.success(result.message);
                setOpen(false);
                onActionSuccess?.();
            } else {
                toast.error(result.error || 'Operation failed.');
            }
        });
    };

    const primaryColorClass = isStaged ? "amber" : isReservationView ? "amber" : "blue";
    const Icon = isStaged ? CheckCircle2 : isReservationView ? Calendar : Zap;

    return (
        <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
                {children || (
                    <Button
                        size="sm"
                        variant="outline"
                        className={cn(
                            `h-8 gap-2 text-${primaryColorClass}-600 hover:text-${primaryColorClass}-700 hover:bg-${primaryColorClass}-50 border-${primaryColorClass}-100 rounded-lg font-bold text-[10px] uppercase tracking-widest transition-all active:scale-95 shadow-sm`,
                            triggerClassName
                        )}
                    >
                        <Icon className="h-3.5 w-3.5" /> {triggerLabel || (isStaged ? 'Confirm Handoff' : isReservationView ? 'Approve & Dispatch' : 'Approve Request')}
                    </Button>
                )}
            </DialogTrigger>
            <DialogContent className="sm:max-w-[860px] p-0 border-none bg-white rounded-3xl overflow-hidden shadow-2xl">
                <form onSubmit={handleAction}>
                    <DialogHeader className="p-8 pb-4">
                        <DialogTitle className="text-2xl font-bold text-slate-900 flex items-center gap-2">
                            {isStaged ? '📦 Process Handoff' : isReservationView ? '⚡ Dispatch Request' : '⚡ Tactical Approval'}
                        </DialogTitle>
                        <DialogDescription className="text-slate-500 font-medium pt-1">
                            {isStaged 
                                ? `Confirm the physical release of equipment to ${request.borrower_name}.`
                                : `Review and dispatch the requested equipment to ${request.borrower_name}.`}
                        </DialogDescription>
                    </DialogHeader>

                    <div className="px-8 pb-8 space-y-6">
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            {/* Left Summary Panel */}
                            <div className="bg-slate-50/70 p-6 rounded-2xl border border-slate-100 space-y-5">
                                <div className="flex items-center gap-2 pb-1 border-b border-slate-200/80">
                                    <ClipboardCheck className={`h-4 w-4 text-${primaryColorClass}-500`} />
                                    <span className="text-[11px] font-black text-slate-600 uppercase tracking-widest">Request Summary</span>
                                </div>

                                <div className="space-y-3">
                                    <div className="flex items-start gap-3">
                                        <button
                                            type="button"
                                            onClick={() => {
                                                if (imageUrl) setExpandedImage({ url: imageUrl, name: itemDetails?.item_name || request.item_name });
                                            }}
                                            className="h-20 w-20 rounded-xl border border-slate-200 bg-white overflow-hidden relative shrink-0 group"
                                        >
                                            {imageUrl ? (
                                                <>
                                                    <Image
                                                        src={imageUrl}
                                                        alt={request.item_name}
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
                                                {request.item_name}
                                            </span>
                                            {(itemDetails?.category || 'Uncategorized') && (
                                                <span className="inline-flex items-center gap-1 text-xs text-slate-500 mt-0.5">
                                                    {(() => {
                                                        const CategoryIcon = getCategoryIcon(itemDetails?.category);
                                                        return <CategoryIcon className="h-3.5 w-3.5" />;
                                                    })()}
                                                    {itemDetails?.category || 'Uncategorized'}
                                                </span>
                                            )}
                                        </div>
                                    </div>
                                    
                                    <div className="grid grid-cols-2 gap-4">
                                        <div className="flex flex-col">
                                            <span className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Borrower</span>
                                            <span className="text-sm font-bold text-slate-900">{request.borrower_name}</span>
                                        </div>
                                        <div className="flex flex-col">
                                            <span className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Quantity</span>
                                            <span className={`text-sm font-bold text-${primaryColorClass}-600`}>{request.quantity} units</span>
                                        </div>
                                    </div>

                                    <div className="flex flex-col">
                                        <span className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Storage Hub</span>
                                        <div className={`flex items-center gap-1.5 text-${primaryColorClass}-600 font-bold`}>
                                            <MapPin className="h-3.5 w-3.5" />
                                            <span className="text-sm">{itemDetails?.storage_location || 'Main Hub'}</span>
                                        </div>
                                    </div>
                                </div>

                                <p className="text-[11px] font-semibold text-slate-600 bg-slate-100/80 border border-slate-200 rounded-xl px-3 py-2">
                                    This action will be recorded with your administrator identity for forensic audit trail.
                                </p>
                            </div>

                            {/* Right Form Panel */}
                            <div className="p-7 md:p-8 border border-slate-100 rounded-2xl bg-white space-y-6 shadow-sm">
                                <div className="flex items-center gap-2 pb-2 border-b border-slate-100">
                                    <ClipboardCheck className={`h-4 w-4 text-${primaryColorClass}-500`} />
                                    <span className="text-[11px] font-black text-slate-600 uppercase tracking-widest">Audit Verification</span>
                                </div>

                                <div className="space-y-2">
                                    <div className="flex justify-between items-center">
                                        <Label className="text-[13px] font-bold text-slate-700">Physically Handed To <span className="text-red-500">*</span></Label>
                                        <Button
                                            type="button"
                                            variant="ghost"
                                            size="sm"
                                            onClick={() => setHandedTo(request.borrower_name)}
                                            className={`h-7 px-2 text-[9px] font-black uppercase text-slate-400 hover:text-${primaryColorClass}-600`}
                                        >
                                            Same as borrower
                                        </Button>
                                    </div>
                                    <div className="relative">
                                        <Input 
                                            placeholder="Name of person receiving item" 
                                            value={handedTo} 
                                            onChange={e => setHandedTo(e.target.value)} 
                                            className="h-12 bg-white border-slate-200 rounded-xl pl-10" 
                                        />
                                        <UserCircle2 className="absolute left-3.5 top-3.5 h-5 w-5 text-slate-400" />
                                    </div>
                                </div>

                                <div className="space-y-2">
                                    <Label className="text-[13px] font-bold text-slate-700">Authorizing Admin <span className="text-red-500">*</span></Label>
                                    <div className="relative">
                                        <Input 
                                            placeholder="Full name of admin" 
                                            value={adminName} 
                                            onChange={e => setAdminName(e.target.value)} 
                                            className="h-12 bg-white border-slate-200 rounded-xl pr-28" 
                                        />
                                        <Button
                                            type="button"
                                            variant="ghost"
                                            size="sm"
                                            onClick={handleUseMyName}
                                            className={`absolute right-1.5 top-1.5 h-9 px-2 text-[10px] font-bold text-${primaryColorClass}-600 hover:text-${primaryColorClass}-700 rounded-md`}
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
                            disabled={isPending || !handedTo || !adminName} 
                            className={cn(
                                "h-14 px-8 text-white rounded-2xl font-bold gap-3 shadow-lg flex-1 sm:flex-none transition-all",
                                isStaged || isReservationView 
                                    ? "bg-amber-600 hover:bg-amber-700 shadow-amber-500/20" 
                                    : "bg-blue-600 hover:bg-blue-700 shadow-blue-500/20"
                            )}
                        >
                            {isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Icon className="h-5 w-5" />}
                            {isStaged ? 'Confirm Handoff' : isReservationView ? 'Schedule Readiness' : 'Authorize Dispatch'}
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
