/**
 * Типы для модуля Wishlist V1 («Список желаний»).
 * Связаны с коллекцией `wishlist_items` в Firestore.
 */

import { Timestamp } from "firebase-admin/firestore";
import { BudgetLevel } from "./common";

export type WishlistStatus = "active" | "done" | "archived";
export type WishlistPriority = "low" | "medium" | "high";

/** Документ коллекции `wishlist_items`. */
export interface WishlistItemDoc {
  id: string;
  coupleId: string;
  title: string;
  description: string | null;
  emoji: string;
  category: string;
  priority: WishlistPriority;
  budgetLevel: BudgetLevel;
  status: WishlistStatus;
  createdBy: string;
  completedBy: string | null;
  completedAt: Timestamp | null;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

/** Входные данные для createWishlistItem. */
export interface CreateWishlistItemInput {
  title: string;
  description?: string | null;
  emoji?: string;
  category?: string;
  priority?: WishlistPriority;
  budgetLevel?: BudgetLevel;
}

/** Входные данные для updateWishlistItemStatus. */
export interface UpdateWishlistItemStatusInput {
  itemId: string;
  status: "active" | "done" | "archived";
}

/** Входные данные для deleteWishlistItem (soft-delete → archived). */
export interface DeleteWishlistItemInput {
  itemId: string;
}
