#!/bin/bash
 
read -p "Enter a filename: " fname
invalid_chars=',.!@#$%^&*()+=?{}[]|~ \t'
 
remain=$( echo "${fname}" | tr -d "${invalid_chars}" )
 
if [ "$remain" != "$fname" ]; then
    echo "Bad characters"
fi
