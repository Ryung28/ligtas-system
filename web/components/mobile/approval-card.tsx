'use client'

import { BorrowLog } from '@/lib/types/inventory'
import { Card } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Check, X, User } from 'lucide-react'
import { formatDistanceToNow } from 'date-fns'
import { cn } from '@/lib/utils'
import { TacticalAssetImage } from '@/src/shared/ui/tactical-asset-image'

interface ApprovalCardProps {
    request: BorrowLog
    onApprove: (id: number, isInstant?: boolean) => void
    onReject: (id: number) => void
    onHandoff: (id: number) => void
    isProcessing: boolean
}

export function ApprovalCard({ request, onApprove, onReject, onHandoff, isProcessing }: ApprovalCardProps) {
    const isStaged = request.status === 'staged'
    const imageUrl = request.image_url || request.inventory?.image_url
    
    return (
        <Card 
            id={`request-${request.id}`}
            className={cn(
                "p-4 rounded-2xl border-none shadow-sm bg-white active:scale-[0.98] transition-all",
                "target:ring-4 target:ring-red-500/20 target:animate-pulse"
            )}
        >
            <div className="flex justify-between items-start mb-3">
                <div className="flex items-center gap-3">
                    <TacticalAssetImage 
                        url={imageUrl} 
                        alt={request.item_name}
                        size="sm"
                        className="rounded-xl shadow-sm overflow-hidden"
                    />
                    <div>
                        <h4 className="text-sm font-bold text-slate-900 leading-tight truncate max-w-[150px]">
                            {request.item_name}
                        </h4>
                        <p className="text-[10px] text-slate-500 font-medium">
                            {request.quantity} {request.quantity > 1 ? 'items' : 'item'}
                        </p>
                    </div>
                </div>
                <Badge variant="outline" className={cn(
                    "text-[9px] font-black uppercase tracking-widest px-2 py-0.5 rounded-full border-none",
                    isStaged ? "bg-amber-50 text-amber-600" : "bg-blue-50 text-blue-600"
                )}>
                    {isStaged ? "Ready" : "New"}
                </Badge>
            </div>

            <div className="flex items-center gap-2 mb-3">
                <User className="h-3 w-3 text-slate-400" />
                <span className="text-[10px] font-black uppercase tracking-widest text-slate-500">Requester:</span>
                <span className="text-[10px] font-bold text-slate-800">{request.borrower_name}</span>
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
                            Hand Over
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
                                Decline
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
