# Git Sync Functionality

This repository includes automatic git synchronization functionality that helps keep your local repository in sync with the remote repository. This document explains how to use these features.

## Overview

The git sync functionality provides two main capabilities:
1. One-time synchronization (pull and push)
2. Continuous automatic synchronization at set intervals

## Available Commands

### One-Time Sync

To perform a one-time sync (pull and push):

```bash
npm run git-sync
```

This command will:
1. Pull the latest changes from the remote repository
2. Stash any local changes if needed
3. Rebase if there are divergent changes
4. Commit any local changes
5. Push all changes to the remote repository

### Continuous Automatic Sync

To start automatic synchronization at regular intervals:

```bash
npm run auto-git-sync
```

By default, this will sync every 5 minutes. To specify a custom interval:

```bash
node scripts/auto-git-sync.js 10  # Sync every 10 minutes
```

## How It Works

The synchronization scripts perform the following operations:

1. Check if you're in a git repository
2. Fetch the latest changes from the remote
3. Stash any local changes to prevent conflicts
4. Pull latest changes or rebase if needed
5. Re-apply stashed changes
6. Commit any new local changes
7. Push all changes to the remote repository

## Platform Support

The functionality works on both Windows and Unix-like systems (Linux, macOS).

## Troubleshooting

If you encounter issues with the git sync functionality:

1. Make sure you have git installed and on your PATH
2. Ensure you have the appropriate permissions for the repository
3. Check if your git credentials are properly configured
4. Verify that you have a remote repository set up

If the synchronization fails, you may need to manually resolve conflicts or fix other git-related issues before running the sync again.

## Customization

You can modify the scripts in the `scripts` directory to customize the git sync behavior:

- `scripts/git-sync.sh` - Bash script for Unix-like systems
- `scripts/git-sync.bat` - Batch script for Windows
- `scripts/auto-git-sync.js` - Node.js script for continuous synchronization 