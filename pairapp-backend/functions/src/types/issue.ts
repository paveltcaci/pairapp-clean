import { FieldValue } from "firebase-admin/firestore";
import {
  FirestoreTimestamp,
  IssueCategory,
  IssueFeeling,
  IssueMessageType,
  IssueStatus,
} from "./common";

/**
 * Коллекция `issues` (раздел 17.3 ТЗ).
 */
export interface IssueDoc {
  id: string;
  coupleId: string;
  authorId: string;
  title: string;
  description: string | null;
  feelings: IssueFeeling[];
  /** 1..5, раздел 8.4 ТЗ. */
  importanceLevel: number;
  desiredOutcome: string | null;
  category: IssueCategory;
  status: IssueStatus;
  createdAt: FirestoreTimestamp;
  updatedAt: FirestoreTimestamp | FieldValue;
  solvedAt: FirestoreTimestamp | null;
  reopenedAt: FirestoreTimestamp | null;
  archivedAt: FirestoreTimestamp | null;
  /**
   * Денормализованные поля для быстрого списка (раздел 8.1: "количество
   * сообщений, наличие новой активности"). Не указаны явно в разделе 17,
   * но требуются разделом 8.1 — поддерживаются триггером на issue_messages.
   */
  messageCount: number;
  lastMessageAt: FirestoreTimestamp | null;
}

export interface CreateIssueInput {
  title: string;
  description?: string | null;
  feelings?: IssueFeeling[];
  importanceLevel: number;
  desiredOutcome?: string | null;
  category: IssueCategory;
}

export interface UpdateIssueInput {
  issueId: string;
  title?: string;
  description?: string | null;
  feelings?: IssueFeeling[];
  importanceLevel?: number;
  desiredOutcome?: string | null;
  category?: IssueCategory;
}

/**
 * Коллекция `issue_messages` (раздел 17.4 ТЗ).
 */
export interface IssueMessageDoc {
  id: string;
  issueId: string;
  coupleId: string;
  authorId: string;
  type: IssueMessageType;
  text: string;
  createdAt: FirestoreTimestamp;
  updatedAt: FirestoreTimestamp | null;
  isDeleted: boolean;
  readByPartner: boolean;
}

export interface CreateIssueMessageInput {
  issueId: string;
  type: IssueMessageType;
  text: string;
}

/** Допустимые переходы статуса проблемы (раздел 8.3 ТЗ), для валидации в коде. */
export const ISSUE_STATUS_TRANSITIONS: Record<IssueStatus, IssueStatus[]> = {
  open: ["in_discussion", "archived"],
  in_discussion: ["agreement_proposed", "reopened", "archived"],
  agreement_proposed: ["agreed", "in_discussion", "archived"],
  agreed: ["solved", "reopened", "archived"],
  solved: ["reopened", "archived"],
  reopened: ["in_discussion", "agreement_proposed", "archived"],
  archived: [],
};
