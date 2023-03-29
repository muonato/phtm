#!/bin/bash
# Picture HTML Gallery
# muonato/phtm @ GitHub (27-JAN-2022)
#
# Creates a printer-friendly picture gallery HTML by reading
# picture filenames in CSV file. ImageMagick is required for
# picture verification (identify) and orientation (convert).
#
# Arguments:
#       $1 - path to CSV file
#       $2 - delimiter character used in CSV file, default ','
#       $3 - filename column number in CSV file, default '0'
#       $4 - path to picture gallery folder, default './'
#       $5 - output filename, default 'index.html'
#
# Examples:
#       $ phtml.sh photos.csv
#       $ phtml.sh images.csv , 1 ./images images.html
#
HELP="Usage: phtml <CSV FILE> [DELIM] [COLUMN] [FOLDER] [HTM FILE]"
HOME=$(dirname $0)

fn_orientation() {
    # Outputs picture orientation by using 'convert' to detect
    #
    # Parameters:
    #       $1 - path to picture

    local pic=$1
    aspect=$(convert "$pic" -format "%[fx:w/h]" info:)

    if [[ $aspect > 1 ]]; then
        echo "landscape"
    else
        echo "portrait"
    fi
}

fn_print_div() {
    # Prints out HTML <div> section associated with
    # picture orientation
    #
    # Parameters:
    #       $1 - path to picture
    #       $2 - landscape or portrait orientation
    #       $3 - row number in the CSV file

    local path=$1
    local ornt=$2
    local rnum=$3

    cat <<- _EOF_
        <div class="$ornt">
            <div class="label">Picture #$rnum</div>
            <img src="$path">
        </div>
_EOF_
}

# BEGIN __main__

# Verify package ImageMagick
if ! identify > /dev/null 2> /dev/null; then
    echo "ImageMagick missing, exiting"
    exit
fi

# Read commandline arguments
read -r ARG1 ARG2 ARG3 ARG4 ARG5 <<< "$1 $2 $3 $4 $5"

# Prompt for args when none
if [[ -z $ARG1 ]]; then
    read -p "Input CSV file: " ARG1
    read -p "Delimiter char: " ARG2
    read -p "Image name col: " ARG3
    read -p "Path to images: " ARG4
    read -p "Output to file: " ARG5
fi

# Set var defaults
CSV=${ARG1:?$HELP}
CHR=${ARG2:-","}
COL=${ARG3:-"0"}
SRC=${ARG4:-"./"}
HTM=${ARG5:-"./index.html"}

# Test CSV file exists
if ! test -f "$CSV"; then
    echo "Missing CSV '$CSV'"
    exit
fi

# Add fw-slash to path
if [[ -d $SRC ]]; then
    SRC="${SRC%/}/"
fi

# Link file to stdin
exec 6<&0
exec < $CSV

# Set delimiter
IFS=$CHR

echo -n "Reading header, "
read header
read -ra arr_head <<< "$header"

cols=${#arr_head[@]}
echo "columns (0 - $((cols - 1))) found"

# Verify column num
if [[ $((cols - 1)) -lt $COL ]]; then
    echo "Invalid column or CSV format, exiting"
    exit
fi

# Use template in script folder
cat $HOME/template.html > $HTM

echo "Reading filenames in column ($COL) '${arr_head[$COL]}'"
row=0
while read line; do
    ((row++))
    read -ra arr_csv <<< "$line"

    pic=$SRC${arr_csv[$COL]}

    # Verify file as picture
    if identify "$pic" > /dev/null 2> /dev/null; then
        echo "Writing $row: '$pic'"
        fn_print_div $pic $(fn_orientation $pic) $row >> $HTM
    else
        echo "Skipped $row: '$pic'"
    fi
done

# Close CSV file
exec 0<&6 6<&-

# Finish with footer
cat <<- _EOF_ >> $HTM
    </body>
</html>
_EOF_
