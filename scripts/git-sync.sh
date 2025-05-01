#!/bin/bash

# git-sync.sh
# Script to automatically sync with git repository (pull and push)

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting git synchronization...${NC}"

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a git repository.${NC}"
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null)
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Unable to determine current branch.${NC}"
    exit 1
fi

echo -e "${YELLOW}Current branch: ${CURRENT_BRANCH}${NC}"

# Fetch the latest changes
echo -e "${YELLOW}Fetching latest changes...${NC}"
git fetch

# Check if local branch is behind remote
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u})
BASE=$(git merge-base @ @{u})

# Stash any local changes
STASHED=0
if git diff-index --quiet HEAD --; then
    echo -e "${GREEN}Working directory clean.${NC}"
else
    echo -e "${YELLOW}Stashing local changes...${NC}"
    git stash
    STASHED=1
fi

# Pull changes from remote
if [ $LOCAL = $REMOTE ]; then
    echo -e "${GREEN}Local branch is up-to-date with remote.${NC}"
elif [ $LOCAL = $BASE ]; then
    echo -e "${YELLOW}Pulling changes from remote...${NC}"
    git pull
    echo -e "${GREEN}Successfully pulled changes.${NC}"
elif [ $REMOTE = $BASE ]; then
    echo -e "${YELLOW}Local branch is ahead of remote. Will push changes.${NC}"
else
    echo -e "${YELLOW}Local and remote have diverged. Attempting to rebase...${NC}"
    git pull --rebase
    if [ $? -ne 0 ]; then
        echo -e "${RED}Rebase failed. Please resolve conflicts manually.${NC}"
        if [ $STASHED -eq 1 ]; then
            echo -e "${YELLOW}Applying stashed changes back...${NC}"
            git stash pop
        fi
        exit 1
    fi
    echo -e "${GREEN}Successfully rebased local changes.${NC}"
fi

# Apply stashed changes if any
if [ $STASHED -eq 1 ]; then
    echo -e "${YELLOW}Applying stashed changes back...${NC}"
    git stash pop
    if [ $? -ne 0 ]; then
        echo -e "${RED}Applying stashed changes failed. Please resolve conflicts manually.${NC}"
        exit 1
    fi
fi

# Check if there are changes to commit
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}Changes detected. Committing...${NC}"
    git add .
    git commit -m "Auto-commit: $(date)"
    echo -e "${GREEN}Changes committed.${NC}"
fi

# Push changes to remote
echo -e "${YELLOW}Pushing changes to remote...${NC}"
git push
if [ $? -ne 0 ]; then
    echo -e "${RED}Push failed. Please check your credentials and try again.${NC}"
    exit 1
fi

echo -e "${GREEN}Successfully pushed changes to remote.${NC}"
echo -e "${GREEN}Git synchronization completed successfully.${NC}" 