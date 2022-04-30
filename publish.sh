#!/bin/zsh
git checkout jk
git branch -D master
git checkout -b master
git filter-branch --subdirectory-filter _site/ -f
git push --all
git checkout jk

# ./publish.sh 로 실행