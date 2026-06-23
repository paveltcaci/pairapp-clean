import React from 'react';
import {
  Settings,
  Bell,
  Globe,
  HelpCircle,
  Info,
  ChevronRight,
  LogOut,
  ShieldCheck } from
'lucide-react';
import { Avatar, Button, Card } from '../components/UI';
import { TabBar } from '../components/TabBar';
export function ProfileScreen({
  onNavigate


}: {onNavigate: (screen: string) => void;}) {
  return (
    <div className="min-h-full pb-24 flex flex-col bg-app-bg">
      <div className="flex-1 overflow-y-auto hide-scrollbar">
        {/* Header Profile Info */}
        <div className="flex flex-col items-center pt-12 pb-8 px-6 relative">
          <div className="absolute top-0 left-0 w-full h-48 bg-accent-gradient opacity-5 blur-3xl pointer-events-none"></div>

          <div className="relative mb-4">
            <div className="absolute inset-0 bg-app-accent/20 rounded-full blur-xl"></div>
            <Avatar
              src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&h=150&fit=crop"
              size="xl"
              className="relative z-10 !p-1" />
            
          </div>

          <h1 className="text-2xl font-bold text-white mb-1">Маша</h1>
          <button className="text-sm font-medium text-app-accent hover:text-white transition-colors">
            Редактировать
          </button>
        </div>

        {/* Menu List */}
        <div className="px-6 space-y-6">
          <div className="space-y-2">
            <MenuRow icon={Settings} label="Настройки пары" />
            <MenuRow
              icon={Bell}
              label="Уведомления"
              onClick={() => onNavigate('notifications-settings')} />
            
            <MenuRow icon={Globe} label="Язык" value="Русский" />
            <MenuRow
              icon={ShieldCheck}
              label="Безопасность"
              onClick={() => onNavigate('security-safety')} />
            
          </div>

          <div className="space-y-2">
            <MenuRow icon={HelpCircle} label="Поддержка" />
            <MenuRow icon={Info} label="О приложении" />
          </div>

          <div className="pt-4 pb-8 space-y-3">
            <Button
              variant="danger"
              fullWidth
              className="gap-3"
              onClick={() => onNavigate('delete-account')}>
              
              <LogOut className="w-5 h-5" />
              Выйти из пары
            </Button>
          </div>
        </div>
      </div>

      <TabBar activeTab="profile" onTabChange={onNavigate} />
    </div>);

}
function MenuRow({
  icon: Icon,
  label,
  value,
  onClick





}: {icon: any;label: string;value?: string;onClick?: () => void;}) {
  return (
    <button
      onClick={onClick}
      className="w-full bg-app-card rounded-[20px] p-4 flex items-center justify-between border border-transparent hover:border-white/5 transition-colors">
      
      <div className="flex items-center gap-4">
        <div className="w-10 h-10 rounded-full bg-app-bg flex items-center justify-center text-app-muted">
          <Icon className="w-5 h-5" />
        </div>
        <span className="text-app-text font-medium text-sm">{label}</span>
      </div>
      <div className="flex items-center gap-3">
        {value && <span className="text-sm text-app-muted">{value}</span>}
        <ChevronRight className="w-5 h-5 text-app-muted/50" />
      </div>
    </button>);

}