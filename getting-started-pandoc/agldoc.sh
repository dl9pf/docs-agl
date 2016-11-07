#!/bin/bash

### default options
MACHINE=all
DOCTYPE=html
HELP=0

TOPDIR=`dirname $0`


function exportdoc {
        FILEDOC="$TOPDIR/machines/$1.md"
        if [ ! -e $FILEDOC ] ; then
                echo "Document for $1 not found."
                exit 1
        fi
        FILETROUBLE="$TOPDIR/footers/$1-footer.md"
        if [ ! -e $FILETROUBLE ] ; then
                FILETROUBLE=""
        fi
        FILEEXPORT="$DOCTYPE/$1.$DOCTYPE"
        pandoc $TOPDIR/source-code.md $FILEDOC $TOPDIR/troubleshooting.md $FILETROUBLE $FILECONFIG -o $FILEEXPORT
        echo "Document exported to $DIREXPORT/$FILEEXPORT"
}

while [[ $# -gt 0 ]]
do
	case $1 in
		-m|--machine)  MACHINE=$2; shift;;
		-d|--document) DOCTYPE=$2; shift;;
		-h|--help)     HELP=1;;
		*) ;;
	esac
	shift
done

if [ 1 == $HELP ] ; then
	printf "Usage: . agldoc.sh [options]\n"
	printf "Options:\n"
	printf "\t-m|--machine <machine>\n\t\twhat machine to use\n\t\tdefault: 'all'\n"
	printf "\t-d|--document <pdf|html|dokuwiki>\n\t\twhat document format to use\n\t\tdefault: 'html'\n"
	printf "\t-h|--help\n\t\tget some help\n"
	exit 0
fi

# handle alias
case $MACHINE in
	raspberrypi2|raspberrypi3) MACHINE=raspberrypi;;
	qemux86-64|qemux86) MACHINE=qemu;;
esac

DIRROOT=$(dirname "$0")
cd $DIRROOT
mkdir -p ../export
cp -R ../templates ../export
cp -R ../images ../export
cd ../export
DIREXPORT=`pwd`

if [ "pdf" == $DOCTYPE ] ; then
	FILECONFIG="-N --template=templates/pdf/agl.tex --variable mainfont=\"Arial\" --variable sansfont=\"Arial\" --variable monofont=\"Arial\" --variable fontsize=12pt --latex-engine=xelatex --toc"
elif [ "dokuwiki" == $DOCTYPE ] ; then
	FILECONFIG="-t dokuwiki"
else
	DOCTYPE="html"
	FILECONFIG="-f markdown -t html -s -S --toc -c ../templates/html/pandoc.css -B templates/html/header.html -A templates/html/footer.html"
fi

mkdir -p "$DOCTYPE"

if [ "all" == $MACHINE ] ; then
	echo "Exporting documentation for all machines."
	for TARGET in $TOPDIR/machines/*.md
	do
		TARGET=$(basename $TARGET)
		TARGET=${TARGET%.*}
		exportdoc $TARGET
	done
else
	exportdoc $MACHINE
fi
