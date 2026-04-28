import { createClient } from '@supabase/supabase-js'
import { NextResponse } from 'next/server'

/**
 * 🏥 LIGTAS KEEP-ALIVE SYSTEM
 * This endpoint is pinged by an external cron service (like cron-job.org)
 * to prevent Supabase Free Tier from pausing due to inactivity.
 */
export async function GET() {
    try {
        const supabase = createClient(
            process.env.NEXT_PUBLIC_SUPABASE_URL!,
            process.env.SUPABASE_SERVICE_ROLE_KEY!
        )

        // Reset the 7-day inactivity timer by performing a simple query
        const { error } = await supabase
            .from('inventory')
            .select('id')
            .limit(1)

        if (error) throw error

        return NextResponse.json({ 
            status: 'awake', 
            timestamp: new Date().toISOString() 
        })
    } catch (error) {
        console.error('Health check failed:', error)
        return NextResponse.json({ 
            status: 'error', 
            message: 'Database connection failed' 
        }, { status: 500 })
    }
}
