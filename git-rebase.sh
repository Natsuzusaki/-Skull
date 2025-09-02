#!/bin/bash

# Simple Git Rebase Script
# WARNING: This can overwrite local changes if conflicts are resolved automatically.

echo "Fetching latest changes from remote..."
git fetch origin

# Show current status before rebasing
git status

echo "Your local commits (if any):"
git log --oneline origin/main..HEAD

echo "Rebasing your local branch onto origin/main..."
git rebase origin/main

if [ $? -ne 0 ]; then
    echo
    echo "⚠ Conflicts detected! You need to resolve them manually."
    echo "Run 'git status' to see conflicted files."
    echo "After resolving, use 'git add <file>' and then 'git rebase --continue'"
else
    echo
    echo "Rebase completed successfully!"
    echo "You can now push your changes:"
    echo "git push origin main"
fi

