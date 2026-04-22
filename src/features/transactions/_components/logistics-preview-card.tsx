'use client';

import Image from 'next/image';
import { Package, MapPin, Info, AlertCircle } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { TacticalAssetImage } from '@/src/shared/ui/tactical-asset-image';

interface LogisticsPreviewCardProps {
    item: {
        item_name: string;
        category: string;
        image_url?: string | null;
        primary_location?: string;
        primary_stock_available?: number;
        status?: string;
    } | null;
    isLoading?: boolean;
}

/**
 * LogisticsPreviewCard Molecule
 * A high-fidelity card used in Transaction V2 to verify equipment details
 * before finalizing a borrow or return action.
 */
export function LogisticsPreviewCard({ item, isLoading }: LogisticsPreviewCardProps) {
    if (isLoading) {
        return <LogisticsPreviewSkeleton />;
    }

    if (!item) return null;

    const stock = item.primary_stock_available ?? 0;
    const isLowStock = stock <= 2;

    return (
        <Card className="overflow-hidden border-blue-100 bg-gradient-to-br from-blue-50/30 to-white shadow-sm transition-all duration-300 animate-in fade-in slide-in-from-top-2">
            <CardContent className="p-3">
                <div className="flex gap-4 items-center">
                    {/* Item Thumbnail with SSOT Integration */}
                    <TacticalAssetImage 
                        url={item.image_url} 
                        alt={item.item_name}
                        size="md"
                        className="rounded-lg shadow-sm shrink-0"
                    />

                    {/* Logistics Metadata Stack */}
                    <div className="flex-1 min-w-0">
                        <div className="flex items-center justify-between gap-2 mb-0.5">
                            <h4 className="font-bold text-slate-900 truncate uppercase tracking-tight text-[11px]">
                                {item.item_name}
                            </h4>
                            <Badge 
                                variant={isLowStock ? "destructive" : "outline"} 
                                className={`text-[9px] h-4 px-1.5 font-bold ${!isLowStock && 'border-green-200 text-green-700 bg-green-50'}`}
                            >
                                {isLowStock && <AlertCircle className="w-2.5 h-2.5 mr-1" />}
                                {stock} UNITS
                            </Badge>
                        </div>

                        <div className="flex flex-col gap-1">
                            <div className="flex items-center gap-1 text-[10px] text-slate-500">
                                <Info className="w-3 h-3 text-slate-400" />
                                <span className="truncate">{item.category}</span>
                            </div>

                            <div className="flex items-center gap-1 text-[10px] font-semibold text-blue-700 bg-blue-50/50 rounded px-1.5 py-0.5 w-fit border border-blue-100 uppercase">
                                <MapPin className="w-3 h-3" />
                                <span className="truncate">{item.primary_location || 'GENERAL STORAGE'}</span>
                            </div>
                        </div>
                    </div>
                </div>
            </CardContent>
        </Card>
    );
}

function LogisticsPreviewSkeleton() {
    return (
        <div className="flex items-center space-x-4 p-3 border rounded-xl bg-slate-50/50 border-slate-100">
            <Skeleton className="h-16 w-16 rounded-md" />
            <div className="space-y-2 flex-1">
                <Skeleton className="h-3 w-[60%]" />
                <Skeleton className="h-2 w-[40%]" />
                <div className="flex items-center space-x-2 pt-1">
                    <Skeleton className="h-4 w-24" />
                </div>
            </div>
        </div>
    );
}
