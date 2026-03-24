'use client'

import { useState, useEffect } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { PieChart, Pie, Cell, Tooltip, Legend, ResponsiveContainer } from 'recharts'

interface DeploymentClustersChartProps {
    data: any[]
}

export function DeploymentClustersChart({ data }: DeploymentClustersChartProps) {
    const [mounted, setMounted] = useState(false)

    useEffect(() => {
        setMounted(true)
    }, [])

    if (!mounted) {
        return (
            <Card className="h-[270px] bg-white/80 backdrop-blur-md border-none rounded-[1.5rem] animate-pulse" />
        )
    }

    return (
        <Card className="bg-white/80 backdrop-blur-md shadow-xl shadow-slate-200/40 border-none rounded-[1.5rem] ring-1 ring-slate-100 overflow-hidden">
            <CardHeader className="p-6 pb-0">
                <CardTitle className="text-sm font-heading font-semibold text-slate-900 uppercase tracking-wide">Stock by Category</CardTitle>
            </CardHeader>
            <CardContent className="p-6 pt-2">
                <div className="h-[180px]">
                    <ResponsiveContainer width="100%" height="100%">
                        <PieChart>
                            <Pie
                                data={data}
                                innerRadius={55}
                                outerRadius={73}
                                paddingAngle={8}
                                dataKey="value"
                                stroke="none"
                                cornerRadius={6}
                            >
                                {data.map((entry, index) => (
                                    <Cell key={`cell-${index}`} fill={entry.fill} />
                                ))}
                            </Pie>
                            <Tooltip contentStyle={{ borderRadius: '0.75rem', border: 'none', boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)', fontSize: '10px' }} />
                            <Legend
                                verticalAlign="middle"
                                align="right"
                                layout="vertical"
                                iconType="circle"
                                formatter={(value) => <span className="text-[10px] font-medium text-slate-500 uppercase tracking-wide ml-1">{value}</span>}
                            />
                        </PieChart>
                    </ResponsiveContainer>
                </div>
            </CardContent>
        </Card>
    )
}
