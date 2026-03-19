'use client'

import React from 'react'
import { motion } from 'framer-motion'

export function NotificationSkeleton({ index }: { index: number }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 16 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: index * 0.05 }}
      className="rounded-xl overflow-hidden"
      style={{
        background: "rgba(255,255,255,0.72)",
        border: "1px solid rgba(0,0,0,0.07)",
      }}
    >
      <div className="p-3 pl-4">
        <div className="flex items-start gap-2.5">
          <div className="flex-shrink-0 w-8 h-8 rounded-lg bg-gray-200 animate-pulse" />
          <div className="flex-1 space-y-1.5">
            <div className="h-2.5 bg-gray-200 rounded w-16 animate-pulse" />
            <div className="h-3 bg-gray-200 rounded w-3/4 animate-pulse" />
            <div className="h-2.5 bg-gray-200 rounded w-full animate-pulse" />
            <div className="h-7 bg-gray-200 rounded w-20 animate-pulse mt-2" />
          </div>
        </div>
      </div>
    </motion.div>
  )
}
