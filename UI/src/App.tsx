import React, { useState, Component } from 'react';
import { useScreenInit } from './useScreenInit.js';
import { PhoneFrame } from './components/PhoneFrame';
import { HomeScreen } from './screens/HomeScreen';
import { IssuesScreen } from './screens/IssuesScreen';
import { IssueChatScreen } from './screens/IssueChatScreen';
import { AgreementsScreen } from './screens/AgreementsScreen';
import { ActivitiesScreen } from './screens/ActivitiesScreen';
import { RandomActivityResultScreen } from './screens/RandomActivityResultScreen';
import { CreateIssueScreen } from './screens/CreateIssueScreen';
import { ProfileScreen } from './screens/ProfileScreen';
import { QuizScreen } from './screens/QuizScreen';
import { QuizResultScreen } from './screens/QuizResultScreen';
import {
  OnboardingSlide1Screen,
  OnboardingSlide2Screen,
  OnboardingSlide3Screen } from
'./screens/OnboardingScreens';
import {
  LoginScreen,
  RegisterScreen,
  ForgotPasswordScreen,
  AgeConfirmationScreen } from
'./screens/AuthScreens';
import {
  CreateOrJoinCoupleScreen,
  InviteCodeScreen,
  EnterCodeScreen,
  CoupleConnectedSuccessScreen } from
'./screens/CoupleConnectionScreens';
import {
  NotificationsSettingsScreen,
  SecuritySafetyScreen,
  DeleteAccountScreen } from
'./screens/SettingsScreens';
export function App() {
  const screenInit = useScreenInit();
  const [currentScreen, setCurrentScreen] = useState(
    screenInit?.screen || 'onboarding-1'
  );
  const screens = [
  {
    id: 'onboarding-1',
    name: 'Onboarding 1 (Welcome)',
    component: OnboardingSlide1Screen
  },
  {
    id: 'onboarding-2',
    name: 'Onboarding 2 (Benefit)',
    component: OnboardingSlide2Screen
  },
  {
    id: 'onboarding-3',
    name: 'Onboarding 3 (Disclaimer)',
    component: OnboardingSlide3Screen
  },
  {
    id: 'login',
    name: 'Login',
    component: LoginScreen
  },
  {
    id: 'register',
    name: 'Register',
    component: RegisterScreen
  },
  {
    id: 'forgot-password',
    name: 'Forgot Password',
    component: ForgotPasswordScreen
  },
  {
    id: 'age-gate',
    name: 'Age Confirmation',
    component: AgeConfirmationScreen
  },
  {
    id: 'create-join-couple',
    name: 'Create/Join Couple',
    component: CreateOrJoinCoupleScreen
  },
  {
    id: 'invite-code',
    name: 'Invite Code',
    component: InviteCodeScreen
  },
  {
    id: 'enter-code',
    name: 'Enter Code',
    component: EnterCodeScreen
  },
  {
    id: 'couple-success',
    name: 'Couple Success',
    component: CoupleConnectedSuccessScreen
  },
  {
    id: 'home',
    name: 'Home / Dashboard',
    component: HomeScreen
  },
  {
    id: 'issues',
    name: 'Issues List',
    component: IssuesScreen
  },
  {
    id: 'issue-chat',
    name: 'Issue Chat/Thread',
    component: IssueChatScreen
  },
  {
    id: 'agreements',
    name: 'Agreements List',
    component: AgreementsScreen
  },
  {
    id: 'activities',
    name: 'Activities Hub',
    component: ActivitiesScreen
  },
  {
    id: 'random-activity',
    name: 'Random Activity Result',
    component: RandomActivityResultScreen
  },
  {
    id: 'create-issue',
    name: 'Create Issue Form',
    component: CreateIssueScreen
  },
  {
    id: 'profile',
    name: 'Profile',
    component: ProfileScreen
  },
  {
    id: 'notifications-settings',
    name: 'Notifications Settings',
    component: NotificationsSettingsScreen
  },
  {
    id: 'security-safety',
    name: 'Security & Safety',
    component: SecuritySafetyScreen
  },
  {
    id: 'delete-account',
    name: 'Delete Account',
    component: DeleteAccountScreen
  },
  {
    id: 'quiz',
    name: 'Quiz Screen',
    component: QuizScreen
  },
  {
    id: 'quiz-result',
    name: 'Quiz Result',
    component: QuizResultScreen
  }];

  const CurrentComponent =
  screens.find((s) => s.id === currentScreen)?.component ||
  OnboardingSlide1Screen;
  return (
    <div className="flex w-full min-h-screen bg-[#0F0D13] font-sans text-white">
      {/* Sidebar for navigation */}
      <div className="w-64 bg-[#14121A] border-r border-white/10 p-6 flex flex-col gap-2 overflow-y-auto">
        <div className="mb-6">
          <h2 className="text-xl font-bold text-white mb-1">PairApp</h2>
          <p className="text-xs text-app-muted">UI Kit Navigator</p>
        </div>

        {screens.map((screen) =>
        <button
          key={screen.id}
          onClick={() => setCurrentScreen(screen.id)}
          className={`text-left px-4 py-3 rounded-xl text-sm transition-colors ${currentScreen === screen.id ? 'bg-app-accent/20 text-app-accent font-medium border border-app-accent/30' : 'text-app-muted hover:bg-white/5 hover:text-white border border-transparent'}`}>
          
            {screen.name}
          </button>
        )}
      </div>

      {/* Main Content Area */}
      <div className="flex-1 flex items-center justify-center p-8 overflow-y-auto">
        <PhoneFrame>
          <CurrentComponent onNavigate={setCurrentScreen} />
        </PhoneFrame>
      </div>
    </div>);

}