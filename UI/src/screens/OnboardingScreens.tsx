import React, { useState } from 'react';
import {
  Heart,
  BookHeart,
  CheckSquare,
  Dices,
  HelpCircle,
  AlertTriangle } from
'lucide-react';
import { Button, Card } from '../components/UI';
export function OnboardingSlide1Screen({
  onNavigate


}: {onNavigate: (screen: string) => void;}) {
  return (
    <div className="min-h-full flex flex-col bg-app-bg px-6 py-12">
      <div className="flex-1 flex flex-col items-center justify-center text-center">
        <div className="relative w-32 h-32 mb-12 flex items-center justify-center">
          <div className="absolute inset-0 bg-app-accent/20 rounded-full blur-2xl animate-pulse"></div>
          <Heart className="w-20 h-20 text-app-accent fill-app-accent/20 drop-shadow-[0_0_20px_rgba(155,126,240,0.5)]" />
        </div>

        <h1 className="text-3xl font-bold text-white mb-4">PairApp</h1>
        <h2 className="text-xl font-semibold text-white mb-4 leading-tight">
          Спокойные отношения начинаются с честного разговора
        </h2>
        <p className="text-sm text-app-muted leading-relaxed">
          Создайте безопасное пространство для вас двоих, где можно делиться
          чувствами, решать проблемы и планировать совместное время.
        </p>
      </div>

      <div className="flex flex-col items-center gap-8 mt-auto">
        <div className="flex gap-2">
          <div className="w-6 h-1.5 rounded-full bg-app-accent"></div>
          <div className="w-1.5 h-1.5 rounded-full bg-white/20"></div>
          <div className="w-1.5 h-1.5 rounded-full bg-white/20"></div>
        </div>
        <Button fullWidth onClick={() => onNavigate('onboarding-2')}>
          Далее
        </Button>
      </div>
    </div>);

}
export function OnboardingSlide2Screen({
  onNavigate


}: {onNavigate: (screen: string) => void;}) {
  const features = [
  {
    icon: BookHeart,
    text: 'Дневник отношений и эмоций'
  },
  {
    icon: CheckSquare,
    text: 'Трекер общих договорённостей'
  },
  {
    icon: Dices,
    text: 'Рандомайзеры для свиданий'
  },
  {
    icon: HelpCircle,
    text: 'Квизы для лучшего понимания'
  }];

  return (
    <div className="min-h-full flex flex-col bg-app-bg px-6 py-12">
      <div className="flex-1 flex flex-col justify-center">
        <div className="flex justify-center mb-10">
          <div className="relative flex items-center justify-center w-full max-w-[200px] aspect-square">
            <div className="absolute inset-0 bg-accent-gradient opacity-10 rounded-full blur-3xl"></div>
            <div className="flex -space-x-4 relative z-10">
              <div className="w-20 h-20 rounded-full bg-app-card border-4 border-app-bg flex items-center justify-center shadow-xl">
                <Heart className="w-8 h-8 text-app-accent" />
              </div>
              <div className="w-20 h-20 rounded-full bg-app-card border-4 border-app-bg flex items-center justify-center shadow-xl">
                <Heart className="w-8 h-8 text-app-accentDark" />
              </div>
            </div>
          </div>
        </div>

        <h2 className="text-2xl font-bold text-white mb-8 text-center leading-tight">
          Фиксируйте проблемы, договорённости и идеи — без ссор
        </h2>

        <div className="space-y-4">
          {features.map((f, i) =>
          <div key={i} className="flex items-center gap-4">
              <div className="w-10 h-10 rounded-full bg-app-accent/10 flex items-center justify-center text-app-accent shrink-0">
                <f.icon className="w-5 h-5" />
              </div>
              <span className="text-sm font-medium text-white">{f.text}</span>
            </div>
          )}
        </div>
      </div>

      <div className="flex flex-col items-center gap-8 mt-12">
        <div className="flex gap-2">
          <div className="w-1.5 h-1.5 rounded-full bg-white/20"></div>
          <div className="w-6 h-1.5 rounded-full bg-app-accent"></div>
          <div className="w-1.5 h-1.5 rounded-full bg-white/20"></div>
        </div>
        <Button fullWidth onClick={() => onNavigate('onboarding-3')}>
          Далее
        </Button>
      </div>
    </div>);

}
export function OnboardingSlide3Screen({
  onNavigate


}: {onNavigate: (screen: string) => void;}) {
  const [agreed, setAgreed] = useState(false);
  return (
    <div className="min-h-full flex flex-col bg-app-bg px-6 py-12">
      <div className="flex-1 flex flex-col justify-center">
        <Card className="border-amber-500/20 bg-amber-500/5 relative overflow-hidden">
          <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-amber-500/50 to-app-accent/50"></div>
          <div className="flex items-center gap-3 mb-4">
            <div className="w-10 h-10 rounded-full bg-amber-500/20 flex items-center justify-center text-amber-500">
              <AlertTriangle className="w-5 h-5" />
            </div>
            <h2 className="text-xl font-bold text-white">Важно</h2>
          </div>
          <p className="text-sm text-app-text leading-relaxed mb-6">
            Приложение не является заменой психолога, психотерапевта, врача или
            кризисной помощи. Если в отношениях есть насилие, угрозы или
            опасность — обратитесь за профессиональной помощью или в экстренные
            службы.
          </p>

          <label className="flex items-start gap-3 cursor-pointer group">
            <div
              className={`mt-0.5 w-5 h-5 rounded border flex items-center justify-center transition-colors shrink-0 ${agreed ? 'bg-app-accent border-app-accent' : 'border-app-muted group-hover:border-white/50'}`}>
              
              {agreed && <CheckSquare className="w-3.5 h-3.5 text-white" />}
            </div>
            <span className="text-sm text-app-muted group-hover:text-white transition-colors">
              Я понимаю и согласен
            </span>
          </label>
        </Card>
      </div>

      <div className="flex flex-col items-center gap-8 mt-12">
        <div className="flex gap-2">
          <div className="w-1.5 h-1.5 rounded-full bg-white/20"></div>
          <div className="w-1.5 h-1.5 rounded-full bg-white/20"></div>
          <div className="w-6 h-1.5 rounded-full bg-app-accent"></div>
        </div>
        <Button
          fullWidth
          disabled={!agreed}
          className={!agreed ? 'opacity-50' : ''}
          onClick={() => onNavigate('login')}>
          
          Начать
        </Button>
      </div>
    </div>);

}