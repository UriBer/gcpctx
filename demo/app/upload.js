#!/usr/bin/env node

const { Storage } = require('@google-cloud/storage');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

/**
 * CLI tool for uploading files to Cloud Storage
 * 
 * Usage:
 *   node upload.js <file> [bucket-name]
 * 
 * Examples:
 *   gcpctx use dev
 *   node upload.js test.txt my-dev-bucket
 * 
 *   gcpctx use staging
 *   node upload.js test.txt my-staging-bucket
 */

async function upload(filePath, bucketName) {
  const contextName = process.env.GCPCTX_NAME || 'unknown';
  const projectId = process.env.GOOGLE_CLOUD_PROJECT;
  
  console.log('╔════════════════════════════════════════════╗');
  console.log('║  gcpctx Demo: File Upload                ║');
  console.log('╚════════════════════════════════════════════╝\n');
  
  console.log(`📍 Context: ${contextName}`);
  console.log(`📦 Project: ${projectId}`);
  console.log(`📄 File: ${filePath}`);
  console.log(`🗂️  Bucket: ${bucketName}\n`);
  
  // Check file exists
  if (!fs.existsSync(filePath)) {
    console.error(`❌ File not found: ${filePath}\n`);
    process.exit(1);
  }
  
  try {
    const storage = new Storage();
    const bucket = storage.bucket(bucketName);
    
    // Get file stats
    const stats = fs.statSync(filePath);
    const fileName = path.basename(filePath);
    
    console.log(`⏳ Uploading ${(stats.size / 1024).toFixed(2)} KB...\n`);
    
    await bucket.upload(filePath, {
      destination: fileName,
      metadata: {
        metadata: {
          uploadedBy: 'gcpctx-demo',
          context: contextName,
          project: projectId,
          uploadDate: new Date().toISOString()
        }
      }
    });
    
    console.log(`✅ Upload successful!\n`);
    console.log(`   URL: gs://${bucketName}/${fileName}`);
    console.log(`   View: https://console.cloud.google.com/storage/browser/${bucketName}\n`);
    
    // Show context-specific message
    if (contextName === 'prod') {
      console.log('⚠️  You just uploaded to PRODUCTION!');
      console.log('   Consider protecting this context:');
      console.log('   $ gcpctx protect prod\n');
    } else {
      console.log(`💡 Switch contexts to upload elsewhere:`);
      console.log(`   $ gcpctx use staging`);
      console.log(`   $ node upload.js ${filePath} staging-bucket\n`);
    }
    
  } catch (error) {
    console.error('❌ Upload failed:');
    console.error(`   ${error.message}\n`);
    
    if (error.code === 404) {
      console.log('💡 Bucket does not exist. Create it:');
      console.log(`   $ gsutil mb gs://${bucketName}`);
      console.log(`   or`);
      console.log(`   $ gcloud storage buckets create gs://${bucketName}\n`);
    } else if (error.code === 403) {
      console.log('💡 Permission denied. Check your context:');
      console.log('   $ gcpctx current');
      console.log('   $ gcpctx doctor');
      console.log(`   $ gcpctx login ${contextName}\n`);
    }
    
    process.exit(1);
  }
}

// Parse command line arguments
const args = process.argv.slice(2);

if (args.length < 2) {
  console.log('Usage: node upload.js <file> <bucket-name>\n');
  console.log('Example:');
  console.log('  $ gcpctx use dev');
  console.log('  $ node upload.js test.txt my-dev-bucket\n');
  process.exit(1);
}

const [filePath, bucketName] = args;
upload(filePath, bucketName);
