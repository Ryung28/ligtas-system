import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { Shield, Package, BarChart3 } from 'lucide-react'

export default function Home() {
    return (
        <main className="flex min-h-screen flex-col items-center justify-center bg-gradient-to-br from-blue-50 via-white to-orange-50 p-8">
            <div className="max-w-4xl w-full text-center space-y-8">
                {/* Logo */}
                <div className="flex justify-center mb-6">
                    <div className="inline-flex items-center justify-center w-24 h-24 bg-gradient-to-br from-blue-600 to-blue-700 rounded-3xl shadow-xl">
                        <Shield className="w-12 h-12 text-white" />
                    </div>
                </div>

                {/* Title */}
                <div className="space-y-4">
                    <h1 className="text-5xl md:text-6xl font-bold text-gray-900">
                        CDRRMO Inventory System
                    </h1>
                    <p className="text-xl text-gray-600 max-w-2xl mx-auto">
                        City Disaster Risk Reduction & Management Office
                    </p>
                    <p className="text-lg text-gray-500">
                        Professional inventory tracking and management solution
                    </p>
                </div>

                {/* Features */}
                <div className="grid md:grid-cols-3 gap-6 my-12">
                    <div className="bg-white p-6 rounded-2xl shadow-md border-t-4 border-blue-600">
                        <Package className="h-10 w-10 text-blue-600 mx-auto mb-4" />
                        <h3 className="font-bold text-gray-900 mb-2">Real-Time Tracking</h3>
                        <p className="text-sm text-gray-600">
                            Monitor inventory levels with live updates
                        </p>
                    </div>
                    <div className="bg-white p-6 rounded-2xl shadow-md border-t-4 border-orange-500">
                        <BarChart3 className="h-10 w-10 text-orange-500 mx-auto mb-4" />
                        <h3 className="font-bold text-gray-900 mb-2">Smart Analytics</h3>
                        <p className="text-sm text-gray-600">
                            Get insights on stock levels and alerts
                        </p>
                    </div>
                    <div className="bg-white p-6 rounded-2xl shadow-md border-t-4 border-green-600">
                        <Shield className="h-10 w-10 text-green-600 mx-auto mb-4" />
                        <h3 className="font-bold text-gray-900 mb-2">Secure Access</h3>
                        <p className="text-sm text-gray-600">
                            Protected with enterprise-grade security
                        </p>
                    </div>
                </div>

                {/* CTA Buttons */}
                <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
                    <Link href="/login">
                        <Button size="lg" className="bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white px-8 py-6 text-lg rounded-xl shadow-lg hover:shadow-xl transition-all">
                            Sign In
                        </Button>
                    </Link>
                    <Link href="/dashboard/inventory">
                        <Button size="lg" variant="outline" className="border-2 border-blue-600 text-blue-600 hover:bg-blue-50 px-8 py-6 text-lg rounded-xl transition-all">
                            View Dashboard
                        </Button>
                    </Link>
                </div>

                {/* Footer Note */}
                <p className="text-sm text-gray-500 mt-12">
                    Powered by Next.js, Supabase & Shadcn/UI
                </p>
            </div>
        </main>
    )
}
