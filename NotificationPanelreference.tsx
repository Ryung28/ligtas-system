"use client";

import { useState, useEffect } from "react";
import { motion, AnimatePresence, stagger, useAnimate } from "framer-motion";

// ─── Types ────────────────────────────────────────────────────────────────────
type Category = "ALL" | "LOGS" | "AUTH" | "ALERTS";

interface Notification {
  id: string;
  type: "SECURITY" | "LOGISTICS" | "AUTH" | "ALERT";
  title: string;
  description: string;
  time: string;
  action: string;
  read: boolean;
}

// ─── Mock Data ────────────────────────────────────────────────────────────────
const NOTIFICATIONS: Notification[] = [
  {
    id: "1",
    type: "SECURITY",
    title: "New Access Request",
    description: "Brandon is requesting system credentials.",
    time: "1 day ago",
    action: "Review Access",
    read: false,
  },
  {
    id: "2",
    type: "LOGISTICS",
    title: "Logistics Alert",
    description: "New borrow request from Lll (Qty: 1)",
    time: "1 day ago",
    action: "Manage Log",
    read: false,
  },
  {
    id: "3",
    type: "AUTH",
    title: "Login Attempt",
    description: "Unrecognized device logged in from Manila, PH.",
    time: "3 hrs ago",
    action: "View Details",
    read: true,
  },
  {
    id: "4",
    type: "ALERT",
    title: "System Threshold",
    description: "CPU usage exceeded 90% on node cluster-04.",
    time: "5 hrs ago",
    action: "See Report",
    read: true,
  },
];

