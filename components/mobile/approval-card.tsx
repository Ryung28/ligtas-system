'use client'

import { BorrowLog } from '@/lib/types/inventory'
import { Card } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Check, X, Clock, User, Package, MessageSquare } from 'lucide-react'
import { formatDistanceToNow } from 'date-fns'
import { cn } from '@/lib/utils'

interface ApprovalCardProps {
    request: BorrowLog
    onApprove: (id: number, isInstant?: boolean) => void
    onReject: (id: number) => void
    onHandoff: (id: number) => void
    isProcessing: boolean
}

export function ApprovalCard({ request, onApprove, onReject, onHandoff, isProcessing }: ApprovalCardProps) {
    const isStaged = request.status === 'staged'
    
    return (
        <Card className="p-4 rounded-2xl border-none shadow-sm bg-white active:scale-[0.98] transition-all">
            <div className="flex justify-between items-start mb-3">
                <div className="flex items-center gap-2">
                    <div className={cn(
                        "p-2 rounded-xl",
                        isStaged ? "bg-amber-100 text-amber-700" : "bg-blue-100 text-blue-700"
                    )}>
                        {isStaged ? <Package className="h-4 w-4" /> : <Clock className="h-4 w-4" />}
                    </div>
                    <div>
                        <h4 className="text-sm font-bold text-slate-900 leading-tight truncate max-w-[150px]">
                            {request.item_name}
                        </h4>
                        <p className="text-[10px] text-slate-500 font-medium">
                            {request.quantity} {request.quantity > 1 ? 'units' : 'unit'}
                        </p>
                    </div>
                </div>
                <Badge variant="outline" className={cn(
                    "text-[9px] font-black uppercase tracking-widest px-2 py-0.5 rounded-full border-none",
                    isStaged ? "bg-amber-50 text-amber-600" : "bg-blue-50 text-blue-600"
                )}>
                    {request.status}
                </Badge>
            </div>

            <div className="space-y-2 mb-4">
                <div className="flex items-center gap-2 text-xs text-slate-600">
                    <User className="h-3 w-3 text-slate-400" />
                    <span className="font-semibold text-slate-800">{request.borrower_name}</span>
                    <span className="text-slate-300">|</span>
                    <span className="text-[10px] uppercase font-bold text-slate-400">
                        {request.borrower_organization || 'External'}
                    </span>
                </div>
                
                {request.purpose && (
                    <div className="flex items-start gap-2 bg-slate-50 p-2 rounded-xl">
                        <MessageSquare className="h-3 w-3 text-slate-400 mt-0.5" />
                        <p className="text-[11px] text-slate-600 italic leading-snug">
                            &quot;{request.purpose}&quot;
                        </p>
                    </div>
                )}
            </div>

            <div className="flex items-center justify-between gap-2 border-t border-slate-50 pt-3">
                <div className="text-[9px] text-slate-400 font-bold uppercase tracking-tighter">
                    {formatDistanceToNow(new Date(request.created_at), { addSuffix: true })}
                </div>
                
                <div className="flex gap-2">
                    {isStaged ? (
                        <Button 
                            size="sm" 
                            onClick={() => onHandoff(request.id)}
                            disabled={isProcessing}
                            className="bg-emerald-600 hover:bg-emerald-700 h-8 px-4 rounded-lg text-[10px] font-black uppercase tracking-wider"
                        >
                            <Check className="h-3 w-3 mr-1.5" /> 
                            Dispatch
                        </Button>
                    ) : (
                        <>
                           <Button 
                                size="sm" 
                                variant="ghost"
                                onClick={() => onReject(request.id)}
                                disabled={isProcessing}
                                className="text-red-600 hover:bg-red-50 h-8 px-3 rounded-lg text-[10px] font-black uppercase tracking-wider"
                            >
                                <X className="h-3 w-3 mr-1" />
                                Deny
                            </Button>
                            <Button 
                                size="sm" 
                                onClick={() => onApprove(request.id)}
                                disabled={isProcessing}
                                className="bg-blue-600 hover:bg-blue-700 h-8 px-4 rounded-lg text-[10px] font-black uppercase tracking-wider shadow-md shadow-blue-100"
                            >
                                Approve
                            </Button>
                        </>
                    )}
                </div>
            </div>
        </Card>
    )
}
