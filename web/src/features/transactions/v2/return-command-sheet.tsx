'use client';

import { useState, useTransition } from 'react';
import { 
    RotateCcw, 
    ShieldCheck,
    AlertTriangle,
    Loader2,
    History,
    ClipboardCheck
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

// V3 API Bridge
import { finalizeReturn } from '../api/transaction-repository';
import { toast } from 'sonner';

interface ReturnCommandSheetProps {
    logId: number;
    itemName: string;
    borrowerName: string;
    quantity: number;
    inventoryId: number;
}

/**
 * ReturnCommandSheet (Light/Soft-Boxed Sync)
 * 
 * Pattern: Clean Header + Soft Assessment Tray
 * Color Signature: Orange-Tactical
 */
export function ReturnCommandSheet({ logId, itemName, borrowerName, quantity, inventoryId }: ReturnCommandSheetProps) {
    const [open, setOpen] = useState(false);
    const [isPending, startTransition] = useTransition();
    
    // Identity State (Matched to Image Aesthetic)
    const [returnCondition, setReturnCondition] = useState('Good');
    const [returnNotes, setReturnNotes] = useState('');
    const [receivedBy, setReceivedBy] = useState('Officer Name');

    const handleReturn = async (e: React.FormEvent) => {
        e.preventDefault();
        
        startTransition(async () => {
            const result = await finalizeReturn(
                logId, 
                {
                    received_by_name: receivedBy,
                    return_condition: returnCondition.toLowerCase() as any,
                    return_notes: returnNotes
                },
                quantity,
                inventoryId
            );

            if (result.success) {
                toast.success(`Items restored to cache.`);
                setOpen(false);
            } else {
                toast.error(result.error);
            }
        });
    };

    return (
        <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
                <Button size="sm" variant="outline" className="h-8 gap-2 text-orange-600 hover:text-orange-700 hover:bg-orange-50 border-orange-100 rounded-lg font-bold text-[10px] uppercase tracking-widest transition-all active:scale-95 shadow-sm">
                    <RotateCcw className="h-3.5 w-3.5" /> Return Item
                </Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[550px] p-0 border-none bg-white rounded-3xl overflow-hidden shadow-2xl">
                <form onSubmit={handleReturn}>
                    {/* Header Parity: Clean White (Orange Accents) */}
                    <DialogHeader className="p-8 pb-4">
                        <DialogTitle className="text-2xl font-bold text-slate-900 flex items-center gap-2">
                            🔄 Process Return
                        </DialogTitle>
                        <DialogDescription className="text-slate-500 font-medium pt-1">
                            Verify item condition and restore <strong>{itemName}</strong> to technical registry.
                        </DialogDescription>
                    </DialogHeader>

                    <div className="px-8 pb-8 space-y-6">
                        {/* Session Metadata Tray */}
                        <div className="bg-slate-50 p-6 rounded-2xl border border-slate-100 flex items-center justify-between">
                            <div className="flex flex-col">
                                <span className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Returning Party</span>
                                <span className="text-sm font-bold text-slate-900">{borrowerName}</span>
                            </div>
                            <div className="flex flex-col items-end">
                                <span className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Asset Volume</span>
                                <span className="text-sm font-bold text-orange-600">{quantity}x Units</span>
                            </div>
                        </div>

                        {/* Assessment Box (Ref: Soft Tray Style) */}
                        <div className="p-6 border border-slate-100 rounded-2xl bg-white space-y-6 shadow-sm">
                            <div className="flex items-center gap-2 pb-2 border-b border-slate-50">
                                <History className="h-4 w-4 text-orange-500" />
                                <span className="text-[11px] font-black text-slate-600 uppercase tracking-widest">Return Assessment</span>
                            </div>

                            <div className="grid gap-5">
                                <div className="space-y-2">
                                    <Label className="text-[13px] font-bold text-slate-700">Receiving Officer <span className="text-red-500">*</span></Label>
                                    <Input 
                                        placeholder="Full name of receiver" 
                                        value={receivedBy} 
                                        onChange={e => setReceivedBy(e.target.value)} 
                                        className="h-12 bg-white border-slate-200 rounded-xl" 
                                    />
                                </div>

                                <div className="grid grid-cols-2 gap-5">
                                    <div className="space-y-2">
                                        <Label className="text-[13px] font-bold text-slate-700">Condition State <span className="text-red-500">*</span></Label>
                                        <Select value={returnCondition} onValueChange={setReturnCondition}>
                                            <SelectTrigger className="h-12 bg-white border-slate-200 rounded-xl">
                                                <SelectValue />
                                            </SelectTrigger>
                                            <SelectContent>
                                                <SelectItem value="Good" className="text-green-600 font-bold">Good Condition</SelectItem>
                                                <SelectItem value="Maintenance" className="text-orange-600 font-bold">Needs Prep</SelectItem>
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
                            </div>
                        </div>

                        {returnCondition === 'Damaged' && (
                            <div className="p-4 bg-red-50 border border-red-100 rounded-xl flex items-center gap-3 animate-in fade-in slide-in-from-top-1">
                                <AlertTriangle className="w-5 h-5 text-red-600 shrink-0" />
                                <p className="text-[10px] font-bold text-red-800 uppercase tracking-tight leading-normal">
                                    Property Alert: Item will be flagged for quarantine and maintenance registry.
                                </p>
                            </div>
                        )}
                    </div>

                    <DialogFooter className="px-8 pb-8 pt-4 flex items-center justify-between gap-4">
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
                            className="h-14 px-8 bg-orange-300 hover:bg-orange-400 text-white rounded-2xl font-bold gap-3 shadow-lg shadow-orange-500/10 flex-1 sm:flex-none transition-all"
                        >
                            {isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <ClipboardCheck className="h-5 w-5" />}
                            Confirm Recovery
                        </Button>
                    </DialogFooter>
                </form>
            </DialogContent>
        </Dialog>
    );
}
