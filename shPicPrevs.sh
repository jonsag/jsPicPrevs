#!/bin/bash

##############################################################################
# created by Jon Sagebrand
# 110505
##############################################################################

# location of configuration file
# this must correlate to line in configurationfile at install time
CONFFILEDIR="/etc/jspicprevs"

# version of this script
VERSION="0.1"

# checking for config and reading it
if [ -e $CONFFILEDIR/jspicprevs.conf ]; then
    source $CONFFILEDIR/jspicprevs.conf
else
    echo "###################################################################"
    echo "You do not have a config file at $CONFFILEDIR/jspicprevs.conf."
    echo "Make sure it's in it's right place, and the try again!"
    echo "Exiting..."
    echo "###################################################################"
    exit 1
fi

# starting up some more variables
TIME=$(date +%y%m%d-%H:%M:%S)
LOGFILE=$LOGDIR/$LOGNAME-$TIME.log
THISDIR=$(dirname $0)

# check for temporary directory
if [ -d $TEMPDIR ]; then
    echo "##########################################################################"
    echo -e $GREEN"Temporary directory $TEMPDIR exists" $RESET
    echo -e $YELLOW"Cleaning out old temp files..." $RESET
    rm $TEMPDIR/jspicprevs*
    echo "##########################################################################"
else
    echo "##########################################################################"
    echo -e $RED"Temporary directory $TEMPDIR does not exist" $RESET
    echo -e $YELLOW"Creating it..." $RESET
    mkdir -p $TEMPDIR
    echo "##########################################################################"
fi
echo

# check if logdirectory exists
if [ -d $LOGDIR ]; then
    echo "###################################################################"
    echo -e $GREEN"Logdirectory exists" $RESET
    echo "###################################################################"
else
    echo "###################################################################"
    echo -e $RED"Logdirectory doesn't exist." $RESET
    echo -e $YELLOW"Creating it" $RESET
    echo "###################################################################"
    mkdir -p $LOGDIR
fi
echo

# creating symbolic link
touch $LOGFILE
if [ $MAKELINK = 1 ]; then
    ln -sf $LOGFILE $LOGDIR/$LOGPREFIX-latest.log
    echo "###################################################################"
    echo -e $YELLOW"Symbolic link created," $RESET
    echo -e $YELLOW"pointing to $LOGFILE" $RESET
    echo -e $YELLOW"Location is $LOGDIR/$LOGPREFIX-latest.log" $RESET
    echo "###################################################################"
else
    echo "###################################################################"
    echo -e $YELLOW"No symbolic link created" $RESET
    echo "###################################################################"
fi
echo

echo

if [ "$COPY" == "true" ]; then
    if [ -d "$SAMPLESDIR" ]; then
	echo "The directory $SAMPLESDIR already exists"
    else
	echo "Creating the directory $SAMPLESDIR"
	mkdir $SAMPLESDIR
    fi
fi

echo

if [ -d "$CONTACTSDIR" ]; then
    echo "The directory $CONTACTSDIR already exists"
else
    echo "Creating the directory $CONTACTSDIR"
    mkdir $CONTACTSDIR
fi

echo

if [ "$COPY" == "true" ]; then
    echo "You have chosen to copy samples to $SAMPLESDIR"
else
    echo "You have chosen not to make any copies"
fi

echo

# remove spaces in filenames
$INSTALLDIR/$JSPICPREVSDIR/rename.sh


let NOPICS=($WIDTH*$HEIGTH)
echo "Will create a $WIDTH by $HEIGTH grid, which will make a total of $NOPICS frames"
echo

let LOOPS=($NOPICS-1)

NODIRS=`find . -maxdepth 1 -type d | wc -l`
echo "There are $NODIRS directories to process"
echo

# starting the clock
STARTUPTIME=$(date +%s)

for DIR in $( ls ) ]; do
    if [ -d "$DIR" ]; then

	if [ "$DIR" == "$SAMPLESDIR" ] || [ "$DIR" == "$CONTACTSDIR" ] || [ -s "$CONTACTSDIR/$DIR.jpg" ]; then
	    if [ -s "$CONTACTSDIR/$DIR.jpg" ]; then
		echo "The file $CONTACTSDIR/$DIR.jpg already exists"
	    fi
	    echo "Will not process the directory $DIR"
	    echo
	else

	    NO=`find ./$DIR -iname *.jp*g | wc -l`
	    echo "$DIR is a directory and contains $NO jpeg-files"
	    echo "--------------------------------------------------------------"

	    FIRSTFILE=$(ls $DIR | head -1)
	    if [ "$COPY" == "true" ]; then
		cp -f $DIR/$FIRSTFILE $SAMPLESDIR/$DIR-$FIRSTFILE
		echo "Pic 1 - File no 1: $DIR/$FIRSTFILE copied to $SAMPLESDIR/$DIR-$FIRSTFILE"
	    else
		echo "Pic 1 - File no 1 is $DIR/$FIRSTFILE"
	    fi

	    PICS="$DIR/$FIRSTFILE"

	    let INCREMENTS=($NO/$NOPICS)
	    STEP=$INCREMENTS

	    for NUMBER in $(eval echo {2..$LOOPS})
	    do
		PICFILE=$(ls $DIR | head -n $STEP | tail -1)
		if [ "$COPY" == "true" ]; then
		    cp -f $DIR/$PICFILE $SAMPLESDIR/$PICFILE
		    echo "Pic $NUMBER - File no $STEP: $DIR/$PICFILE copied to $SAMPLESDIR/$DIR-$SPICFILE"
		else
		    echo "Pic $NUMBER - File no $STEP is $DIR/$PICFILE"
		fi

		PICS="$PICS $DIR/$PICFILE"
		let STEP=($STEP+$INCREMENTS)
	    done

	    LASTFILE=$(ls $DIR | tail -1)
	    if [ "$COPY" == "true" ]; then
		cp -f $DIR/$LASTFILE $SAMPLESDIR/$DIR-$LASTFILE
		echo "Pic $NOPICS - File no $NO: $DIR/$LASTFILE copied to $SAMPLESDIR/$DIR-$LASTFILE"
	    else
		echo "Pic $NOPICS - File no $NO is $DIR/$LASTFILE"
	    fi

	    PICS="$PICS $DIR/$LASTFILE"

	    echo

	    echo "Creating contactsheet from these images to $CONTACTSDIR/$DIR.jpg"
	    montage -label $DIR/%f -quality $QUALITY $FRAME -tile ${WIDTH}x${HEIGTH} -geometry ${SIZE}+${SPACINGH}+${SPACINGV} $PICS $CONTACTSDIR/$DIR.jpg
#	    echo "Resizing image to fit $SIZE"
#	    convert $CONTACTSDIR/$DIR.jpg -resize $SIZE $CONTACTSDIR/$DIR.jpg
	    echo
       fi

    fi
done

echo "Processed $NODIRS directories"
echo

# calculating the time it took
ENDTIME=$(date +%s)
DIFFTIME=$(( $ENDTIME - $STARTUPTIME ))
echo "##########################################################################"
echo -e $YELLOW"Whole operation took $DIFFTIME seconds" $RESET
echo "Whole operation took $DIFFTIME seconds" >> $LOGFILE
echo "##########################################################################"
