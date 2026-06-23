import React from 'react';
import {
  HeartHandshake,
  KeyRound,
  Copy,
  Share2,
  RefreshCw,
  ArrowLeft } from
'lucide-react';
import { Avatar, Button, Card } from '../components/UI';
export function CreateOrJoinCoupleScreen({
  onNavigate


}: {onNavigate: (screen: string) => void;}) {
  return (
    <div className="min-h-full flex flex-col bg-app-bg px-6 py-12">
      <div className="flex-1 flex flex-col justify-center">
        <h1 className="text-2xl font-bold text-white mb-8 text-center leading-tight">
          Создайте пару или присоединитесь
        </h1>

        <div className="space-y-4">
          <button
            onClick={() => onNavigate('invite-code')}
            className="w-full bg-app-card rounded-[24px] p-6 flex flex-col items-center text-center border border-white/5 hover:border-app-accent/50 transition-colors group relative overflow-hidden">
            
            <div className="absolute top-0 right-0 w-32 h-32 bg-app-accent opacity-5 rounded-full blur-2xl -mr-10 -mt-10 group-hover:opacity-10 transition-opacity"></div>
            <div className="w-16 h-16 rounded-2xl bg-app-accent/10 flex items-center justify-center text-app-accent mb-4 group-hover:scale-110 transition-transform">
              <HeartHandshake className="w-8 h-8" />
            </div>
            <h2 className="text-lg font-bold text-white mb-2">Создать пару</h2>
            <p className="text-sm text-app-muted">
              Сгенерировать код приглашения для вашего партнёра
            </p>
          </button>

          <button
            onClick={() => onNavigate('enter-code')}
            className="w-full bg-app-card rounded-[24px] p-6 flex flex-col items-center text-center border border-white/5 hover:border-blue-500/50 transition-colors group relative overflow-hidden">
            
            <div className="absolute top-0 left-0 w-32 h-32 bg-blue-500 opacity-5 rounded-full blur-2xl -ml-10 -mt-10 group-hover:opacity-10 transition-opacity"></div>
            <div className="w-16 h-16 rounded-2xl bg-blue-500/10 flex items-center justify-center text-blue-400 mb-4 group-hover:scale-110 transition-transform">
              <KeyRound className="w-8 h-8" />
            </div>
            <h2 className="text-lg font-bold text-white mb-2">
              У меня есть код
            </h2>
            <p className="text-sm text-app-muted">
              Ввести код, который вам отправил партнёр
            </p>
          </button>
        </div>
      </div>
    </div>);

}
export function InviteCodeScreen({
  onNavigate


}: {onNavigate: (screen: string) => void;}) {
  return (
    <div className="min-h-full flex flex-col bg-app-bg">
      <div className="flex items-center justify-between px-4 pt-2 pb-4">
        <button
          onClick={() => onNavigate('create-join-couple')}
          className="w-10 h-10 flex items-center justify-center text-app-text">
          
          <ArrowLeft className="w-6 h-6" />
        </button>
        <div className="w-10 h-10"></div>
      </div>

      <div className="flex-1 flex flex-col items-center px-6 pb-12">
        <div className="relative w-32 h-32 mb-8 flex items-center justify-center">
          <div className="absolute inset-0 bg-app-accent/20 rounded-full blur-2xl"></div>
          <HeartHandshake className="w-16 h-16 text-app-accent relative z-10" />
        </div>

        <h1 className="text-2xl font-bold text-white mb-2 text-center">
          Поделитесь кодом с партнёром
        </h1>
        <p className="text-sm text-app-muted text-center mb-8">
          Отправьте этот код вашему партнёру, чтобы он мог присоединиться к
          вашей паре.
        </p>

        <Card className="w-full mb-8 flex flex-col items-center py-8 border-app-accent/30 bg-app-accent/5">
          <span className="text-3xl font-mono font-bold text-white tracking-widest mb-2">
            PAIR-7F3K2
          </span>
          <span className="text-xs text-app-muted">
            Код бессрочный, действует один раз
          </span>
        </Card>

        <div className="w-full space-y-3 mb-8">
          <Button fullWidth className="gap-2">
            <Copy className="w-5 h-5" />
            Скопировать код
          </Button>
          <Button fullWidth variant="secondary" className="gap-2">
            <Share2 className="w-5 h-5" />
            Поделиться ссылкой
          </Button>
        </div>

        <button className="flex items-center gap-2 text-sm font-medium text-app-muted hover:text-white transition-colors mt-auto">
          <RefreshCw className="w-4 h-4" />
          Обновить код
        </button>
      </div>
    </div>);

}
export function EnterCodeScreen({
  onNavigate


}: {onNavigate: (screen: string) => void;}) {
  return (
    <div className="min-h-full flex flex-col bg-app-bg">
      <div className="flex items-center justify-between px-4 pt-2 pb-4">
        <button
          onClick={() => onNavigate('create-join-couple')}
          className="w-10 h-10 flex items-center justify-center text-app-text">
          
          <ArrowLeft className="w-6 h-6" />
        </button>
        <div className="w-10 h-10"></div>
      </div>

      <div className="flex-1 flex flex-col px-6 pb-12">
        <div className="flex justify-center mb-8">
          <div className="w-20 h-20 rounded-full bg-blue-500/10 flex items-center justify-center text-blue-400">
            <KeyRound className="w-10 h-10" />
          </div>
        </div>

        <h1 className="text-2xl font-bold text-white mb-2 text-center">
          Введите код партнёра
        </h1>
        <p className="text-sm text-app-muted text-center mb-10">
          Вставьте код, который вам отправил партнёр, чтобы создать пару.
        </p>

        <div className="flex justify-center gap-2 mb-4">
          {['P', 'A', 'I', 'R', '-', '7', 'F', '3', 'K', '2'].map((char, i) =>
          <div
            key={i}
            className={`w-8 h-12 rounded-lg flex items-center justify-center text-lg font-mono font-bold ${char === '-' ? 'bg-transparent text-app-muted' : 'bg-app-card border border-app-accent/50 text-white'}`}>
            
              {char}
            </div>
          )}
        </div>

        {/* Example error state */}
        <p className="text-xs text-rose-400 text-center mb-10">
          Этот код уже использован
        </p>

        <div className="mt-auto">
          <Button fullWidth onClick={() => onNavigate('couple-success')}>
            Подключиться
          </Button>
        </div>
      </div>
    </div>);

}
export function CoupleConnectedSuccessScreen({
  onNavigate


}: {onNavigate: (screen: string) => void;}) {
  return (
    <div className="min-h-full flex flex-col bg-app-bg px-6 py-12">
      <div className="flex-1 flex flex-col items-center justify-center text-center">
        <div className="relative w-full max-w-[280px] h-40 mb-10 flex items-center justify-center">
          <div className="absolute inset-0 bg-accent-gradient opacity-10 rounded-full blur-3xl"></div>

          <div className="absolute left-4 top-1/2 -translate-y-1/2 z-10">
            <Avatar
              src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&h=150&fit=crop"
              size="xl"
              className="border-4 border-app-bg shadow-2xl" />
            
          </div>

          <div className="absolute right-4 top-1/2 -translate-y-1/2 z-10">
            <Avatar
              src="https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=150&h=150&fit=crop"
              size="xl"
              className="border-4 border-app-bg shadow-2xl" />
            
          </div>

          <div className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 z-0 w-full flex justify-center">
            <div className="h-1 w-32 bg-gradient-to-r from-transparent via-app-accent to-transparent relative">
              <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-12 h-12 bg-app-bg rounded-full flex items-center justify-center border-2 border-app-accent">
                <HeartHandshake className="w-6 h-6 text-app-accent" />
              </div>
            </div>
          </div>
        </div>

        <h1 className="text-3xl font-bold text-white mb-4">
          Вы теперь пара! 🎉
        </h1>
        <p className="text-lg text-app-muted">
          Маша <span className="text-app-accent mx-2">♡</span> Илья
        </p>
      </div>

      <div className="mt-auto">
        <Button fullWidth onClick={() => onNavigate('home')}>
          Перейти в приложение
        </Button>
      </div>
    </div>);

}