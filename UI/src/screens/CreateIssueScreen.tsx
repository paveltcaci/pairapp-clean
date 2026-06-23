import React, { useState } from 'react';
import { ArrowLeft, ChevronDown } from 'lucide-react';
import { Button } from '../components/UI';
export function CreateIssueScreen({
  onNavigate


}: {onNavigate: (screen: string) => void;}) {
  const [selectedEmotions, setSelectedEmotions] = useState<string[]>([]);
  const [importance, setImportance] = useState(3);
  const emotions = ['грусть', 'одиночество', 'злость', 'тревога', 'усталость'];
  const toggleEmotion = (emotion: string) => {
    if (selectedEmotions.includes(emotion)) {
      setSelectedEmotions(selectedEmotions.filter((e) => e !== emotion));
    } else {
      setSelectedEmotions([...selectedEmotions, emotion]);
    }
  };
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
          <h1 className="text-[15px] font-bold text-white">Создать проблему</h1>
        </div>
        <div className="w-10 h-10"></div>
      </div>

      <div className="flex-1 overflow-y-auto hide-scrollbar p-6 space-y-6 pb-32">
        {/* Field 1 */}
        <div className="space-y-2">
          <label className="text-sm font-medium text-app-muted">
            Что вас беспокоит?
          </label>
          <textarea
            className="w-full bg-app-card border border-white/5 rounded-2xl p-4 text-sm text-white placeholder:text-app-muted/50 focus:outline-none focus:border-app-accent/50 transition-colors resize-none h-28"
            placeholder="Опишите ситуацию...">
          </textarea>
        </div>

        {/* Field 2 */}
        <div className="space-y-2">
          <label className="text-sm font-medium text-app-muted">
            Категория
          </label>
          <div className="relative">
            <select className="w-full bg-app-card border border-white/5 rounded-2xl p-4 text-sm text-white appearance-none focus:outline-none focus:border-app-accent/50 transition-colors">
              <option>Быт и обязанности</option>
              <option>Время вместе</option>
              <option>Финансы</option>
              <option>Общение</option>
            </select>
            <ChevronDown className="absolute right-4 top-1/2 -translate-y-1/2 w-5 h-5 text-app-muted pointer-events-none" />
          </div>
        </div>

        {/* Field 3 */}
        <div className="space-y-3">
          <label className="text-sm font-medium text-app-muted">
            Что я чувствую
          </label>
          <div className="flex flex-wrap gap-2">
            {emotions.map((emotion) =>
            <button
              key={emotion}
              onClick={() => toggleEmotion(emotion)}
              className={`px-4 py-2 rounded-full text-sm font-medium transition-colors border ${selectedEmotions.includes(emotion) ? 'bg-app-accent/20 border-app-accent text-app-accent' : 'bg-transparent border-white/10 text-app-muted hover:border-white/20'}`}>
              
                {emotion}
              </button>
            )}
          </div>
        </div>

        {/* Field 4 */}
        <div className="space-y-4">
          <div className="flex justify-between items-center">
            <label className="text-sm font-medium text-app-muted">
              Насколько важно?
            </label>
            <span className="text-xs font-bold text-app-accent">
              {importance} / 5
            </span>
          </div>
          <div className="flex justify-between gap-2">
            {[1, 2, 3, 4, 5].map((num) =>
            <button
              key={num}
              onClick={() => setImportance(num)}
              className={`flex-1 h-12 rounded-xl flex items-center justify-center text-sm font-bold transition-colors ${importance === num ? 'bg-app-accent text-white shadow-[0_0_15px_rgba(155,126,240,0.3)]' : 'bg-app-card text-app-muted border border-white/5 hover:border-white/20'}`}>
              
                {num}
              </button>
            )}
          </div>
        </div>

        {/* Field 5 */}
        <div className="space-y-2">
          <label className="text-sm font-medium text-app-muted">
            Что хочу получить в итоге
          </label>
          <input
            type="text"
            className="w-full bg-app-card border border-white/5 rounded-2xl p-4 text-sm text-white placeholder:text-app-muted/50 focus:outline-none focus:border-app-accent/50 transition-colors"
            placeholder="Например: договориться о..." />
          
        </div>
      </div>

      {/* Bottom Button */}
      <div className="absolute bottom-0 left-0 right-0 p-6 bg-gradient-to-t from-app-bg via-app-bg to-transparent z-20">
        <Button fullWidth onClick={() => onNavigate('issues')}>
          Создать
        </Button>
      </div>
    </div>);

}