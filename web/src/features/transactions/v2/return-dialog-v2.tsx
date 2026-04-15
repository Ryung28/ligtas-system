'use client';

import { useState } from 'react';
import { CheckCircle2, RotateCcw, Package, AlertTriangle } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { 
    Dialog, 
    DialogContent, 
    DialogDescription, 
    DialogHeader, 
    DialogTitle, 
    DialogTrigger 
} from '@/components/ui/dialog';
import { AuditReturnForm, ReturnAuditFormValues } from '../_components/audit-return-form';
import { finalizeReturn } from '../api/transaction-repository';
import { toast } from 'sonner';
import { useCallback } from 'react';

interface ReturnDialogV2Props {
    logId: number;
    itemName: string;
    borrowerName: string;
    quantity: number;
    inventoryId: number;
}

/**
 * ReturnDialogV2 (The Restorer)
 * 
 * Pattern: Audit Verification
 * Constraints: Locked to 150 lines. Manages the equipment health-check pipeline.
 */
export function ReturnDialogV2({ logId, itemName, borrowerName, quantity, inventoryId }: ReturnDialogV2Props) {
    const [open, setOpen] = useState(false);
    const [audit, setAudit] = useState<ReturnAuditFormValues | null>(null);
    
    // Stable handler to prevent Infinite Render Loops
    const handleAuditChange = useCallback((values: ReturnAuditFormValues) => {
        setAudit(values);
    }, []);

    const handleReturn = async () => {
        if (!audit) return;
        
        const result = await finalizeReturn(
            logId, 
            {
                received_by_name: audit.received_by_name,
                return_condition: audit.return_condition,
                return_notes: audit.return_notes
            },
            quantity,
            inventoryId
        );

        if (result.success) {
            toast.success(`LOGISTICS RECOVERY: ${itemName} restored to inventory by ${borrowerName}.`);
            setOpen(false);
        } else {
            toast.error(result.error);
        }
    };

    return (
        <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
                <Button size="sm" variant="outline" className="h-8 gap-2 text-emerald-600 hover:text-emerald-700 hover:bg-emerald-50 border-emerald-100 rounded-lg font-bold text-[10px] uppercase tracking-widest transition-all active:scale-95 shadow-sm">
                    <RotateCcw className="h-3.5 w-3.5" /> Return V2
                </Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[550px] border-none shadow-2xl overflow-hidden rounded-3xl">
                <DialogHeader className="bg-emerald-50/30 -mx-6 -mt-6 px-6 py-8 border-b border-emerald-100/50">
                    <div className="flex items-center gap-3 mb-2">
                        <div className="bg-emerald-100 p-2 rounded-xl">
                            <RotateCcw className="w-5 h-5 text-emerald-600" />
                        </div>
                        <DialogTitle className="text-xl font-black tracking-tighter text-emerald-950 uppercase">Verify Recovery</DialogTitle>
                    </div>
                    <DialogDescription className="text-emerald-800/60 font-medium">Log the physical state of equipment to close the operational loop.</DialogDescription>
                </DialogHeader>

                <div className="space-y-6 pt-6">
                    {/* Logistical Context Summary */}
                    <div className="grid grid-cols-2 gap-px bg-slate-100 rounded-2xl border border-slate-100 overflow-hidden shadow-inner">
                        <div className="bg-white p-4">
                            <Label className="text-[10px] font-black uppercase tracking-widest text-slate-400 block mb-1">Holder</Label>
                            <span className="text-xs font-bold text-slate-900 truncate block">{borrowerName}</span>
                        </div>
                        <div className="bg-white p-4">
                            <Label className="text-[10px] font-black uppercase tracking-widest text-slate-400 block mb-1">Line Item</Label>
                            <span className="text-xs font-bold text-slate-900 truncate block">{itemName} ({quantity}x)</span>
                        </div>
                    </div>

                    {/* Return Audit Form Molecule */}
                    <AuditReturnForm defaultValues={{}} onChange={handleAuditChange} />

                    {audit?.return_condition === 'damaged' && (
                        <div className="mb-4 p-3 bg-red-50 border border-red-100 rounded-xl flex items-center gap-3 animate-in fade-in zoom-in-95">
                            <AlertTriangle className="w-4 h-4 text-red-600" />
                            <p className="text-[10px] font-bold text-red-800 uppercase tracking-tight">DAMAGED FLAG: Asset will be moved to technical maintenance queue.</p>
                        </div>
                    )}

                    <Button 
                        onClick={handleReturn} 
                        disabled={!audit} 
                        className="w-full h-14 bg-emerald-600 hover:bg-emerald-700 text-white rounded-2xl font-black uppercase tracking-widest shadow-xl shadow-emerald-500/30 gap-3 text-sm transition-all hover:-translate-y-0.5"
                    >
                        <CheckCircle2 className="w-5 h-5" /> Execute Restoration
                    </Button>
                </div>
            </DialogContent>
        </Dialog>
    );
}
