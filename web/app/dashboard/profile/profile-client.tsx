'use client'

import { useMemo, useRef, useState } from 'react'
import { createBrowserClient } from '@supabase/ssr'
import useSWR from 'swr'
import { Card, CardContent, CardHeader, CardTitle, CardDescription, CardFooter } from '@/components/ui/card'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { Separator } from '@/components/ui/separator'
import {
    AlertDialog,
    AlertDialogAction,
    AlertDialogCancel,
    AlertDialogContent,
    AlertDialogDescription,
    AlertDialogFooter,
    AlertDialogHeader,
    AlertDialogTitle,
    AlertDialogTrigger,
} from '@/components/ui/alert-dialog'
import { Mail, Shield, Building, Loader2, User, Save, AlertTriangle } from 'lucide-react'
import { toast } from 'sonner'
import { UserProfile } from '@/hooks/use-user-management'
import {
    BACKUP_CONFIRMATION_PHRASE,
    IMPORT_CONFIRMATION_PHRASE,
    RESET_CONFIRMATION_PHRASE,
    RESTORE_CONFIRMATION_PHRASE,
} from '@/src/features/admin-logbook-reset/reset-scope'
import { getMaxBackupImportBytes } from '@/src/features/admin-logbook-reset/backup-config'

interface ProfileClientProps {
    initialProfile: UserProfile
}

interface LogbookJobStatus {
    id: string | null
    status: string | null
    created_at: string | null
    completed_at: string | null
    snapshot_id: string | null
}

interface LogbookAdminStatusResponse {
    success: boolean
    data?: {
        backup: LogbookJobStatus
        reset: LogbookJobStatus
        restore: LogbookJobStatus
    }
    error?: string
}

interface SnapshotPreviewResponse {
    success: boolean
    data?: {
        snapshot_id: string
        created_at: string
        requested_by: string
        reason: string
        scope_version: string
        table_counts: Array<{ table_name: string; row_count: number }>
    }
    error?: string
}

