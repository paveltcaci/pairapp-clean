import React, { useState } from 'react';
import {
  ArrowLeft,
  User,
  Baby,
  Utensils,
  Music,
  Sparkles,
  Heart } from
'lucide-react';
import { Button, Card } from '../components/UI';
export function QuizScreen({
  onNavigate


}: {onNavigate: (screen: string) => void;}) {
  const [step, setStep] = useState<'categories' | 'question'>('categories');
  const [selectedAnswer, setSelectedAnswer] = useState<number | null>(null);
  const categories = [
  {
    id: 1,
    title: 'Обо мне',
    icon: User,
    color: 'from-blue-500 to-cyan-500'
  },
  {
    id: 2,
    title: 'Детство',
    icon: Baby,
    color: 'from-yellow-400 to-orange-500'
  },
  {
    id: 3,
    title: 'Еда',
    icon: Utensils,
    color: 'from-emerald-500 to-teal-500'
  },
  {
    id: 4,
    title: 'Фильмы и музыка',
    icon: Music,
    color: 'from-purple-500 to-indigo-500'
  },
  {
    id: 5,
    title: 'Мечты',
    icon: Sparkles,
    color: 'from-pink-500 to-rose-500'
  },
  {
    id: 6,
    title: 'Отношения',
    icon: Heart,
    color: 'from-red-500 to-pink-600'
  }];

  const answers = [
  'В горах, подальше от людей',
  'На шумном курорте у моря',
  'В новом городе, изучая архитектуру',
  'Дома на диване с сериалами'];

  if (step === 'categories') {
    return (
      <div className="min-h-full flex flex-col bg-app-bg">
        <div className="flex items-center justify-between px-4 pt-2 pb-4">
          <button
            onClick={() => onNavigate('activities')}
            className="w-10 h-10 flex items-center justify-center text-app-text">
            
            <ArrowLeft className="w-6 h-6" />
          </button>
          <div className="flex-1 px-2 text-center">
            <h1 className="text-[15px] font-bold text-white">Квизы</h1>
          </div>
          <div className="w-10 h-10"></div>
        </div>

        <div className="px-6 py-4">
          <h2 className="text-xl font-bold text-white mb-6">
            Выберите категорию
          </h2>
          <div className="grid grid-cols-2 gap-4">
            {categories.map((cat) => {
              const Icon = cat.icon;
              return (
                <button
                  key={cat.id}
                  onClick={() => setStep('question')}
                  className="bg-app-card rounded-[24px] p-5 flex flex-col items-center gap-4 border border-white/5 hover:border-white/10 transition-colors text-center">
                  
                  <div
                    className={`w-14 h-14 rounded-full bg-gradient-to-br ${cat.color} flex items-center justify-center shadow-lg`}>
                    
                    <Icon className="w-7 h-7 text-white" />
                  </div>
                  <span className="text-sm font-semibold text-white">
                    {cat.title}
                  </span>
                </button>);

            })}
          </div>
        </div>
      </div>);

  }
  return (
    <div className="min-h-full flex flex-col bg-app-bg">
      <div className="flex items-center justify-between px-4 pt-2 pb-4">
        <button
          onClick={() => setStep('categories')}
          className="w-10 h-10 flex items-center justify-center text-app-text">
          
          <ArrowLeft className="w-6 h-6" />
        </button>
        <div className="flex-1 px-4">
          {/* Progress Bar */}
          <div className="h-1.5 w-full bg-app-card rounded-full overflow-hidden">
            <div className="h-full bg-app-accent w-1/3 rounded-full"></div>
          </div>
        </div>
        <div className="w-10 h-10 flex items-center justify-center text-xs font-bold text-app-muted">
          3/10
        </div>
      </div>

      <div className="flex-1 px-6 py-8 flex flex-col">
        <span className="text-app-accent text-sm font-bold uppercase tracking-wider mb-4">
          Мечты
        </span>
        <h2 className="text-2xl font-bold text-white mb-8 leading-tight">
          Где бы я предпочел провести идеальный отпуск?
        </h2>

        <div className="space-y-3 flex-1">
          {answers.map((answer, idx) =>
          <button
            key={idx}
            onClick={() => setSelectedAnswer(idx)}
            className={`w-full p-5 rounded-[20px] text-left transition-all border ${selectedAnswer === idx ? 'bg-app-accent/20 border-app-accent text-white' : 'bg-app-card border-white/5 text-app-text hover:border-white/20'}`}>
            
              <span className="text-sm font-medium">{answer}</span>
            </button>
          )}
        </div>

        <div className="pt-6">
          <Button
            fullWidth
            disabled={selectedAnswer === null}
            className={selectedAnswer === null ? 'opacity-50' : ''}
            onClick={() => onNavigate('quiz-result')}>
            
            Ответить
          </Button>
        </div>
      </div>
    </div>);

}