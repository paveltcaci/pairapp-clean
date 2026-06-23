import React from 'react';
import { ArrowLeft, CheckCircle2, Circle, Clock } from 'lucide-react';
import { Avatar, Badge, Card } from '../components/UI';
export function AgreementsScreen({
  onNavigate


}: {onNavigate: (screen: string) => void;}) {
  const agreements = [
  {
    id: 1,
    title: 'Один вечер в неделю без телефонов',
    status: 'Активна',
    statusVariant: 'purple' as const,
    proposedBy:
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&h=150&fit=crop',
    checkIn: 'Через 3 дня',
    checked: true
  },
  {
    id: 2,
    title: 'Разделение бытовых обязанностей по выходным',
    status: 'Предложена',
    statusVariant: 'blue' as const,
    proposedBy:
    'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=150&h=150&fit=crop',
    checkIn: 'Ожидает ответа',
    checked: false
  },
  {
    id: 3,
    title: 'Общий бюджет на развлечения',
    status: 'Выполнена',
    statusVariant: 'green' as const,
    proposedBy:
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&h=150&fit=crop',
    checkIn: 'Завершена',
    checked: true
  }];

  return (
    <div className="min-h-full flex flex-col bg-app-bg">
      {/* Header */}
      <div className="flex items-center justify-between px-4 pt-2 pb-4 border-b border-app-border bg-app-bg/90 backdrop-blur-md z-10 sticky top-0">
        <button
          onClick={() => onNavigate('issue-chat')}
          className="w-10 h-10 flex items-center justify-center text-app-text">
          
          <ArrowLeft className="w-6 h-6" />
        </button>
        <div className="flex-1 px-2 text-center">
          <h1 className="text-[15px] font-bold text-white truncate">
            Договорённости
          </h1>
        </div>
        <div className="w-10 h-10"></div>
      </div>

      <div className="flex-1 overflow-y-auto hide-scrollbar p-6 space-y-4">
        {agreements.map((agreement) =>
        <Card
          key={agreement.id}
          className={
          agreement.status === 'Активна' ? 'border-app-accent/30' : ''
          }>
          
            <div className="flex gap-4">
              <div className="mt-1">
                {agreement.checked ?
              <CheckCircle2 className="w-6 h-6 text-app-accent" /> :

              <Circle className="w-6 h-6 text-app-muted" />
              }
              </div>
              <div className="flex-1">
                <div className="flex justify-between items-start mb-2">
                  <Badge variant={agreement.statusVariant}>
                    {agreement.status}
                  </Badge>
                  <Avatar src={agreement.proposedBy} size="sm" />
                </div>
                <h3 className="text-sm font-semibold text-white mb-3 leading-snug">
                  {agreement.title}
                </h3>
                <div className="flex items-center gap-1.5 text-xs text-app-muted">
                  <Clock className="w-3.5 h-3.5" />
                  <span>{agreement.checkIn}</span>
                </div>
              </div>
            </div>
          </Card>
        )}
      </div>
    </div>);

}