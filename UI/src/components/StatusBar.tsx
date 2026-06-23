import React from 'react';
import { Battery, Wifi, Signal } from 'lucide-react';
export function StatusBar() {
  return (
    <div className="flex justify-between items-center px-6 py-3 w-full text-white z-50 relative">
      <div className="text-[15px] font-semibold tracking-tight">9:41</div>
      <div className="flex items-center gap-1.5">
        <Signal className="w-4 h-4" />
        <Wifi className="w-4 h-4" />
        <Battery className="w-[22px] h-[22px]" />
      </div>
    </div>);

}