#!/bin/bash

git add .
git commit -m "📝 :: $VERSION released"
git push -u origin release/$VERSION
gh pr create --repo baegteun/TodayWhat-new --title "🔀 :: $VERSION Release" --body "$VERSION version released" --base "master" --head "release/$VERSION" --assignee @me --label "🌏 Deploy"