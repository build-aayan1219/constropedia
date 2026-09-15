/**
 * Constropedia Dataset Importer
 * 
 * Imports Concrete Mixture Dataset (1,030 records) into Cloud Firestore:
 *   Parent Document: articles/cement
 *   Subcollection:   articles/cement/mixtureData
 *   Document IDs:    record001 ... record1030
 */

const fs = require('fs');
const path = require('path');
const os = require('os');
const XLSX = require('xlsx');
const { Firestore, FieldValue } = require('@google-cloud/firestore');

const PROJECT_ID = 'constropedia-7d7a3';
const EXPECTED_ROW_COUNT = 1030;

// Initialize Firestore Client
async function getFirestoreClient() {
  // Option 1: Local Service Account Key if available
  const serviceAccountPath = path.join(__dirname, 'serviceAccountKey.json');
  if (fs.existsSync(serviceAccountPath)) {
    console.log(`[Auth] Using service account key from: ${serviceAccountPath}`);
    return new Firestore({
      projectId: PROJECT_ID,
      keyFilename: serviceAccountPath,
    });
  }

  // Option 2: GOOGLE_APPLICATION_CREDENTIALS environment variable
  if (process.env.GOOGLE_APPLICATION_CREDENTIALS && fs.existsSync(process.env.GOOGLE_APPLICATION_CREDENTIALS)) {
    console.log(`[Auth] Using GOOGLE_APPLICATION_CREDENTIALS: ${process.env.GOOGLE_APPLICATION_CREDENTIALS}`);
    return new Firestore({
      projectId: PROJECT_ID,
      keyFilename: process.env.GOOGLE_APPLICATION_CREDENTIALS,
    });
  }

  // Option 3: Global Firebase CLI OAuth Token (when logged in via `firebase login`)
  try {
    const { execSync } = require('child_process');
    const globalRoot = execSync('npm root -g', { encoding: 'utf8' }).trim();
    const authModulePath = path.join(globalRoot, 'firebase-tools', 'lib', 'auth');

    if (fs.existsSync(authModulePath + '.js')) {
      const fbAuth = require(authModulePath);
      const defaultAccount = fbAuth.getGlobalDefaultAccount();

      if (defaultAccount && defaultAccount.tokens && defaultAccount.tokens.refresh_token) {
        console.log(`[Auth] Authenticating via Firebase CLI account: ${defaultAccount.user.email}`);
        const tokenResult = await fbAuth.getAccessToken(defaultAccount.tokens.refresh_token, []);

        const { OAuth2Client } = require('google-auth-library');
        const oAuth2Client = new OAuth2Client();
        oAuth2Client.setCredentials({ access_token: tokenResult.access_token });

        return new Firestore({
          projectId: PROJECT_ID,
          authClient: oAuth2Client,
        });
      }
    }
  } catch (err) {
    console.warn(`[Auth] Could not load credentials from Firebase CLI: ${err.message}`);
  }

  // Fallback: Default Firestore Client
  console.log(`[Auth] Initializing default Firestore client for project: ${PROJECT_ID}`);
  return new Firestore({ projectId: PROJECT_ID });
}

// Read and validate dataset
function loadAndValidateDataset() {
  const xlsPath = path.resolve(__dirname, '../../Datasets/Concrete_Data.xls');
  const csvPath = path.resolve(__dirname, 'dataset.csv');

  let rows = [];

  if (fs.existsSync(xlsPath)) {
    console.log(`[Dataset] Reading dataset from Excel: ${xlsPath}`);
    const workbook = XLSX.readFile(xlsPath);
    const firstSheetName = workbook.SheetNames[0];
    const sheet = workbook.Sheets[firstSheetName];
    rows = XLSX.utils.sheet_to_json(sheet, { raw: true });
  } else if (fs.existsSync(csvPath)) {
    console.log(`[Dataset] Reading dataset from CSV: ${csvPath}`);
    const workbook = XLSX.readFile(csvPath);
    const firstSheetName = workbook.SheetNames[0];
    const sheet = workbook.Sheets[firstSheetName];
    rows = XLSX.utils.sheet_to_json(sheet, { raw: true });
  } else {
    throw new Error(`Dataset not found! Looked in ${xlsPath} and ${csvPath}`);
  }

  console.log(`[Validation] Total rows loaded: ${rows.length}`);
  if (rows.length !== EXPECTED_ROW_COUNT) {
    throw new Error(`Dataset validation failed: Expected exactly ${EXPECTED_ROW_COUNT} rows, found ${rows.length}.`);
  }

  const sampleRow = rows[0];
  const keys = Object.keys(sampleRow);
  console.log(`[Validation] Detected columns (${keys.length}):`, keys);

  // Map columns based on substrings to handle spacing differences gracefully
  function findKey(pattern) {
    const matched = keys.find(k => k.toLowerCase().includes(pattern.toLowerCase()));
    if (!matched) {
      throw new Error(`Required column matching pattern "${pattern}" not found in dataset.`);
    }
    return matched;
  }

  const keyCement = findKey('cement (component 1)');
  const keySlag = findKey('blast furnace slag');
  const keyFlyAsh = findKey('fly ash');
  const keyWater = findKey('water');
  const keyPlasticizer = findKey('superplasticizer');
  const keyCoarse = findKey('coarse aggregate');
  const keyFine = findKey('fine aggregate');
  const keyAge = findKey('age');
  const keyStrength = findKey('compressive strength');

  console.log('[Validation] All 9 required columns confirmed.');

  // Validate and parse all rows
  const parsedRecords = [];

  for (let i = 0; i < rows.length; i++) {
    const r = rows[i];
    const rowNum = i + 1;

    const cementVal = parseFloat(r[keyCement]);
    const slagVal = parseFloat(r[keySlag]);
    const flyAshVal = parseFloat(r[keyFlyAsh]);
    const waterVal = parseFloat(r[keyWater]);
    const plasticizerVal = parseFloat(r[keyPlasticizer]);
    const coarseVal = parseFloat(r[keyCoarse]);
    const fineVal = parseFloat(r[keyFine]);
    const ageVal = parseInt(r[keyAge], 10);
    const strengthVal = parseFloat(r[keyStrength]);

    if (
      isNaN(cementVal) ||
      isNaN(slagVal) ||
      isNaN(flyAshVal) ||
      isNaN(waterVal) ||
      isNaN(plasticizerVal) ||
      isNaN(coarseVal) ||
      isNaN(fineVal) ||
      isNaN(ageVal) ||
      isNaN(strengthVal)
    ) {
      throw new Error(`Row ${rowNum} contains invalid numeric data: ${JSON.stringify(r)}`);
    }

    // Deterministic ID format: record001 ... record1030
    const recordId = `record${String(rowNum).padStart(3, '0')}`;

    parsedRecords.push({
      id: recordId,
      data: {
        cement: cementVal,
        blastFurnaceSlag: slagVal,
        flyAsh: flyAshVal,
        water: waterVal,
        superplasticizer: plasticizerVal,
        coarseAggregate: coarseVal,
        fineAggregate: fineVal,
        age: ageVal,
        compressiveStrength: strengthVal,
      },
    });
  }

  console.log(`[Validation] All ${parsedRecords.length} records successfully parsed into numeric formats.`);
  return parsedRecords;
}

