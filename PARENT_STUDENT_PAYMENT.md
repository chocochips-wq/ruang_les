# Parent–Student Linking and Payments

This document describes the schema, registration flows, implementation steps, and migration guidance to connect `students` with `parents`, add a payments feature for `teachers` and `parents`, and ensure parents can view their children's progress.

## Goals

- Allow parents to view child(ren) progress, achievements and payments.
- Let teachers create/manage payments (CRUD) for classes/students.
- Ensure account creation captures necessary relationships: `student.classId`, `student.parentId` (and `parents.studentIds`).
- Provide a small migration/seeding process to backfill missing fields on existing documents.

---

**Collections (Firestore)**

- `users` (existing): base user data (userId, email, name, role, phone, verificationStatus...)
- `students` (existing): per-student doc keyed by `userId`
  - Schema example:
    ```json
    {
      "userId": "uid_student_123",
      "nickname": "Rani",
      "fullName": "Rani Putri",
      "gradeLevel": "SD 4-6",
      "classId": "class_abc",
      "parentId": "uid_parent_456",
      "learningLevel": 1,
      "totalPoints": 0,
      "badges": [],
      "createdAt": "Timestamp",
    }
    ```
- `parents` (existing-ish): per-parent doc keyed by `userId`
  - Schema example:
    ```json
    {
      "userId": "uid_parent_456",
      "address": "...",
      "phone": "089...",
      "studentIds": ["uid_student_123","uid_student_789"],
      "createdAt": "Timestamp"
    }
    ```
- `payments` (new): payment records created by teachers for classes/students
  - Schema example:
    ```json
    {
      "paymentId": "uuid",
      "teacherId": "uid_teacher_111",
      "classId": "class_abc",
      "studentId": "uid_student_123", // optional if class-level
      "parentId": "uid_parent_456",  // optional but useful
      "amount": 150000,
      "currency": "IDR",
      "description": "Biaya kursus bulan Januari",
      "dueDate": "Timestamp",
      "status": "pending", // pending|paid|overdue|cancelled
      "createdAt": "Timestamp",
      "updatedAt": "Timestamp",
    }
    ```

---

## Registration Flow Options (recommended: A)

- Option A — Parent-first (Recommended): Parent signs up and creates parent account, then adds child(ren) from parent dashboard. This ensures parent -> student links are created server-side and students are provisioned correctly with `parentId` and `classId` if known.

  Pros: clean relationships, easier to manage multiple children, fewer verification issues.
  Cons: Slightly more steps for parent.

- Option B — Student self-registers with parent email/ID: Student signs up and supplies `parentEmail`. The system creates student doc with `parentPendingLink: parentEmail` and sends a notification/email to parent to confirm and link. Parent confirms and system updates both docs.

  Pros: quicker for students to sign up.
  Cons: Needs confirmation flow and notifications; can cause orphaned student docs.

- Option C — Allow both flows: supports both A and B. More implementation work.

Recommendation: Implement Option A first, add Option B later if needed.

---

## Implementation Steps (high level)

1. Schema & repository updates
   - Ensure `StudentModel` includes `parentId` and `classId` (already present).
   - Update `UserRepository.createUserWithRoleData` to accept `parentId` / `studentData.classId` and to update `parents.studentIds` when a student is created.

2. Backend helper: `PaymentRepository`
   - Create `lib/data/repositories/payment_repository.dart` with methods:
     - `createPayment(Map data)`
     - `updatePayment(paymentId, Map data)`
     - `deletePayment(paymentId)`
     - `getPaymentsByParentId(parentId)`, `streamPaymentsByParentId(parentId)`
     - `getPaymentsByTeacherId(teacherId)`, `streamPaymentsByTeacherId(teacherId)`
     - `getPaymentsByStudentId(studentId)`, `streamPaymentsByStudentId(studentId)`

