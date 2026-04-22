import type { ReportType, ReportConfig } from './types'
import { fetchReportDataAction } from '@/app/actions/report-actions'
import { generateReportHTMLV2 } from './report-html-templates-v2'
import { exportToExcel } from './report-excel-utils'
import { toast } from 'sonner'

/**
 * ⚡ ELITE REPORT GENERATOR (BACKGROUND IFRAME)
 * Zero-flicker, background rendering for seamless printing.
 */
export async function generateReport(
    type: ReportType,
    config: ReportConfig,
    format: 'print' | 'excel'
) {
    try {
        // 1. Fetch Data First (In background while button shows loading)
        const res = await fetchReportDataAction(type, config)
        
        if (!res.success || !res.data) {
            throw new Error(res.error || 'Failed to fetch data')
        }
        
        if (format === 'print') {
            // 2. Create Hidden IFrame
            const iframe = document.createElement('iframe');
            iframe.style.position = 'fixed';
            iframe.style.right = '0';
            iframe.style.bottom = '0';
            iframe.style.width = '0';
            iframe.style.height = '0';
            iframe.style.border = '0';
            document.body.appendChild(iframe);

            const doc = iframe.contentWindow?.document;
            if (!doc) throw new Error('Could not access iframe document');

            // 3. Inject HTML
            const html = generateReportHTMLV2(type, res.data, config);
            doc.open();
            doc.write(html);
            doc.close();

            // 4. Wait for Render & Print
            // We use a small delay only to ensure the browser's internal layout engine 
            // has finished painting the injected HTML for the printer.
            await new Promise(resolve => setTimeout(resolve, 250));
            
            iframe.contentWindow?.focus();
            iframe.contentWindow?.print();

            // 5. Cleanup
            setTimeout(() => {
                document.body.removeChild(iframe);
            }, 1000); // Wait for print dialog to clear before removal

        } else {
            await exportToExcel(type, res.data, config)
        }
    } catch (error: any) {
        console.error('Report failed:', error)
        toast.error('Could not generate report: ' + error.message)
    }
}
