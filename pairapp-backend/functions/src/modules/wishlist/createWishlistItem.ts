import { onCall } from "firebase-functions/v2/https";
import { FieldValue } from "firebase-admin/firestore";
import { db, Collections } from "../../config/firebase";
import { requireAuth } from "../../utils/auth";
import { parseOrThrow, createWishlistItemSchema } from "../../utils/validation";
import { getActiveCoupleOrThrow } from "../../utils/couple-context";
import { WishlistItemDoc, CreateWishlistItemInput } from "../../types";

/** createWishlistItem — создание желания в общем списке пары. */
export const createWishlistItem = onCall<CreateWishlistItemInput>(
  async (request) => {
    const uid = requireAuth(request);
    const input = parseOrThrow(createWishlistItemSchema, request.data);
    const { couple } = await getActiveCoupleOrThrow(uid);

    const itemRef = db.collection(Collections.wishlistItems).doc();
    const now = FieldValue.serverTimestamp() as any;

    const itemDoc: WishlistItemDoc = {
      id: itemRef.id,
      coupleId: couple.id,
      title: input.title,
      description: input.description ?? null,
      emoji: input.emoji ?? "✨",
      category: input.category ?? "другое",
      priority: input.priority ?? "medium",
      budgetLevel: input.budgetLevel ?? "free",
      status: "active",
      createdBy: uid,
      completedBy: null,
      completedAt: null,
      createdAt: now,
      updatedAt: now,
    };

    await itemRef.set(itemDoc);
    return { success: true, itemId: itemRef.id };
  }
);
