#!/usr/bin/env node

/**
 * auto-git-sync.js
 * 
 * This script runs git-sync at regular intervals to automatically push and pull changes.
 * It uses the git-sync.bat or git-sync.sh script depending on the platform.
 */

const { spawn } = require('child_process');
const path = require('path');

// Configuration
const SYNC_INTERVAL_MINUTES = 5; // Default sync interval in minutes
const SYNC_INTERVAL_MS = SYNC_INTERVAL_MINUTES * 60 * 1000;

// Get interval from command line args if provided
const args = process.argv.slice(2);
let interval = SYNC_INTERVAL_MINUTES;
if (args.length > 0 && !isNaN(parseInt(args[0]))) {
  interval = parseInt(args[0]);
  console.log(`Using custom sync interval: ${interval} minutes`);
} else {
  console.log(`Using default sync interval: ${interval} minutes`);
}

// Determine the script to run based on platform
const isWindows = process.platform === 'win32';
const scriptPath = isWindows ? 'scripts/git-sync.bat' : 'scripts/git-sync.sh';
const scriptCmd = isWindows ? scriptPath : 'bash';
const scriptArgs = isWindows ? [] : [scriptPath];

/**
 * Run the git sync script
 */
function runGitSync() {
  console.log(`\n[${new Date().toISOString()}] Running git sync...`);
  
  const child = spawn(scriptCmd, scriptArgs, {
    stdio: 'inherit', 
    shell: isWindows
  });
  
  child.on('close', (code) => {
    if (code !== 0) {
      console.error(`Git sync process exited with code ${code}`);
    } else {
      console.log(`\n[${new Date().toISOString()}] Git sync completed successfully`);
      console.log(`Next sync scheduled in ${interval} minutes`);
    }
  });
}

// Initial run
console.log(`Starting automatic git sync every ${interval} minutes...`);
console.log(`Press Ctrl+C to stop`);

// Run immediately
runGitSync();

// Schedule regular runs
setInterval(runGitSync, interval * 60 * 1000); 