3. Registration / UI changes
   - For Option A (recommended): Add `Parent Dashboard` UI where parent can `Add Child`.
     - `Add Child` form collects: child `fullName`, `nickname`, `gradeLevel`, `classId` (select), optional `avatarUrl`.
     - Backend flow: create Firebase Auth user for the child (teacher/parent may create a password or temporary code), create `users` doc and `students` doc via `UserRepository.createUserWithRoleData({studentData, userModel: ...})`, then update `parents.studentIds` with child's userId.
   - For Option B: update `register_page.dart` to allow students to provide `parentEmail` and store `parentPendingLink` on student doc.

4. Parent Dashboard
   - New page `lib/features/parent/pages/parent_dashboard.dart` listing children and streaming each child progress and achievements (reuse `ProgressRepository` stream methods), and their payments (via `PaymentRepository.streamPaymentsByParentId`).

5. Teacher Payments UI
   - Add UI for teachers to create payment records for their class/students: `lib/features/teacher/pages/payments.dart` with CRUD actions calling `PaymentRepository`.

6. Seeding & Migration
   - Update `lib/core/utils/firebase_seeding.dart` and `quiz_seeding.dart` to create example `parents` docs with `studentIds`, and to create example `payments`.
   - Provide migration function `migrateEnsureStudentFields()` that:
     - Ensures each `students` doc has `totalPoints` (default 0), `fullName` (from `users.name` if missing), and `parentId` (null if unknown).
     - Ensures each `parents` doc has `studentIds` array.

7. Security rules (reminder)
   - Update Firestore rules so parents can read their children's `students/*` docs, progress, and payments; teachers can CRUD payments for their classes; parents cannot modify payments except marking as paid (if allowed).

---

## Detailed Code Notes / Pointers

- `UserRepository.createUserWithRoleData` — modify the `student` branch to accept `parentId` and optionally update the `parents` collection `studentIds` array (using `FieldValue.arrayUnion([studentId])`).

- `AuthProvider.register()` — can accept an extra `roleData` payload. For Option A flow, parent will not use `AuthProvider.register()` to create child; instead parent UI will call a helper repository that:
  - Creates an Auth user (or uses Admin SDK if server-side) for the child OR stores a staged record and invites the child.
  - Calls `createUserWithRoleData` to create `users` and `students` docs.

- `PaymentRepository` example skeleton (to be added in repository file):
  - Use `FirebaseFirestore.instance.collection('payments')` and `doc(paymentId)`.
  - For stream methods, return `query.snapshots().map(...)`.

- Parent UI should show payment status, due date and allow simple actions (view details, mark paid via teacher confirmation, or upload proof).

---

## Migration / Seeding Example Code (pseudo)

- Migration helper should iterate `students` collection and patch missing fields:
  ```dart
  final students = await firestore.collection('students').get();
  for (final doc in students.docs) {
    final data = doc.data();
    final updates = {};
    if (!data.containsKey('totalPoints')) updates['totalPoints'] = 0;
    if (!data.containsKey('fullName')) {
      // lookup in users collection
      final userDoc = await firestore.collection('users').doc(doc.id).get();
      if (userDoc.exists) updates['fullName'] = userDoc.data()?['name'] ?? '';
    }
    if (updates.isNotEmpty) {
      await doc.reference.update(updates);
    }
  }
  ```

---

## UX notes & choices

- Parent-first flow reduces orphaned students and simplifies payments association.
- If you want parents to pay per-class or per-month, `payments` should include `period` or `invoiceId` and support receipts.
- Consider adding `notifications` collection for parent invites / payment reminders.

---

## Next actions I can take now

- Implement `PaymentRepository` and basic teacher UI (CRUD endpoints).
- Update `UserRepository.createUserWithRoleData` to update `parents.studentIds` when creating a student.
- Add `parent_dashboard.dart` to show children and payments.

Which next action should I implement first? Also confirm preferred registration flow: Option A (Parent-first), Option B (Student self-register + parent confirmation), or Option C (both)."