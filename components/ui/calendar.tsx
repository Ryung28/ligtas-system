"use client"

import * as React from "react"
import { ChevronLeft, ChevronRight } from "lucide-react"
import { DayPicker } from "react-day-picker"

import { cn } from "@/lib/utils"
import { buttonVariants } from "@/components/ui/button"

export type CalendarProps = React.ComponentProps<typeof DayPicker>

function Calendar({
  className,
  classNames,
  showOutsideDays = true,
  ...props
}: CalendarProps) {
  return (
    <DayPicker
      showOutsideDays={showOutsideDays}
      className={cn("p-3", className)}
      classNames={{
        months: "flex flex-col sm:flex-row space-y-4 sm:space-x-4 sm:space-y-0 items-start",
        month: "space-y-4",
        month_caption: "flex items-center justify-between h-10 px-1 relative mb-1",
        caption_label: "text-[12px] font-bold text-zinc-950 uppercase tracking-widest pl-2",
        nav: "flex items-center gap-1",
        button_previous: cn(
          buttonVariants({ variant: "outline" }),
          "h-7 w-7 bg-white p-0 opacity-100 border-zinc-200 rounded-md transition-all hover:bg-zinc-50 shadow-sm"
        ),
        button_next: cn(
          buttonVariants({ variant: "outline" }),
          "h-7 w-7 bg-white p-0 opacity-100 border-zinc-200 rounded-md transition-all hover:bg-zinc-50 shadow-sm"
        ),
        month_grid: "w-full border-collapse",
        weekdays: "flex border-b border-zinc-100 pb-2 mb-2",
        weekday: "text-zinc-400 w-8 font-black text-[9px] uppercase tracking-tighter text-center",
        week: "flex w-full mt-1",
        day: "h-8 w-8 text-center text-xs p-0 m-[1px] relative",
        day_button: cn(
          buttonVariants({ variant: "ghost" }),
          "h-8 w-8 p-0 font-medium aria-selected:opacity-100 hover:bg-zinc-100 text-zinc-900 rounded-md transition-all"
        ),
        selected: "bg-zinc-900 text-zinc-50 hover:bg-zinc-900 hover:text-zinc-50 focus:bg-zinc-900 focus:text-zinc-50 rounded-md shadow-[0_4px_12px_rgba(0,0,0,0.1)]",
        today: "bg-zinc-100 text-zinc-950 font-black",
        outside: "day-outside text-zinc-300 opacity-30 aria-selected:bg-zinc-100/50 aria-selected:text-zinc-300 aria-selected:opacity-20",
        disabled: "text-zinc-400 opacity-20",
        range_middle: "aria-selected:bg-zinc-100 aria-selected:text-zinc-900",
        hidden: "invisible",
        ...classNames,
      }}
      components={{
        Chevron: ({ ...props }) => {
          if (props.orientation === 'left') {
            return <ChevronLeft className="h-4 w-4 text-zinc-900" />
          }
          return <ChevronRight className="h-4 w-4 text-zinc-900" />
        }
      }}
      {...props}
    />
  )
}
Calendar.displayName = "Calendar"

export { Calendar }
