import { useState, useCallback, useRef } from 'react';
import { supabase } from '@/lib/supabase';
import { getStationManifest } from '@/src/features/tactical-stations/actions/station.queries';
import { ScannerPayload, ScanResult } from '../types';
import { toast } from 'sonner';

/**
 * 🛠️ SCANNER DATA HOOK
 * Manages the transition from raw QR payload to hydrated UI data.
 */
export function useScannerData() {
    const [isResolving, setIsResolving] = useState(false);
    const [scanResult, setScanResult] = useState<ScanResult | null>(null);
    const isProcessing = useRef(false);
    const hasActiveResult = useRef(false);

    const resolvePayload = useCallback(async (payload: ScannerPayload) => {
        // 🛡️ RE-ENTRANCY GUARD: Use Refs for synchronous locking
        // We check both 'processing' and 'hasActiveResult' to prevent loops
        if (isProcessing.current || hasActiveResult.current) return;

        isProcessing.current = true;
        setIsResolving(true);
        setScanResult(null);

        try {
            if (payload.type === 'item') {
                const { data: item, error } = await supabase
                    .from('inventory')
                    .select('*')
                    .eq('id', payload.id)
                    .single();

                if (error || !item) {
                    setScanResult({ error: `Item ID ${payload.id} not found.` });
                } else {
                    hasActiveResult.current = true;
                    setScanResult({ item });
                }
            } else if (payload.type === 'station') {
                // 🛰️ TACTICAL RESOLUTION: Support both numeric IDs and string codes
                const result = await getStationManifest(payload.id);
                
                if (result.error || !result.data) {
                    setScanResult({ error: result.error || 'Station not found.' });
                } else {
                    const { station, items } = result.data;
                    hasActiveResult.current = true;
                    setScanResult({ 
                        station: { 
                            id: station.id, 
                            name: station.station_name || station.location_name,
                            image_url: station.image_url,
                            manifest: items 
                        } 
                    });
                }
            } else if (payload.type === 'person') {
                setScanResult({ error: 'Personnel scanning is restricted to the Analyst Terminal.' });
            } else {
                setScanResult({ error: 'Unrecognized protocol. Please scan a ResQTrack label.' });
            }
        } catch (e) {
            console.error('[Scanner:Resolve]', e);
            setScanResult({ error: 'Network error while resolving scan.' });
        } finally {
            setIsResolving(false);
            isProcessing.current = false;
        }
    }, []); // Removed scanResult dependency to keep the function stable

    const resetScanner = useCallback(() => {
        isProcessing.current = false;
        hasActiveResult.current = false;
        setScanResult(null);
        setIsResolving(false);
    }, []);

    return {
        isResolving,
        scanResult,
        resolvePayload,
        resetScanner
    };
}
