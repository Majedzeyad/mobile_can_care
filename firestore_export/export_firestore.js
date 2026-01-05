import admin from 'firebase-admin';
import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

/**
 * Recursively exports all documents from a collection, including subcollections
 * @param {admin.firestore.CollectionReference} collectionRef - The collection reference
 * @param {string} collectionPath - The path of the collection
 * @returns {Promise<Object>} - Object containing all documents and subcollections
 */
async function exportCollection(collectionRef, collectionPath) {
  const result = {
    documents: {},
    subcollections: {}
  };

  try {
    // Get all documents in the collection
    const snapshot = await collectionRef.get();
    
    if (snapshot.empty) {
      console.log(`  Collection "${collectionPath}" is empty`);
      return result;
    }

    console.log(`  Found ${snapshot.size} document(s) in "${collectionPath}"`);

    // Process each document
    for (const doc of snapshot.docs) {
      const docData = doc.data();
      const docPath = `${collectionPath}/${doc.id}`;
      
      // Convert Firestore Timestamps to ISO strings
      const processedData = processDocumentData(docData);
      
      result.documents[doc.id] = {
        path: docPath,
        data: processedData,
        createTime: doc.createTime ? doc.createTime.toDate().toISOString() : null,
        updateTime: doc.updateTime ? doc.updateTime.toDate().toISOString() : null
      };

      // Check for subcollections
      const subcollections = await doc.ref.listCollections();
      
      if (subcollections.length > 0) {
        console.log(`    Document "${doc.id}" has ${subcollections.length} subcollection(s)`);
        result.subcollections[doc.id] = {};
        
        for (const subcollection of subcollections) {
          const subcollectionPath = `${docPath}/${subcollection.id}`;
          console.log(`    Processing subcollection: ${subcollectionPath}`);
          
          result.subcollections[doc.id][subcollection.id] = await exportCollection(
            subcollection,
            subcollectionPath
          );
        }
      }
    }
  } catch (error) {
    console.error(`  Error exporting collection "${collectionPath}":`, error.message);
    result.error = error.message;
  }

  return result;
}

/**
 * Recursively processes document data to convert Firestore types to JSON-serializable types
 * @param {any} data - The document data
 * @returns {any} - Processed data
 */
function processDocumentData(data) {
  if (data === null || data === undefined) {
    return data;
  }

  // Handle Firestore Timestamp
  if (data.constructor && data.constructor.name === 'Timestamp') {
    return {
      _firestore_timestamp: data.toDate().toISOString(),
      _seconds: data.seconds,
      _nanoseconds: data.nanoseconds
    };
  }

  // Handle Date objects
  if (data instanceof Date) {
    return {
      _firestore_timestamp: data.toISOString(),
      _date: true
    };
  }

  // Handle GeoPoint
  if (data.constructor && data.constructor.name === 'GeoPoint') {
    return {
      _firestore_geopoint: {
        latitude: data.latitude,
        longitude: data.longitude
      }
    };
  }

  // Handle DocumentReference
  if (data.constructor && data.constructor.name === 'DocumentReference') {
    return {
      _firestore_reference: data.path
    };
  }

  // Handle arrays
  if (Array.isArray(data)) {
    return data.map(item => processDocumentData(item));
  }

  // Handle objects
  if (typeof data === 'object') {
    const processed = {};
    for (const [key, value] of Object.entries(data)) {
      processed[key] = processDocumentData(value);
    }
    return processed;
  }

  // Return primitive types as-is
  return data;
}

/**
 * Main function to export all Firestore data
 */
async function exportFirestore() {
  try {
    // Get service account key path from command line argument, environment variable, or default
    const serviceAccountPath = 
      process.argv[2] || 
      process.env.FIREBASE_SERVICE_ACCOUNT_KEY || 
      path.join(__dirname, 'serviceAccountKey.json');
    
    console.log(`Looking for service account key at: ${serviceAccountPath}`);
    
    try {
      await fs.access(serviceAccountPath);
    } catch {
      throw new Error(
        `Service account key file not found at: ${serviceAccountPath}\n\n` +
        'To fix this:\n' +
        '1. Go to Firebase Console: https://console.firebase.google.com/\n' +
        '2. Select your project (cancare-312a8)\n' +
        '3. Go to Project Settings → Service Accounts\n' +
        '4. Click "Generate New Private Key"\n' +
        '5. Save the downloaded JSON file\n\n' +
        'Then either:\n' +
        `   - Save it as "serviceAccountKey.json" in: ${__dirname}\n` +
        '   - Or run: node export_firestore.js <path-to-key.json>\n' +
        '   - Or set: FIREBASE_SERVICE_ACCOUNT_KEY=<path-to-key.json>'
      );
    }

    // Read and parse service account key
    const serviceAccount = JSON.parse(
      await fs.readFile(serviceAccountPath, 'utf8')
    );

    // Initialize Firebase Admin
    console.log('Initializing Firebase Admin SDK...');
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });

    const db = admin.firestore();
    console.log('Connected to Firestore successfully\n');

    // Get all top-level collections
    console.log('Fetching all collections...');
    const collections = await db.listCollections();
    
    if (collections.length === 0) {
      console.log('No collections found in Firestore');
      const emptyExport = {
        exportDate: new Date().toISOString(),
        projectId: serviceAccount.project_id,
        collections: {}
      };
      
      await fs.writeFile(
        path.join(__dirname, 'firestore_export.json'),
        JSON.stringify(emptyExport, null, 2),
        'utf8'
      );
      
      console.log('\nExport completed: firestore_export.json (empty)');
      process.exit(0);
    }

    console.log(`Found ${collections.length} top-level collection(s)\n`);

    // Export all collections
    const exportData = {
      exportDate: new Date().toISOString(),
      projectId: serviceAccount.project_id,
      totalCollections: collections.length,
      collections: {}
    };

    for (const collection of collections) {
      console.log(`Processing collection: ${collection.id}`);
      exportData.collections[collection.id] = await exportCollection(
        collection,
        collection.id
      );
      console.log(`Completed collection: ${collection.id}\n`);
    }

    // Calculate statistics
    let totalDocuments = 0;
    let totalSubcollections = 0;

    function countDocuments(collections) {
      for (const [collectionName, collectionData] of Object.entries(collections)) {
        if (collectionData.documents) {
          totalDocuments += Object.keys(collectionData.documents).length;
        }
        if (collectionData.subcollections) {
          for (const subcollections of Object.values(collectionData.subcollections)) {
            totalSubcollections += Object.keys(subcollections).length;
            countDocuments(subcollections);
          }
        }
      }
    }

    countDocuments(exportData.collections);
    exportData.totalDocuments = totalDocuments;
    exportData.totalSubcollections = totalSubcollections;

    // Write to JSON file
    const outputPath = path.join(__dirname, 'firestore_export.json');
    console.log(`Writing export to: ${outputPath}`);
    await fs.writeFile(
      outputPath,
      JSON.stringify(exportData, null, 2),
      'utf8'
    );

    console.log('\n✅ Export completed successfully!');
    console.log(`📄 Output file: ${outputPath}`);
    console.log(`📊 Statistics:`);
    console.log(`   - Collections: ${exportData.totalCollections}`);
    console.log(`   - Documents: ${exportData.totalDocuments}`);
    console.log(`   - Subcollections: ${exportData.totalSubcollections}`);

  } catch (error) {
    console.error('\n❌ Export failed:', error.message);
    console.error(error.stack);
    process.exit(1);
  } finally {
    // Clean up Firebase Admin
    if (admin.apps.length > 0) {
      await admin.app().delete();
    }
  }
}

// Run the export
exportFirestore();

