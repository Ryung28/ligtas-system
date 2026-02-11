'use client'

import { Bell, Package, RotateCcw, AlertTriangle, Check } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover'
import { useNotifications, NotificationItem } from '@/hooks/use-notifications'
import { Badge } from '@/components/ui/badge'
// No scroll-area needed, using native overflow-y-auto

export function NotificationBell() {
    const { notifications, unreadCount, markAsRead, isLoading } = useNotifications()

    const getIcon = (type: NotificationItem['type']) => {
        switch (type) {
            case 'return': return <RotateCcw className="h-4 w-4 text-green-600" />
            case 'stock': return <AlertTriangle className="h-4 w-4 text-amber-600" />
            case 'overdue': return <Package className="h-4 w-4 text-red-600" />
        }
    }

    const formatTime = (timeStr: string) => {
        const date = new Date(timeStr)
        const now = new Date()
        const diffMs = now.getTime() - date.getTime()
        const diffMins = Math.floor(diffMs / 60000)

        if (diffMins < 1) return 'Just now'
        if (diffMins < 60) return `${diffMins}m ago`
        if (diffMins < 1440) return `${Math.floor(diffMins / 60)}h ago`
        return date.toLocaleDateString()
    }

    return (
        <Popover onOpenChange={(open) => { if (open && unreadCount > 0) setTimeout(markAsRead, 2000) }}>
            <PopoverTrigger asChild>
                <Button variant="ghost" size="icon" className="relative h-10 w-10 rounded-full hover:bg-gray-100 transition-colors">
                    <Bell className="h-5 w-5 text-gray-600" />
                    {unreadCount > 0 && (
                        <span className="absolute top-2 right-2 flex h-4 w-4 items-center justify-center rounded-full bg-red-500 text-[10px] font-bold text-white ring-2 ring-white animate-in zoom-in">
                            {unreadCount}
                        </span>
                    )}
                </Button>
            </PopoverTrigger>
            <PopoverContent className="w-80 p-0 mr-4 mt-2 overflow-hidden rounded-2xl border-gray-200 shadow-2xl" align="end">
                <div className="flex items-center justify-between border-b border-gray-100 bg-gray-50/50 px-4 py-3">
                    <h3 className="text-sm font-bold text-gray-900">Notifications</h3>
                    <Badge variant="outline" className="bg-white text-[10px] font-bold border-gray-200">
                        {notifications.length} Total
                    </Badge>
                </div>

                <div className="max-h-[400px] overflow-y-auto">
                    {isLoading && notifications.length === 0 ? (
                        <div className="flex items-center justify-center py-8">
                            <RotateCcw className="h-5 w-5 animate-spin text-gray-300" />
                        </div>
                    ) : notifications.length === 0 ? (
                        <div className="flex flex-col items-center justify-center py-12 text-center">
                            <div className="bg-gray-50 p-3 rounded-full mb-3">
                                <Bell className="h-6 w-6 text-gray-300" />
                            </div>
                            <p className="text-sm text-gray-500 font-medium">No recent updates</p>
                        </div>
                    ) : (
                        <div className="divide-y divide-gray-50">
                            {notifications.map((n) => (
                                <div
                                    key={n.id}
                                    className={`flex gap-3 px-4 py-4 transition-colors hover:bg-gray-50/80 cursor-default ${!n.isRead ? 'bg-blue-50/30' : ''}`}
                                >
                                    <div className={`mt-0.5 flex h-8 w-8 shrink-0 items-center justify-center rounded-lg ${n.type === 'return' ? 'bg-green-50' :
                                        n.type === 'stock' ? 'bg-amber-50' : 'bg-red-50'
                                        }`}>
                                        {getIcon(n.type)}
                                    </div>
                                    <div className="flex flex-col gap-0.5">
                                        <div className="flex items-center justify-between gap-2">
                                            <span className="text-sm font-bold text-gray-900">{n.title}</span>
                                            <span className="text-[10px] text-gray-400 font-medium whitespace-nowrap">{formatTime(n.time)}</span>
                                        </div>
                                        <p className="text-xs text-gray-600 leading-relaxed font-medium">
                                            {n.message}
                                        </p>
                                    </div>
                                </div>
                            ))}
                        </div>
                    )}
                </div>

                <div className="border-t border-gray-100 p-2 bg-gray-50/30">
                    <Button
                        variant="ghost"
                        size="sm"
                        className="w-full text-xs font-bold text-blue-600 hover:text-blue-700 hover:bg-blue-50/50 rounded-lg"
                        onClick={markAsRead}
                    >
                        Mark all as read
                    </Button>
                </div>
            </PopoverContent>
        </Popover>
    )
}
