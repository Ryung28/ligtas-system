"use client"

import { useState, useEffect } from "react"
import { Bar, BarChart, ResponsiveContainer, XAxis, YAxis, Tooltip, Cell } from "recharts"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { motion, AnimatePresence } from "framer-motion"
import { type TrendingItem } from "@/lib/validations/analytics"
import { Package } from "lucide-react"

/**
 * 🛰️ TRENDING INVENTORY CHART: TACTICAL LEADERSHIP VIZ
 * STEEL CAGE: Compressed viewport adherence for 14" screens.
 * PREMIUM: Glassmorphism + Dynamic Color Scaling.
 */

interface TrendingInventoryChartProps {
  data: TrendingItem[]
}

const CHART_COLORS = [
  "hsl(142, 70%, 45%)", // Primary Emerald
  "hsl(142, 60%, 50%)",
  "hsl(142, 50%, 55%)",
  "hsl(142, 40%, 60%)",
  "hsl(142, 30%, 65%)",
]

export function TrendingInventoryChart({ data }: TrendingInventoryChartProps) {
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  if (!mounted || !data?.length) {
    return (
      <div className="h-[310px] bg-white/80 backdrop-blur-md rounded-[1.5rem] flex items-center justify-center p-6 min-h-[300px]">
        <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest">Awaiting Tactical Intel</p>
      </div>
    )
  }

  return (
    <div className="h-[310px] p-6 pt-2">
      <div className="flex items-center justify-between mb-4 px-0">
        <div className="bg-emerald-50 text-emerald-600 px-2.5 py-1 rounded-lg font-bold text-[9px] uppercase tracking-wider border border-emerald-100">
          High Activity Borrow Patterns
        </div>
      </div>
      <ResponsiveContainer width="100%" height="100%">
        <BarChart
          data={data}
          layout="vertical"
          margin={{ left: 0, right: 40, top: 0, bottom: 0 }}
        >
          <XAxis type="number" hide />
          <YAxis
            dataKey="itemName"
            type="category"
            width={130}
            fontSize={10}
            axisLine={false}
            tickLine={false}
            tick={{ fill: "#64748b", fontWeight: 700 }}
          />

          <Tooltip
            cursor={{ fill: '#f8fafc', radius: 8 }}
            contentStyle={{ 
              borderRadius: '0.75rem', 
              border: 'none', 
              boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)', 
              fontSize: '11px', 
              fontWeight: 'bold',
              backgroundColor: 'white'
            }}
            content={({ active, payload }) => {
              if (active && payload?.[0]) {
                const item = payload[0].payload as TrendingItem
                return (
                  <div className="rounded-xl border border-slate-100 bg-white p-3 shadow-xl ring-1 ring-slate-200/50">
                    <p className="text-[11px] font-bold text-slate-900 uppercase tracking-tight">{item.itemName}</p>
                    <p className="text-[10px] text-slate-500 mt-1">
                      {item.category.toUpperCase()} • <span className="text-emerald-600 font-bold">{item.borrowCount} TIMES</span>
                    </p>
                  </div>
                )
              }
              return null
            }}
          />

          <Bar
            dataKey="borrowCount"
            radius={[0, 6, 6, 0]}
            barSize={22}
            fill="#10b981"
          >
            {data.map((_, index) => (
              <Cell 
                key={`cell-${index}`} 
                fill={index === 0 ? '#10b981' : index === 1 ? '#34d399' : '#6ee7b7'}
              />
            ))}
          </Bar>
        </BarChart>
      </ResponsiveContainer>
    </div>
  )
}

