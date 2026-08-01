const { Storage } = require('@google-cloud/storage');
require('dotenv').config();

/**
 * Demo application showing gcpctx usage
 * 
 * This app uses Application Default Credentials (ADC) and
 * environment variables that gcpctx manages.
 * 
 * Switch contexts with: gcpctx use <context-name>
 * Auto-load context with: gcpctx activate (reads .gcpctx file)
 */

class CloudStorageDemo {
  constructor() {
    // The Storage client automatically uses:
    // - GOOGLE_APPLICATION_CREDENTIALS (set by gcpctx)
    // - GOOGLE_CLOUD_PROJECT (set by gcpctx)
    this.storage = new Storage();
    
    this.projectId = process.env.GOOGLE_CLOUD_PROJECT || process.env.GCLOUD_PROJECT;
    this.contextName = process.env.GCPCTX_NAME || 'unknown';
    
    console.log('╔════════════════════════════════════════════╗');
    console.log('║  gcpctx Demo: Cloud Storage App          ║');
    console.log('╚════════════════════════════════════════════╝\n');
    
    console.log(`📍 Active Context: ${this.contextName}`);
    console.log(`📦 GCP Project: ${this.projectId}`);
    console.log(`🔐 Credentials: ${process.env.GOOGLE_APPLICATION_CREDENTIALS || 'ADC default'}\n`);
  }

  async listBuckets() {
    try {
      console.log('🔍 Listing Cloud Storage buckets...\n');
      
      const [buckets] = await this.storage.getBuckets();
      
      if (buckets.length === 0) {
        console.log('  No buckets found in this project.');
        console.log(`  Create one: gsutil mb gs://my-bucket-${this.projectId}\n`);
        return [];
      }
      
      console.log(`  Found ${buckets.length} bucket(s):\n`);
      buckets.forEach(bucket => {
        console.log(`  📦 ${bucket.name}`);
      });
      console.log('');
      
      return buckets;
    } catch (error) {
      console.error('❌ Error listing buckets:');
      console.error(`   ${error.message}\n`);
      
      if (error.code === 403) {
        console.log('💡 Troubleshooting:');
        console.log('   1. Check your context: gcpctx current');
        console.log('   2. Verify credentials: gcpctx doctor');
        console.log('   3. Re-login if needed: gcpctx login ' + this.contextName);
        console.log('');
      }
      
      throw error;
    }
  }

  async uploadFile(bucketName, filePath) {
    try {
      console.log(`📤 Uploading ${filePath} to ${bucketName}...\n`);
      
      const bucket = this.storage.bucket(bucketName);
      await bucket.upload(filePath);
      
      console.log(`✅ File uploaded successfully!`);
      console.log(`   gs://${bucketName}/${filePath}\n`);
      
      return true;
    } catch (error) {
      console.error('❌ Error uploading file:');
      console.error(`   ${error.message}\n`);
      throw error;
    }
  }

  async demonstrateContextAwareness() {
    console.log('🎯 This app is context-aware!\n');
    console.log('Try these commands:\n');
    console.log('  1. Switch to another context:');
    console.log('     $ gcpctx use staging');
    console.log('     $ npm start\n');
    console.log('  2. Use folder markers:');
    console.log('     $ echo \'{"name":"dev","project":"my-dev"}\' > .gcpctx');
    console.log('     $ gcpctx activate');
    console.log('     $ npm start\n');
    console.log('  3. Safe execution:');
    console.log('     $ gcpctx exec --require-context dev -- npm start\n');
    console.log('  4. Assert before running:');
    console.log('     $ gcpctx assert --context dev && npm start\n');
  }
}

async function main() {
  const demo = new CloudStorageDemo();
  
  try {
    await demo.listBuckets();
    await demo.demonstrateContextAwareness();
  } catch (error) {
    process.exit(1);
  }
}

if (require.main === module) {
  main();
}

module.exports = CloudStorageDemo;
