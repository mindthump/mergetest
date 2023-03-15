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

