import { onCall } from "firebase-functions/v2/https";
import { FieldValue } from "firebase-admin/firestore";
import { db, Collections } from "../../config/firebase";
import { requireAuth } from "../../utils/auth";
import { parseOrThrow, deleteWishlistItemSchema } from "../../utils/validation";
import { getActiveCoupleOrThrow } from "../../utils/couple-context";
import { Errors } from "../../utils/errors";
import { DeleteWishlistItemInput, WishlistItemDoc } from "../../types";

/**
 * deleteWishlistItem — soft delete: переводит желание в статус `archived`.
 * Hard delete не производится.
 */
export const deleteWishlistItem = onCall<DeleteWishlistItemInput>(
  async (request) => {
    const uid = requireAuth(request);
    const input = parseOrThrow(deleteWishlistItemSchema, request.data);
    const { couple } = await getActiveCoupleOrThrow(uid);

    const itemRef = db.collection(Collections.wishlistItems).doc(input.itemId);
    const snap = await itemRef.get();
    if (!snap.exists) {
      throw Errors.notFound("Желание");
    }
    const item = snap.data() as WishlistItemDoc;
    if (item.coupleId !== couple.id) {
      throw Errors.permissionDenied("Это желание принадлежит другой паре.");
    }

    await itemRef.update({
      status: "archived",
      updatedAt: FieldValue.serverTimestamp(),
    });

    return { success: true };
  }
);
