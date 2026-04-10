/**
 * 📱 LIGTAS Device Detection Utility
 * 🛠️ WORKER'S TOOL: User-Agent Interception
 * Used in middleware to determine the operational segment (Desktop vs Mobile PWA)
 */

export function isMobileDevice(userAgent: string): boolean {
    if (!userAgent) return false;
    
    const mobileRegex = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i;
    
    return mobileRegex.test(userAgent);
}
