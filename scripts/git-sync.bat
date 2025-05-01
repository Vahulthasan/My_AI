@echo off
REM git-sync.bat
REM Script to automatically sync with git repository (pull and push)

echo Starting git synchronization...

REM Check if we're in a git repository
git rev-parse --is-inside-work-tree > nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: Not in a git repository.
    exit /b 1
)

REM Get current branch
for /f "tokens=*" %%a in ('git symbolic-ref --short HEAD 2^>nul') do set CURRENT_BRANCH=%%a
if "%CURRENT_BRANCH%"=="" (
    echo Error: Unable to determine current branch.
    exit /b 1
)

echo Current branch: %CURRENT_BRANCH%

REM Fetch the latest changes
echo Fetching latest changes...
git fetch

REM Check if local branch is behind remote
for /f "tokens=*" %%a in ('git rev-parse @') do set LOCAL=%%a
for /f "tokens=*" %%a in ('git rev-parse @{u}') do set REMOTE=%%a
for /f "tokens=*" %%a in ('git merge-base @ @{u}') do set BASE=%%a

REM Stash any local changes
set STASHED=0
git diff-index --quiet HEAD --
if %ERRORLEVEL% equ 0 (
    echo Working directory clean.
) else (
    echo Stashing local changes...
    git stash
    set STASHED=1
)

REM Pull changes from remote
if "%LOCAL%"=="%REMOTE%" (
    echo Local branch is up-to-date with remote.
) else if "%LOCAL%"=="%BASE%" (
    echo Pulling changes from remote...
    git pull
    echo Successfully pulled changes.
) else if "%REMOTE%"=="%BASE%" (
    echo Local branch is ahead of remote. Will push changes.
) else (
    echo Local and remote have diverged. Attempting to rebase...
    git pull --rebase
    if %ERRORLEVEL% neq 0 (
        echo Rebase failed. Please resolve conflicts manually.
        if %STASHED%==1 (
            echo Applying stashed changes back...
            git stash pop
        )
        exit /b 1
    )
    echo Successfully rebased local changes.
)

REM Apply stashed changes if any
if %STASHED%==1 (
    echo Applying stashed changes back...
    git stash pop
    if %ERRORLEVEL% neq 0 (
        echo Applying stashed changes failed. Please resolve conflicts manually.
        exit /b 1
    )
)

REM Check if there are changes to commit
git diff-index --quiet HEAD --
if %ERRORLEVEL% neq 0 (
    echo Changes detected. Committing...
    git add .
    git commit -m "Auto-commit: %DATE% %TIME%"
    echo Changes committed.
)

REM Push changes to remote
echo Pushing changes to remote...
git push
if %ERRORLEVEL% neq 0 (
    echo Push failed. Please check your credentials and try again.
    exit /b 1
)

echo Successfully pushed changes to remote.
echo Git synchronization completed successfully. 