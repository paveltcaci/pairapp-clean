import { onCall } from "firebase-functions/v2/https";
import { FieldValue } from "firebase-admin/firestore";
import { db, Collections } from "../../config/firebase";
import { requireAuth } from "../../utils/auth";
import {
  parseOrThrow,
  updateWishlistItemStatusSchema,
} from "../../utils/validation";
import { getActiveCoupleOrThrow } from "../../utils/couple-context";
import { Errors } from "../../utils/errors";
import { UpdateWishlistItemStatusInput, WishlistItemDoc } from "../../types";

/** updateWishlistItemStatus — смена статуса желания (active / done / archived). */
export const updateWishlistItemStatus =
  onCall<UpdateWishlistItemStatusInput>(async (request) => {
    const uid = requireAuth(request);
    const input = parseOrThrow(updateWishlistItemStatusSchema, request.data);
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

    let updateData: Record<string, unknown>;

    switch (input.status) {
      case "done":
        updateData = {
          status: "done",
          completedBy: uid,
          completedAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        };
        break;
      case "active":
        updateData = {
          status: "active",
          completedBy: null,
          completedAt: null,
          updatedAt: FieldValue.serverTimestamp(),
        };
        break;
      case "archived":
        updateData = {
          status: "archived",
          updatedAt: FieldValue.serverTimestamp(),
        };
        break;
    }

    await itemRef.update(updateData);
    return { success: true };
  });
