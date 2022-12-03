## Proper and complete commit process with Tags

> Important: save all files in VScode

````bash
cd ~/docker-guacamole-light
# Template
read -d '' changelog << EOF
Header if more than 1 type: Features, Bug fixes and Docs
- feat or fix: use text BREAKING CHANGE to highlight a major breaking change
- feat: added feature abc eventually close #123 if requested
- fix: issue blabla close #123 if bug referenced
- docs: added cluster-prep with base stack deployment
- chore: updating grunt tasks etc; no production code change 
EOF

# For simple undocumented commit without tag
changelog="minor changes in docs"

# latest update (temp)
read -d '' changelog << EOF
Features and Docs
- feat: add all files to build basic docker-guacamole (v1.4.0) for arm without DB nor auth (strip down fork from jwetzell/docker-guacamole)
- docs: create build-docker-image.md to detail the building process
- docs: create git-cheatsheet.md for standardized and documented commits
- docs: create README.md for end users
EOF
# Version
version="v1.4.0"


# Checks
cd ~/docker-guacamole-light
git diff
git status
#??git rm -r --cached .
git add -A #Important!
#git check-ignore -v a/b/c/*
# Last checks, be sure nothing is forgotten
git diff
git status

# And Go commit + tag all in one
git commit -m "$changelog"
git log
git tag -a "$version" -m "$changelog"
git push --tags -u origin main
# (master or main branch)
````

## Cloning a repository
````bash
git clone https://github.com/CypZ/docker-guacamole-light.git
cd docker-guacamole-light
git switch -c main
````

# In case of conflict git local/remote
````bash
git fetch origin
git diff main origin/main (detailed)
git cherry main origin/main (detailed)
````