#!/usr/bin/env bash -eux

testdir='mergetest'

rm -rf ${testdir}
mkdir -p ${testdir}

cd ${testdir}

# Create the inital files
cat >README.md <<"EOF"
The 'mergetest-setup.sh' script will set up a git repo with interesting
conflicts in two branches.

FIRST THINGS FIRST... the script will create the repo in a subdirectory,
so move or copy it to the parent or some other directory. This script
will delete and recreate the ${testdir} directory if it exists, so don't
put anything important there.

`hello.txt` and `goodbye.txt` have fairly simple conflicts.

`mergetool.txt` and `lorum.txt` have conflicts designed to better test
the capability of external merge tools.

TODO: Add line numbers to lorum.txt to make the changes easier to see. Or maybe change it to a simple list.

EOF

# We'll patch this for conflicts then delete the patches after we apply them.
cat >lorum.txt <<EOF
Fusce interdum volutpat sodales. Etiam pulvinar turpis nec consectetur
fringilla. Ut finibus vel nunc ut porta. Phasellus feugiat mollis
turpis, vel pretium augue porttitor vitae. Curabitur ligula quam,
pellentesque sit amet nisi ut, rhoncus vehicula lacus. Vivamus ornare
magna ut leo malesuada, in iaculis nisl dignissim. Praesent at maximus
purus. Sed sed urna in dolor accumsan lacinia. Suspendisse egestas
eget risus a fermentum. Sed faucibus justo dolor, nec volutpat ligula
congue vel. Mauris velit nisl, ultrices ac imperdiet nec, luctus sed
sem. Curabitur lacinia ultricies lorem ut placerat. Proin turpis diam,
convallis eu condimentum nec, pretium non sem. Nulla facilisi.

Morbi finibus consequat vulputate. Duis in erat quis velit vehicula
vehicula et sed diam. Aliquam ligula nulla, faucibus eu auctor et,
facilisis vel magna. Mauris sit amet nisi vel erat facilisis vulputate.
Pellentesque semper sem id elit commodo, at luctus nulla porta. Sed
sollicitudin libero quis sem elementum lacinia. Pellentesque neque odio,
auctor in efficitur nec, sagittis a nisl. Maecenas ut leo nec augue
maximus dictum. Donec faucibus aliquet lacus, laoreet molestie dui
varius in. Curabitur eleifend malesuada diam, at pharetra nisi finibus
eu. Cras finibus tincidunt nisi ac rutrum. Suspendisse dignissim, arcu
et varius cursus, est lectus interdum ligula, ac tempor eros velit in
massa.
EOF

cat >mergetool.txt <<EOF
LINE 1
LINE 2
LINE 3
LINE 4: This will not be changed by anyone
EOF

echo "Hello, original." >hello.txt
echo "Goodbye, original." >goodbye.txt

# Be careful not to destroy an existing repo
if [ -d .git ]; then
  echo ".git directory found.  aborting..."
  exit 1
fi

git init

# Add them to the index (stage them for commit)
# Note that we don't add README
git add lorum.txt
git add mergetool.txt

# Commit them
git commit -m "Initial Commit"

# A few more files
git add hello.txt
git add goodbye.txt
git commit -m "A few more files, hello & goodbye"

# In a new branch "feature_branch"

git checkout -b feature_branch

# Make some changes...
sed -i '' "s/LINE 2/LINE 2: Branch feature_branch changed this./" mergetool.txt
sed -i '' "s/LINE 3/LINE 3: Branch feature_branch changed this too./" mergetool.txt
git commit -a -m "Change branch feature_branch, mergetool"

# Additional commit to make things a little more interesting
sed -i '' "s/original/feature_branch, hello!/" hello.txt
sed -i '' "s/original/feature_branch, goodbye!/" goodbye.txt
git commit -a -m "Change feature_branch, hi/bye"

# Patch lorum.txt in the feature_branch
# Create patches on the fly so we never commit them
# Date: Thu, 14 Oct 2021 17:38:15 -0700
cat >lorum_feature.patch <<EOF
From 03c391eb248b89a1c04909d4d1f74bb7d30207a7 Mon Sep 17 00:00:00 2001
From: Ed Cardinal <edcgit@mindthump.com>
Subject: [PATCH] Edit lorum on the feature_branch.

---
 lorum.txt | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/lorum.txt b/lorum.txt
index e2ab20e..a455a31 100644
--- a/lorum.txt
+++ b/lorum.txt
@@ -3,18 +3,16 @@ fringilla. Ut finibus vel nunc ut porta. Phasellus feugiat mollis
 turpis, vel pretium augue porttitor vitae. Curabitur ligula quam,
 pellentesque sit amet nisi ut, rhoncus vehicula lacus. Vivamus ornare
 magna ut leo malesuada, in iaculis nisl dignissim. Praesent at maximus
