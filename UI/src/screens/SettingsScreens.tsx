import React, { useState } from 'react';
import { ArrowLeft, ShieldAlert, AlertTriangle } from 'lucide-react';
import { Button, Card } from '../components/UI';
function Toggle({
  checked,
  onChange



}: {checked: boolean;onChange: () => void;}) {
  return (
    <button
      onClick={onChange}
      className={`w-12 h-6 rounded-full transition-colors relative ${checked ? 'bg-app-accent' : 'bg-white/10'}`}>
      
      <div
        className={`w-5 h-5 rounded-full bg-white absolute top-0.5 transition-transform ${checked ? 'translate-x-6' : 'translate-x-0.5'}`}>
      </div>
    </button>);

}
export function NotificationsSettingsScreen({
  onNavigate


}: {onNavigate: (screen: string) => void;}) {
  const [toggles, setToggles] = useState<Record<string, boolean>>({
    'new-issue': true,
    'partner-reply': true,
    'solution-proposed': true,
    'agreement-accepted': true,
    'agreement-check': true,
    anniversary: true,
    quiz: true,
    'new-idea': false,
    'partner-left': true
  });
  const toggle = (key: string) =>
  setToggles((prev) => ({
    ...prev,
    [key]: !prev[key]
  }));
  return (
    <div className="min-h-full flex flex-col bg-app-bg">
      <div className="flex items-center justify-between px-4 pt-2 pb-4 sticky top-0 bg-app-bg/90 backdrop-blur-md z-10">
        <button
          onClick={() => onNavigate('profile')}
          className="w-10 h-10 flex items-center justify-center text-app-text">
          
          <ArrowLeft className="w-6 h-6" />
        </button>
        <div className="flex-1 px-2 text-center">
          <h1 className="text-[15px] font-bold text-white">Уведомления</h1>
        </div>
        <div className="w-10 h-10"></div>
      </div>

      <div className="flex-1 overflow-y-auto hide-scrollbar px-6 pb-12 space-y-8">
        <div className="space-y-4">
          <h2 className="text-xs font-bold text-app-muted uppercase tracking-wider ml-1">
            Проблемы и обсуждения
          </h2>
          <Card className="p-0 overflow-hidden divide-y divide-white/5">
            <div className="flex items-center justify-between p-4">
              <span className="text-sm font-medium text-white">
                Новая проблема
              </span>
              <Toggle
                checked={toggles['new-issue']}
                onChange={() => toggle('new-issue')} />
              
            </div>
            <div className="flex items-center justify-between p-4">
              <span className="text-sm font-medium text-white">
                Ответ партнёра
              </span>
              <Toggle
                checked={toggles['partner-reply']}
                onChange={() => toggle('partner-reply')} />
              
            </div>
            <div className="flex items-center justify-between p-4">
              <span className="text-sm font-medium text-white">
                Предложено решение
              </span>
              <Toggle
                checked={toggles['solution-proposed']}
                onChange={() => toggle('solution-proposed')} />
              
            </div>
          </Card>
        </div>

        <div className="space-y-4">
          <h2 className="text-xs font-bold text-app-muted uppercase tracking-wider ml-1">
            Договорённости
          </h2>
          <Card className="p-0 overflow-hidden divide-y divide-white/5">
            <div className="flex items-center justify-between p-4">
              <span className="text-sm font-medium text-white">
                Договорённость принята
              </span>
              <Toggle
                checked={toggles['agreement-accepted']}
                onChange={() => toggle('agreement-accepted')} />
              
            </div>
            <div className="flex items-center justify-between p-4">
              <span className="text-sm font-medium text-white">
                Время проверки договорённости
              </span>
              <Toggle
                checked={toggles['agreement-check']}
                onChange={() => toggle('agreement-check')} />
              
            </div>
          </Card>
        </div>

        <div className="space-y-4">
          <h2 className="text-xs font-bold text-app-muted uppercase tracking-wider ml-1">
            Активности и события
          </h2>
          <Card className="p-0 overflow-hidden divide-y divide-white/5">
            <div className="flex items-center justify-between p-4">
              <span className="text-sm font-medium text-white">Годовщина</span>
              <Toggle
                checked={toggles['anniversary']}
                onChange={() => toggle('anniversary')} />
              
            </div>
            <div className="flex items-center justify-between p-4">
              <span className="text-sm font-medium text-white">
                Квиз запущен/завершён
              </span>
              <Toggle
                checked={toggles['quiz']}
                onChange={() => toggle('quiz')} />
              
            </div>
            <div className="flex items-center justify-between p-4">
              <span className="text-sm font-medium text-white">
                Новая идея занятия
              </span>
              <Toggle
                checked={toggles['new-idea']}
                onChange={() => toggle('new-idea')} />
              
            </div>
          </Card>
        </div>

        <div className="space-y-4">
          <h2 className="text-xs font-bold text-app-muted uppercase tracking-wider ml-1">
            Системные
          </h2>
          <Card className="p-0 overflow-hidden divide-y divide-white/5">
            <div className="flex items-center justify-between p-4">
              <span className="text-sm font-medium text-white">
                Партнёр вышел из пары
              </span>
              <Toggle
                checked={toggles['partner-left']}
                onChange={() => toggle('partner-left')} />
              
            </div>
          </Card>
        </div>
      </div>
    </div>);

}
export function SecuritySafetyScreen({
  onNavigate


}: {onNavigate: (screen: string) => void;}) {
  const [showReport, setShowReport] = useState(false);
  const [reportReason, setReportReason] = useState('');
  const reasons = [
  'Оскорбления',
  'Угрозы',
  'Сексуальный контент',
  'Давление и манипуляции',
  'Спам',
  'Другое'];

  return (
    <div className="min-h-full flex flex-col bg-app-bg">
      <div className="flex items-center justify-between px-4 pt-2 pb-4 sticky top-0 bg-app-bg/90 backdrop-blur-md z-10">
        <button
          onClick={() => onNavigate('profile')}
          className="w-10 h-10 flex items-center justify-center text-app-text">
          
          <ArrowLeft className="w-6 h-6" />
        </button>
        <div className="flex-1 px-2 text-center">
          <h1 className="text-[15px] font-bold text-white">Безопасность</h1>
        </div>
        <div className="w-10 h-10"></div>
      </div>

      <div className="flex-1 overflow-y-auto hide-scrollbar px-6 pb-12 space-y-6">
        {!showReport ?
        <>
            <Card className="p-0 overflow-hidden divide-y divide-white/5">
              <button className="w-full flex items-center justify-between p-4 text-left hover:bg-white/5 transition-colors">
                <span className="text-sm font-medium text-rose-400">
                  Заблокировать партнёра
                </span>
              </button>
              <button
              onClick={() => setShowReport(true)}
              className="w-full flex items-center justify-between p-4 text-left hover:bg-white/5 transition-colors">
              
                <span className="text-sm font-medium text-rose-400">
                  Пожаловаться
                </span>
              </button>
            </Card>

            <Card className="border-amber-500/20 bg-amber-500/5 mt-8">
              <div className="flex items-center gap-3 mb-3">
                <ShieldAlert className="w-5 h-5 text-amber-500" />
                <h2 className="text-sm font-bold text-white">
                  Экстренные службы
                </h2>
              </div>
              <p className="text-xs text-app-text leading-relaxed">
                Приложение не является заменой кризисной помощи. Если в
                отношениях есть насилие, угрозы или опасность — немедленно
                обратитесь за профессиональной помощью или в экстренные службы
                вашего региона.
              </p>
            </Card>
          </> :

        <div className="space-y-6">
            <h2 className="text-lg font-bold text-white">Причина жалобы</h2>
            <div className="space-y-2">
              {reasons.map((r) =>
            <button
              key={r}
              onClick={() => setReportReason(r)}
              className={`w-full p-4 rounded-2xl text-left text-sm font-medium transition-colors border ${reportReason === r ? 'bg-app-accent/20 border-app-accent text-white' : 'bg-app-card border-white/5 text-app-text hover:border-white/20'}`}>
              
                  {r}
                </button>
            )}
            </div>

            <div className="space-y-2">
              <label className="text-xs font-medium text-app-muted ml-1">
                Комментарий (необязательно)
              </label>
              <textarea
              className="w-full bg-app-card border border-white/5 rounded-2xl p-4 text-sm text-white placeholder:text-app-muted/50 focus:outline-none focus:border-app-accent/50 transition-colors resize-none h-24"
              placeholder="Опишите ситуацию подробнее...">
            </textarea>
            </div>

            <div className="pt-4 flex gap-3">
              <Button
              fullWidth
              variant="ghost"
              onClick={() => setShowReport(false)}>
              
                Отмена
              </Button>
              <Button
              fullWidth
              variant="danger"
              disabled={!reportReason}
              className={!reportReason ? 'opacity-50' : ''}>
              
                Отправить
              </Button>
            </div>
          </div>
        }
      </div>
    </div>);

}
export function DeleteAccountScreen({
  onNavigate


}: {onNavigate: (screen: string) => void;}) {
  const [step, setStep] = useState(1);
  const [confirmText, setConfirmText] = useState('');
  return (
    <div className="min-h-full flex flex-col bg-app-bg">
      <div className="flex items-center justify-between px-4 pt-2 pb-4 sticky top-0 bg-app-bg/90 backdrop-blur-md z-10">
        <button
          onClick={() => step === 1 ? onNavigate('profile') : setStep(1)}
          className="w-10 h-10 flex items-center justify-center text-app-text">
          
          <ArrowLeft className="w-6 h-6" />
        </button>
        <div className="flex-1 px-2 text-center">
          <h1 className="text-[15px] font-bold text-white">
            Удаление аккаунта
          </h1>
        </div>
        <div className="w-10 h-10"></div>
      </div>

      <div className="flex-1 px-6 pb-12 flex flex-col">
        {step === 1 ?
        <>
            <Card className="border-rose-500/20 bg-rose-500/5 mb-8">
              <div className="flex items-center gap-3 mb-4">
                <div className="w-10 h-10 rounded-full bg-rose-500/20 flex items-center justify-center text-rose-500">
                  <AlertTriangle className="w-5 h-5" />
                </div>
                <h2 className="text-lg font-bold text-white">Внимание</h2>
              </div>
              <ul className="space-y-3 text-sm text-app-text leading-relaxed list-disc pl-5">
                <li>
                  Все ваши личные данные будут навсегда удалены или
                  анонимизированы.
                </li>
                <li>
                  Ваш партнёр получит уведомление о том, что вы покинули пару и
                  удалили аккаунт.
                </li>
                <li>
                  Общие проблемы и договорённости останутся у партнёра в
                  анонимном виде.
                </li>
                <li>Это действие невозможно отменить.</li>
              </ul>
            </Card>

            <div className="mt-auto">
              <Button fullWidth variant="danger" onClick={() => setStep(2)}>
                Удалить аккаунт
              </Button>
            </div>
          </> :

        <div className="flex-1 flex flex-col justify-center">
            <Card className="p-6 text-center border-rose-500/30">
              <h2 className="text-xl font-bold text-white mb-2">Вы уверены?</h2>
              <p className="text-sm text-app-muted mb-6">
                Это действие нельзя отменить.
              </p>

              <div className="space-y-2 mb-8 text-left">
                <label className="text-xs font-medium text-app-muted ml-1">
                  Введите УДАЛИТЬ для подтверждения
                </label>
                <input
                type="text"
                value={confirmText}
                onChange={(e) => setConfirmText(e.target.value)}
                placeholder="УДАЛИТЬ"
                className="w-full bg-app-bg border border-white/5 rounded-2xl px-4 py-3.5 text-sm text-white focus:outline-none focus:border-rose-500/50 transition-colors uppercase" />
              
              </div>

              <div className="space-y-3">
                <Button
                fullWidth
                variant="danger"
                disabled={confirmText !== 'УДАЛИТЬ'}
                className={confirmText !== 'УДАЛИТЬ' ? 'opacity-50' : ''}>
                
                  Удалить навсегда
                </Button>
                <Button fullWidth variant="ghost" onClick={() => setStep(1)}>
                  Отмена
                </Button>
              </div>
            </Card>
          </div>
        }
      </div>
    </div>);

}