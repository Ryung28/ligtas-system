'use client'

import { motion, AnimatePresence } from 'framer-motion'
import { Package, Clock, ShieldAlert, ArrowUpRight, CheckCircle2, RefreshCw, AlertTriangle, Thermometer, ShieldCheck } from 'lucide-react'
import { formatDistanceToNow } from 'date-fns'
import Link from 'next/link'
import useSWR from 'swr'
import { createBrowserClient } from '@supabase/ssr'
import { useEffect, useMemo, useState } from 'react'
import { isLowStock } from '@/lib/inventory-utils'
import { isExpiringSoon } from '@/lib/expiry-utils'
import type { InventoryItem } from '@/lib/supabase'
import { getInventoryAlerts } from '../../src/features/catalog/actions/catalog.actions'

interface SystemIntel {
    id: string
    category: 'INVENTORY' | 'LOGISTICS' | 'OVERDUE' | 'ACCESS'
    priority: 'CRITICAL' | 'WARNING' | 'INFO'
    title: string
    message: string
    metadata: any
    created_at: string
}

const supabase = createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)

const fetchIntel = async (): Promise<SystemIntel[]> => {
    const { data, error } = await supabase
        .from('system_intel')
        .select('*')
        .order('priority', { ascending: true }) // CRITICAL < INFO, but we'll sort custom below if needed. Actually it's text.
        // Let's just order by created_at DESC for a feed
        .order('created_at', { ascending: false })
        .limit(500)

    if (error) {
        console.error('Error fetching system intel:', error)
        return []
    }
    
    // Custom sort to put CRITICAL first, then WARNING, then INFO
    const priorityWeight = { CRITICAL: 3, WARNING: 2, INFO: 1 }
    return (data as SystemIntel[]).sort((a, b) => {
        if (priorityWeight[a.priority] !== priorityWeight[b.priority]) {
            return priorityWeight[b.priority] - priorityWeight[a.priority]
        }
        return new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
    })
}

const CATEGORY_CONFIG = {
    INVENTORY: { icon: Package, color: 'text-amber-600', bg: 'bg-amber-100', border: 'border-amber-200', href: '/dashboard/inventory' },
    LOGISTICS: { icon: RefreshCw, color: 'text-blue-600', bg: 'bg-blue-100', border: 'border-blue-200', href: '/dashboard/approvals' },
    OVERDUE: { icon: Clock, color: 'text-red-600', bg: 'bg-red-100', border: 'border-red-200', href: '/dashboard/logs' },
    ACCESS: { icon: ShieldAlert, color: 'text-purple-600', bg: 'bg-purple-100', border: 'border-purple-200', href: '/dashboard/users' }
}

import { resolveSystemRoute } from '@/lib/utils/route-resolver'

/** Narrow `system_intel` rows to inventory alert sub-types (metadata must include stock/expiry fields). */
type InventoryIntelFilter = 'all' | 'out_of_stock' | 'low_stock' | 'expiring'

function metadataAsInventoryPartial(metadata: Record<string, unknown> | null | undefined): Partial<InventoryItem> {
    if (!metadata || typeof metadata !== 'object') return {}
    const m = metadata as Record<string, unknown>
    return {
        stock_available: typeof m.stock_available === 'number' ? m.stock_available : Number(m.stock_available ?? 0),
        target_stock: typeof m.target_stock === 'number' ? m.target_stock : Number(m.target_stock ?? 0),
        low_stock_threshold: typeof m.low_stock_threshold === 'number' ? m.low_stock_threshold : Number(m.low_stock_threshold ?? 0),
        restock_alert_enabled: m.restock_alert_enabled !== false,
        status: typeof m.status === 'string' ? m.status : undefined,
        expiry_date: typeof m.expiry_date === 'string' ? m.expiry_date : undefined,
        expiry_alert_days:
            m.expiry_alert_days == null ? undefined : typeof m.expiry_alert_days === 'number' ? m.expiry_alert_days : Number(m.expiry_alert_days),
    }
}

/** Action Center lists one `system_intel` row per pending `access_requests` row; duplicates (same user, multiple pending rows) inflate the count vs Users. Keep the first row per person after the global sort (newest-first within INFO). */
function dedupeAccessIntelRows(items: SystemIntel[]): SystemIntel[] {
    const seen = new Set<string>()
    return items.filter((item) => {
        if (item.category !== 'ACCESS') return true
        const uid = String(item.metadata?.borrower_user_id ?? item.metadata?.email ?? '').trim()
        if (!uid) return true
        if (seen.has(uid)) return false
        seen.add(uid)
        return true
    })
}

