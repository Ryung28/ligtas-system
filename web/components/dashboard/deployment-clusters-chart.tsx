'use client'

import { useState, useEffect, useMemo } from 'react'
import { PieChart, Pie, Cell, Tooltip, ResponsiveContainer } from 'recharts'
import { Package } from 'lucide-react'

interface DeploymentClustersChartProps {
    data: any[]
}

export function DeploymentClustersChart({ data }: DeploymentClustersChartProps) {
    const [mounted, setMounted] = useState(false)

    useEffect(() => {
        setMounted(true)
    }, [])

    const totalCount = useMemo(() => {
        return data.reduce((sum, item) => sum + (item.value || 0), 0)
    }, [data])

    if (!mounted) {
        return (
            <div className="h-[320px] bg-white/80 backdrop-blur-md rounded-[1.5rem] animate-pulse" />
        )
    }

    return (
        <div className="p-6 h-full flex flex-col justify-center gap-6">
            <div className="flex items-center gap-2">
                <div className="bg-blue-50 text-blue-600 px-2 py-1 rounded-lg font-bold text-[9px] uppercase tracking-wider border border-blue-100 flex items-center gap-1.5 shadow-sm">
                    <Package className="h-3 w-3" />
                    Category Breakdown
                </div>
            </div>

            <div className="flex items-center gap-6">
                {/* Visual: Compact Donut */}
                <div className="relative h-[150px] w-[150px] shrink-0">
                    <ResponsiveContainer width="100%" height="100%">
                        <PieChart>
                            <Pie
                                data={data}
                                innerRadius={55}
                                outerRadius={70}
                                paddingAngle={6}
                                dataKey="value"
                                stroke="none"
                                cornerRadius={8}
                                animationBegin={400}
                                animationDuration={1000}
                            >
                                {data.map((entry, index) => (
                                    <Cell 
                                        key={`cell-${index}`} 
                                        fill={entry.fill} 
                                        className="hover:opacity-80 transition-opacity cursor-pointer filter drop-shadow-md"
                                    />
                                ))}
                            </Pie>
                            <Tooltip 
                                contentStyle={{ 
                                    borderRadius: '1rem', 
                                    border: 'none', 
                                    boxShadow: '0 20px 25px -5px rgb(0 0 0 / 0.1)', 
                                    fontSize: '11px',
                                    padding: '12px'
                                }} 
                            />
                        </PieChart>
                    </ResponsiveContainer>
                    {/* Statistical Core: Central Value */}
                    <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none">
                        <span className="text-[9px] items-center gap-1 font-bold text-slate-400 uppercase tracking-widest mb-0.5">Total</span>
                        <span className="text-xl font-black text-slate-900 font-heading leading-none tracking-tighter">
                            {totalCount} 
                        </span>
                        <span className="text-[8px] font-bold text-slate-400 uppercase tracking-widest mt-1 italic">Units</span>
                    </div>
                </div>

                {/* Data: Detailed Category Ledger with Hairline Dividers */}
                <div className="flex-1 divide-y divide-slate-100/60 pr-2 overflow-y-auto max-h-[220px] scrollbar-hide">
                    {data.sort((a, b) => b.value - a.value).map((item, index) => (
                        <div key={index} className="group flex items-center justify-between gap-4 py-3 px-2 first:pt-0 last:pb-0 hover:bg-slate-50/50 transition-colors rounded-lg">
                            <div className="flex items-center gap-3">
                                <div 
                                    className="h-2 rounded-full ring-2 ring-white shadow-sm w-2" 
                                    style={{ backgroundColor: item.fill }}
                                />
                                <span className="text-[10px] font-bold text-slate-500 uppercase tracking-wider group-hover:text-slate-900 transition-colors">
                                    {item.name}
                                </span>
                            </div>
                            <div className="flex items-center gap-3">
                                <span className="text-xs font-black text-slate-800 tabular-nums">
                                    {item.value}
                                </span>
                                <span className="text-[9px] font-bold text-slate-400 uppercase italic">
                                    {((item.value / totalCount) * 100).toFixed(0)}%
                                </span>
                            </div>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    )
}
