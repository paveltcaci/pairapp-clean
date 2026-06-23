import React, { useState } from 'react';
import { Dices, Home, HelpCircle, Heart } from 'lucide-react';
import { Avatar, Card } from '../components/UI';
import { TabBar } from '../components/TabBar';
export function ActivitiesScreen({
  onNavigate


}: {onNavigate: (screen: string) => void;}) {
  const [activeTab, setActiveTab] = useState('Идеи');
  const tiles = [
  {
    id: 'random',
    title: 'Рандом занятие',
    icon: Dices,
    color: 'from-purple-500 to-indigo-500',
    shadow: 'shadow-purple-500/20'
  },
  {
    id: 'house',
    title: 'Бытовой рандомайзер',
    icon: Home,
    color: 'from-blue-500 to-cyan-500',
    shadow: 'shadow-blue-500/20'
  },
  {
    id: 'quiz',
    title: 'Квизы для пары',
    icon: HelpCircle,
    color: 'from-emerald-500 to-teal-500',
    shadow: 'shadow-emerald-500/20'
  },
  {
    id: 'wishlist',
    title: 'Список желаний',
    icon: Heart,
    color: 'from-rose-500 to-pink-500',
    shadow: 'shadow-rose-500/20'
  }];

  const recentIdeas = [
  {
    id: 1,
    title: 'Пикник в парке',
    avatar:
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&h=150&fit=crop'
  },
  {
    id: 2,
    title: 'Вечер настолок',
    avatar:
    'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=150&h=150&fit=crop'
  }];

  return (
    <div className="min-h-full pb-24 flex flex-col">
      {/* Header */}
      <div className="px-6 pt-2 pb-6">
        <h1 className="text-2xl font-bold text-white leading-tight pr-8">
          Что бы вы хотели сделать вместе?
        </h1>
      </div>

      {/* Sub-tabs */}
      <div className="flex px-6 mb-6 gap-4 border-b border-app-border/50">
        <button
          onClick={() => setActiveTab('Идеи')}
          className={`pb-2 text-sm font-medium border-b-2 transition-colors ${activeTab === 'Идеи' ? 'border-app-accent text-white' : 'border-transparent text-app-muted'}`}>
          
          Идеи
        </button>
        <button
          onClick={() => setActiveTab('История')}
          className={`pb-2 text-sm font-medium border-b-2 transition-colors ${activeTab === 'История' ? 'border-app-accent text-white' : 'border-transparent text-app-muted'}`}>
          
          История
        </button>
      </div>

      <div className="flex-1 overflow-y-auto hide-scrollbar px-6 space-y-8">
        {/* Grid */}
        <div className="grid grid-cols-2 gap-4">
          {tiles.map((tile) => {
            const Icon = tile.icon;
            return (
              <button
                key={tile.id}
                onClick={() => {
                  if (tile.id === 'random') onNavigate('random-activity');
                  if (tile.id === 'quiz') onNavigate('quiz');
                }}
                className={`bg-app-card rounded-[24px] p-5 flex flex-col items-start gap-4 border border-white/5 relative overflow-hidden group`}>
                
                <div
                  className={`absolute top-0 right-0 w-24 h-24 bg-gradient-to-br ${tile.color} opacity-10 rounded-full blur-xl -mr-8 -mt-8 group-hover:opacity-20 transition-opacity`}>
                </div>
                <div
                  className={`w-12 h-12 rounded-2xl bg-gradient-to-br ${tile.color} flex items-center justify-center shadow-lg ${tile.shadow}`}>
                  
                  <Icon className="w-6 h-6 text-white" />
                </div>
                <span className="text-sm font-semibold text-white text-left leading-tight">
                  {tile.title}
                </span>
              </button>);

          })}
        </div>

        {/* Recent Ideas */}
        <div>
          <h2 className="text-sm font-bold text-app-muted uppercase tracking-wider mb-4">
            Недавние идеи
          </h2>
          <div className="space-y-3">
            {recentIdeas.map((idea) =>
            <Card
              key={idea.id}
              className="py-3.5 px-4 flex items-center justify-between">
              
                <span className="text-sm font-medium text-white">
                  {idea.title}
                </span>
                <Avatar src={idea.avatar} size="sm" />
              </Card>
            )}
          </div>
        </div>
      </div>

      <TabBar activeTab="activities" onTabChange={onNavigate} />
    </div>);

}