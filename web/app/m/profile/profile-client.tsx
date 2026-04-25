'use client'

import { useMemo, useState } from 'react'
import { createBrowserClient } from '@supabase/ssr'
import { toast } from 'sonner'
import {
    Building2,
    Shield,
    ShieldCheck,
    Mail,
    Save,
    Loader2,
    Undo2,
    LogOut,
    AtSign,
    User as UserIcon,
} from 'lucide-react'
import { logoutAction } from '@/app/actions/auth-actions'
import { MobileHeader } from '@/components/mobile/mobile-header'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import {
    FormField,
    MInput,
    MBadge,
} from '@/components/mobile/primitives'
import { cn } from '@/lib/utils'
import { mFocus } from '@/lib/mobile/tokens'
import type { UserProfile } from '@/hooks/use-user-management'

interface ProfileClientProps {
    initialProfile: UserProfile
}

type RoleTone = 'brand' | 'info' | 'neutral' | 'warning'

const roleTone: Record<string, RoleTone> = {
    admin: 'brand',
    staff: 'info',
    editor: 'info',
    responder: 'warning',
    viewer: 'neutral',
}

export function ProfileClient({ initialProfile }: ProfileClientProps) {
    const [profile, setProfile] = useState<UserProfile>(initialProfile)
    const [fullName, setFullName] = useState(initialProfile.full_name || '')
    const [department, setDepartment] = useState(initialProfile.department || '')
    const [saving, setSaving] = useState(false)
    const [fullNameError, setFullNameError] = useState<string>()

    const supabase = useMemo(
        () =>
            createBrowserClient(
                process.env.NEXT_PUBLIC_SUPABASE_URL!,
                process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
            ),
        [],
    )

    const isDirty =
        (fullName.trim() || '') !== (profile.full_name || '') ||
        (department.trim() || '') !== (profile.department || '')

    const handleLogout = async () => {
        try {
            // Clear SW cache before server-side redirect
            if ('serviceWorker' in navigator && navigator.serviceWorker.controller) {
                navigator.serviceWorker.controller.postMessage({ type: 'LOGOUT' })
            }
            await logoutAction()
        } catch (error) {
            console.error('Logout failed:', error)
            toast.error('Logout failed')
        }
    }

    const initials = (profile.full_name || profile.email || 'AD')
        .substring(0, 2)
        .toUpperCase()

    const validate = () => {
        const name = fullName.trim()
        if (!name) {
            setFullNameError('Full name is required.')
            return false
        }
        if (name.length < 2) {
            setFullNameError('Name must be at least 2 characters.')
            return false
        }
        setFullNameError(undefined)
        return true
    }

    const handleSave = async () => {
        if (!validate() || !isDirty) return
        setSaving(true)
        try {
            const { error } = await supabase
                .from('user_profiles')
                .update({
                    full_name: fullName.trim(),
                    department: department.trim() || undefined,
                })
                .eq('id', profile.id)

            if (error) throw error

            setProfile({
                ...profile,
                full_name: fullName.trim(),
                department: department.trim() || undefined,
            })
            toast.success('Profile updated', {
                description: 'Your changes are live.',
            })
        } catch (err) {
            console.error('[/m/profile] save failed', err)
            toast.error('Save failed', {
                description: 'Please check your connection and try again.',
            })
        } finally {
            setSaving(false)
        }
    }

    const handleReset = () => {
        setFullName(profile.full_name || '')
        setDepartment(profile.department || '')
        setFullNameError(undefined)
    }

    return (
        <div className="space-y-6 pb-32">
            <MobileHeader title="Profile" />

            {/* Identity card */}
            <section
                className="relative rounded-3xl overflow-hidden border border-gray-100 bg-white shadow-sm"
                aria-label="Account summary"
            >
                <div className="h-24 bg-gradient-to-br from-gray-900 via-gray-800 to-red-900 relative">
                    <div
                        className="absolute inset-0 opacity-[0.08]"
                        style={{
                            backgroundImage:
                                'radial-gradient(circle at 20% 20%, #fff 1px, transparent 1.5px), radial-gradient(circle at 80% 60%, #fff 1px, transparent 1.5px)',
                            backgroundSize: '24px 24px',
                        }}
                        aria-hidden
                    />
                </div>

                <div className="px-5 pb-5 -mt-12">
                    <Avatar className="h-20 w-20 border-4 border-white shadow-lg bg-white">
                        <AvatarFallback className="text-lg font-black bg-gray-900 text-white">
                            {initials}
                        </AvatarFallback>
                    </Avatar>

                    <div className="mt-3">
                        <h2 className="text-lg font-bold text-gray-900 truncate">
                            {profile.full_name || 'Unnamed responder'}
                        </h2>
                        <p className="text-xs text-gray-500 flex items-center gap-1 mt-0.5 truncate">
                            <AtSign className="w-3 h-3 shrink-0" aria-hidden />
                            {profile.email}
                        </p>
                    </div>

                    <div className="mt-3 flex items-center gap-2 flex-wrap">
                        <MBadge
                            tone={roleTone[profile.role] || 'neutral'}
                            icon={Shield}
                        >
                            {profile.role || 'viewer'}
                        </MBadge>
                        <MBadge
                            tone={profile.status === 'active' ? 'success' : 'warning'}
                            icon={ShieldCheck}
                        >
                            {profile.status || 'pending'}
                        </MBadge>
                    </div>
                </div>
            </section>

            {/* Editable fields */}
            <section className="space-y-4" aria-label="Edit profile">
                <div className="flex items-center gap-2 px-1">
                    <UserIcon className="w-4 h-4 text-red-600" aria-hidden />
                    <h3 className="text-sm font-bold text-gray-900 uppercase tracking-tight">
                        Your information
                    </h3>
                </div>

                <div className="rounded-2xl bg-white border border-gray-100 p-4 space-y-5 shadow-sm">
                    <FormField
                        label="Full name"
                        htmlFor="full-name"
                        required
                        error={fullNameError}
                    >
                        <MInput
                            id="full-name"
                            value={fullName}
                            onChange={(e) => {
                                setFullName(e.target.value)
                                if (fullNameError) setFullNameError(undefined)
                            }}
                            onBlur={validate}
                            placeholder="e.g. Juan Dela Cruz"
                            autoComplete="name"
                            enterKeyHint="next"
                            invalid={!!fullNameError}
                        />
                    </FormField>

                    <FormField
                        label="Department"
                        htmlFor="department"
                        optional
                        hint="Your team or unit — e.g. Logistics & Inventory."
                    >
                        <MInput
                            id="department"
                            value={department}
                            onChange={(e) => setDepartment(e.target.value)}
                            placeholder="Assign a department"
                            autoComplete="organization"
                        />
                    </FormField>

                    <FormField
                        label="Email"
                        htmlFor="email"
                        hint="Contact an administrator to change your email."
                    >
                        <div className="relative">
                            <Mail
                                className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400 pointer-events-none"
                                aria-hidden
                            />
                            <MInput
                                id="email"
                                value={profile.email || ''}
                                disabled
                                readOnly
                                className="pl-10"
                            />
                        </div>
                    </FormField>
                </div>

                <div className="rounded-2xl bg-gray-50 border border-gray-100 p-4 flex items-start gap-3">
                    <div className="w-9 h-9 rounded-xl bg-white border border-gray-100 flex items-center justify-center shrink-0">
                        <Building2 className="w-4 h-4 text-gray-500" aria-hidden />
                    </div>
                    <div className="min-w-0">
                        <p className="text-[10px] font-bold uppercase tracking-widest text-gray-500">
                            Access level
                        </p>
                        <p className="text-sm text-gray-700 mt-0.5">
                            Your role determines what you can manage. Contact an admin to request changes.
                        </p>
                    </div>
                </div>
            </section>

            {/* 🚪 LOGOUT — High-visibility exit point */}
            <section className="px-4 mt-8 pb-32">
                <button
                    onClick={handleLogout}
                    className={cn(
                        "w-full bg-white border border-red-100 rounded-3xl p-5 shadow-sm",
                        "flex items-center justify-center gap-3 active:bg-red-50 active:scale-[0.98] transition-all group"
                    )}
                >
                    <LogOut className="w-5 h-5 text-red-600" />
                    <span className="text-sm font-black text-red-600 uppercase tracking-widest">
                        Safe Logout
                    </span>
                </button>
                
                <p className="text-[9px] text-center text-slate-300 font-bold mt-8 uppercase tracking-[0.3em]">
                    SECURE TERMINAL • v2.4.0-RT
                </p>
            </section>

            {/* Sticky save bar — visible only when dirty */}
            <div
                className={cn(
                    'fixed left-0 right-0 bottom-[calc(64px+env(safe-area-inset-bottom))] z-40',
                    'px-4 pb-3 pt-3',
                    'motion-safe:transition-all motion-safe:duration-200',
                    isDirty
                        ? 'translate-y-0 opacity-100 pointer-events-auto'
                        : 'translate-y-4 opacity-0 pointer-events-none',
                )}
                aria-hidden={!isDirty}
            >
                <div className="max-w-screen-md mx-auto bg-white border border-gray-200 rounded-2xl shadow-xl flex items-center gap-2 p-2">
                    <button
                        type="button"
                        onClick={handleReset}
                        disabled={saving}
                        className={cn(
                            'flex-none h-11 px-3 rounded-xl text-xs font-bold uppercase tracking-wider',
                            'text-gray-600 hover:bg-gray-50 active:bg-gray-100 disabled:opacity-50',
                            'inline-flex items-center gap-1.5 motion-safe:transition-colors',
                            mFocus,
                        )}
                    >
                        <Undo2 className="w-4 h-4" aria-hidden />
                        Reset
                    </button>
                    <button
                        type="button"
                        onClick={handleSave}
                        disabled={saving || !!fullNameError}
                        className={cn(
                            'flex-1 h-11 rounded-xl text-sm font-semibold',
                            'bg-red-600 text-white hover:bg-red-700 active:bg-red-700',
                            'inline-flex items-center justify-center gap-2 disabled:opacity-60',
                            'shadow-md shadow-red-200',
                            'motion-safe:transition-transform motion-safe:active:scale-[0.98]',
                            mFocus,
                        )}
                    >
                        {saving ? (
                            <>
                                <Loader2 className="w-4 h-4 animate-spin" aria-hidden />
                                Saving…
                            </>
                        ) : (
                            <>
                                <Save className="w-4 h-4" aria-hidden />
                                Save changes
                            </>
                        )}
                    </button>
                </div>
            </div>
        </div>
    )
}
