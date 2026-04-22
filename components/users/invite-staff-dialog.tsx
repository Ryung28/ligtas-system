'use client'

import { useState } from 'react'
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
    DialogFooter
} from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { UserPlus, Loader2, ShieldCheck, Mail } from 'lucide-react'
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select'

interface InviteStaffDialogProps {
    onInvite: (email: string, role: 'admin' | 'editor' | 'viewer' | 'responder') => Promise<boolean>
}

export function InviteStaffDialog({ onInvite }: InviteStaffDialogProps) {
    const [open, setOpen] = useState(false)
    const [isLoading, setIsLoading] = useState(false)
    const [email, setEmail] = useState('')
    const [role, setRole] = useState<'admin' | 'editor' | 'viewer' | 'responder'>('editor')

    const handleInvite = async (e: React.FormEvent) => {
        e.preventDefault()
        if (!email) return

        setIsLoading(true)
        const success = await onInvite(email, role)
        setIsLoading(false)

        if (success) {
            setEmail('')
            setRole('editor')
            setOpen(false)
        }
    }

    return (
        <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
                <Button
                    size="sm"
                    className="h-8 14in:h-9 bg-indigo-950 hover:bg-slate-900 text-white shadow-xl shadow-indigo-100 text-[10px] 14in:text-xs uppercase tracking-widest font-bold transition-all active:scale-95 border-0 rounded-lg"
                >
                    <UserPlus className="mr-1.5 h-3.5 w-3.5 stroke-[2.5px]" />
                    Invite Staff
                </Button>
            </DialogTrigger>
        <DialogContent className="sm:max-w-[425px] rounded-2xl border border-slate-200 shadow-2xl overflow-hidden p-0 bg-white">
            {/* 🛡️ Tactical Top Bar */}
            <div className="absolute top-0 left-0 w-full h-1 bg-indigo-950 z-50" />

            <div className="p-8 pb-4 bg-white relative">
                <div className="absolute top-6 right-8 opacity-[0.03] text-indigo-950">
                    <ShieldCheck size={80} strokeWidth={1.5} />
                </div>
                <DialogHeader className="relative z-10">
                    <DialogTitle className="text-xl font-bold tracking-tight text-slate-900 font-heading">
                        Invite Personnel
                    </DialogTitle>
                    <DialogDescription className="text-slate-500 text-sm font-medium">
                        Grant administrative or specialized system access.
                    </DialogDescription>
                </DialogHeader>
            </div>

            <form 
                onSubmit={handleInvite} 
                className="p-8 pt-4 space-y-6 bg-white bg-[radial-gradient(#e2e8f0_1px,transparent_1px)] [background-size:20px_20px]"
            >
                <div className="space-y-5">
                    <div className="space-y-2">
                        <Label 
                            htmlFor="email" 
                            className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] ml-0.5"
                        >
                            Official Email Address
                        </Label>
                        <div className="relative group">
                            <Mail className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400 group-focus-within:text-indigo-900 transition-colors" />
                            <Input
                                id="email"
                                type="email"
                                placeholder="staff@cdrrmo.gov.ph"
                                value={email}
                                onChange={(e) => setEmail(e.target.value)}
                                className="pl-11 h-12 bg-white/80 backdrop-blur-sm border-slate-200 rounded-xl focus:ring-1 focus:ring-indigo-950 focus:border-indigo-950 transition-all font-medium text-slate-900 shadow-sm"
                                required
                            />
                        </div>
                    </div>

                    <div className="space-y-2">
                        <Label 
                            htmlFor="role" 
                            className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] ml-0.5"
                        >
                            Staff Position / Role
                        </Label>
                        <Select value={role} onValueChange={(value) => setRole(value as 'admin' | 'editor' | 'viewer' | 'responder')}>
                            <SelectTrigger className="h-12 bg-white/80 backdrop-blur-sm border-slate-200 rounded-xl focus:ring-1 focus:ring-indigo-950 font-medium capitalize shadow-sm text-slate-900">
                                <SelectValue placeholder="Select a role" />
                            </SelectTrigger>
                            <SelectContent className="rounded-xl border-slate-200 shadow-2xl p-1">
                                <SelectItem value="editor" className="rounded-lg mb-1 focus:bg-slate-50">
                                    <div className="flex flex-col py-0.5">
                                        <span className="font-bold text-slate-900 text-sm">Inventory Manager</span>
                                        <span className="text-[10px] text-slate-500 font-medium">Full asset & log clearance</span>
                                    </div>
                                </SelectItem>
                                <SelectItem value="admin" className="rounded-lg focus:bg-indigo-50">
                                    <div className="flex flex-col py-0.5">
                                        <span className="font-bold text-indigo-950 text-sm">System Administrator</span>
                                        <span className="text-[10px] text-indigo-600 font-medium">Total command & personnel control</span>
                                    </div>
                                </SelectItem>
                            </SelectContent>
                        </Select>
                    </div>
                </div>

                <DialogFooter className="pt-2">
                    <Button
                        type="submit"
                        disabled={isLoading}
                        className="w-full h-12 bg-indigo-950 hover:bg-slate-900 text-white rounded-xl font-bold shadow-xl shadow-indigo-100 transition-all active:scale-[0.98]"
                    >
                        {isLoading ? (
                            <>
                                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                                Authorizing...
                            </>
                        ) : (
                            'GRANT SYSTEM ACCESS'
                        )}
                    </Button>
                </DialogFooter>
            </form>
        </DialogContent>
        </Dialog>
    )
}