export function ProfileClient({ initialProfile }: ProfileClientProps) {
    const [saving, setSaving] = useState(false)
    const [resetReason, setResetReason] = useState('')
    const [resetConfirmation, setResetConfirmation] = useState('')
    const [restoreSnapshotId, setRestoreSnapshotId] = useState('')
    const [resetLoading, setResetLoading] = useState(false)
    const [backupLoading, setBackupLoading] = useState(false)
    const [restoreLoading, setRestoreLoading] = useState(false)
    const [previewLoading, setPreviewLoading] = useState(false)
    const [exportLoading, setExportLoading] = useState(false)
    const [importLoading, setImportLoading] = useState(false)
    const [snapshotPreview, setSnapshotPreview] = useState<SnapshotPreviewResponse['data'] | null>(null)
    const importFileInputRef = useRef<HTMLInputElement | null>(null)

    // Form states
    const [fullName, setFullName] = useState(initialProfile.full_name || '')
    const [department, setDepartment] = useState(initialProfile.department || '')

    const supabase = useMemo(
        () =>
            createBrowserClient(
                process.env.NEXT_PUBLIC_SUPABASE_URL!,
                process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
            ),
        []
    )

    const profileKey = ['profile-me', initialProfile.id]
    const { data: profile = initialProfile, mutate: mutateProfile } = useSWR<UserProfile>(
        profileKey,
        async () => {
            const { data, error } = await supabase
                .from('user_profiles')
                .select('*')
                .eq('id', initialProfile.id)
                .single()

            if (error) throw error
            return data as UserProfile
        },
        {
            fallbackData: initialProfile,
            revalidateOnFocus: false,
            dedupingInterval: 30000,
        }
    )

    const { data: logbookStatus, mutate: mutateLogbookStatus } = useSWR<LogbookAdminStatusResponse>(
        profile.role === 'admin' ? 'logbook-admin-status' : null,
        async () => {
            const response = await fetch('/api/admin/logbook-status', {
                method: 'GET',
                cache: 'no-store',
            })
            return response.json()
        },
        {
            revalidateOnFocus: false,
            dedupingInterval: 10000,
        }
    )

    const notifyLogbookMutation = () => {
        window.dispatchEvent(new Event('resqtrack:logbook-mutated'))
    }

    const handleSave = async () => {
        try {
            setSaving(true)
            const { error } = await supabase
                .from('user_profiles')
                .update({
                    full_name: fullName,
                    department: department
                })
                .eq('id', profile.id)

            if (error) throw error

            toast.success('Profile updated successfully')
            await mutateProfile(
                { ...profile, full_name: fullName, department },
                false
            )
        } catch (error) {
            console.error('Error updating profile:', error)
            toast.error('Failed to update profile')
        } finally {
            setSaving(false)
        }
    }

    const handleLogbookReset = async () => {
        if (!latestBackup?.id || latestBackup?.status !== 'completed') {
            toast.error('Create a completed recovery snapshot first.')
            return
        }

        if (resetConfirmation !== RESET_CONFIRMATION_PHRASE) {
            toast.error(`Type ${RESET_CONFIRMATION_PHRASE} exactly to continue.`)
            return
        }

        if (resetReason.trim().length < 10) {
            toast.error('Please provide a clear reason (at least 10 characters).')
            return
        }

        try {
            setResetLoading(true)
            const response = await fetch('/api/admin/logbook-reset', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    confirmation: resetConfirmation,
                    reason: resetReason,
                }),
            })

            const result = await response.json()

            if (!response.ok || !result.success) {
                toast.error(result.error || 'Reset failed.')
                return
            }

            toast.success(`Logbook cleared. Job: ${result.jobId}`)
            setResetReason('')
            setResetConfirmation('')
            await mutateLogbookStatus()
            notifyLogbookMutation()
        } catch (error) {
            console.error('Logbook reset error:', error)
            toast.error('Failed to clear logbook.')
        } finally {
            setResetLoading(false)
        }
    }

    const handleLogbookBackup = async () => {
        if (resetConfirmation !== BACKUP_CONFIRMATION_PHRASE) {
            toast.error(`Type ${BACKUP_CONFIRMATION_PHRASE} exactly to continue.`)
            return
        }

        if (resetReason.trim().length < 10) {
            toast.error('Please provide a clear reason (at least 10 characters).')
            return
        }

        try {
            setBackupLoading(true)
            const response = await fetch('/api/admin/logbook-backup', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    confirmation: resetConfirmation,
                    reason: resetReason,
                }),
            })

            const result = await response.json()

            if (!response.ok || !result.success) {
                toast.error(result.error || 'Backup failed.')
                return
            }

            toast.success(`Recovery snapshot created. Snapshot: ${result.snapshotId}`)
            await mutateLogbookStatus()
        } catch (error) {
            console.error('Logbook backup error:', error)
            toast.error('Failed to create recovery snapshot.')
        } finally {
            setBackupLoading(false)
        }
    }

    const handleLogbookRestore = async () => {
        if (resetConfirmation !== RESTORE_CONFIRMATION_PHRASE) {
            toast.error(`Type ${RESTORE_CONFIRMATION_PHRASE} exactly to continue.`)
            return
        }

        if (resetReason.trim().length < 10) {
            toast.error('Please provide a clear reason (at least 10 characters).')
            return
        }

        if (!restoreSnapshotId.trim()) {
            toast.error('Snapshot ID is required.')
            return
        }

        if (!snapshotPreview || snapshotPreview.snapshot_id !== restoreSnapshotId.trim()) {
            toast.error('Preview snapshot first before restoring.')
            return
        }

        try {
            setRestoreLoading(true)
            const response = await fetch('/api/admin/logbook-restore', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    confirmation: resetConfirmation,
                    reason: resetReason,
                    snapshotId: restoreSnapshotId.trim(),
                }),
            })

            const result = await response.json()

            if (!response.ok || !result.success) {
                toast.error(result.error || 'Restore failed.')
                return
            }

            toast.success(`Restore complete. Job: ${result.jobId}`)
            await mutateLogbookStatus()
            notifyLogbookMutation()
        } catch (error) {
            console.error('Logbook restore error:', error)
            toast.error('Failed to restore snapshot.')
        } finally {
            setRestoreLoading(false)
        }
    }

    const handleSnapshotPreview = async () => {
        if (!restoreSnapshotId.trim()) {
            toast.error('Enter a snapshot ID first.')
            return
        }

        try {
            setPreviewLoading(true)
            const response = await fetch('/api/admin/logbook-snapshot-preview', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ snapshotId: restoreSnapshotId.trim() }),
            })
            const result: SnapshotPreviewResponse = await response.json()

            if (!response.ok || !result.success || !result.data) {
                setSnapshotPreview(null)
                toast.error(result.error || 'Failed to preview snapshot.')
                return
            }

            setSnapshotPreview(result.data)
            toast.success('Snapshot preview loaded.')
        } catch (error) {
            console.error('Snapshot preview error:', error)
            setSnapshotPreview(null)
            toast.error('Failed to preview snapshot.')
        } finally {
            setPreviewLoading(false)
        }
    }

    const handleExportBackup = async () => {
        const targetSnapshotId =
            (restoreSnapshotId.trim().length > 0
                ? restoreSnapshotId.trim()
                : latestBackup?.snapshot_id) ?? ''

        if (!targetSnapshotId) {
            toast.error('No snapshot to export. Create one first or enter a snapshot ID.')
            return
        }

        try {
            setExportLoading(true)
            // Use direct navigation download so the browser can open Save dialog immediately
            // without waiting for full blob materialization in JS memory.
            const url = `/api/admin/logbook-export?snapshotId=${encodeURIComponent(targetSnapshotId)}`
            const a = document.createElement('a')
            a.href = url
            a.download = ''
            document.body.appendChild(a)
            a.click()
            a.remove()
            toast.success('Snapshot export started.')
        } catch (error) {
            console.error('Backup export error:', error)
            toast.error('Failed to export snapshot.')
        } finally {
            setExportLoading(false)
        }
    }

    const resetImportPicker = () => {
        if (importFileInputRef.current) {
            importFileInputRef.current.value = ''
        }
    }

    const handleImportBackup = async (file: File) => {
        setImportLoading(true)
        try {
            if (resetConfirmation !== IMPORT_CONFIRMATION_PHRASE) {
                toast.error(`Type ${IMPORT_CONFIRMATION_PHRASE} exactly to continue.`)
                return
            }

            if (resetReason.trim().length < 10) {
                toast.error('Please provide a clear reason (at least 10 characters).')
                return
            }

            if (file.size > getMaxBackupImportBytes()) {
                toast.error(`Snapshot file too large. Max ${Math.floor(getMaxBackupImportBytes() / (1024 * 1024))}MB.`)
                return
            }

            toast.info(`Validating ${file.name}...`)
            const raw = await file.text()
            let payload: unknown
            try {
                payload = JSON.parse(raw)
            } catch {
                toast.error('Invalid JSON file.')
                return
            }

            const response = await fetch('/api/admin/logbook-import', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    confirmation: resetConfirmation,
                    reason: resetReason,
                    payload,
                }),
            })
            const result = await response.json()

            if (!response.ok || !result.success || !result.snapshotId) {
                toast.error(result.error || 'Import failed.')
                return
            }

            const importedSnapshotId = String(result.snapshotId)
            setRestoreSnapshotId(importedSnapshotId)
            setSnapshotPreview(null)
            await mutateLogbookStatus()
            notifyLogbookMutation()
            toast.success(`Snapshot imported. ID: ${importedSnapshotId}`)
        } catch (error) {
            console.error('Backup import error:', error)
            toast.error('Failed to import snapshot.')
        } finally {
            setImportLoading(false)
            resetImportPicker()
        }
    }

    const initials = (profile.full_name || profile.email).substring(0, 2).toUpperCase()
    const roleColors = {
        admin: 'bg-purple-100 text-purple-700 border-purple-200',
        editor: 'bg-blue-100 text-blue-700 border-blue-200',
        viewer: 'bg-gray-100 text-gray-700 border-gray-200',
        responder: 'bg-orange-100 text-orange-700 border-orange-200'
    }

    const latestBackup = logbookStatus?.data?.backup
    const latestReset = logbookStatus?.data?.reset
    const latestRestore = logbookStatus?.data?.restore
    const hasCompletedBackup = latestBackup?.status === 'completed'
    const canRestore =
        !!snapshotPreview &&
        snapshotPreview.snapshot_id === restoreSnapshotId.trim() &&
        !previewLoading

    return (
        <div className="space-y-6 max-w-5xl mx-auto animate-in fade-in duration-500">
            <div>
                <h1 className="text-3xl font-bold tracking-tight text-gray-900 font-heading">Profile</h1>
                <p className="text-gray-500 mt-1">View and update your account details.</p>
            </div>

            <div className="grid gap-6 md:grid-cols-[320px_1fr]">
                {/* User Card */}
                <Card className="h-fit shadow-sm border-gray-200 overflow-hidden">
                    <div className="h-24 bg-gradient-to-r from-slate-900 to-slate-800 relative">
                        <div className="absolute inset-0 bg-[url('https://grainy-gradients.vercel.app/noise.svg')] opacity-20"></div>
                    </div>
                    <CardHeader className="text-center relative pb-2 -mt-12">
                        <div className="mx-auto relative group">
                            <Avatar className="h-24 w-24 border-4 border-white shadow-lg mx-auto bg-white ring-1 ring-gray-100">
                                <AvatarFallback className="text-2xl text-slate-700 font-bold bg-slate-50">
                                    {initials}
                                </AvatarFallback>
                            </Avatar>
                        </div>
                        <CardTitle className="mt-4 text-xl font-bold text-gray-900 capitalize">
                            {profile.full_name || 'Unnamed User'}
                        </CardTitle>
                        <CardDescription className="text-sm font-medium text-gray-500">
                            {profile.email}
                        </CardDescription>
                        <div className="flex justify-center mt-4">
                            <Badge className={`px-3 py-1 text-xs capitalize border shadow-sm ${roleColors[profile.role] || roleColors.viewer}`}>
                                {profile.role}
                            </Badge>
                        </div>
                    </CardHeader>
                    <CardContent className="space-y-4 pt-6">
                        <div className="flex items-center gap-3 text-sm text-gray-700 p-3 bg-gray-50/80 rounded-lg border border-gray-100">
                            <Building className="h-4 w-4 text-gray-500" />
                            <span className="font-medium">{profile.department || 'No Department'}</span>
                        </div>
                        <div className="flex items-center gap-3 text-sm text-gray-700 p-3 bg-gray-50/80 rounded-lg border border-gray-100">
                            <Shield className="h-4 w-4 text-gray-500" />
                            <span className="font-medium capitalize">{profile.status}</span>
                        </div>
                    </CardContent>
                </Card>

                {/* Edit Form */}
                <Card className="shadow-sm border-gray-200">
                    <CardHeader>
                        <div className="flex items-center gap-2">
                            <User className="h-5 w-5 text-gray-400" />
                            <CardTitle className="text-lg">Your Info</CardTitle>
                        </div>
                        <CardDescription>Keep your information up to date.</CardDescription>
                    </CardHeader>
                    <CardContent className="space-y-6">
                        <div className="grid gap-2">
                            <Label htmlFor="fullname">Full Name</Label>
                            <Input
                                id="fullname"
                                value={fullName}
                                onChange={(e) => setFullName(e.target.value)}
                                className="bg-white"
                                placeholder="Enter your full name"
                            />
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div className="grid gap-2">
                                <Label htmlFor="email">Email Address</Label>
                                <div className="relative">
                                    <Mail className="absolute left-3 top-2.5 h-4 w-4 text-gray-400" />
                                    <Input
                                        id="email"
                                        value={profile.email}
                                        disabled
                                        className="pl-9 bg-gray-50 text-gray-500 cursor-not-allowed"
                                    />
                                </div>
                            </div>
                            <div className="grid gap-2">
                                <Label htmlFor="dept">Department</Label>
                                <Input
                                    id="dept"
                                    value={department}
                                    onChange={(e) => setDepartment(e.target.value)}
                                    className="bg-white"
                                    placeholder="e.g. Logistics & Inventory"
                                />
                            </div>
                        </div>
                    </CardContent>
                    <CardFooter className="flex justify-end gap-3 border-t border-gray-100 pt-6 bg-gray-50/50">
                        <Button
                            onClick={handleSave}
                            disabled={saving}
                            className="bg-slate-900 hover:bg-slate-800 text-white shadow-md min-w-[140px]"
                        >
                            {saving ? (
                                <>
                                    <Loader2 className="h-4 w-4 animate-spin mr-2" />
                                    Saving...
                                </>
                            ) : (
                                <>
                                    <Save className="h-4 w-4 mr-2" />
                                    Save Changes
                                </>
                            )}
                        </Button>
                    </CardFooter>
                </Card>
            </div>

            {profile.role === 'admin' && (
                <Card className="border-red-200 shadow-sm">
                    <CardHeader>
                        <div className="flex items-center gap-2 text-red-700">
                            <AlertTriangle className="h-5 w-5" />
                            <CardTitle className="text-lg">Recovery & Clear Logbook</CardTitle>
                        </div>
                        <CardDescription>
                            Save, restore, export, or clear logbook records. Inventory and storage files stay intact.
                        </CardDescription>
                    </CardHeader>
                    <CardContent className="space-y-5">
                        <div className="grid gap-2">
                            <Label htmlFor="reset-reason">Reason (required)</Label>
                            <Textarea
                                id="reset-reason"
                                value={resetReason}
                                onChange={(e) => setResetReason(e.target.value)}
                                placeholder="Why are you running this operation?"
                                className="bg-white"
                            />
                        </div>
                        <div className="grid gap-2">
                            <Label htmlFor="reset-confirmation">
                                Type one of: <span className="font-semibold">BACKUP LOGBOOK</span>, <span className="font-semibold">IMPORT LOGBOOK</span>, <span className="font-semibold">RESET LOGBOOK</span>, or <span className="font-semibold">RESTORE LOGBOOK</span>
                            </Label>
                            <Input
                                id="reset-confirmation"
                                value={resetConfirmation}
                                onChange={(e) => setResetConfirmation(e.target.value)}
                                placeholder="BACKUP LOGBOOK / IMPORT LOGBOOK / RESET LOGBOOK / RESTORE LOGBOOK"
                                className="bg-white"
                            />
                        </div>

                        <Separator className="bg-red-100" />

                        <section className="rounded-lg border border-emerald-200 bg-emerald-50/70 p-4 space-y-3">
                            <p className="text-xs font-bold uppercase tracking-wider text-emerald-700">Step 1 · Protect</p>
                            <p className="text-sm text-emerald-900">Create a recovery snapshot before making risky changes.</p>
                            <Button
                                type="button"
                                variant="outline"
                                onClick={handleLogbookBackup}
                                disabled={backupLoading || resetLoading || restoreLoading || exportLoading || importLoading}
                                className="min-w-[220px] border-emerald-300 text-emerald-900 hover:bg-emerald-100"
                            >
                                {backupLoading ? (
                                    <>
                                        <Loader2 className="h-4 w-4 animate-spin mr-2" />
                                        Saving...
                                    </>
                                ) : (
                                    'Save Recovery Snapshot'
                                )}
                            </Button>
                        </section>

                        <section className="rounded-lg border border-slate-200 bg-slate-50/70 p-4 space-y-3">
                            <p className="text-xs font-bold uppercase tracking-wider text-slate-600">Step 2 · Verify</p>
                            <p className="text-sm text-slate-700">Preview the snapshot first, then restore only if details are correct.</p>
                            <div className="grid gap-2">
                                <Label htmlFor="restore-snapshot-id">Snapshot ID</Label>
                                <div className="flex gap-2">
                                    <Input
                                        id="restore-snapshot-id"
                                        value={restoreSnapshotId}
                                        onChange={(e) => {
                                            setRestoreSnapshotId(e.target.value)
                                            setSnapshotPreview(null)
                                        }}
                                        placeholder="Paste snapshot UUID"
                                        className="bg-white"
                                    />
                                    <Button
                                        type="button"
                                        variant="outline"
                                        onClick={handleSnapshotPreview}
                                        disabled={previewLoading || restoreLoading || backupLoading || resetLoading}
                                    >
                                        {previewLoading ? 'Checking...' : 'Preview Snapshot'}
                                    </Button>
                                </div>
                            </div>
                            {snapshotPreview ? (
                                <div className="rounded-md border border-slate-200 bg-white p-3 text-xs text-slate-700 space-y-1">
                                    <p>
                                        <span className="font-semibold">Snapshot:</span> {snapshotPreview.snapshot_id}
                                    </p>
                                    <p>
                                        <span className="font-semibold">Created:</span>{' '}
                                        {new Date(snapshotPreview.created_at).toLocaleString()}
                                    </p>
                                    <p>
                                        <span className="font-semibold">Rows:</span>{' '}
                                        {snapshotPreview.table_counts.reduce((acc, row) => acc + row.row_count, 0)}
                                    </p>
                                </div>
                            ) : null}
                        </section>

                        <section className="rounded-lg border border-amber-300 bg-amber-50/80 p-4 space-y-3">
                            <p className="text-xs font-bold uppercase tracking-wider text-amber-700">Step 3 · Recover or Clear</p>
                            <p className="text-sm text-amber-900">Restore from a verified snapshot, or clear logbook only after snapshot is saved.</p>
                            <div className="flex flex-wrap gap-2">
                                <Button
                                    type="button"
                                    variant="secondary"
                                    onClick={handleLogbookRestore}
                                    disabled={restoreLoading || backupLoading || resetLoading || exportLoading || importLoading || !canRestore}
                                    className="min-w-[190px]"
                                >
                                    {restoreLoading ? (
                                        <>
                                            <Loader2 className="h-4 w-4 animate-spin mr-2" />
                                            Restoring...
                                        </>
                                    ) : (
                                        'Restore Snapshot'
                                    )}
                                </Button>

                                <AlertDialog>
                                    <AlertDialogTrigger asChild>
                                        <Button
                                            variant="destructive"
                                            disabled={resetLoading || backupLoading || restoreLoading || !hasCompletedBackup}
                                            className="min-w-[190px]"
                                        >
                                            {resetLoading ? (
                                                <>
                                                    <Loader2 className="h-4 w-4 animate-spin mr-2" />
                                                    Clearing...
                                                </>
                                            ) : (
                                                'Clear Logbook'
                                            )}
                                        </Button>
                                    </AlertDialogTrigger>
                                    <AlertDialogContent>
                                        <AlertDialogHeader>
                                            <AlertDialogTitle>Confirm Clear Logbook</AlertDialogTitle>
                                            <AlertDialogDescription>
                                                This clears current logbook records. You can recover only by restoring a snapshot.
                                            </AlertDialogDescription>
                                            {!hasCompletedBackup ? (
                                                <p className="text-sm text-red-600 font-medium">
                                                    Clear Logbook is disabled until at least one recovery snapshot is completed.
                                                </p>
                                            ) : null}
                                        </AlertDialogHeader>
                                        <AlertDialogFooter>
                                            <AlertDialogCancel disabled={resetLoading}>Cancel</AlertDialogCancel>
                                            <AlertDialogAction
                                                onClick={handleLogbookReset}
                                                disabled={resetLoading}
                                                className="bg-red-600 hover:bg-red-700"
                                            >
                                                Confirm Clear
                                            </AlertDialogAction>
                                        </AlertDialogFooter>
                                    </AlertDialogContent>
                                </AlertDialog>
                            </div>
                        </section>

                        <details className="rounded-lg border border-slate-200 bg-white p-4">
                            <summary className="cursor-pointer text-sm font-semibold text-slate-700">Advanced Snapshot Tools</summary>
                            <div className="mt-3 flex flex-wrap gap-2">
                                <input
                                    ref={importFileInputRef}
                                    type="file"
                                    accept="application/json,.json"
                                    className="hidden"
                                    onClick={() => resetImportPicker()}
                                    onChange={(event) => {
                                        const file = event.target.files?.[0]
                                        if (!file) return
                                        void handleImportBackup(file)
                                    }}
                                />
                                <Button
                                    type="button"
                                    variant="outline"
                                    onClick={() => importFileInputRef.current?.click()}
                                    disabled={importLoading || backupLoading || resetLoading || restoreLoading || exportLoading}
                                    className="min-w-[170px]"
                                >
                                    {importLoading ? (
                                        <>
                                            <Loader2 className="h-4 w-4 animate-spin mr-2" />
                                            Importing...
                                        </>
                                    ) : (
                                        'Import Snapshot'
                                    )}
                                </Button>
                                <Button
                                    type="button"
                                    variant="outline"
                                    onClick={handleExportBackup}
                                    disabled={exportLoading || backupLoading || resetLoading || restoreLoading || importLoading}
                                    className="min-w-[170px]"
                                >
                                    {exportLoading ? (
                                        <>
                                            <Loader2 className="h-4 w-4 animate-spin mr-2" />
                                            Exporting...
                                        </>
                                    ) : (
                                        'Export Snapshot'
                                    )}
                                </Button>
                            </div>
                        </details>

                        <Separator className="bg-red-100" />

                        <div className="grid gap-3 text-sm">
                            <div>
                                <p className="font-semibold text-slate-800">Last Recovery Snapshot</p>
                                <p className="text-slate-600">
                                    {latestBackup?.created_at
                                        ? `${new Date(latestBackup.created_at).toLocaleString()} | ${latestBackup.status ?? 'unknown'}`
                                        : 'No recovery snapshot yet'}
                                </p>
                                <p className="text-xs text-slate-500 break-all">
                                    Snapshot: {latestBackup?.snapshot_id ?? 'N/A'}
                                </p>
                            </div>
                            <div>
                                <p className="font-semibold text-slate-800">Last Restore Job</p>
                                <p className="text-slate-600">
                                    {latestRestore?.created_at
                                        ? `${new Date(latestRestore.created_at).toLocaleString()} | ${latestRestore.status ?? 'unknown'}`
                                        : 'No restore yet'}
                                </p>
                                <p className="text-xs text-slate-500 break-all">
                                    Snapshot: {latestRestore?.snapshot_id ?? 'N/A'}
                                </p>
                            </div>
                            <div>
                                <p className="font-semibold text-slate-800">Last Clear Job</p>
                                <p className="text-slate-600">
                                    {latestReset?.created_at
                                        ? `${new Date(latestReset.created_at).toLocaleString()} | ${latestReset.status ?? 'unknown'}`
                                        : 'No clear job yet'}
                                </p>
                                <p className="text-xs text-slate-500 break-all">
                                    Snapshot: {latestReset?.snapshot_id ?? 'N/A'}
                                </p>
                            </div>
                        </div>
                    </CardContent>
                </Card>
            )}
        </div>
    )
}
