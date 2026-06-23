import React from 'react';
import { ArrowLeft, Check, X } from 'lucide-react';
import { Avatar, Button, Card } from '../components/UI';
export function QuizResultScreen({
  onNavigate


}: {onNavigate: (screen: string) => void;}) {
  const results = [
  {
    id: 1,
    question: 'Где бы я предпочел провести идеальный отпуск?',
    match: true,
    myAnswer: 'В горах, подальше от людей',
    partnerAnswer: 'В горах, подальше от людей'
  },
  {
    id: 2,
    question: 'Мой любимый способ расслабиться после работы?',
    match: false,
    myAnswer: 'Поиграть в видеоигры',
    partnerAnswer: 'Посмотреть сериал'
  }];

  return (
    <div className="min-h-full flex flex-col bg-app-bg">
      {/* Header */}
      <div className="flex items-center justify-between px-4 pt-2 pb-4 z-10 sticky top-0 bg-app-bg/90 backdrop-blur-md">
        <button
          onClick={() => onNavigate('activities')}
          className="w-10 h-10 flex items-center justify-center text-app-text">
          
          <ArrowLeft className="w-6 h-6" />
        </button>
        <div className="flex-1 px-2 text-center">
          <h1 className="text-[15px] font-bold text-white">Результаты</h1>
        </div>
        <div className="w-10 h-10"></div>
      </div>

      <div className="flex-1 overflow-y-auto hide-scrollbar px-6 pb-12">
        {/* Match Circle */}
        <div className="flex flex-col items-center py-8">
          <div className="relative w-40 h-40 flex items-center justify-center mb-6">
            <svg
              className="w-full h-full transform -rotate-90"
              viewBox="0 0 100 100">
              
              <circle
                cx="50"
                cy="50"
                r="45"
                fill="none"
                stroke="rgba(155, 126, 240, 0.1)"
                strokeWidth="8" />
              
              <circle
                cx="50"
                cy="50"
                r="45"
                fill="none"
                stroke="url(#gradient)"
                strokeWidth="8"
                strokeDasharray="283"
                strokeDashoffset="73.58"
                /* 283 * (1 - 0.74) */ strokeLinecap="round" />
              
              <defs>
                <linearGradient
                  id="gradient"
                  x1="0%"
                  y1="0%"
                  x2="100%"
                  y2="100%">
                  
                  <stop offset="0%" stopColor="#9B7EF0" />
                  <stop offset="100%" stopColor="#7C5CFA" />
                </linearGradient>
              </defs>
            </svg>
            <div className="absolute inset-0 flex flex-col items-center justify-center">
              <span className="text-4xl font-bold text-white">74%</span>
              <span className="text-[10px] text-app-muted uppercase tracking-wider font-bold mt-1">
                Совпадение
              </span>
            </div>
          </div>

          <h2 className="text-xl font-bold text-white mb-2 text-center">
            Вы отлично знаете друг друга!
          </h2>
          <p className="text-sm text-app-muted text-center px-4">
            Есть пара моментов, которые стоит обсудить, но в целом вы на одной
            волне.
          </p>
        </div>

        {/* Answers List */}
        <div className="space-y-4 mt-4">
          <h3 className="text-sm font-bold text-white mb-4">Ответы</h3>

          {results.map((res) =>
          <Card key={res.id} className="p-4">
              <p className="text-sm font-medium text-white mb-4 leading-snug">
                {res.question}
              </p>

              <div className="space-y-3">
                {/* My Answer */}
                <div className="flex items-start gap-3">
                  <Avatar
                  src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&h=150&fit=crop"
                  size="sm" />
                
                  <div
                  className={`flex-1 p-3 rounded-xl border ${res.match ? 'bg-emerald-500/10 border-emerald-500/20' : 'bg-app-card border-white/5'}`}>
                  
                    <span
                    className={`text-xs ${res.match ? 'text-emerald-400' : 'text-app-text'}`}>
                    
                      {res.myAnswer}
                    </span>
                  </div>
                </div>

                {/* Partner Answer */}
                <div className="flex items-start gap-3">
                  <Avatar
                  src="https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=150&h=150&fit=crop"
                  size="sm" />
                
                  <div
                  className={`flex-1 p-3 rounded-xl border ${res.match ? 'bg-emerald-500/10 border-emerald-500/20' : 'bg-rose-500/10 border-rose-500/20'}`}>
                  
                    <span
                    className={`text-xs ${res.match ? 'text-emerald-400' : 'text-rose-400'}`}>
                    
                      {res.partnerAnswer}
                    </span>
                  </div>
                  <div className="mt-2">
                    {res.match ?
                  <Check className="w-5 h-5 text-emerald-500" /> :

                  <X className="w-5 h-5 text-rose-500" />
                  }
                  </div>
                </div>
              </div>
            </Card>
          )}
        </div>

        <div className="mt-8">
          <Button fullWidth onClick={() => onNavigate('activities')}>
            Завершить
          </Button>
        </div>
      </div>
    </div>);

}