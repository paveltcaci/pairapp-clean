import React from 'react';
interface AvatarProps {
  src: string;
  size?: 'sm' | 'md' | 'lg' | 'xl';
  className?: string;
}
export function Avatar({ src, size = 'md', className = '' }: AvatarProps) {
  const sizeClasses = {
    sm: 'w-6 h-6',
    md: 'w-10 h-10',
    lg: 'w-16 h-16',
    xl: 'w-24 h-24'
  };
  return (
    <div
      className={`rounded-full p-[2px] bg-accent-gradient ${sizeClasses[size]} ${className}`}>
      
      <img
        src={src}
        alt="Avatar"
        className="w-full h-full rounded-full object-cover border-2 border-app-bg" />
      
    </div>);

}
interface BadgeProps {
  children: React.ReactNode;
  variant?: 'purple' | 'blue' | 'green' | 'outline' | 'red' | 'yellow';
  className?: string;
}
export function Badge({
  children,
  variant = 'purple',
  className = ''
}: BadgeProps) {
  const variants = {
    purple: 'bg-app-accent/20 text-app-accent border border-app-accent/30',
    blue: 'bg-blue-500/20 text-blue-400 border border-blue-500/30',
    green: 'bg-emerald-500/20 text-emerald-400 border border-emerald-500/30',
    red: 'bg-rose-500/20 text-rose-400 border border-rose-500/30',
    yellow: 'bg-amber-500/20 text-amber-400 border border-amber-500/30',
    outline: 'bg-transparent text-app-muted border border-app-border'
  };
  return (
    <span
      className={`px-2.5 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider ${variants[variant]} ${className}`}>
      
      {children}
    </span>);

}
interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'danger' | 'ghost';
  fullWidth?: boolean;
}
export function Button({
  children,
  variant = 'primary',
  fullWidth = false,
  className = '',
  ...props
}: ButtonProps) {
  const baseClasses =
  'px-5 py-3.5 rounded-2xl font-semibold transition-all active:scale-[0.98] flex items-center justify-center gap-2';
  const widthClass = fullWidth ? 'w-full' : '';
  const variants = {
    primary:
    'bg-accent-gradient text-white shadow-[0_0_20px_rgba(155,126,240,0.3)]',
    secondary:
    'bg-transparent border border-app-accent/50 text-app-accent hover:bg-app-accent/10',
    danger:
    'bg-rose-500/10 text-rose-500 border border-rose-500/20 hover:bg-rose-500/20',
    ghost: 'bg-transparent text-app-muted hover:text-white hover:bg-white/5'
  };
  return (
    <button
      className={`${baseClasses} ${widthClass} ${variants[variant]} ${className}`}
      {...props}>
      
      {children}
    </button>);

}
interface CardProps {
  children: React.ReactNode;
  className?: string;
  glow?: boolean;
}
export function Card({ children, className = '', glow = false }: CardProps) {
  return (
    <div
      className={`bg-app-card rounded-[20px] p-5 border border-white/5 ${glow ? 'shadow-[0_0_30px_rgba(155,126,240,0.1)] border-app-accent/20' : ''} ${className}`}>
      
      {children}
    </div>);

}