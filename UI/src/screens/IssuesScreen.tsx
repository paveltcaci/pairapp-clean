import React, { useState } from 'react';
import { Filter, Plus } from 'lucide-react';
import { Avatar, Badge, Button, Card } from '../components/UI';
import { TabBar } from '../components/TabBar';
export function IssuesScreen({
  onNavigate


}: {onNavigate: (screen: string) => void;}) {
  const [activeTab, setActiveTab] = useState('Все');
  const tabs = ['Все', 'Мои', 'Партнёра', 'Открытые'];
  const issues = [
  {
    id: 1,
    title: 'Не хватает времени на нас',
    status: 'Открыта',
    statusVariant: 'purple' as const,
    author: 'Маша',
    avatar:
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&h=150&fit=crop'
  },
  {
    id: 2,
    title: 'Бытовые дела',
    status: 'В обсуждении',
    statusVariant: 'blue' as const,
    author: 'Илья',
    avatar:
    'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=150&h=150&fit=crop'
  },
  {
    id: 3,
    title: 'Разные взгляды на отдых',
    status: 'Решена',
    statusVariant: 'green' as const,
    author: 'Маша',
    avatar:
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&h=150&fit=crop'
  },
  {
    id: 4,
    title: 'Финансы',
    status: 'В обсуждении',
    statusVariant: 'blue' as const,
    author: 'Илья',
    avatar:
    'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=150&h=150&fit=crop'
  }];

  return (
    <div className="min-h-full pb-24 flex flex-col">
      {/* Header */}
      <div className="flex justify-between items-center px-6 pt-2 pb-4">
        <h1 className="text-2xl font-bold text-white">Проблемы</h1>
        <button className="w-10 h-10 rounded-full bg-app-card flex items-center justify-center text-app-text">
          <Filter className="w-5 h-5" />
        </button>
      </div>

      {/* Sub-tabs */}
      <div className="px-6 pb-4 overflow-x-auto hide-scrollbar">
        <div className="flex gap-2 min-w-max">
          {tabs.map((tab) =>
          <button
            key={tab}
            onClick={() => setActiveTab(tab)}
            className={`px-4 py-2 rounded-full text-sm font-medium transition-colors ${activeTab === tab ? 'bg-app-accent text-white' : 'bg-app-card text-app-muted hover:text-white'}`}>
            
              {tab}
            </button>
          )}
        </div>
      </div>

      {/* List */}
      <div className="px-6 space-y-4 flex-1 overflow-y-auto hide-scrollbar pb-20">
        {issues.map((issue) =>
        <Card
          key={issue.id}
          className="cursor-pointer hover:border-app-border transition-colors"
          glow={issue.status === 'Открыта'}>
          
            <div onClick={() => onNavigate('issue-chat')}>
              <div className="flex justify-between items-start mb-3">
                <Badge variant={issue.statusVariant}>{issue.status}</Badge>
                <div className="flex items-center gap-2">
                  <span className="text-xs text-app-muted">{issue.author}</span>
                  <Avatar src={issue.avatar} size="sm" />
                </div>
              </div>
              <h3 className="text-lg font-semibold text-white leading-tight">
                {issue.title}
              </h3>
            </div>
          </Card>
        )}
      </div>

      {/* Bottom Button */}
      <div className="absolute bottom-[90px] left-0 right-0 px-6 z-30">
        <Button fullWidth onClick={() => onNavigate('create-issue')}>
          <Plus className="w-5 h-5" />
          Создать проблему
        </Button>
      </div>

      <TabBar activeTab="issues" onTabChange={onNavigate} />
    </div>);

}