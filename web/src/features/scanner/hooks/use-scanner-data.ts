import { useState, useCallback } from 'react';
import { supabase } from '@/lib/supabase';
import { getStationManifest } from '@/src/features/tactical-stations/actions/station.actions';
import { ScannerPayload, ScanResult } from '../types';
import { toast } from 'sonner';

/**
 * 🛠️ SCANNER DATA HOOK
 * Manages the transition from raw QR payload to hydrated UI data.
 */
export function useScannerData() {
    const [isResolving, setIsResolving] = useState(false);
    const [scanResult, setScanResult] = useState<ScanResult | null>(null);

    const resolvePayload = useCallback(async (payload: ScannerPayload) => {
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
                    setScanResult({ item });
                }
            } else if (payload.type === 'station') {
                const result = await getStationManifest(Number(payload.id));
                
                if (result.error || !result.data) {
                    setScanResult({ error: result.error || 'Station not found.' });
                } else {
                    setScanResult({ 
                        station: { 
                            id: Number(payload.id), 
                            name: payload.metadata?.name || 'Tactical Hub',
                            manifest: result.data 
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
        }
    }, []);

    const resetScanner = useCallback(() => {
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
