#!/bin/bash

git add .
git commit -m "📝 :: build number increase"
git push -u origin build-number-increase-for-testflight
gh pr create --repo baekteun/TodayWhat-new --title "🔀 :: build number increase" --body "build number increased" --base "master" --head "build-number-increase-for-testflight" --assignee @me --label "🌏 Deploy"