// Main Import Task
async function runImport() {
  console.log('====================================================');
  console.log(' CONSTROPEDIA — CONCRETE MIXTURE DATASET IMPORT ');
  console.log('====================================================');

  const records = loadAndValidateDataset();
  const db = await getFirestoreClient();

  // Step 1: Ensure parent article document 'articles/cement' exists
  console.log('\n[1/3] Ensuring parent article document articles/cement exists...');
  const cementRef = db.collection('articles').doc('cement');
  const cementDoc = await cementRef.get();

  if (!cementDoc.exists) {
    console.log('Creating new articles/cement document...');
    await cementRef.set({
      title: 'Cement',
      category: 'Materials',
      description: 'A hydraulic binder substance that sets, hardens, and adheres to other materials to bind them together.',
      content: 'Cement is a fine powder made from limestone, clay, and gypsum. When mixed with water, sand, and gravel, it forms concrete or mortar. Portland cement is the most common type used worldwide in structural and architectural engineering.',
      imageUrl: 'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?w=800&auto=format&fit=crop',
      createdAt: FieldValue.serverTimestamp(),
    });
    console.log('Created articles/cement.');
  } else {
    console.log('articles/cement already exists. Preserving existing data and merging missing fields.');
    const existingData = cementDoc.data() || {};
    const updates = {};
    if (!existingData.title) updates.title = 'Cement';
    if (!existingData.category) updates.category = 'Materials';
    if (!existingData.description) updates.description = 'A hydraulic binder substance that sets, hardens, and adheres to other materials to bind them together.';
    if (!existingData.content) updates.content = 'Cement is a fine powder made from limestone, clay, and gypsum. When mixed with water, sand, and gravel, it forms concrete or mortar.';
    if (Object.keys(updates).length > 0) {
      await cementRef.set(updates, { merge: true });
    }
  }

  // Step 2: Batched writes for 1,030 mixtureData subcollection records
  console.log(`\n[2/3] Uploading ${records.length} mixture records into articles/cement/mixtureData...`);
  const BATCH_SIZE = 400; // Well below 500 Firestore limit
  let importedCount = 0;

  for (let i = 0; i < records.length; i += BATCH_SIZE) {
    const chunk = records.slice(i, i + BATCH_SIZE);
    const batch = db.batch();

    for (const record of chunk) {
      const docRef = cementRef.collection('mixtureData').doc(record.id);
      batch.set(docRef, record.data, { merge: true });
    }

    await batch.commit();
    importedCount += chunk.length;
    console.log(`  Progress: ${importedCount} / ${records.length} records committed...`);
  }

  // Step 3: Verification
  console.log('\n[3/3] Verifying imported records in Cloud Firestore...');
  const countSnapshot = await cementRef.collection('mixtureData').count().get();
  const actualCount = countSnapshot.data().count;

  console.log(`  Firestore mixtureData document count: ${actualCount}`);
  if (actualCount < EXPECTED_ROW_COUNT) {
    console.warn(`  Warning: Expected ${EXPECTED_ROW_COUNT}, but count query returned ${actualCount}`);
  } else {
    console.log(`  Verification PASSED: Exactly ${actualCount} records present.`);
  }

  const rec001 = await cementRef.collection('mixtureData').doc('record001').get();
  console.log('  Sample record001 in Firestore:', rec001.data());

  const rec1030 = await cementRef.collection('mixtureData').doc('record1030').get();
  console.log('  Sample record1030 in Firestore:', rec1030.data());

  console.log('\n====================================================');
  console.log(' IMPORT COMPLETED SUCCESSFULLY! ');
  console.log(` Total records processed & stored: ${importedCount}`);
  console.log('====================================================\n');
}

runImport().catch(err => {
  console.error('\n[FATAL ERROR during import]:', err);
  process.exit(1);
});
