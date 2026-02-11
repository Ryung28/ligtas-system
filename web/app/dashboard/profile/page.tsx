'use client'

import { useEffect, useState } from 'react'
import { getCurrentUser } from '@/lib/auth'
import { Card, CardContent, CardHeader, CardTitle, CardDescription, CardFooter } from '@/components/ui/card'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Mail, Shield, Building, Loader2, Camera } from 'lucide-react'

export default function ProfilePage() {
    const [user, setUser] = useState<any>(null)
    const [loading, setLoading] = useState(true)

    useEffect(() => {
        getCurrentUser().then(u => {
            setUser(u)
            setLoading(false)
        })
    }, [])

    if (loading) {
        return (
            <div className="flex h-[50vh] items-center justify-center">
                <Loader2 className="h-8 w-8 animate-spin text-gray-300" />
            </div>
        )
    }

    const email = user?.email || 'user@example.com'
    const name = email.split('@')[0]
    const initials = name.substring(0, 2).toUpperCase()

    return (
        <div className="space-y-6 max-w-5xl mx-auto">
            <div>
                <h1 className="text-3xl font-bold tracking-tight text-gray-900 font-heading">My Profile</h1>
                <p className="text-gray-500 mt-1">Manage your account settings and preferences.</p>
            </div>

            <div className="grid gap-6 md:grid-cols-[320px_1fr]">
                {/* ID Card */}
                <Card className="h-fit shadow-sm border-gray-200">
                    <CardHeader className="text-center relative pb-2 pt-8">
                        <div className="mx-auto relative group cursor-pointer">
                            <Avatar className="h-32 w-32 border-4 border-white shadow-xl mx-auto bg-blue-50 ring-1 ring-gray-100">
                                <AvatarFallback className="text-4xl text-blue-600 font-bold bg-blue-50">{initials}</AvatarFallback>
                            </Avatar>
                            <div className="absolute inset-0 bg-black/40 rounded-full opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                                <Camera className="h-8 w-8 text-white/80" />
                            </div>
                        </div>
                        <CardTitle className="mt-4 text-xl font-bold text-gray-900 capitalize">{name.replace('.', ' ')}</CardTitle>
                        <CardDescription className="text-sm font-medium text-gray-500">{email}</CardDescription>
                        <div className="flex justify-center mt-4">
                            <Badge className="bg-blue-100 text-blue-700 hover:bg-blue-200 px-3 py-1 text-xs">Administrator</Badge>
                        </div>
                    </CardHeader>
                    <CardContent className="space-y-4 pt-6">
                        <div className="flex items-center gap-3 text-sm text-gray-700 p-3 bg-gray-50/80 rounded-lg border border-gray-100">
                            <Building className="h-4 w-4 text-gray-500" />
                            <span className="font-medium">CDRRMO Office</span>
                        </div>
                        <div className="flex items-center gap-3 text-sm text-gray-700 p-3 bg-gray-50/80 rounded-lg border border-gray-100">
                            <Shield className="h-4 w-4 text-gray-500" />
                            <span className="font-medium">Full System Access</span>
                        </div>
                    </CardContent>
                </Card>

                {/* Details Form */}
                <Card className="shadow-sm border-gray-200">
                    <CardHeader>
                        <CardTitle className="text-lg">Personal Information</CardTitle>
                        <CardDescription>Update your personal details here.</CardDescription>
                    </CardHeader>
                    <CardContent className="space-y-6">
                        <div className="grid grid-cols-2 gap-4">
                            <div className="grid gap-2">
                                <Label htmlFor="firstname">First Name</Label>
                                <Input id="firstname" defaultValue="Admin" className="bg-white" />
                            </div>
                            <div className="grid gap-2">
                                <Label htmlFor="lastname">Last Name</Label>
                                <Input id="lastname" defaultValue="User" className="bg-white" />
                            </div>
                        </div>
                        <div className="grid gap-2">
                            <Label htmlFor="email">Email Address</Label>
                            <div className="relative">
                                <Mail className="absolute left-3 top-2.5 h-4 w-4 text-gray-400" />
                                <Input id="email" defaultValue={email} disabled className="pl-9 bg-gray-50 text-gray-500" />
                            </div>
                        </div>
                        <div className="grid gap-2">
                            <Label htmlFor="dept">Department</Label>
                            <Input id="dept" defaultValue="Logistics & Inventory" className="bg-white" />
                        </div>

                        <div className="pt-4 border-t border-gray-100">
                            <h3 className="text-sm font-medium text-gray-900 mb-4">Security</h3>
                            <Button variant="outline" className="w-full sm:w-auto text-red-600 border-red-200 hover:bg-red-50 hover:text-red-700">
                                Reset Password
                            </Button>
                        </div>
                    </CardContent>
                    <CardFooter className="flex justify-end gap-3 border-t border-gray-100 pt-6 bg-gray-50/30">
                        <Button variant="ghost" className="text-gray-600">Discard</Button>
                        <Button className="bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white shadow-md">
                            Save Changes
                        </Button>
                    </CardFooter>
                </Card>
            </div>
        </div>
    )
}
