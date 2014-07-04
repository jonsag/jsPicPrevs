#!/bin/bash

THISDIR=$(dirname $0)

source $THISDIR/jspicprevs.conf

echo

if [ $(whoami) = "root" ]; then
  echo "You are root, and can run this script"
  echo
else
  echo "You are not root, but we will check if there is another way..."
  EXIT="yes"
fi

echo

if [ $EXIT = "yes" ]; then
    SYSTEM=`cat /proc/version | gawk -F_ '{ print $1 }'`
    if [ $SYSTEM == "CYGWIN" ]; then
        echo "You are lucky, you are on a CYGWIN system, so we will go right ahead."
        EXIT="no"
    fi
fi

if [ $EXIT = "yes" ]; then
    echo "Sorry, no luck"
    echo "Exiting..."
    exit 0
fi

echo

echo "Uninstalling..."
echo

if [ -h $INSTALLDIR/jspicprevs ]; then
   echo "Removing link"
   rm -f $INSTALLDIR/jspicprevs
else
    echo "Link does not exist"
fi

if [ -e $INSTALLDIR/$JSPICPREVSDIR/jspicprevs.sh ]; then
    echo "Removing scripts"
    rm -f $INSTALLDIR/$JSPICPREVSDIR/*.sh
else
    echo "Script does not exist"
fi

if [ -d $INSTALLDIR/$JSPICPREVSDIR ]; then
    echo "Removing directory"
    rmdir --ignore-fail-on-non-empty $INSTALLDIR/$JSPICPREVSDIR
else
    echo "Directory does not exist"
fi

echo

if [ -h $INSTALLDIR/jspicprevs ] || [ -e $INSTALLDIR/$JSPICPREVSDIR/jspicprevs.sh ] || [ -d $INSTALLDIR/$JSPICPREVSDIR ]; then
    echo "Everything could not be uninstalled"
    echo "Exiting"
    exit 1
else
    echo "Uninstall successful"
fi
