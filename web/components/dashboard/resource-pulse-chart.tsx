'use client'

import { useState, useEffect } from 'react'
import { BarChart, Bar, Cell, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts'

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
            <div className="h-[385px] bg-white/80 backdrop-blur-md rounded-[1.5rem] animate-pulse" />
        )
    }

    return (
        <div className="h-[310px] p-6 pt-2 pl-4">
            <div className="flex items-center justify-between mb-4 px-2">
                <div className="bg-blue-50 text-blue-600 px-2 py-0.5 rounded-lg font-bold text-[9px] uppercase tracking-wider">
                    Current Inventory Stock
                </div>
            </div>
            <ResponsiveContainer width="100%" height="100%">
                <BarChart data={data} layout="vertical" margin={{ left: -10, right: 40, top: 0, bottom: 0 }}>
                    <CartesianGrid strokeDasharray="3 3" horizontal={false} stroke="#f1f5f9" opacity={0.5} />
                    <XAxis type="number" hide />
                    <YAxis dataKey="name" type="category" width={100} tick={{ fontSize: 10, fontWeight: 700, fill: '#64748b' }} tickLine={false} axisLine={false} />
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
    )
}
