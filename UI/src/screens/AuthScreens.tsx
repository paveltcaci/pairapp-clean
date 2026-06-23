import React, { useState } from 'react';
import { Heart, Eye, EyeOff, ArrowLeft, ShieldAlert } from 'lucide-react';
import { Button, Card } from '../components/UI';
export function LoginScreen({
  onNavigate


}: {onNavigate: (screen: string) => void;}) {
  const [showPassword, setShowPassword] = useState(false);
  return (
    <div className="min-h-full flex flex-col bg-app-bg px-6 py-12">
      <div className="flex justify-center mb-8">
        <div className="w-12 h-12 rounded-xl bg-accent-gradient flex items-center justify-center shadow-[0_0_20px_rgba(155,126,240,0.3)]">
          <Heart className="w-6 h-6 text-white" />
        </div>
      </div>

      <h1 className="text-2xl font-bold text-white mb-8 text-center">Вход</h1>

      <div className="space-y-4 mb-6">
        <div className="space-y-1.5">
          <label className="text-xs font-medium text-app-muted ml-1">
            Email
          </label>
          <input
            type="email"
            placeholder="name@example.com"
            className="w-full bg-app-card border border-white/5 rounded-2xl px-4 py-3.5 text-sm text-white placeholder:text-app-muted/50 focus:outline-none focus:border-app-accent/50 transition-colors" />
          
        </div>

        <div className="space-y-1.5 relative">
          <label className="text-xs font-medium text-app-muted ml-1">
            Пароль
          </label>
          <div className="relative">
            <input
              type={showPassword ? 'text' : 'password'}
              placeholder="••••••••"
              className="w-full bg-app-card border border-white/5 rounded-2xl px-4 py-3.5 text-sm text-white placeholder:text-app-muted/50 focus:outline-none focus:border-app-accent/50 transition-colors pr-12" />
            
            <button
              onClick={() => setShowPassword(!showPassword)}
              className="absolute right-4 top-1/2 -translate-y-1/2 text-app-muted hover:text-white transition-colors">
              
              {showPassword ?
              <EyeOff className="w-5 h-5" /> :

              <Eye className="w-5 h-5" />
              }
            </button>
          </div>
        </div>

        <div className="flex justify-end">
          <button
            onClick={() => onNavigate('forgot-password')}
            className="text-xs font-medium text-app-accent hover:text-white transition-colors">
            
            Забыли пароль?
          </button>
        </div>
      </div>

      <Button
        fullWidth
        onClick={() => onNavigate('create-join-couple')}
        className="mb-8">
        
        Войти
      </Button>

      <div className="relative flex items-center justify-center mb-8">
        <div className="absolute inset-x-0 h-px bg-white/5"></div>
        <span className="relative bg-app-bg px-4 text-xs font-medium text-app-muted uppercase tracking-wider">
          или
        </span>
      </div>

      <div className="space-y-3 mb-auto">
        <Button
          fullWidth
          variant="secondary"
          className="!bg-app-card !border-white/5 !text-white hover:!border-white/20">
          
          Войти через Apple
        </Button>
        <Button
          fullWidth
          variant="secondary"
          className="!bg-app-card !border-white/5 !text-white hover:!border-white/20">
          
          Войти через Google
        </Button>
      </div>

      <div className="mt-8 text-center">
        <span className="text-sm text-app-muted">Нет аккаунта? </span>
        <button
          onClick={() => onNavigate('register')}
          className="text-sm font-medium text-app-accent hover:text-white transition-colors">
          
          Зарегистрироваться
        </button>
      </div>
    </div>);

}
export function RegisterScreen({
  onNavigate


}: {onNavigate: (screen: string) => void;}) {
  const [gender, setGender] = useState('Мужской');
  return (
    <div className="min-h-full flex flex-col bg-app-bg">
      <div className="flex items-center justify-between px-4 pt-2 pb-4 sticky top-0 bg-app-bg/90 backdrop-blur-md z-10">
        <button
          onClick={() => onNavigate('login')}
          className="w-10 h-10 flex items-center justify-center text-app-text">
          
          <ArrowLeft className="w-6 h-6" />
        </button>
        <div className="flex-1 px-2 text-center">
          <h1 className="text-[15px] font-bold text-white">Регистрация</h1>
        </div>
        <div className="w-10 h-10"></div>
      </div>

      <div className="flex-1 overflow-y-auto hide-scrollbar px-6 pb-8 space-y-5">
        <div className="space-y-1.5">
          <label className="text-xs font-medium text-app-muted ml-1">
            Имя / ник
          </label>
          <input
            type="text"
            className="w-full bg-app-card border border-white/5 rounded-2xl px-4 py-3.5 text-sm text-white focus:outline-none focus:border-app-accent/50 transition-colors" />
          
        </div>

        <div className="space-y-1.5">
          <label className="text-xs font-medium text-app-muted ml-1">
            Email
          </label>
          <input
            type="email"
            className="w-full bg-app-card border border-white/5 rounded-2xl px-4 py-3.5 text-sm text-white focus:outline-none focus:border-app-accent/50 transition-colors" />
          
        </div>

        <div className="space-y-1.5">
          <label className="text-xs font-medium text-app-muted ml-1">
            Пароль (мин. 8 символов)
          </label>
          <input
            type="password"
            className="w-full bg-app-card border border-white/5 rounded-2xl px-4 py-3.5 text-sm text-white focus:outline-none focus:border-app-accent/50 transition-colors" />
          
        </div>

        <div className="space-y-1.5">
          <div className="flex justify-between items-end ml-1 mb-1">
            <label className="text-xs font-medium text-app-muted">
              Дата рождения
            </label>
            <span className="text-[10px] text-app-accent">
              Доступно с 16 лет
            </span>
          </div>
          <input
            type="date"
            className="w-full bg-app-card border border-white/5 rounded-2xl px-4 py-3.5 text-sm text-white focus:outline-none focus:border-app-accent/50 transition-colors [color-scheme:dark]" />
          
        </div>

        <div className="space-y-2">
          <label className="text-xs font-medium text-app-muted ml-1">Пол</label>
          <div className="flex flex-col gap-2">
            {['Мужской', 'Женский', 'Другой', 'Не указывать'].map((g) =>
            <button
              key={g}
              onClick={() => setGender(g)}
              className={`px-4 py-3 rounded-xl text-sm font-medium text-left transition-colors border ${gender === g ? 'bg-app-accent/20 border-app-accent text-white' : 'bg-app-card border-white/5 text-app-muted hover:border-white/20'}`}>
              
                {g}
              </button>
            )}
          </div>
        </div>

        <div className="pt-4 space-y-3">
          <label className="flex items-start gap-3 cursor-pointer group">
            <div className="mt-0.5 w-5 h-5 rounded border border-app-accent bg-app-accent flex items-center justify-center shrink-0">
              <svg
                className="w-3.5 h-3.5 text-white"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor">
                
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M5 13l4 4L19 7" />
                
              </svg>
            </div>
            <span className="text-xs text-app-muted leading-tight">
              Я согласен с <span className="text-app-accent">Terms of Use</span>
            </span>
          </label>
          <label className="flex items-start gap-3 cursor-pointer group">
            <div className="mt-0.5 w-5 h-5 rounded border border-app-accent bg-app-accent flex items-center justify-center shrink-0">
              <svg
                className="w-3.5 h-3.5 text-white"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor">
                
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M5 13l4 4L19 7" />
                
              </svg>
            </div>
            <span className="text-xs text-app-muted leading-tight">
              Я согласен с{' '}
              <span className="text-app-accent">Privacy Policy</span>
            </span>
          </label>
        </div>

        <div className="pt-6">
          <Button fullWidth onClick={() => onNavigate('age-gate')}>
            Создать аккаунт
          </Button>
        </div>
      </div>
    </div>);

}
export function ForgotPasswordScreen({
  onNavigate


}: {onNavigate: (screen: string) => void;}) {
  return (
    <div className="min-h-full flex flex-col bg-app-bg">
      <div className="flex items-center justify-between px-4 pt-2 pb-4">
        <button
          onClick={() => onNavigate('login')}
          className="w-10 h-10 flex items-center justify-center text-app-text">
          
          <ArrowLeft className="w-6 h-6" />
        </button>
        <div className="flex-1 px-2 text-center">
          <h1 className="text-[15px] font-bold text-white">
            Восстановление пароля
          </h1>
        </div>
        <div className="w-10 h-10"></div>
      </div>

      <div className="px-6 py-6 flex-1">
        <p className="text-sm text-app-muted mb-8 leading-relaxed">
          Введите email, указанный при регистрации. Мы отправим вам ссылку для
          создания нового пароля.
        </p>

        <div className="space-y-1.5 mb-8">
          <label className="text-xs font-medium text-app-muted ml-1">
            Email
          </label>
          <input
            type="email"
            placeholder="name@example.com"
            className="w-full bg-app-card border border-white/5 rounded-2xl px-4 py-3.5 text-sm text-white placeholder:text-app-muted/50 focus:outline-none focus:border-app-accent/50 transition-colors" />
          
        </div>

        <Button fullWidth onClick={() => onNavigate('login')}>
          Отправить ссылку
        </Button>
      </div>
    </div>);

}
export function AgeConfirmationScreen({
  onNavigate


}: {onNavigate: (screen: string) => void;}) {
  return (
    <div className="min-h-full flex flex-col bg-app-bg px-6 py-12">
      <div className="flex-1 flex flex-col items-center justify-center">
        <Card className="w-full p-8 flex flex-col items-center text-center">
          <div className="w-16 h-16 rounded-full bg-app-accent/20 flex items-center justify-center text-app-accent mb-6">
            <ShieldAlert className="w-8 h-8" />
          </div>

          <h2 className="text-xl font-bold text-white mb-3">
            Подтверждение возраста
          </h2>
          <p className="text-sm text-app-muted mb-8 leading-relaxed">
            По правилам платформы, использование приложения доступно только
            лицам старше 16 лет. Пожалуйста, подтвердите вашу дату рождения.
          </p>

          <div className="w-full space-y-1.5 mb-8 text-left">
            <label className="text-xs font-medium text-app-muted ml-1">
              Дата рождения
            </label>
            <input
              type="date"
              className="w-full bg-app-bg border border-white/5 rounded-2xl px-4 py-3.5 text-sm text-white focus:outline-none focus:border-app-accent/50 transition-colors [color-scheme:dark]" />
            
          </div>

          <div className="w-full space-y-3">
            <Button fullWidth onClick={() => onNavigate('create-join-couple')}>
              Продолжить
            </Button>
            <Button
              fullWidth
              variant="ghost"
              className="text-app-muted hover:text-rose-400">
              
              Мне нет 16
            </Button>
          </div>
        </Card>
      </div>
    </div>);

}