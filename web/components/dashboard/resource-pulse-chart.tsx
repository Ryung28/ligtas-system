'use client'

import { useState, useEffect } from 'react'
import { BarChart, Bar, Cell, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'

interface ResourcePulseChartProps {
    data: any[]
}

export function ResourcePulseChart({ data }: ResourcePulseChartProps) {
    const [mounted, setMounted] = useState(false)

    // Senior Dev: Use a mounting guard to ensure Recharts only renders on the client
    // This resolves ChunkLoadErrors and SSR mismatch issues in Next.js 14
    useEffect(() => {
        setMounted(true)
    }, [])

    if (!mounted) {
        return (
            <Card className="lg:col-span-8 h-[385px] bg-white/80 backdrop-blur-md border-none rounded-[1.5rem] animate-pulse" />
        )
    }

    return (
        <Card className="lg:col-span-8 bg-white/80 backdrop-blur-md shadow-xl shadow-slate-200/40 border-none rounded-[1.5rem] ring-1 ring-slate-100 overflow-hidden">
            <CardHeader className="p-6 pb-2">
                <div className="flex items-center justify-between">
                    <CardTitle className="text-sm font-heading font-semibold text-slate-900 uppercase tracking-wide">Inventory Stock Levels</CardTitle>
                    <Badge variant="secondary" className="bg-blue-50 text-blue-600 border-none font-medium text-[9px] uppercase tracking-wide px-2 py-0.5">Top Items</Badge>
                </div>
            </CardHeader>
            <CardContent className="p-6 pt-2 pl-0">
                <div className="h-[280px]">
                    <ResponsiveContainer width="100%" height="100%">
                        <BarChart data={data} layout="vertical" margin={{ left: 0, right: 40, top: 10, bottom: 10 }}>
                            <CartesianGrid strokeDasharray="3 3" horizontal={false} stroke="#f1f5f9" opacity={0.5} />
                            <XAxis type="number" hide />
                            <YAxis dataKey="name" type="category" width={130} tick={{ fontSize: 10, fontWeight: 700, fill: '#64748b' }} tickLine={false} axisLine={false} />
                            <Tooltip
                                cursor={{ fill: '#f8fafc', radius: 8 }}
                                contentStyle={{ borderRadius: '0.75rem', border: 'none', boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)', fontSize: '11px', fontWeight: 'bold' }}
                            />
                            <Bar dataKey="stock" radius={[0, 6, 6, 0]} barSize={20} fill="#3b82f6">
                                {data.map((entry, index) => (
                                    <Cell
                                        key={`cell-${index}`}
                                        fill={index < 3 ? '#3b82f6' : '#93c5fd'}
                                    />
                                ))}
                            </Bar>
                        </BarChart>
                    </ResponsiveContainer>
                </div>
            </CardContent>
        </Card>
    )
}
