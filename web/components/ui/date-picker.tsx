"use client"

import * as React from "react"
import { format } from "date-fns"
import { Calendar as CalendarIcon, X } from "lucide-react"

import { cn } from "@/lib/utils"
import { Button } from "@/components/ui/button"
import { Calendar } from "@/components/ui/calendar"
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover"

interface DatePickerProps {
  date?: Date
  setDate: (date?: Date) => void
  placeholder?: string
  className?: string
  clearable?: boolean
}

export function DatePicker({
  date,
  setDate,
  placeholder = "Pick a date",
  className,
  clearable = true
}: DatePickerProps) {
  return (
    <Popover>
      <PopoverTrigger asChild>
        <Button
          variant={"outline"}
          className={cn(
            "h-10 justify-start text-left font-medium text-xs border-zinc-200 rounded-lg bg-white hover:bg-zinc-50 transition-all shadow-sm",
            "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-zinc-900/10 focus-visible:border-zinc-900",
            !date && "text-zinc-400",
            "relative",
            className
          )}
        >
          <CalendarIcon className="mr-2 h-4 w-4 text-zinc-400" />
          {date ? format(date, "PPP") : <span>{placeholder}</span>}
          
          {clearable && date && (
            <div 
              className="absolute right-2 top-1/2 -translate-y-1/2 p-1 rounded-full hover:bg-zinc-200 text-zinc-400 hover:text-zinc-600 z-10 transition-colors"
              onClick={(e) => {
                e.stopPropagation()
                setDate(undefined)
              }}
            >
              <X className="h-3 w-3" />
            </div>
          )}
        </Button>
      </PopoverTrigger>
      <PopoverContent className="w-auto p-0 bg-white/95 backdrop-blur-md shadow-[0_8px_40px_rgb(0,0,0,0.06)] border border-zinc-200 rounded-xl" align="start">
        <Calendar
          mode="single"
          selected={date}
          onSelect={setDate}
          initialFocus
        />
      </PopoverContent>
    </Popover>
  )
}
