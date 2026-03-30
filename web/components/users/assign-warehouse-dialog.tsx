'use client'

import { useState } from 'react'
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Warehouse, Loader2 } from 'lucide-react'

interface AssignWarehouseDialogProps {
  userId: string
  currentWarehouse: string | null
  userName: string
  onAssign: (userId: string, warehouse: string | null) => Promise<boolean>
}

export function AssignWarehouseDialog({ userId, currentWarehouse, userName, onAssign }: AssignWarehouseDialogProps) {
  const [open, setOpen] = useState(false)
  const [selectedWarehouse, setSelectedWarehouse] = useState<string | null>(currentWarehouse)
  const [isSubmitting, setIsSubmitting] = useState(false)

  const handleSubmit = async () => {
    setIsSubmitting(true)
    const success = await onAssign(userId, selectedWarehouse)
    setIsSubmitting(false)
    
    if (success) {
      setOpen(false)
    }
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button
          variant="ghost"
          size="icon"
          title="Assign Warehouse"
          className="h-8 w-8 rounded-md text-gray-400 hover:text-blue-600 hover:bg-blue-50 transition-colors"
        >
          <Warehouse className="h-3.5 w-3.5" />
        </Button>
      </DialogTrigger>
      <DialogContent className="rounded-xl">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <Warehouse className="h-5 w-5 text-blue-600" />
            Assign Warehouse
          </DialogTitle>
          <DialogDescription>
            Assign {userName} to a specific warehouse. Admins have full access regardless of assignment.
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-4 py-4">
          <div className="space-y-2">
            <label className="text-sm font-medium text-gray-700">Warehouse Location</label>
            <Select value={selectedWarehouse || 'none'} onValueChange={(val) => setSelectedWarehouse(val === 'none' ? null : val)}>
              <SelectTrigger className="rounded-lg">
                <SelectValue placeholder="Select warehouse" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="none">No Assignment (No Access)</SelectItem>
                <SelectItem value="Lower Warehouse">Lower Warehouse</SelectItem>
                <SelectItem value="2nd Floor Warehouse">2nd Floor Warehouse</SelectItem>
                <SelectItem value="Office">Office</SelectItem>
                <SelectItem value="Field">Field</SelectItem>
              </SelectContent>
            </Select>
            <p className="text-xs text-gray-500">
              {selectedWarehouse 
                ? `User will only see inventory and logs from ${selectedWarehouse}`
                : 'User will have no access until assigned'}
            </p>
          </div>
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={() => setOpen(false)} disabled={isSubmitting} className="rounded-lg">
            Cancel
          </Button>
          <Button onClick={handleSubmit} disabled={isSubmitting} className="rounded-lg bg-blue-600 hover:bg-blue-700">
            {isSubmitting ? (
              <>
                <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                Assigning...
              </>
            ) : (
              'Assign Warehouse'
            )}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