function inventoryRowMatchesFilter(item: SystemIntel, filter: InventoryIntelFilter): boolean {
    if (item.category !== 'INVENTORY') return false
    const m = item.metadata || {}
    const row = metadataAsInventoryPartial(m)
    const stock = row.stock_available ?? 0

    switch (filter) {
        case 'out_of_stock':
            return stock <= 0
        case 'low_stock':
            return isLowStock(row)
        case 'expiring':
            return isExpiringSoon(row.expiry_date, row.expiry_alert_days)
        default:
            return true
    }
}

export function LogisticsIntelQueue() {
    const { data: intel = [], isLoading: isIntelLoading, mutate } = useSWR('system_intel', fetchIntel, {
        refreshInterval: 10000,
    })

    const { data: alertData, isLoading: isAlertsLoading } = useSWR('inventory_actionable_alerts', async () => {
        const result = await getInventoryAlerts()
        return result.success ? result : null
    }, { refreshInterval: 15000 })

    const [inventoryFilter, setInventoryFilter] = useState<InventoryIntelFilter>('all')

    const intelDedupedAccess = useMemo(() => dedupeAccessIntelRows(intel), [intel])

    // 🎯 INTEL FUSION: Merge system logs with live actionable view items
    const displayedIntel = useMemo(() => {
        let baseItems = intelDedupedAccess;

        // If we have live view items, we prioritize them for the INVENTORY category
        // to ensure real-time accuracy even if logs haven't been generated yet.
        if (alertData?.items) {
            const liveInventoryItems: SystemIntel[] = alertData.items.map((item: any) => ({
                id: `live-${item.id}`,
                category: 'INVENTORY' as const,
                priority: item.is_out_of_stock ? 'CRITICAL' : 'WARNING' as const,
                title: item.item_name,
                message: item.is_out_of_stock ? 'OUT OF STOCK' : item.is_low_stock ? 'LOW STOCK' : 'EXPIRING',
                metadata: {
                    item_id: item.id,
                    item_name: item.item_name,
                    stock_available: item.stock_available,
                    target_stock: item.target_stock,
                    expiry_date: item.expiry_date
                },
                created_at: new Date().toISOString() // Live items are "now"
            }));

            // Filter out old inventory logs to avoid duplicates if we have live data
            const nonInventoryLogs = baseItems.filter(i => i.category !== 'INVENTORY');
            baseItems = [...liveInventoryItems, ...nonInventoryLogs];
        }

        if (inventoryFilter === 'all') return baseItems
        return baseItems.filter((row) => inventoryRowMatchesFilter(row, inventoryFilter))
    }, [intelDedupedAccess, alertData, inventoryFilter])

    const isLoading = isIntelLoading || isAlertsLoading;

    // Realtime Pulse
    useEffect(() => {
        const channel = supabase.channel('system_intel_changes')
            .on('postgres_changes', { event: '*', schema: 'public', table: 'inventory' }, () => mutate())
            .on('postgres_changes', { event: '*', schema: 'public', table: 'logistics_actions' }, () => mutate())
            .on('postgres_changes', { event: '*', schema: 'public', table: 'borrow_logs' }, () => mutate())
            .on('postgres_changes', { event: '*', schema: 'public', table: 'access_requests' }, () => mutate())
            .subscribe()

        return () => {
            supabase.removeChannel(channel)
        }
    }, [mutate])

    const filterChip = (id: InventoryIntelFilter, label: string) => {
        const active = inventoryFilter === id
        return (
            <button
                type="button"
                key={id}
                onClick={() => setInventoryFilter(id)}
                className={`rounded-lg px-2.5 py-1 text-[9px] font-black uppercase tracking-wide transition-all border ${
                    active
                        ? 'border-slate-900 bg-slate-900 text-white shadow-sm'
                        : 'border-slate-200 bg-white text-slate-500 hover:border-slate-300 hover:bg-slate-50'
                }`}
            >
                {label}
            </button>
        )
    }

    const stats = alertData?.data;

    return (
        <div className="flex flex-col h-full bg-white/50 backdrop-blur-sm">
            {/* 🛡️ TACTICAL STATUS HUB */}
            <div className="grid grid-cols-4 gap-2 p-2 bg-slate-50/50 border-b border-slate-100">
                <div className="flex flex-col items-center justify-center p-2 rounded-xl bg-white border border-slate-100 shadow-sm">
                    <span className="text-[14px] font-black text-rose-600 leading-none">{stats?.out_of_stock || 0}</span>
                    <span className="text-[8px] font-bold text-slate-400 uppercase mt-1">OOS</span>
                </div>
                <div className="flex flex-col items-center justify-center p-2 rounded-xl bg-white border border-slate-100 shadow-sm">
                    <span className="text-[14px] font-black text-amber-600 leading-none">{stats?.low_stock || 0}</span>
                    <span className="text-[8px] font-bold text-slate-400 uppercase mt-1">Low</span>
                </div>
                <div className="flex flex-col items-center justify-center p-2 rounded-xl bg-white border border-slate-100 shadow-sm">
                    <span className="text-[14px] font-black text-orange-600 leading-none">{stats?.expiring_soon || 0}</span>
                    <span className="text-[8px] font-bold text-slate-400 uppercase mt-1">Expire</span>
                </div>
                <div className="flex flex-col items-center justify-center p-2 rounded-xl bg-white border border-slate-100 shadow-sm">
                    <span className="text-[14px] font-black text-slate-900 leading-none">{stats?.damaged || 0}</span>
                    <span className="text-[8px] font-bold text-slate-400 uppercase mt-1">Issue</span>
                </div>
            </div>

            <div className="shrink-0 px-2 pt-2 pb-1.5 border-b border-slate-100/80">
                <div className="flex items-center justify-between mb-1.5">
                    <p className="text-[8px] font-black uppercase tracking-[0.12em] text-slate-400">Inventory alerts</p>
                    {stats?.total_active_alerts && stats.total_active_alerts > 0 && (
                        <div className="flex items-center gap-1">
                            <span className="h-1.5 w-1.5 rounded-full bg-red-500 animate-pulse"></span>
                            <span className="text-[8px] font-bold text-red-600 uppercase tracking-tight">{stats.total_active_alerts} Critical</span>
                        </div>
                    )}
                </div>
                <div className="flex flex-wrap gap-1.5">
                    {filterChip('all', 'All')}
                    {filterChip('out_of_stock', 'Out of stock')}
                    {filterChip('low_stock', 'Low stock')}
                    {filterChip('expiring', 'Expiring')}
                </div>
            </div>
            <div className="flex-1 overflow-y-auto px-2 divide-y divide-slate-100/60 scrollbar-hide max-h-[340px]">
                <AnimatePresence mode="popLayout">
                    {isLoading ? (
                        <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="flex flex-col items-center justify-center h-40 text-slate-400 gap-3">
                            <RefreshCw className="h-5 w-5 animate-spin" />
                            <span className="text-xs font-medium uppercase tracking-widest">Updating data...</span>
                        </motion.div>
                    ) : intelDedupedAccess.length === 0 ? (
                        <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="flex items-center justify-center h-40 text-slate-400 gap-4">
                            <div className="h-10 w-10 rounded-xl bg-emerald-50 flex items-center justify-center border border-emerald-100">
                                <CheckCircle2 className="h-5 w-5 text-emerald-500" />
                            </div>
                            <div className="text-left">
                                <p className="text-xs font-bold text-slate-700">All Clear</p>
                                <p className="text-[10px] font-medium uppercase tracking-widest text-slate-400 italic">No tasks pending</p>
                            </div>
                        </motion.div>
                    ) : displayedIntel.length === 0 ? (
                        <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="flex flex-col items-center justify-center h-36 px-4 text-center text-slate-400 gap-2">
                            <Package className="h-8 w-8 opacity-40" />
                            <p className="text-xs font-bold text-slate-600">No alerts in this view</p>
                            <p className="text-[10px] font-medium text-slate-400 max-w-[220px]">
                                Try another filter, or open Inventory for the full registry.
                            </p>
                        </motion.div>
                    ) : (
                        displayedIntel.map((item, i) => {
                            const config = CATEGORY_CONFIG[item.category] || CATEGORY_CONFIG.INVENTORY
                            const Icon = config.icon

                            const target = resolveSystemRoute({
                                type: item.priority === 'CRITICAL' ? 'logistics_alert' : item.category.toLowerCase(),
                                category: item.category,
                                metadata: item.metadata,
                                reference_id: item.metadata?.borrow_id || item.metadata?.log_id || (item as any).reference_id,
                                id: item.id,
                                title: item.title
                            })

                            return (
                                <motion.div
                                    key={item.id}
                                    layout
                                    initial={{ opacity: 0, y: 5 }}
                                    animate={{ opacity: 1, y: 0 }}
                                    exit={{ opacity: 0, scale: 0.98 }}
                                    transition={{ duration: 0.2 }}
                                >
                                    <Link 
                                        href={target || config.href}
                                        className="group flex items-center gap-4 py-4 px-2 hover:bg-slate-50/80 transition-colors cursor-pointer"
                                    >
                                        <div className={`shrink-0 h-8 w-8 rounded-lg flex items-center justify-center border ${config.bg} ${config.border} ${config.color} shadow-sm ring-1 ring-white`}>
                                            <Icon className="h-4 w-4" />
                                        </div>
                                        <div className="flex-1 min-w-0">
                                            <div className="flex items-center gap-2 mb-0.5">
                                                <span className={`text-[8px] font-black tracking-[0.1em] uppercase ${config.color}`}>
                                                    {item.category}
                                                </span>
                                                <span className="text-[10px] font-medium text-slate-400 tabular-nums">
                                                    • {item.created_at ? formatDistanceToNow(new Date(item.created_at), { addSuffix: false }) : 'now'}
                                                </span>
                                            </div>
                                            <div className="mb-1 text-slate-400">
                                                <p className="text-[11px] font-black text-slate-900 leading-tight uppercase truncate">
                                                    {item.title}
                                                </p>
                                            </div>

                                            <div className="mb-2">
                                                <p className="text-[11px] font-bold text-slate-700 font-sans truncate">
                                                    {item.metadata?.borrower_name || item.title}
                                                </p>
                                                {item.metadata?.borrower_organization && (
                                                    <span className="text-[7px] inline-block bg-slate-100 text-slate-500 px-1 py-0.5 rounded-[2px] font-black uppercase tracking-[0.1em] leading-none border border-slate-200 mt-1">
                                                        {item.metadata.borrower_organization}
                                                    </span>
                                                )}
                                            </div>

                                            {item.metadata?.item_name && (
                                                <div className="mb-2">
                                                    <span className="inline-flex items-center gap-1.5 text-zinc-900 font-bold bg-zinc-50 px-1.5 py-1 rounded-[4px] border border-zinc-200 uppercase text-[9px] tracking-tight shadow-sm">
                                                        <span className="opacity-60 text-[8px]">ITEM:</span>
                                                        {item.metadata.item_name}
                                                        {item.metadata.quantity && (
                                                            <span className="text-zinc-400 bg-white px-0.5 rounded-[1px] border border-zinc-100 font-mono italic">x{item.metadata.quantity}</span>
                                                        )}
                                                    </span>
                                                </div>
                                            )}

                                            <p className="text-[11px] text-slate-500 font-medium line-clamp-2 opacity-90 font-sans leading-relaxed">
                                                {(() => {
                                                    if (item.category === 'ACCESS') {
                                                        return 'Needs approval: open Mobile App Users, then Pending Requests.'
                                                    }
                                                    const rawMessage = item.message || ''
                                                    const cleanMessage = rawMessage
                                                        .replace(/New borrow request from .*?:|New borrow request from .*?\s|New borrow request from/gi, '')
                                                        .replace(/\d+\)\s*/g, '')
                                                        .replace(new RegExp(item.metadata?.item_name || '___NONE___', 'gi'), '')
                                                        .replace(/\(Qty:\s*\d+\)/gi, '')
                                                        .trim()

                                                    return cleanMessage || 'Details pending.'
                                                })()}
                                            </p>
                                        </div>
                                        <div className="shrink-0 flex items-center gap-1 text-[9px] font-black uppercase tracking-wider px-2.5 py-1.5 rounded-lg border border-slate-200 text-slate-500 group-hover:bg-slate-900 group-hover:text-white group-hover:border-slate-900 transition-all shadow-sm bg-white">
                                            <ArrowUpRight className="h-3 w-3" />
                                        </div>
                                    </Link>
                                </motion.div>
                            )
                        })
                    )}
                </AnimatePresence>
            </div>
        </div>
    )
}
