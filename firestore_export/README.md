# Firestore Export Script

A production-safe Node.js script that exports **ALL** Firestore collections, documents, and subcollections to a single JSON file.

## Features

- ✅ Exports **ALL** collections (no filtering)
- ✅ Exports **ALL** documents (no assumptions)
- ✅ Recursively exports subcollections
- ✅ Handles all Firestore data types (Timestamps, GeoPoints, References, etc.)
- ✅ Production-safe with comprehensive error handling
- ✅ Preserves document metadata (createTime, updateTime)
- ✅ Includes export statistics

## Prerequisites

- Node.js (v18 or higher recommended)
- Firebase project with Firestore enabled
- Service account key with Firestore permissions

## Setup

1. **Install dependencies:**
   ```bash
   cd firestore_export
   npm install
   ```

2. **Get your Firebase service account key:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select your project
   - Go to Project Settings → Service Accounts
   - Click "Generate New Private Key"
   - Save the downloaded JSON file as `serviceAccountKey.json` in the `firestore_export` directory

3. **Ensure your service account has proper permissions:**
   - The service account needs `Cloud Datastore User` role or equivalent
   - For production, use least-privilege access

## Usage

**Option 1: Default location (recommended)**
```bash
# Save serviceAccountKey.json in the firestore_export directory, then:
npm run export
```

**Option 2: Specify path as argument**
```bash
node export_firestore.js /path/to/your/serviceAccountKey.json
```

**Option 3: Use environment variable**
```bash
# Windows PowerShell:
$env:FIREBASE_SERVICE_ACCOUNT_KEY="C:\path\to\serviceAccountKey.json"
npm run export

# Windows CMD:
set FIREBASE_SERVICE_ACCOUNT_KEY=C:\path\to\serviceAccountKey.json
npm run export

# Linux/Mac:
export FIREBASE_SERVICE_ACCOUNT_KEY=/path/to/serviceAccountKey.json
npm run export
```

## Output

The script generates `firestore_export.json` with the following structure:

```json
{
  "exportDate": "2024-01-01T00:00:00.000Z",
  "projectId": "your-project-id",
  "totalCollections": 5,
  "totalDocuments": 100,
  "totalSubcollections": 10,
  "collections": {
    "users": {
      "documents": {
        "user123": {
          "path": "users/user123",
          "data": { ... },
          "createTime": "2024-01-01T00:00:00.000Z",
          "updateTime": "2024-01-01T00:00:00.000Z"
        }
      },
      "subcollections": {
        "user123": {
          "orders": {
            "documents": { ... },
            "subcollections": { ... }
          }
        }
      }
    }
  }
}
```

## Data Type Handling

The script converts Firestore-specific types to JSON-serializable formats:

- **Timestamps**: Converted to ISO strings with metadata
- **GeoPoints**: Converted to `{ latitude, longitude }` objects
- **DocumentReferences**: Converted to path strings
- **Arrays**: Recursively processed
- **Nested Objects**: Recursively processed

## Security Notes

- ⚠️ **Never commit `serviceAccountKey.json` to version control**
- ⚠️ **Add `serviceAccountKey.json` to `.gitignore`**
- ⚠️ **Store service account keys securely in production**
- ⚠️ **Use environment-specific service accounts when possible**

## Error Handling

The script includes comprehensive error handling:
- Validates service account key file exists
- Handles network errors gracefully
- Continues processing even if individual collections fail
- Provides detailed error messages

## Production Safety

- No data filtering or assumptions
- Complete export of all data
- Proper cleanup of Firebase Admin connections
- Exit codes for CI/CD integration
- Detailed logging for debugging

## Troubleshooting

**Error: Service account key not found**
- Ensure `serviceAccountKey.json` is in the same directory as the script
- Verify the file name is exactly `serviceAccountKey.json`

**Error: Permission denied**
- Check that your service account has Firestore read permissions
- Verify the service account key is for the correct project

**Large exports taking too long**
- This is normal for large databases
- The script processes collections sequentially to avoid overwhelming Firestore
- Consider running during off-peak hours for production databases

## License

ISC