-purus. Sed sed urna in dolor accumsan lacinia. Suspendisse egestas
 eget risus a fermentum. Sed faucibus justo dolor, nec volutpat ligula
-congue vel. Mauris velit nisl, ultrices ac imperdiet nec, luctus sed
-sem. Curabitur lacinia ultricies lorem ut placerat. Proin turpis diam,
-convallis eu condimentum nec, pretium non sem. Nulla facilisi.
+sem. Curabitur lacinia ultricies lorem ut placerat. Proin turpis diam.
 
 Morbi finibus consequat vulputate. Duis in erat quis velit vehicula
 vehicula et sed diam. Aliquam ligula nulla, faucibus eu auctor et,
-facilisis vel magna. Mauris sit amet nisi vel erat facilisis vulputate.
+convallis eu condimentum nec, pretium non sem. Nulla facilisi.
 Pellentesque semper sem id elit commodo, at luctus nulla porta. Sed
 sollicitudin libero quis sem elementum lacinia. Pellentesque neque odio,
 auctor in efficitur nec, sagittis a nisl. Maecenas ut leo nec augue
+congue vel. Mauris velit nisl, ultrices ac imperdiet nec, luctus sed
 maximus dictum. Donec faucibus aliquet lacus, laoreet molestie dui
 varius in. Curabitur eleifend malesuada diam, at pharetra nisi finibus
 eu. Cras finibus tincidunt nisi ac rutrum. Suspendisse dignissim, arcu
-- 
2.33.0
EOF

git am lorum_feature.patch
rm lorum_feature.patch

# A commit to move around during a rebase?
sed -i '' "s/feature_branch/crazy_branch/" hello.txt
sed -i '' "s/feature_branch/insane_branch/" goodbye.txt
git commit -a -m "A change to feature_branch that really belongs with the others."

# Back in main...
git checkout main

# Make some conflicting changes...
sed -i '' 's/LINE 1/LINE 1: Branch main changed this./' mergetool.txt
sed -i '' 's/LINE 3/LINE 3: Branch main changed this as well./' mergetool.txt
sed -i '' "s/original/main arriving/" hello.txt
sed -i '' "s/original/main leaving/" goodbye.txt

# Commit the changes
git commit -a -m "Change main"


# Apply the main lorum patch
# Date: Thu, 14 Oct 2021 17:28:13 -0700
cat >lorum_main.patch <<EOF
From 796bb46a70e7f2886cebcb783c284a0a1955dbda Mon Sep 17 00:00:00 2001
From: Ed Cardinal <edcgit@mindthump.com>
Subject: [PATCH] Edited lorum text.

---
 lorum.txt | 13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

diff --git a/lorum.txt b/lorum.txt
index e2ab20e..5a3fda6 100644
--- a/lorum.txt
+++ b/lorum.txt
@@ -1,20 +1,11 @@
 Fusce interdum volutpat sodales. Etiam pulvinar turpis nec consectetur
 fringilla. Ut finibus vel nunc ut porta. Phasellus feugiat mollis
-turpis, vel pretium augue porttitor vitae. Curabitur ligula quam,
-pellentesque sit amet nisi ut, rhoncus vehicula lacus. Vivamus ornare
-magna ut leo malesuada, in iaculis nisl dignissim. Praesent at maximus
-purus. Sed sed urna in dolor accumsan lacinia. Suspendisse egestas
-eget risus a fermentum. Sed faucibus justo dolor, nec volutpat ligula
-congue vel. Mauris velit nisl, ultrices ac imperdiet nec, luctus sed
-sem. Curabitur lacinia ultricies lorem ut placerat. Proin turpis diam,
+turpis, vel pretium augue porttitor vitae. Curabitur ligula quam.
+Curabitur lacinia ultricies lorem ut placerat. Proin turpis diam,
 convallis eu condimentum nec, pretium non sem. Nulla facilisi.
 
 Morbi finibus consequat vulputate. Duis in erat quis velit vehicula
 vehicula et sed diam. Aliquam ligula nulla, faucibus eu auctor et,
-facilisis vel magna. Mauris sit amet nisi vel erat facilisis vulputate.
-Pellentesque semper sem id elit commodo, at luctus nulla porta. Sed
-sollicitudin libero quis sem elementum lacinia. Pellentesque neque odio,
-auctor in efficitur nec, sagittis a nisl. Maecenas ut leo nec augue
 maximus dictum. Donec faucibus aliquet lacus, laoreet molestie dui
 varius in. Curabitur eleifend malesuada diam, at pharetra nisi finibus
 eu. Cras finibus tincidunt nisi ac rutrum. Suspendisse dignissim, arcu
-- 
2.33.0
EOF

git am lorum_main.patch
rm -f lorum_main.patch
