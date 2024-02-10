#!/bin/bash

# Variable to show what will be written out
display_on=word

# Function that prints out user help
function Usage() {
cat << EOF
The linguist.sh script prints out words found in the file,
with the number of their occurrences, starting with the most frequent.
If no text file is specified for reading, the program reads
from standard input until the user presses Esc.
Usage: $0 [-c] [-n] [-h] [file]
-c prints the occurring letters, instead of the words
-n prints no more than the specified number
-h displays help and terminates the program
EOF
}

# Function that prints out statistics of occurrences of words or letters
function Writing_out() {
if [ "$display_on" == "word" ]; then
    echo "Words with the number of their occurrences:"
    echo "$file" | sed 's/.*/\L&/g' | sed 's/[^[:alpha:]^[:digit:]]/\n/g' \
    | sed '/./!d' | sort | uniq -c | sort -nr
else
    echo "Letters with their number of occurrences:"
    echo "$file" | sed 's/.*/\L&/g' | sed 's/[^[:alpha:]^[:digit:]]/\n/g' \
    | sed '/./!d' | grep -o . | sort | uniq -c | sort -nr
fi
}

# Data parsing using getopts
while getopts ":cn:h" argument; do
    case $argument in
        c) 
            display_on=letter;;
        n) 
            count=$OPTARG;;
        h) 
            help=1;;
        \?)
            echo "Invalid option: -$OPTARG"
            exit 13;;
        :)
            echo "Option -$OPTARG requires the argument"
            exit 13;;
    esac
done

# -h parameter indicates display help and terminate the program
if [ $help ]; then
    Usage 
    exit 0
fi

file=${@:$OPTIND} # File name is an argument that has been

# If no file is specified then it reads from standard input
if [ ! "$file" ]; then
    # Press Esc to finish reading the file
    read -p "Write your own text:" -d $'\e' file
# If there is no file, that means an online source is provided
elif [ ! -f "$file" ]; then
    file=$(echo "$file" | sed 's/.*/\L&/g')
    if [[ "$file" == http* ]]; then
        file=$(wget -q -O - "$file")
    else
        echo "No website address was provided!"
        exit 13
    fi

    if [ ! "$file" ]; then # The website was not read
        echo "The wrong website address was given!"
        exit 14
    fi
else
    file=$(cat "$file") # File variable stores the text
fi

# Write out no more than the specified number of words
if [ "$count" ]; then
    count=$(($count + 1)) # Add display to count
    Writing_out | head -$count | less
else
    Writing_out | less
fi
