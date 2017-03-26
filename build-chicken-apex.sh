#!/bin/bash

set -e

# directory where compiled files will be written
# this could/should be added to .gitignore
outdir="apex-build"

# file containing config for this script
# must exist and contain an 'eggs=' line
# for example:
#
# eggs="medea redis-client"
#
config="chicken-apex.txt"

dir=$(pwd)
name="${dir##*/}"

# read in config
if [ ! -f $config ]; then
  echo "chicken-apex.txt not found in dir: $dir"
  exit 1
fi

source $config

# build program
csc -deploy -o "$outdir" "$name.scm"

# build required eggs
cd "$outdir"
array=(${eggs// / })
for egg in "${array[@]}"
do
  if [ ! -f "$egg.so" ]; then
    echo "building egg: $egg"
    chicken-install -deploy -p $(pwd) $egg
  fi
done
cd ..

# write main script which apex's shim will invoke
# this runs our compiled chicken program
cat <<EOF > main
#!/bin/sh
set -e
cd $outdir && ./$outdir
EOF
chmod 755 main
