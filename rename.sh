#!/bin/bash

ls | while read src
do
    dest="$(echo "$src" | tr ' ' _ | tr "[:upper:]" "[:lower:]")"
    if [ "$src" != "$dest" ]; then
#	if [ -f "$dest" ]; then
#            ls -l "$src" "$dest"
#            echo "Can't rename \"$src\", \"$dest\" already exist"
#	else
            echo "$src" "->" "$dest"
            mv "$src" "$dest"
#	fi
    fi
done

exit 0

for f in *; do
    file=$(echo $f | tr A-Z a-z | tr ' ' _)
    [ ! -f $file ] && mv "$f" $file
done

exit 0

IFS=$'\n'
for f in `find .`; do
    file=$(echo $f | tr [:blank:] '_')
    [ -e $f ] && [ ! -e $file ] && mv "$f" $file
done
unset IFS

exit 0

echo "Removing unwanted characters in directorynames..."
find -name "* *" -type d | rename 's/ /_/g'
find -name "*[*" -type d | rename 's/[/_/g'
find -name "*]*" -type d | rename 's/]/_/g'
find -name "*(*" -type d | rename 's/(/_/g'
find -name "*)*" -type d | rename 's/)/_/g'
find -name "*&*" -type d | rename 's/&/_/g'


echo "Removing unwanted characters in filenames..."
find -name "* *" -type f | rename 's/ /_/g'
find -name "*[*" -type f | rename 's/[/_/g'
find -name "*]*" -type f | rename 's/]/_/g'
find -name "*(*" -type f | rename 's/(/_/g'
find -name "*)*" -type f | rename 's/)/_/g'
find -name "*&*" -type f | rename 's/&/_/g'