// ─── Icons (inline SVG) ───────────────────────────────────────────────────────
const Icons = {
  logo: (
    <svg viewBox="0 0 24 24" fill="none" className="w-5 h-5">
      <rect x="2" y="3" width="20" height="14" rx="3" stroke="currentColor" strokeWidth="1.8"/>
      <path d="M8 21h8M12 17v4" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round"/>
      <path d="M6 8h4M6 11h8" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/>
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
  close: (
    <svg viewBox="0 0 24 24" fill="none" className="w-5 h-5">
      <path d="M18 6L6 18M6 6l12 12" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
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
};

// ─── Config Maps ──────────────────────────────────────────────────────────────
const TYPE_CONFIG = {
  SECURITY: {
    icon: Icons.shield,
    label: "Security",
    accent: "#ef4444",
    bg: "rgba(239,68,68,0.08)",
    border: "rgba(239,68,68,0.2)",
    dot: "#ef4444",
  },
  LOGISTICS: {
    icon: Icons.box,
    label: "Logistics",
    accent: "#6366f1",
    bg: "rgba(99,102,241,0.08)",
    border: "rgba(99,102,241,0.2)",
    dot: "#6366f1",
  },
  AUTH: {
    icon: Icons.users,
    label: "Auth",
    accent: "#f59e0b",
    bg: "rgba(245,158,11,0.08)",
    border: "rgba(245,158,11,0.2)",
    dot: "#f59e0b",
  },
  ALERT: {
    icon: Icons.bell,
    label: "Alert",
    accent: "#10b981",
    bg: "rgba(16,185,129,0.08)",
    border: "rgba(16,185,129,0.2)",
    dot: "#10b981",
  },
};

const FILTER_MAP: Record<Category, Notification["type"][]> = {
  ALL: ["SECURITY", "LOGISTICS", "AUTH", "ALERT"],
  LOGS: ["LOGISTICS"],
  AUTH: ["AUTH"],
  ALERTS: ["ALERT", "SECURITY"],
};

// ─── Notification Card ────────────────────────────────────────────────────────
function NotificationCard({
  notif,
  index,
  onMarkRead,
}: {
  notif: Notification;
  index: number;
  onMarkRead: (id: string) => void;
}) {
  const cfg = TYPE_CONFIG[notif.type];

  return (
    <motion.div
      layout
      initial={{ opacity: 0, y: 16, scale: 0.97 }}
      animate={{ opacity: 1, y: 0, scale: 1 }}
      exit={{ opacity: 0, scale: 0.95, y: -8 }}
      transition={{ delay: index * 0.06, duration: 0.35, ease: [0.22, 1, 0.36, 1] }}
      className="group relative rounded-2xl overflow-hidden cursor-pointer"
      style={{
        background: "rgba(255,255,255,0.72)",
        border: "1px solid rgba(0,0,0,0.07)",
        backdropFilter: "blur(12px)",
        boxShadow: "0 2px 12px rgba(0,0,0,0.04), 0 1px 3px rgba(0,0,0,0.03)",
      }}
      whileHover={{
        y: -2,
        boxShadow: "0 8px 32px rgba(0,0,0,0.1), 0 2px 8px rgba(0,0,0,0.06)",
        transition: { duration: 0.2 },
      }}
    >
      {/* Unread indicator bar */}
      <AnimatePresence>
        {!notif.read && (
          <motion.div
            initial={{ scaleY: 0 }}
            animate={{ scaleY: 1 }}
            exit={{ scaleY: 0 }}
            className="absolute left-0 top-0 bottom-0 w-[3px] rounded-l-2xl origin-top"
            style={{ background: cfg.accent }}
          />
        )}
      </AnimatePresence>

      <div className="p-4 pl-5">
        <div className="flex items-start gap-3">
          {/* Icon badge */}
          <motion.div
            className="flex-shrink-0 w-10 h-10 rounded-xl flex items-center justify-center mt-0.5"
            style={{ background: cfg.bg, border: `1px solid ${cfg.border}`, color: cfg.accent }}
            whileHover={{ rotate: [0, -8, 8, 0], transition: { duration: 0.4 } }}
          >
            {cfg.icon}
          </motion.div>

          <div className="flex-1 min-w-0">
            {/* Header row */}
            <div className="flex items-center justify-between gap-2 mb-1">
              <div className="flex items-center gap-2">
                <span
                  className="text-[10px] font-bold tracking-widest uppercase"
                  style={{ color: cfg.accent }}
                >
                  {cfg.label}
                </span>
                {!notif.read && (
                  <motion.span
                    animate={{ scale: [1, 1.3, 1] }}
                    transition={{ repeat: Infinity, duration: 2, ease: "easeInOut" }}
                    className="w-1.5 h-1.5 rounded-full"
                    style={{ background: cfg.dot }}
                  />
                )}
              </div>
              <span className="text-[11px] text-gray-400 font-medium flex-shrink-0">{notif.time}</span>
            </div>

            {/* Title */}
            <h3 className="font-black text-[15px] text-gray-900 leading-tight tracking-tight mb-1">
              {notif.title}
            </h3>

            {/* Description */}
            <p className="text-[13px] text-gray-500 leading-relaxed mb-3">{notif.description}</p>

            {/* Action row */}
            <div className="flex items-center justify-between">
              <motion.button
                className="flex items-center gap-1.5 text-[11px] font-bold tracking-widest uppercase px-3 py-1.5 rounded-lg transition-colors"
                style={{
                  background: "rgba(0,0,0,0.04)",
                  border: "1px solid rgba(0,0,0,0.08)",
                  color: "#374151",
                }}
                whileHover={{
                  background: cfg.bg,
                  borderColor: cfg.border,
                  color: cfg.accent,
                }}
                whileTap={{ scale: 0.97 }}
              >
                {notif.action}
                <motion.span
                  initial={{ x: 0, y: 0 }}
                  whileHover={{ x: 2, y: -2 }}
                  transition={{ duration: 0.15 }}
                >
                  {Icons.arrowUpRight}
                </motion.span>
              </motion.button>

              {!notif.read && (
                <motion.button
                  onClick={(e) => { e.stopPropagation(); onMarkRead(notif.id); }}
                  className="text-[11px] text-gray-400 hover:text-gray-700 font-medium transition-colors px-2 py-1"
                  whileTap={{ scale: 0.95 }}
                >
                  Mark read
                </motion.button>
              )}
            </div>
          </div>
        </div>
      </div>
    </motion.div>
  );
}

// ─── Main Component ───────────────────────────────────────────────────────────
export default function TacticalCloudPanel() {
  const [activeFilter, setActiveFilter] = useState<Category>("ALL");
  const [notifications, setNotifications] = useState<Notification[]>(NOTIFICATIONS);
  const [isScanning, setIsScanning] = useState(false);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [allRead, setAllRead] = useState(false);

  const filtered = notifications.filter((n) =>
    FILTER_MAP[activeFilter].includes(n.type)
  );

  const unreadCount = notifications.filter((n) => !n.read).length;

  const handleMarkRead = (id: string) => {
    setNotifications((prev) =>
      prev.map((n) => (n.id === id ? { ...n, read: true } : n))
    );
  };

  const handleMarkAllRead = () => {
    setAllRead(true);
    setNotifications((prev) => prev.map((n) => ({ ...n, read: true })));
  };

  const handleRefresh = () => {
    setIsRefreshing(true);
    setTimeout(() => setIsRefreshing(false), 1200);
  };

  const handleScan = () => {
    setIsScanning(true);
    setTimeout(() => setIsScanning(false), 2400);
  };

  const FILTERS: Category[] = ["ALL", "LOGS", "AUTH", "ALERTS"];

  return (
    <>
      {/* Google Fonts */}
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Syne:wght@400;600;700;800&family=DM+Sans:ital,wght@0,300;0,400;0,500;1,400&display=swap');
        * { font-family: 'DM Sans', sans-serif; }
        .font-display { font-family: 'Syne', sans-serif !important; }
        .scrollbar-hide::-webkit-scrollbar { display: none; }
        .scrollbar-hide { -ms-overflow-style: none; scrollbar-width: none; }
      `}</style>

      <div className="min-h-screen flex items-center justify-center p-6"
        style={{ background: "linear-gradient(135deg, #e8eaf0 0%, #dde1e9 50%, #e4e6ed 100%)" }}>

        <motion.div
          initial={{ opacity: 0, scale: 0.96, y: 20 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          transition={{ duration: 0.5, ease: [0.22, 1, 0.36, 1] }}
          className="relative w-full max-w-[400px] rounded-[28px] overflow-hidden"
          style={{
            background: "rgba(240,242,248,0.92)",
            boxShadow: "0 32px 80px rgba(0,0,0,0.14), 0 8px 24px rgba(0,0,0,0.08), inset 0 1px 0 rgba(255,255,255,0.8)",
            backdropFilter: "blur(24px)",
            border: "1px solid rgba(255,255,255,0.6)",
          }}
        >
          {/* ── Header ──────────────────────────────────────────────── */}
          <div className="px-5 pt-5 pb-4">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-2">
                <div className="w-7 h-7 rounded-lg bg-gray-900 flex items-center justify-center text-white">
                  {Icons.logo}
                </div>
                <div>
                  <p className="font-display text-[10px] font-600 tracking-[0.2em] text-gray-400 uppercase leading-none">
                    Tactical Cloud
                  </p>
                  <h1 className="font-display text-[22px] font-800 text-gray-900 leading-tight">
                    Intel
                  </h1>
                </div>
              </div>

              <div className="flex items-center gap-2">
                {/* Unread badge */}
                <AnimatePresence>
                  {unreadCount > 0 && (
                    <motion.div
                      initial={{ scale: 0 }}
                      animate={{ scale: 1 }}
                      exit={{ scale: 0 }}
                      className="w-6 h-6 rounded-full bg-red-500 flex items-center justify-center"
                    >
                      <span className="text-[10px] font-bold text-white">{unreadCount}</span>
                    </motion.div>
                  )}
                </AnimatePresence>

                {/* Action buttons */}
                <div className="flex items-center gap-1 rounded-2xl p-1"
                  style={{ background: "rgba(255,255,255,0.7)", border: "1px solid rgba(0,0,0,0.08)" }}>
                  <motion.button
                    onClick={handleRefresh}
                    className="w-8 h-8 rounded-xl flex items-center justify-center text-gray-500 hover:text-gray-900 hover:bg-white transition-colors"
                    animate={{ rotate: isRefreshing ? 360 : 0 }}
                    transition={{ duration: 1, ease: "linear", repeat: isRefreshing ? Infinity : 0 }}
                    whileTap={{ scale: 0.9 }}
                  >
                    {Icons.refresh}
                  </motion.button>
                  <motion.button
                    onClick={handleMarkAllRead}
                    className="w-8 h-8 rounded-xl flex items-center justify-center transition-colors"
                    style={{ color: allRead ? "#10b981" : "#9ca3af" }}
                    whileHover={{ color: "#10b981", background: "white" }}
                    whileTap={{ scale: 0.9 }}
                  >
                    {Icons.check}
                  </motion.button>
                </div>

                <motion.button
                  className="w-8 h-8 rounded-xl flex items-center justify-center text-gray-400 hover:text-gray-900 hover:bg-white transition-colors"
                  whileTap={{ scale: 0.9 }}
                >
                  {Icons.close}
                </motion.button>
              </div>
            </div>

            {/* ── Filter Tabs ──────────────────────────────────────── */}
            <div className="flex items-center gap-1 p-1 rounded-2xl"
              style={{ background: "rgba(255,255,255,0.5)", border: "1px solid rgba(0,0,0,0.06)" }}>
              {FILTERS.map((f) => (
                <motion.button
                  key={f}
                  onClick={() => setActiveFilter(f)}
                  className="relative flex-1 flex items-center justify-center gap-1.5 py-2 px-2 rounded-xl text-[11px] font-bold tracking-widest uppercase transition-colors z-10"
                  style={{ color: activeFilter === f ? "white" : "#9ca3af" }}
                  whileTap={{ scale: 0.97 }}
                >
                  {activeFilter === f && (
                    <motion.div
                      layoutId="activeTab"
                      className="absolute inset-0 rounded-xl bg-gray-900"
                      transition={{ type: "spring", stiffness: 500, damping: 35 }}
                    />
                  )}
                  <span className="relative z-10 flex items-center gap-1">
                    {f === "ALL" && Icons.allLayers}
                    {f === "LOGS" && Icons.box}
                    {f === "AUTH" && Icons.users}
                    {f === "ALERTS" && Icons.bell}
                    <span className="hidden sm:inline">{f}</span>
                    <span className="sm:hidden">{f}</span>
                  </span>
                </motion.button>
              ))}
            </div>
          </div>

          {/* ── Notification List ────────────────────────────────────── */}
          <div className="px-4 pb-4">
            <div className="flex items-center justify-between mb-3 px-1">
              <p className="font-display text-[10px] font-700 tracking-[0.18em] text-gray-400 uppercase">
                Historical Data
              </p>
              <motion.span
                key={filtered.length}
                initial={{ opacity: 0, scale: 0.8 }}
                animate={{ opacity: 1, scale: 1 }}
                className="text-[10px] font-bold text-gray-400"
              >
                {filtered.length} {filtered.length === 1 ? "item" : "items"}
              </motion.span>
            </div>

            <div
              className="flex flex-col gap-2.5 overflow-y-auto scrollbar-hide"
              style={{ maxHeight: "340px" }}
            >
              <AnimatePresence mode="popLayout">
                {filtered.length === 0 ? (
                  <motion.div
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    className="flex flex-col items-center justify-center py-12 text-gray-400"
                  >
                    <div className="w-12 h-12 rounded-2xl bg-gray-100 flex items-center justify-center mb-3">
                      {Icons.bell}
                    </div>
                    <p className="text-sm font-medium">No notifications</p>
                  </motion.div>
                ) : (
                  filtered.map((notif, i) => (
                    <NotificationCard
                      key={notif.id}
                      notif={notif}
                      index={i}
                      onMarkRead={handleMarkRead}
                    />
                  ))
                )}
              </AnimatePresence>
            </div>
          </div>

          {/* ── Scan Button ──────────────────────────────────────────── */}
          <div className="px-4 pb-5">
            <motion.button
              onClick={handleScan}
              disabled={isScanning}
              className="relative w-full py-4 rounded-2xl overflow-hidden flex items-center justify-center gap-3 font-display text-[13px] font-700 tracking-widest uppercase text-white"
              style={{ background: "linear-gradient(135deg, #111827 0%, #1f2937 100%)" }}
              whileHover={{ scale: 1.01, boxShadow: "0 8px 32px rgba(0,0,0,0.3)" }}
              whileTap={{ scale: 0.99 }}
            >
              {/* Scanning animation overlay */}
              <AnimatePresence>
                {isScanning && (
                  <motion.div
                    initial={{ x: "-100%" }}
                    animate={{ x: "200%" }}
                    transition={{ duration: 1.2, ease: "easeInOut", repeat: 1 }}
                    className="absolute inset-0 pointer-events-none"
                    style={{
                      background: "linear-gradient(90deg, transparent, rgba(255,255,255,0.12), transparent)",
                      width: "60%",
                    }}
                  />
                )}
              </AnimatePresence>

              <motion.span
                animate={{ rotate: isScanning ? 360 : 0 }}
                transition={{ duration: 0.8, repeat: isScanning ? Infinity : 0, ease: "linear" }}
              >
                {Icons.scan}
              </motion.span>

              <span>{isScanning ? "Scanning…" : "Scan Deep History"}</span>

              {isScanning && (
                <motion.div className="flex gap-1">
                  {[0, 1, 2].map((i) => (
                    <motion.span
                      key={i}
                      className="w-1 h-1 rounded-full bg-white/60"
                      animate={{ opacity: [0.3, 1, 0.3], scale: [0.8, 1.2, 0.8] }}
                      transition={{ delay: i * 0.2, duration: 0.8, repeat: Infinity }}
                    />
                  ))}
                </motion.div>
              )}
            </motion.button>
          </div>
        </motion.div>
      </div>
    </>
  );
}
