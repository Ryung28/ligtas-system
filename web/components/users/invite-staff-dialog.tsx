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
    onInvite: (email: string, role: string) => Promise<boolean>
}

export function InviteStaffDialog({ onInvite }: InviteStaffDialogProps) {
    const [open, setOpen] = useState(false)
    const [isLoading, setIsLoading] = useState(false)
    const [email, setEmail] = useState('')
    const [role, setRole] = useState('editor')

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
                    className="h-8 14in:h-9 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 text-white shadow-lg shadow-blue-200/50 text-[10px] 14in:text-xs uppercase tracking-wide font-bold transition-all active:scale-95 border-0"
                >
                    <UserPlus className="mr-1.5 h-3.5 w-3.5" />
                    Invite Staff
                </Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[425px] rounded-[2rem] border-none shadow-2xl overflow-hidden p-0">
                <div className="bg-gradient-to-br from-blue-600 to-indigo-700 p-8 text-white relative">
                    <div className="absolute top-0 right-0 p-8 opacity-10">
                        <ShieldCheck size={120} />
                    </div>
                    <DialogHeader className="relative z-10">
                        <DialogTitle className="text-2xl font-bold tracking-tight text-white mb-2 font-heading">Invite Staff Member</DialogTitle>
                        <DialogDescription className="text-blue-100/80 font-medium">
                            Add an administrator or inventory manager to the system.
                        </DialogDescription>
                    </DialogHeader>
                </div>

                <form onSubmit={handleInvite} className="p-8 space-y-6 bg-white">
                    <div className="space-y-4">
                        <div className="space-y-2">
                            <Label htmlFor="email" className="text-xs font-bold text-slate-400 uppercase tracking-widest ml-1">Official Email Address</Label>
                            <div className="relative group">
                                <Mail className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400 group-focus-within:text-blue-600 transition-colors" />
                                <Input
                                    id="email"
                                    type="email"
                                    placeholder="staff@cdrrmo.gov.ph"
                                    value={email}
                                    onChange={(e) => setEmail(e.target.value)}
                                    className="pl-10 h-12 bg-slate-50 border-slate-100 rounded-xl focus:ring-blue-600 focus:border-blue-600 transition-all font-medium"
                                    required
                                />
                            </div>
                        </div>

                        <div className="space-y-2">
                            <Label htmlFor="role" className="text-xs font-bold text-slate-400 uppercase tracking-widest ml-1">Staff Position</Label>
                            <Select value={role} onValueChange={setRole}>
                                <SelectTrigger className="h-12 bg-slate-50 border-slate-100 rounded-xl focus:ring-blue-600 font-medium capitalize">
                                    <SelectValue placeholder="Select a role" />
                                </SelectTrigger>
                                <SelectContent className="rounded-xl border-slate-100 shadow-xl">
                                    <SelectItem value="editor" className="rounded-lg mb-1 focus:bg-blue-50">
                                        <div className="flex flex-col py-0.5">
                                            <span className="font-bold text-blue-900 text-sm">Inventory Manager</span>
                                            <span className="text-[10px] text-blue-500 font-medium">Can manage items & logs</span>
                                        </div>
                                    </SelectItem>
                                    <SelectItem value="admin" className="rounded-lg focus:bg-purple-50">
                                        <div className="flex flex-col py-0.5">
                                            <span className="font-bold text-purple-900 text-sm">Administrator</span>
                                            <span className="text-[10px] text-purple-500 font-medium">Full system & personnel control</span>
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
                            className="w-full h-12 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold shadow-lg shadow-blue-200 transition-all active:scale-[0.98]"
                        >
                            {isLoading ? (
                                <>
                                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                                    Authorizing...
                                </>
                            ) : (
                                'Grant Access'
                            )}
                        </Button>
                    </DialogFooter>
                </form>
            </DialogContent>
        </Dialog>
    )
}
