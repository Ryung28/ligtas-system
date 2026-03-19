import React from 'react'
import { Category, TypeConfig } from '../types/notification.types'

// ─── Icons (inline SVG) ───────────────────────────────────────────────────────
export const Icons = {
  logo: (
    <svg viewBox="0 0 24 24" fill="none" className="w-5 h-5">
      <path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9M13.73 21a2 2 0 01-3.46 0" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  ),
  refresh: (
    <svg viewBox="0 0 24 24" fill="none" className="w-4 h-4">
      <path d="M4 12a8 8 0 018-8 8 8 0 016.32 3.1L21 4v6h-6l2.18-2.18A6 6 0 106 12" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  ),
  check: (
    <svg viewBox="0 0 24 24" fill="none" className="w-4 h-4">
      <path d="M4 12l5 5L20 7" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  ),
  allLayers: (
    <svg viewBox="0 0 24 24" fill="none" className="w-4 h-4">
      <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  ),
  shield: (
    <svg viewBox="0 0 24 24" fill="none" className="w-4 h-4">
      <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  ),
  users: (
    <svg viewBox="0 0 24 24" fill="none" className="w-4 h-4">
      <path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round"/>
      <circle cx="9" cy="7" r="4" stroke="currentColor" strokeWidth="1.8"/>
      <path d="M23 21v-2a4 4 0 00-3-3.87M16 3.13a4 4 0 010 7.75" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round"/>
    </svg>
  ),
  bell: (
    <svg viewBox="0 0 24 24" fill="none" className="w-4 h-4">
      <path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9M13.73 21a2 2 0 01-3.46 0" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  ),
  box: (
    <svg viewBox="0 0 24 24" fill="none" className="w-5 h-5">
      <path d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z" stroke="currentColor" strokeWidth="1.8"/>
      <path d="M3.27 6.96L12 12.01l8.73-5.05M12 22.08V12" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round"/>
    </svg>
  ),
  arrowUpRight: (
    <svg viewBox="0 0 24 24" fill="none" className="w-3.5 h-3.5">
      <path d="M7 17L17 7M7 7h10v10" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  ),
  scan: (
    <svg viewBox="0 0 24 24" fill="none" className="w-5 h-5">
      <path d="M3 9V5a2 2 0 012-2h4M3 15v4a2 2 0 002 2h4M15 3h4a2 2 0 012 2v4M15 21h4a2 2 0 002-2v-4" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round"/>
      <line x1="3" y1="12" x2="21" y2="12" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round"/>
    </svg>
  ),
  package: (
    <svg viewBox="0 0 24 24" fill="none" className="w-6 h-6">
      <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/>
      <path d="M12 12v10" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round"/>
    </svg>
  ),
  trash: (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="w-3.5 h-3.5">
      <path d="M3 6h18M19 6v14a2 2 0 01-2 2H7a2 2 0 01-2-2V6m3 0V4a2 2 0 012-2h4a2 2 0 012 2v2M10 11v6M14 11v6"/>
    </svg>
  ),
}

// ─── Config Maps ──────────────────────────────────────────────────────────────
export const TYPE_CONFIG: Record<string, TypeConfig> = {
  user_pending: {
    icon: Icons.shield,
    label: "Security",
    accent: "#ef4444",
    bg: "rgba(239,68,68,0.08)",
    border: "rgba(239,68,68,0.2)",
  },
  user_request: {
    icon: Icons.shield,
    label: "Security",
    accent: "#ef4444",
    bg: "rgba(239,68,68,0.08)",
    border: "rgba(239,68,68,0.2)",
  },
  borrow: {
    icon: Icons.box,
    label: "Logistics",
    accent: "#6366f1",
    bg: "rgba(99,102,241,0.08)",
    border: "rgba(99,102,241,0.2)",
  },
  return: {
    icon: Icons.box,
    label: "Logistics",
    accent: "#6366f1",
    bg: "rgba(99,102,241,0.08)",
    border: "rgba(99,102,241,0.2)",
  },
  borrow_request: {
    icon: Icons.box,
    label: "Logistics",
    accent: "#6366f1",
    bg: "rgba(99,102,241,0.08)",
    border: "rgba(99,102,241,0.2)",
  },
  stock_low: {
    icon: Icons.bell,
    label: "Alert",
    accent: "#f59e0b",
    bg: "rgba(245,158,11,0.08)",
    border: "rgba(245,158,11,0.2)",
  },
  stock_out: {
    icon: Icons.bell,
    label: "Alert",
    accent: "#f59e0b",
    bg: "rgba(245,158,11,0.08)",
    border: "rgba(245,158,11,0.2)",
  },
  low_stock: {
    icon: Icons.bell,
    label: "Alert",
    accent: "#f59e0b",
    bg: "rgba(245,158,11,0.08)",
    border: "rgba(245,158,11,0.2)",
  },
  overdue_alert: {
    icon: Icons.bell,
    label: "Alert",
    accent: "#f59e0b",
    bg: "rgba(245,158,11,0.08)",
    border: "rgba(245,158,11,0.2)",
  },
}

export const FILTER_MAP: Record<Category, string[]> = {
  ALL: ['borrow', 'return', 'borrow_request', 'user_pending', 'user_request', 'stock_low', 'stock_out', 'low_stock', 'overdue_alert'],
  LOGS: ['borrow', 'return', 'borrow_request'],
  AUTH: ['user_pending', 'user_request'],
  ALERTS: ['stock_low', 'stock_out', 'low_stock', 'overdue_alert'],
}
