import { ActivitySource, BudgetLevel, FirestoreTimestamp } from "./common";

/**
 * Коллекция `activities` (раздел 17.7 ТЗ).
 */
export interface ActivityDoc {
  id: string;
  /** null для встроенных активностей (builtin), доступных всем парам. */
  coupleId: string | null;
  title: string;
  description: string;
  category: string;
  durationMinutes: number | null;
  budgetLevel: BudgetLevel;
  source: ActivitySource;
  createdBy: string | null;
  isActive: boolean;
  createdAt: FirestoreTimestamp;
}

export interface CreateActivityInput {
  title: string;
  description: string;
  category: string;
  durationMinutes?: number | null;
  budgetLevel: BudgetLevel;
}

export interface SpinActivityInput {
  /** Опциональный фильтр по категории (раздел 11.2 ТЗ). */
  category?: string | null;
}

/**
 * Коллекция `activity_history` (раздел 17.8 ТЗ).
 *
 * Обратная совместимость: записи от acceptActivity имеют
 * source = undefined, localIdeaId = undefined, chosenBy = string.
 * Записи от saveActivityIdeaSnapshot имеют source = "local_builtin",
 * localIdeaId = string, chosenBy = null.
 */
export interface ActivityHistoryDoc {
  id: string;
  coupleId: string;
  // ── Поля от acceptActivity (старые записи) ──
  activityId: string | null;
  chosenBy: string | null;
  chosenAt: FirestoreTimestamp | null;
  // ── Поля от saveActivityIdeaSnapshot (новые записи) ──
  source?: "local_builtin";
  localIdeaId?: string;
  title?: string;
  description?: string;
  emoji?: string;
  categories?: string[];
  durationMinutes?: number | null;
  budgetLevel?: BudgetLevel;
  locationType?: string;
  vibe?: string;
  preparation?: string | null;
  savedBy?: string;
  savedAt?: FirestoreTimestamp;
  createdAt?: FirestoreTimestamp;
}

/**
 * Коллекция `chore_tasks` (раздел 17.9 ТЗ).
 */
export interface ChoreTaskDoc {
  id: string;
  coupleId: string;
  title: string;
  description: string | null;
  createdBy: string;
  isActive: boolean;
  createdAt: FirestoreTimestamp;
  updatedAt: FirestoreTimestamp;
}

export interface CreateChoreTaskInput {
  title: string;
  description?: string | null;
}

export interface SpinChoreInput {
  choreTaskId: string;
}

/**
 * Коллекция `chore_spins` (раздел 17.10 ТЗ).
 */
export interface ChoreSpinDoc {
  id: string;
  choreTaskId: string;
  coupleId: string;
  selectedUserId: string;
  partnerARecentCount: number;
  partnerBRecentCount: number;
  spunAt: FirestoreTimestamp;
}

/**
 * Окно "последних N спинов", используемое алгоритмом честного выбора
 * (раздел 12.2 ТЗ). N фиксировано на уровне backend, не настраивается пользователем.
 */
export const CHORE_FAIRNESS_WINDOW = 5;
