#! /bin/bash

usage="
Usage: 
ripinclude [-options]
    -h                         view this help
ripinclude filename            filename [do NOT include extension, .tex]
ripinclude filename [subfiles] subfiles are optional subfiles for \includeonly{...}
                               If subfiles arg ommitted, all includes are ripped

    Example:
    \$ ripinclude.sh main

    Every file that is included in a LaTeX document gets turned into its own PDF and put in a PDFs subdirectory.
    MAKE SURE that all \"includeonly\" commands are commented out!

    Changelog:
    Rev01: 29-Jun-16
    Rev01: 30-Jun-16 [subfile option]
    Rev02: 13-Nov-24 [svn changeded to git, and works with included sub directories, e.g. admin/dmp ]
    Noah J. Cowan
    "


# Parse options
while getopts "hg" opt; do
    case $opt in
        h)
            echo "$usage"
	    ;;
        
        g)
            echo "adding git version to directory name"
            VER=-v$(git log --oneline | wc -l | xargs)
	    ;;
        \?) # Handle unknown options
            echo "$usage"
            exit 1
            ;;
	
        :)
            exit 1
            ;;
    esac
done


shift "$((OPTIND - 1))"



if [[  $#<1 ]] ; then
    echo Exiting gracefully
    exit 1
fi


if [[  ! -f ${!#}.tex ]] ; then
   echo "Invalid filename ${!#}.tex"
   exit 1
fi



# Grab SVN version to make directory. DEPRICATED
# DIRNAME=PDFs-v$(svnversion) 

# NEW 13/NOV/2024
# $VER is empty unless the -g option is called
DIRNAME=PDFs$VER



if [ ! -d $DIRNAME ]; then
   mkdir $DIRNAME
fi


# Crucial: first run latexmk once when ALL files are included (no includeonly)
echo =============================================================================
echo  Preprocessing with latexmk 
echo =============================================================================
cp $1.tex tmpfile.tex
latexmk -quiet -pdf tmpfile.tex


if [[ -f $2.tex ]] ; then
   INCLUDELIST=${@:2}
else
   INCLUDELIST=$(sed -n -e '/^\\include{/p' $1.tex | cut -d"{" -f2 | cut -d"}" -f1)
fi

echo
echo
echo =============================================================================
echo Rippping pdfs for $INCLUDELIST
echo =============================================================================
echo
echo


for FILE in $INCLUDELIST
do
   echo 
   echo
   echo =============================================================================
   echo  Generating $DIRNAME/$FILE.pdf....
   echo =============================================================================
   echo
   echo

   #BONEYARD:
    #sed -e 's/\\\\begin{document}/\\\\includeonly{$FILE}\n\\\\begin{document}/g' $1.tex > tmpfile.tex
   #sed -e "s/\\begin{document}/\\includeonly{$FILE}\n\\\begin{document}/g" "$1.tex" > tmpfile.tex

   # Added Nov 13, 2024 - this was a pain!
   # This makes it work if you have \include{admin/facilities}, i.e. a subdirectory.
   sed -e "s|\\begin{document}|\\includeonly{$FILE}\n\\\begin{document}|g" "$1.tex" > tmpfile.tex
   latexmk -quiet -pdf tmpfile.tex
   mv tmpfile.pdf $DIRNAME/${FILE/\//\_}.pdf
   
done
rm -f tmpfile.*


