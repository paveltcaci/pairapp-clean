import React from 'react';
import { Home, MessageSquareWarning, Sparkles, User } from 'lucide-react';
interface TabBarProps {
  activeTab: string;
  onTabChange?: (tab: string) => void;
}
export function TabBar({ activeTab, onTabChange }: TabBarProps) {
  const tabs = [
  {
    id: 'home',
    icon: Home,
    label: 'Главная'
  },
  {
    id: 'issues',
    icon: MessageSquareWarning,
    label: 'Проблемы'
  },
  {
    id: 'activities',
    icon: Sparkles,
    label: 'Активности'
  },
  {
    id: 'profile',
    icon: User,
    label: 'Профиль'
  }];

  return (
    <div className="absolute bottom-0 left-0 right-0 h-[84px] bg-app-bg/90 backdrop-blur-md border-t border-app-border px-6 pb-6 pt-3 flex justify-between items-center z-40">
      {tabs.map((tab) => {
        const Icon = tab.icon;
        const isActive = activeTab === tab.id;
        return (
          <button
            key={tab.id}
            onClick={() => onTabChange?.(tab.id)}
            className={`flex flex-col items-center gap-1 w-16 ${isActive ? 'text-app-accent' : 'text-app-muted hover:text-white transition-colors'}`}>
            
            <Icon
              className={`w-6 h-6 ${isActive ? 'fill-app-accent/20' : ''}`}
              strokeWidth={isActive ? 2.5 : 2} />
            
            <span className="text-[10px] font-medium">{tab.label}</span>
          </button>);

      })}
    </div>);

}