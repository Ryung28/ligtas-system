'use client'

import { useState } from 'react'

/**
 * CATALOG ITEM DIALOG V3 — Identity Hook
 * Domain: name, category, item type, serial, model, brand, expiry.
 * No cross-domain dependencies. Safe to test in isolation.
 */
export function useItemIdentity(item?: any) {
    const [name, setName] = useState<string>(item?.item_name || '')
    const [categoryId, setCategoryId] = useState<string>(item?.category || '')
    const [description, setDescription] = useState<string>(item?.description || '')
    const [itemType, setItemType] = useState<'equipment' | 'consumable'>(item?.item_type || 'equipment')
    const [serialNumber, setSerialNumber] = useState<string>(item?.serial_number || '')
    const [modelNumber, setModelNumber] = useState<string>(item?.model_number || '')
    const [brand, setBrand] = useState<string>(item?.brand || '')
    const [expiryDate, setExpiryDate] = useState<string>(
        item?.expiry_date ? new Date(item.expiry_date).toISOString().split('T')[0] : ''
    )
    const [expiryAlertDays, setExpiryAlertDays] = useState<number | string>(item?.expiry_alert_days ?? 15)

    return {
        name, setName,
        categoryId, setCategoryId,
        description, setDescription,
        itemType, setItemType,
        serialNumber, setSerialNumber,
        modelNumber, setModelNumber,
        brand, setBrand,
        expiryDate, setExpiryDate,
        expiryAlertDays, setExpiryAlertDays,
    }
}

export type ItemIdentityState = ReturnType<typeof useItemIdentity>
