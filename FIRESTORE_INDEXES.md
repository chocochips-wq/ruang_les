# Firestore Index Requirements

## Issue
The application is experiencing Firestore index errors when querying data. These errors occur because Firestore requires composite indexes for certain queries.

## Error Messages
```
Error: [cloud_firestore/failed-precondition] The query requires an index. 
You can create it here: https://console.firebase.google.com/...
```

## Required Indexes

### Index 1: Sessions Query
**Collection:** `sessions`
**Fields to Index:**
- `classId` (Ascending)
- `date` (Descending)

**Query Usage:** Used when loading sessions for a specific class, ordered by date.

### Index 2: Payment Queries
**Collection:** `payments`
**Fields to Index:**
- `studentId` (Ascending)
- `createdAt` (Descending)

**Query Usage:** Used when loading payment history for students.

### Index 3: Progress Notes
**Collection:** `progressNotes`
**Fields to Index:**
- `sessionId` (Ascending)
- `createdAt` (Descending)

**Query Usage:** Used when loading progress notes for specific sessions.

## How to Create Indexes

### Option 1: Automatic (Recommended)
1. Run the app and trigger the error
2. Click the URL provided in the error message
3. Firebase Console will open with pre-filled index configuration
4. Click "Create Index"
5. Wait for index to build (may take a few minutes)

### Option 2: Manual
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to Firestore Database → Indexes
4. Click "Create Index"
5. Select collection name
6. Add fields one by one
7. Choose Ascending/Descending for each field
8. Click "Create"

## Notes
- Index creation can take several minutes for large collections
- The app may show errors until indexes are fully built
- You only need to create each index once
- Indexes persist even if you redeploy the app

## Testing After Index Creation
1. Wait for all indexes to show status: "Enabled"
2. Hot restart the app (`R` in terminal)
3. Navigate to the pages that previously showed errors
4. Verify data loads correctly
