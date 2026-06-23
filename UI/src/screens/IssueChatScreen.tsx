import React, { useState } from 'react';
import { ArrowLeft, MoreVertical, Paperclip, Send } from 'lucide-react';
import { Avatar, Badge } from '../components/UI';
export function IssueChatScreen({
  onNavigate


}: {onNavigate: (screen: string) => void;}) {
  const [activeTab, setActiveTab] = useState('Чат');
  return (
    <div className="min-h-full flex flex-col bg-app-bg">
      {/* Header */}
      <div className="flex items-center justify-between px-4 pt-2 pb-4 border-b border-app-border bg-app-bg/90 backdrop-blur-md z-10 sticky top-0">
        <button
          onClick={() => onNavigate('issues')}
          className="w-10 h-10 flex items-center justify-center text-app-text">
          
          <ArrowLeft className="w-6 h-6" />
        </button>
        <div className="flex-1 px-2 text-center">
          <h1 className="text-[15px] font-bold text-white truncate">
            Не хватает времени на нас
          </h1>
          <span className="text-xs text-app-accent">Открыта</span>
        </div>
        <button className="w-10 h-10 flex items-center justify-center text-app-text">
          <MoreVertical className="w-5 h-5" />
        </button>
      </div>

      {/* Sub-tabs */}
      <div className="flex px-6 py-3 gap-4 border-b border-app-border/50">
        <button
          onClick={() => setActiveTab('Чат')}
          className={`flex-1 pb-2 text-sm font-medium border-b-2 transition-colors ${activeTab === 'Чат' ? 'border-app-accent text-white' : 'border-transparent text-app-muted'}`}>
          
          Чат
        </button>
        <button
          onClick={() => {
            setActiveTab('Договорённости');
            onNavigate('agreements');
          }}
          className={`flex-1 pb-2 text-sm font-medium border-b-2 transition-colors ${activeTab === 'Договорённости' ? 'border-app-accent text-white' : 'border-transparent text-app-muted'}`}>
          
          Договорённости
        </button>
      </div>

      {/* Chat Area */}
      <div className="flex-1 overflow-y-auto hide-scrollbar p-6 space-y-6">
        {/* Message Left */}
        <div className="flex gap-3 max-w-[85%]">
          <Avatar
            src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&h=150&fit=crop"
            size="sm"
            className="mt-auto" />
          
          <div>
            <div className="bg-app-card rounded-2xl rounded-bl-sm p-3.5 border border-white/5">
              <Badge
                variant="outline"
                className="mb-2 inline-block !text-[8px] !py-0.5">
                
                Комментарий
              </Badge>
              <p className="text-sm text-app-text leading-relaxed">
                Мне кажется, мы стали меньше проводить времени вместе. Вечером
                каждый в своём телефоне.
              </p>
            </div>
            <span className="text-[10px] text-app-muted mt-1 ml-1 block">
              14:30
            </span>
          </div>
        </div>

        {/* Message Right */}
        <div className="flex gap-3 max-w-[85%] ml-auto flex-row-reverse">
          <Avatar
            src="https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=150&h=150&fit=crop"
            size="sm"
            className="mt-auto" />
          
          <div>
            <div className="bg-app-accent/20 rounded-2xl rounded-br-sm p-3.5 border border-app-accent/30">
              <Badge
                variant="blue"
                className="mb-2 inline-block !text-[8px] !py-0.5">
                
                Возражение
              </Badge>
              <p className="text-sm text-white leading-relaxed">
                Я просто очень устаю на работе в последнее время. Мне нужно
                немного времени, чтобы переключиться.
              </p>
            </div>
            <span className="text-[10px] text-app-muted mt-1 mr-1 block text-right">
              14:45
            </span>
          </div>
        </div>

        {/* Message Left */}
        <div className="flex gap-3 max-w-[85%]">
          <Avatar
            src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&h=150&fit=crop"
            size="sm"
            className="mt-auto" />
          
          <div>
            <div className="bg-app-card rounded-2xl rounded-bl-sm p-3.5 border border-white/5">
              <Badge
                variant="green"
                className="mb-2 inline-block !text-[8px] !py-0.5">
                
                Решение
              </Badge>
              <p className="text-sm text-app-text leading-relaxed">
                Давай попробуем выделить хотя бы один вечер в неделю без
                телефонов? Только мы.
              </p>
            </div>
            <span className="text-[10px] text-app-muted mt-1 ml-1 block">
              15:10
            </span>
          </div>
        </div>
      </div>

      {/* Input Bar */}
      <div className="p-4 bg-app-bg border-t border-app-border flex items-center gap-3">
        <button className="w-10 h-10 flex items-center justify-center text-app-muted hover:text-white transition-colors">
          <Paperclip className="w-5 h-5" />
        </button>
        <div className="flex-1 bg-app-card rounded-full border border-white/5 px-4 py-2.5 flex items-center">
          <input
            type="text"
            placeholder="Написать сообщение..."
            className="bg-transparent border-none outline-none text-sm text-white w-full placeholder:text-app-muted" />
          
        </div>
        <button className="w-10 h-10 rounded-full bg-accent-gradient flex items-center justify-center text-white shadow-[0_0_15px_rgba(155,126,240,0.3)]">
          <Send className="w-4 h-4 ml-0.5" />
        </button>
      </div>
    </div>);

}