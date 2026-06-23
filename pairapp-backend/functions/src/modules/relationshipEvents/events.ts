import { onCall } from "firebase-functions/v2/https";
import { Timestamp } from "firebase-admin/firestore";
import { z } from "zod";
import { db, Collections } from "../../config/firebase";
import { requireAuth } from "../../utils/auth";
import { parseOrThrow } from "../../utils/validation";
import { getActiveCoupleOrThrow, resolvePartner } from "../../utils/couple-context";
import { Errors } from "../../utils/errors";
import { RelationshipEventDoc } from "../../types";

/**
 * createRelationshipEvent — раздел 10.4 ТЗ: "Партнёры могут добавлять
 * свои собственные важные даты (первое свидание, помолвка и т.п.) —
 * они отображаются на временной шкале наравне со встроенными вехами".
 * Не выделена отдельной строкой в разделе 18 (там только update/confirm
 * для самой relationshipStartDate), но коллекция relationship_events
 * (раздел 17.13 ТЗ) без функции создания была бы недостижима.
 */
const createRelationshipEventSchema = z.object({
  type: z.enum(["anniversary", "milestone", "custom"]),
  title: z.string().trim().min(1).max(120),
  description: z.string().trim().max(1000).nullish(),
  date: z.string().refine((v) => !Number.isNaN(Date.parse(v))),
  isRecurring: z.boolean().default(false),
});

export const createRelationshipEvent = onCall(async (request) => {
  const uid = requireAuth(request);
  const input = parseOrThrow(createRelationshipEventSchema, request.data);
  const { couple } = await getActiveCoupleOrThrow(uid);
  resolvePartner(couple, uid);

  const eventRef = db.collection(Collections.relationshipEvents).doc();
  const doc: RelationshipEventDoc = {
    id: eventRef.id,
    coupleId: couple.id,
    type: input.type,
    title: input.title,
    description: input.description ?? null,
    date: Timestamp.fromDate(new Date(input.date)),
    isRecurring: input.isRecurring,
    createdBy: uid,
    createdAt: Timestamp.now(),
  };

  await eventRef.set(doc);
  return { eventId: eventRef.id };
});

export const deleteRelationshipEvent = onCall<{ eventId: string }>(
  async (request) => {
    const uid = requireAuth(request);
    const eventId = request.data?.eventId;
    if (!eventId) {
      throw Errors.invalidArgument("eventId обязателен.");
    }
    const { couple } = await getActiveCoupleOrThrow(uid);
    resolvePartner(couple, uid);

    const eventRef = db.collection(Collections.relationshipEvents).doc(eventId);
    const snap = await eventRef.get();
    if (!snap.exists) {
      throw Errors.notFound("Событие");
    }
    const event = snap.data() as RelationshipEventDoc;
    if (event.coupleId !== couple.id) {
      throw Errors.permissionDenied("Это событие принадлежит другой паре.");
    }

    await eventRef.delete();
    return { success: true };
  }
);
