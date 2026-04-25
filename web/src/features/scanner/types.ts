import { StationManifestItem } from "../tactical-stations/types";
import { InventoryItem } from "@/lib/supabase";

export type ScannerPayloadType = 'item' | 'station' | 'person' | 'unknown';

export interface ScannerPayload {
    type: ScannerPayloadType;
    id: string | number;
    raw: string;
    metadata?: {
        name?: string;
        location?: string;
        role?: string;
    };
}

export interface ScanResult {
    item?: InventoryItem;
    station?: {
        id: number;
        name: string;
        manifest: StationManifestItem[];
    };
    error?: string;
}
