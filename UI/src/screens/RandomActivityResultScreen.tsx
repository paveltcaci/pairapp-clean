import React from 'react';
import { ArrowLeft, Clock, Banknote, Tag, Sparkles } from 'lucide-react';
import { Badge, Button, Card } from '../components/UI';
export function RandomActivityResultScreen({
  onNavigate


}: {onNavigate: (screen: string) => void;}) {
  return (
    <div className="min-h-full flex flex-col bg-app-bg">
      {/* Header */}
      <div className="flex items-center justify-between px-4 pt-2 pb-4 z-10">
        <button
          onClick={() => onNavigate('activities')}
          className="w-10 h-10 flex items-center justify-center text-app-text">
          
          <ArrowLeft className="w-6 h-6" />
        </button>
        <div className="flex-1 px-2 text-center">
          <h1 className="text-[15px] font-bold text-white">Результат</h1>
        </div>
        <div className="w-10 h-10"></div>
      </div>

      <div className="flex-1 flex flex-col items-center justify-center px-6 pb-12">
        <div className="w-full relative">
          {/* Background glow */}
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-64 h-64 bg-app-accent/20 rounded-full blur-[60px] pointer-events-none"></div>

          <Card
            glow
            className="relative z-10 p-8 flex flex-col items-center text-center">
            
            <div className="w-16 h-16 rounded-full bg-accent-gradient flex items-center justify-center mb-6 shadow-[0_0_30px_rgba(155,126,240,0.4)]">
              <Sparkles className="w-8 h-8 text-white" />
            </div>

            <Badge variant="purple" className="mb-4">
              Романтика
            </Badge>

            <h2 className="text-2xl font-bold text-white mb-3">
              Приготовить ужин вместе
            </h2>

            <p className="text-sm text-app-muted mb-8 leading-relaxed">
              Выберите новый рецепт, который вы никогда не пробовали, купите
              ингредиенты и приготовьте его вместе под любимую музыку.
            </p>

            <div className="flex gap-6 w-full justify-center border-t border-white/5 pt-6">
              <div className="flex flex-col items-center gap-1.5">
                <div className="w-8 h-8 rounded-full bg-app-bg flex items-center justify-center text-app-accent">
                  <Clock className="w-4 h-4" />
                </div>
                <span className="text-[10px] text-app-muted font-medium">
                  2-3 часа
                </span>
              </div>
              <div className="flex flex-col items-center gap-1.5">
                <div className="w-8 h-8 rounded-full bg-app-bg flex items-center justify-center text-app-accent">
                  <Banknote className="w-4 h-4" />
                </div>
                <span className="text-[10px] text-app-muted font-medium">
                  Средний
                </span>
              </div>
              <div className="flex flex-col items-center gap-1.5">
                <div className="w-8 h-8 rounded-full bg-app-bg flex items-center justify-center text-app-accent">
                  <Tag className="w-4 h-4" />
                </div>
                <span className="text-[10px] text-app-muted font-medium">
                  Дома
                </span>
              </div>
            </div>
          </Card>
        </div>

        <div className="w-full space-y-3 mt-12">
          <Button fullWidth onClick={() => onNavigate('activities')}>
            Принять
          </Button>
          <Button fullWidth variant="secondary">
            Крутить ещё
          </Button>
        </div>
      </div>
    </div>);

}