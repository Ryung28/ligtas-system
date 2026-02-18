'use client'

import { useEffect, useState } from 'react'
import { createBrowserClient } from '@supabase/ssr'
import { Card, CardContent, CardHeader, CardTitle, CardDescription, CardFooter } from '@/components/ui/card'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Mail, Shield, Building, Loader2, User, Save } from 'lucide-react'
import { toast } from 'sonner'
import { UserProfile } from '@/hooks/use-user-management'

export default function ProfilePage() {
    const [profile, setProfile] = useState<UserProfile | null>(null)
    const [loading, setLoading] = useState(true)
    const [saving, setSaving] = useState(false)

    // Form states
    const [fullName, setFullName] = useState('')
    const [department, setDepartment] = useState('')

    const supabase = createBrowserClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    )

    useEffect(() => {
        const loadProfile = async () => {
            try {
                // 1. Get auth user
                const { data: { user } } = await supabase.auth.getUser()

                if (!user) {
                    setLoading(false)
                    return
                }

                // 2. Get profile data
                const { data, error } = await supabase
                    .from('user_profiles')
                    .select('*')
                    .eq('id', user.id)
                    .single()

                if (data) {
                    setProfile(data)
                    setFullName(data.full_name || '')
                    setDepartment(data.department || '')
                }
            } catch (error) {
                console.error('Error loading profile:', error)
                toast.error('Failed to load profile data')
            } finally {
                setLoading(false)
            }
        }

        loadProfile()
    }, [supabase])

    const handleSave = async () => {
        if (!profile) return

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
            // Update local state
            setProfile({ ...profile, full_name: fullName, department })
        } catch (error) {
            console.error('Error updating profile:', error)
            toast.error('Failed to update profile')
        } finally {
            setSaving(false)
        }
    }

    if (loading) {
        return (
            <div className="flex h-[50vh] items-center justify-center">
                <Loader2 className="h-8 w-8 animate-spin text-gray-300" />
            </div>
        )
    }

    if (!profile) return null

    const initials = (profile.full_name || profile.email).substring(0, 2).toUpperCase()
    const roleColors = {
        admin: 'bg-purple-100 text-purple-700 border-purple-200',
        editor: 'bg-blue-100 text-blue-700 border-blue-200',
        viewer: 'bg-gray-100 text-gray-700 border-gray-200'
    }

    return (
        <div className="space-y-6 max-w-5xl mx-auto animate-in fade-in duration-500">
            <div>
                <h1 className="text-3xl font-bold tracking-tight text-gray-900 font-heading">My Profile</h1>
                <p className="text-gray-500 mt-1">Manage your professional identity and account details.</p>
            </div>

            <div className="grid gap-6 md:grid-cols-[320px_1fr]">
                {/* ID Card */}
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
                                {profile.role} Access
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
                            <span className="font-medium capitalize">{profile.status} Status</span>
                        </div>
                    </CardContent>
                </Card>

                {/* Details Form */}
                <Card className="shadow-sm border-gray-200">
                    <CardHeader>
                        <div className="flex items-center gap-2">
                            <User className="h-5 w-5 text-gray-400" />
                            <CardTitle className="text-lg">Personal Information</CardTitle>
                        </div>
                        <CardDescription>Update your personal details here.</CardDescription>
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
        </div>
    )
}
