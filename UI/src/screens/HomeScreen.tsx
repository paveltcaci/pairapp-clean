import React from 'react';
import {
  Bell,
  Heart,
  MessageSquareWarning,
  CheckSquare,
  Sparkles,
  MessageCircle,
  ChevronRight,
  Plus } from
'lucide-react';
import { Avatar, Card } from '../components/UI';
import { TabBar } from '../components/TabBar';
export function HomeScreen({
  onNavigate


}: {onNavigate: (screen: string) => void;}) {
  return (
    <div className="min-h-full pb-24">
      {/* Header */}
      <div className="flex justify-between items-center px-6 pt-2 pb-4">
        <div className="flex items-center gap-3">
          <div className="flex -space-x-3">
            <Avatar
              src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&h=150&fit=crop"
              size="md" />
            
            <Avatar
              src="https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=150&h=150&fit=crop"
              size="md" />
            
          </div>
          <h1 className="text-xl font-bold text-white">Маша ♡ Илья</h1>
        </div>
        <button className="w-10 h-10 rounded-full bg-app-card flex items-center justify-center text-app-text relative">
          <Bell className="w-5 h-5" />
          <span className="absolute top-2.5 right-2.5 w-2 h-2 bg-rose-500 rounded-full border-2 border-app-card"></span>
        </button>
      </div>

      <div className="px-6 space-y-6">
        {/* Heart Card */}
        <Card
          glow
          className="flex flex-col items-center py-8 relative overflow-hidden">
          
          <div className="absolute top-0 left-0 w-full h-full bg-accent-gradient opacity-5 blur-2xl"></div>
          <div className="relative w-24 h-24 mb-4 flex items-center justify-center">
            <div className="absolute inset-0 bg-app-accent/20 rounded-full blur-xl animate-pulse"></div>
            <Heart className="w-16 h-16 text-app-accent fill-app-accent/20 drop-shadow-[0_0_15px_rgba(155,126,240,0.5)]" />
          </div>
          <p className="text-app-muted text-sm mb-1">Мы вместе</p>
          <h2 className="text-2xl font-bold text-white">
            2 года 4 месяца 12 дней
          </h2>
        </Card>

        {/* Stats List */}
        <div className="space-y-3">
          <StatRow
            icon={MessageSquareWarning}
            label="Открытые проблемы"
            count={3}
            onClick={() => onNavigate('issues')} />
          
          <StatRow
            icon={CheckSquare}
            label="Договорённости"
            count={5}
            onClick={() => onNavigate('agreements')} />
          
          <StatRow
            icon={Sparkles}
            label="Активные активности"
            count={2}
            onClick={() => onNavigate('activities')} />
          
          <StatRow
            icon={MessageCircle}
            label="Непрочитанные сообщения"
            count={1}
            onClick={() => onNavigate('issue-chat')} />
          
        </div>
      </div>

      {/* Floating Action Button */}
      <div className="absolute bottom-[100px] left-0 right-0 flex justify-center z-50 pointer-events-none">
        <button
          onClick={() => onNavigate('create-issue')}
          className="pointer-events-auto w-14 h-14 rounded-full bg-accent-gradient shadow-[0_0_25px_rgba(155,126,240,0.5)] flex items-center justify-center text-white hover:scale-105 transition-transform">
          
          <Plus className="w-7 h-7" />
        </button>
      </div>

      <TabBar activeTab="home" onTabChange={onNavigate} />
    </div>);

}
function StatRow({
  icon: Icon,
  label,
  count,
  onClick





}: {icon: any;label: string;count: number;onClick: () => void;}) {
  return (
    <button
      onClick={onClick}
      className="w-full bg-app-card rounded-[20px] p-4 flex items-center justify-between border border-transparent hover:border-app-border transition-colors">
      
      <div className="flex items-center gap-4">
        <div className="w-10 h-10 rounded-full bg-app-bg flex items-center justify-center text-app-accent">
          <Icon className="w-5 h-5" />
        </div>
        <span className="text-app-text font-medium">{label}</span>
      </div>
      <div className="flex items-center gap-3">
        <span className="w-6 h-6 rounded-full bg-app-accent/20 text-app-accent text-xs font-bold flex items-center justify-center">
          {count}
        </span>
        <ChevronRight className="w-5 h-5 text-app-muted" />
      </div>
    </button>);

}