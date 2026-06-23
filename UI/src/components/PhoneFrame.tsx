import React from 'react';
import { StatusBar } from './StatusBar';
interface PhoneFrameProps {
  children: React.ReactNode;
}
export function PhoneFrame({ children }: PhoneFrameProps) {
  return (
    <div className="relative w-[390px] h-[844px] bg-app-bg rounded-[50px] overflow-hidden shadow-2xl ring-[12px] ring-[#2A2635] flex flex-col">
      {/* Notch mock */}
      <div className="absolute top-0 inset-x-0 h-7 flex justify-center z-50">
        <div className="w-[120px] h-7 bg-[#2A2635] rounded-b-[20px]"></div>
      </div>

      <StatusBar />

      <div className="flex-1 overflow-y-auto hide-scrollbar relative">
        {children}
      </div>
    </div>);

}