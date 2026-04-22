'use client';

import * as React from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import * as z from 'zod';
import { Label } from '@/components/ui/label';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';

export const borrowerIdentitySchema = z.object({
    borrower_name: z.string().min(1, 'Borrower name is required'),
    contact_number: z.string().regex(/^09\d{9}$/, 'Must be a valid PH mobile number (09XXXXXXXXX)'),
    office_department: z.string().min(1, 'Office/Department is required'),
    released_by: z.string().min(1, 'Released by is required'),
    approved_by: z.string().min(1, 'Approver name is required'),
    purpose: z.string().min(1, 'Purpose is required'),
    return_type: z.enum(['anytime', 'date']).default('anytime'),
    expected_return_date: z.string().optional(),
});

export type IdentityFormValues = z.infer<typeof borrowerIdentitySchema>;

interface BorrowerIdentityFormProps {
    defaultValues: Partial<IdentityFormValues>;
    onChange: (values: IdentityFormValues, isValid: boolean) => void;
}

/**
 * BorrowerIdentityForm (Forensic V3 Edition)
 * 
 * Pattern: High-Contrast Tactical Form
 * Parity: Matches the "Dispatch Item" monolith layout with sticky-friendly constraints.
 */
export function BorrowerIdentityForm({ defaultValues, onChange }: BorrowerIdentityFormProps) {
    const {
        register,
        formState: { errors, isValid },
        watch,
        setValue,
    } = useForm<IdentityFormValues>({
        resolver: zodResolver(borrowerIdentitySchema),
        defaultValues: {
            borrower_name: '',
            contact_number: '',
            office_department: '',
            released_by: 'Brandon James C. Galabin',
            approved_by: '',
            purpose: '',
            return_type: 'anytime',
            expected_return_date: '',
            ...defaultValues,
        },
        mode: 'onChange',
    });

    const values = watch();
    const valuesString = JSON.stringify(values);

    React.useEffect(() => {
        onChange(JSON.parse(valuesString) as IdentityFormValues, isValid);
    }, [valuesString, isValid, onChange]);

    const returnType = watch('return_type');

    return (
        <div className="space-y-8 animate-in fade-in duration-500">
            
            {/* 👤 Personnel Identity Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-2.5">
                    <Label className="text-[14px] font-black text-slate-900 tracking-tight">
                        Borrower Name <span className="text-red-500">*</span>
                    </Label>
                    <Input 
                        {...register('borrower_name')} 
                        placeholder="Full name of borrower" 
                        className="h-14 bg-white border-slate-200 rounded-[18px] px-6 text-sm font-bold shadow-sm ring-blue-500 focus:ring-2 transition-all"
                    />
                    {errors.borrower_name && <p className="text-[10px] text-red-500 font-black uppercase ml-1 tracking-wider">{errors.borrower_name.message}</p>}
                </div>

                <div className="space-y-2.5">
                    <Label className="text-[14px] font-black text-slate-900 tracking-tight">
                        Contact Number <span className="text-red-500">*</span>
                        <span className="text-[11px] font-bold text-slate-400 ml-2 tracking-tighter uppercase">(PH Format: 09XXXXXXXXX)</span>
                    </Label>
                    <Input 
                        {...register('contact_number')} 
                        placeholder="09XXXXXXXXX" 
                        className="h-14 bg-white border-slate-200 rounded-[18px] px-6 text-sm font-bold shadow-sm"
                    />
                    {errors.contact_number && <p className="text-[10px] text-red-500 font-black uppercase ml-1 tracking-wider">{errors.contact_number.message}</p>}
                </div>

                <div className="space-y-2.5">
                    <Label className="text-[14px] font-black text-slate-900 tracking-tight">
                        Office / Department <span className="text-red-500">*</span>
                    </Label>
                    <Input 
                        {...register('office_department')} 
                        placeholder="Agency or Emergency Division" 
                        className="h-14 bg-white border-slate-200 rounded-[18px] px-6 text-sm font-bold shadow-sm"
                    />
                    {errors.office_department && <p className="text-[10px] text-red-500 font-black uppercase ml-1 tracking-wider">{errors.office_department.message}</p>}
                </div>

                <div className="space-y-2.5">
                    <Label className="text-[14px] font-black text-slate-900 tracking-tight">
                        Personnel Purpose <span className="text-red-500">*</span>
                    </Label>
                    <Input 
                        {...register('purpose')} 
                        placeholder="Specific mission or task details" 
                        className="h-14 bg-white border-slate-200 rounded-[18px] px-6 text-sm font-bold shadow-sm"
                    />
                    {errors.purpose && <p className="text-[10px] text-red-500 font-black uppercase ml-1 tracking-wider">{errors.purpose.message}</p>}
                </div>
            </div>

            {/* 🔄 Return Schedule Engine (Restored) */}
            <div className="p-7 border border-slate-100 rounded-[28px] bg-slate-50/50 space-y-5 shadow-sm">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6 items-end">
                    <div className="space-y-2.5">
                        <Label className="text-[14px] font-black text-slate-900 flex items-center gap-2">
                             Logistics Term / Return Schedule <span className="text-red-500">*</span>
                        </Label>
                        <Select value={returnType} onValueChange={(v: any) => setValue('return_type', v)}>
                            <SelectTrigger className="h-14 bg-white border-slate-200 rounded-[18px] px-6 font-bold text-slate-900">
                                <SelectValue placeholder="Return Anytime / Open-ended" />
                            </SelectTrigger>
                            <SelectContent className="rounded-2xl border-slate-200 shadow-xl">
                                <SelectItem value="anytime" className="font-bold text-slate-700">Return Anytime / Open-ended</SelectItem>
                                <SelectItem value="date" className="font-bold text-slate-700">Specific Return Date</SelectItem>
                            </SelectContent>
                        </Select>
                    </div>
                    
                    {returnType === 'date' ? (
                        <div className="space-y-2.5 animate-in slide-in-from-left-4 duration-300">
                            <Label className="text-[14px] font-black text-slate-900">Target Return Date <span className="text-red-500">*</span></Label>
                            <Input 
                                type="date" 
                                {...register('expected_return_date')}
                                className="h-14 bg-white border-slate-200 rounded-[18px] px-6 font-black text-slate-900 shadow-inner" 
                            />
                        </div>
                    ) : (
                        <div className="h-14 flex items-center px-6 bg-slate-200/30 rounded-[18px] border border-dashed border-slate-200 text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] text-center justify-center">
                            Tactical Continuity / Flexible Term
                        </div>
                    )}
                </div>
            </div>

            {/* 🛡️ Sign-Off Authentication */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6 p-7 bg-blue-50/30 rounded-[28px] border border-blue-100/50">
                <div className="space-y-2.5">
                    <div className="flex justify-between items-center px-1">
                        <Label className="text-[13px] font-black text-slate-900">Approved By <span className="text-red-500">*</span></Label>
                        <button type="button" onClick={() => setValue('approved_by', 'Brandon James C. Galabin')} className="text-[9px] font-black text-blue-600 uppercase tracking-widest hover:underline">Autofill</button>
                    </div>
                    <Input 
                        {...register('approved_by')} 
                        placeholder="Officer Authorizing Dispatch" 
                        className="h-14 bg-white border-slate-200 rounded-[18px] px-6 font-bold text-slate-900 shadow-sm"
                    />
                    {errors.approved_by && <p className="text-[10px] text-red-500 font-black uppercase ml-1 tracking-wider">{errors.approved_by.message}</p>}
                </div>

                <div className="space-y-2.5">
                    <Label className="text-[13px] font-black text-slate-900 px-1">Released By <span className="text-red-500">*</span></Label>
                    <Input 
                        {...register('released_by')} 
                        readOnly 
                        className="h-14 bg-slate-100 border-transparent rounded-[18px] px-6 font-black text-slate-600 cursor-not-allowed opacity-80"
                    />
                </div>
            </div>
        </div>
    );
}
