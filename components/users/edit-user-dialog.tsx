'use client'

import { useState } from 'react'
import { 
    Dialog, 
    DialogContent, 
    DialogHeader, 
    DialogTitle, 
    DialogFooter,
    DialogTrigger 
} from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { UserCog, Building2, Phone, User } from 'lucide-react'
import { UserProfile } from '@/hooks/use-user-management'
import { toast } from 'sonner'

interface EditUserDialogProps {
    user: UserProfile
    onUpdate: (userId: string, data: any) => Promise<boolean>
}

export function EditUserDialog({ user, onUpdate }: EditUserDialogProps) {
    const [open, setOpen] = useState(false)
    const [isSubmitting, setIsSubmitting] = useState(false)
    const [formData, setFormData] = useState({
        full_name: user.full_name || '',
        department: user.department || '',
        phone_number: (user as any).phone_number || ''
    })

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault()
        setIsSubmitting(true)
        try {
            const success = await onUpdate(user.id, formData)
            if (success) {
                toast.success('Profile updated')
                setOpen(false)
            }
        } finally {
            setIsSubmitting(false)
        }
    }

    return (
        <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
                <Button variant="ghost" size="icon" className="h-8 w-8 text-gray-400 hover:text-blue-600 hover:bg-blue-50 opacity-0 group-hover:opacity-100 transition-all">
                    <UserCog className="h-4 w-4" />
                </Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[425px] rounded-2xl">
                <DialogHeader>
                    <DialogTitle className="flex items-center gap-2">
                        <div className="h-8 w-8 rounded-lg bg-blue-50 flex items-center justify-center">
                            <UserCog className="h-4 w-4 text-blue-600" />
                        </div>
                        Edit Personnel Details
                    </DialogTitle>
                </DialogHeader>
                <form onSubmit={handleSubmit} className="space-y-4 py-4">
                    <div className="space-y-2">
                        <Label htmlFor="full_name" className="text-[10px] font-bold uppercase tracking-widest text-gray-400">Full Name</Label>
                        <div className="relative">
                            <User className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                            <Input
                                id="full_name"
                                value={formData.full_name}
                                onChange={(e) => setFormData(prev => ({ ...prev, full_name: e.target.value }))}
                                className="pl-10 h-11 bg-gray-50 border-gray-100 focus-visible:ring-blue-500 rounded-xl"
                                placeholder="Enter full name"
                                required
                            />
                        </div>
                    </div>
                    <div className="space-y-2">
                        <Label htmlFor="department" className="text-[10px] font-bold uppercase tracking-widest text-gray-400">Department / Office</Label>
                        <div className="relative">
                            <Building2 className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                            <Input
                                id="department"
                                value={formData.department}
                                onChange={(e) => setFormData(prev => ({ ...prev, department: e.target.value }))}
                                className="pl-10 h-11 bg-gray-50 border-gray-100 focus-visible:ring-blue-500 rounded-xl"
                                placeholder="e.g. CDRRMO, Fire Dept"
                            />
                        </div>
                    </div>
                    <div className="space-y-2">
                        <Label htmlFor="phone" className="text-[10px] font-bold uppercase tracking-widest text-gray-400">Phone Number</Label>
                        <div className="relative">
                            <Phone className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                            <Input
                                id="phone"
                                value={formData.phone_number}
                                onChange={(e) => setFormData(prev => ({ ...prev, phone_number: e.target.value }))}
                                className="pl-10 h-11 bg-gray-50 border-gray-100 focus-visible:ring-blue-500 rounded-xl"
                                placeholder="09XXXXXXXXX"
                            />
                        </div>
                    </div>
                    <DialogFooter className="pt-4 flex gap-2 sm:justify-end">
                        <Button type="button" variant="ghost" onClick={() => setOpen(false)} className="rounded-xl">Cancel</Button>
                        <Button type="submit" disabled={isSubmitting} className="bg-blue-600 hover:bg-blue-700 rounded-xl px-8 shadow-md shadow-blue-200">
                            {isSubmitting ? 'Saving...' : 'Save Changes'}
                        </Button>
                    </DialogFooter>
                </form>
            </DialogContent>
        </Dialog>
    )
}
