#!/bin/bash
git add .
read -p "Commit message: " msg
git commit -m "$msg"
git push origin main
echo "Changes pushed!"
