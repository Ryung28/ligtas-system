import { ScannerPayload } from "./types";

/**
 * 🛡️ ResQTrack PROTOCOL RESOLVER
 * Mirrored from Flutter implementation for functional parity.
 */
export function parseQrPayload(raw: string): ScannerPayload {
    const sanitized = raw.trim();

    // 1. URI RESOLVER (resqtrack://)
    if (sanitized.startsWith('resqtrack://') || sanitized.startsWith('ligtas://')) {
        try {
            const url = new URL(sanitized.replace('ligtas://', 'resqtrack://'));
            const id = url.pathname.split('/').filter(Boolean).pop() || '';
            const name = url.searchParams.get('name') || undefined;

            if (url.host === 'station' || url.host === 's') {
                return { type: 'station', id: parseInt(id) || id, raw: sanitized, metadata: { name } };
            }

            if (url.host === 'item' || url.host === 'i') {
                return { type: 'item', id: parseInt(id) || 0, raw: sanitized, metadata: { name } };
            }

            if (['person', 'p', 'u', 'user'].includes(url.host)) {
                return { type: 'person', id, raw: sanitized, metadata: { name, role: url.searchParams.get('role') || undefined } };
            }
        } catch (e) {
            console.error('[Scanner:Protocol] Mismatch', e);
        }
    }

    // 2. JSON FALLBACK (Legacy & Station Hub Standard)
    if (sanitized.startsWith('{')) {
        try {
            const data = JSON.parse(sanitized);
            
            if (data.sid) {
                return { type: 'station', id: data.sid, raw: sanitized, metadata: { name: data.loc } };
            }

            if (data.itemId) {
                return { type: 'item', id: data.itemId, raw: sanitized, metadata: { name: data.itemName } };
            }
        } catch (e) {}
    }

    // 3. TACTICAL FALLBACK (Raw Numeric or Pipe)
    const itemId = parseInt(sanitized);
    if (!isNaN(itemId)) {
        return { type: 'item', id: itemId, raw: sanitized };
    }

    if (sanitized.includes('|')) {
        const parts = sanitized.split('|');
        const possibleId = parseInt(parts[0]);
        if (!isNaN(possibleId)) {
            return { type: 'item', id: possibleId, raw: sanitized, metadata: { name: parts[1] } };
        }
        return { type: 'person', id: parts[0], raw: sanitized, metadata: { name: parts[1] } };
    }

    return { type: 'unknown', id: sanitized, raw: sanitized };
}
