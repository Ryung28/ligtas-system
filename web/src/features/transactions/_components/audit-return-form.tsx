'use client';

import * as React from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import * as z from 'zod';
import { Label } from '@/components/ui/label';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';

export const returnAuditSchema = z.object({
    received_by_name: z.string().min(1, 'Receiver name is required'),
    return_condition: z.enum(['good', 'fair', 'damaged']),
    return_notes: z.string().optional(),
});

export type ReturnAuditFormValues = z.infer<typeof returnAuditSchema>;

interface AuditReturnFormProps {
    defaultValues: Partial<ReturnAuditFormValues>;
    onChange: (values: ReturnAuditFormValues, isValid: boolean) => void;
}

/**
 * AuditReturnForm (Stabilized)
 * 
 * Pattern: Dependency-Guarded Reactivity
 * Safety: Uses JSON stringification to prevent infinite render loops.
 */
export function AuditReturnForm({ defaultValues, onChange }: AuditReturnFormProps) {
    const {
        register,
        formState: { errors, isValid },
        watch,
        setValue,
    } = useForm<ReturnAuditFormValues>({
        resolver: zodResolver(returnAuditSchema),
        defaultValues: {
            received_by_name: '',
            return_condition: 'good',
            return_notes: '',
            ...defaultValues,
        },
        mode: 'onChange',
    });

    const values = watch();
    const valuesString = JSON.stringify(values);

    React.useEffect(() => {
        onChange(JSON.parse(valuesString) as ReturnAuditFormValues, isValid);
    }, [valuesString, isValid, onChange]);

    return (
        <div className="space-y-4">
            <div className="space-y-2">
                <Label className="text-sm font-semibold text-slate-700">Receiving Officer *</Label>
                <Input 
                    {...register('received_by_name')} 
                    placeholder="Officer on Duty"
                    className="rounded-lg border-slate-300 shadow-sm"
                />
                {errors.received_by_name && <p className="text-[10px] text-red-500 font-bold uppercase">{errors.received_by_name.message}</p>}
            </div>

            <div className="space-y-2">
                <Label className="text-sm font-semibold text-slate-700">Item Condition *</Label>
                <Select 
                    defaultValue={values.return_condition} 
                    onValueChange={(val: any) => setValue('return_condition', val, { shouldValidate: true })}
                >
                    <SelectTrigger className="rounded-lg border-slate-300 h-11 bg-white shadow-sm">
                        <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                        <SelectItem value="good">Good Condition</SelectItem>
                        <SelectItem value="fair">Needs Minor Maintenance</SelectItem>
                        <SelectItem value="damaged">Damaged / Broken</SelectItem>
                    </SelectContent>
                </Select>
            </div>

            <div className="space-y-2">
                <Label className="text-sm font-semibold text-slate-700">Remarks</Label>
                <Textarea 
                    {...register('return_notes')} 
                    placeholder="Note any issues, damage details, or mission feedback..."
                    className="min-h-[100px] rounded-lg border-slate-300 shadow-sm"
                />
            </div>
        </div>
    );
}
