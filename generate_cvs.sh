#!/bin/bash

# inspired from: https://mywiki.wooledge.org/BashFAQ/035
# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} [-hv] [-t OUTPUT_FORMAT] [-o OUTPUT_DIR] [-d INPUT_DIR] [TEX_FILENAME_PATTERN]...
Convert moderncv latex file to the desired format and write the result to standard output.

      -h|--help                         display help.
      -v|--verbose                      verbose.
      -t|--outputformat OUTFILE_FORMAT  output format is either pdf, dvi or ps (default=pdf).
      -d|--inputdirectory DIR           use input file in DIR.
      -o|--outputdirectory DIR          write output files in DIR.
      --                                end of optional argument.
EOF
}

die() {
    printf '%s\n' "$1" >&2
    exit 1
}

# Initialize all the option variables.
# This ensures we are not contaminated by variables from the environment.
# file=
output_format="pdf"
output_directory=$(pwd)
input_directory=$(pwd)
verbose=0

while :; do
    case $1 in
        -h|-\?|--help)
            show_help
            exit
            ;;
        -t|--outputformat)
            if [ "$2" ]; then
                output_format=$2
            else
                die 'ERROR: "--outputformat" requires a non-empty option argument.'
            fi

            if [[ $output_format != "pdf" && $output_format != "dvi" && $output_format != "ps" ]]; then
                die 'ERROR: "--outputformat" requires a value of [dvi|pdf|ps].'
            fi
            ;;
        -d|--inputdirectory)
            if [ "$2" ] && [ -d "$DIRECTORY" ]; then
                input_directory=$2
            else
                die 'ERROR: "--inputformat" requires a non-empty option argument and an existing directory.'
            fi
            ;;
        -o|--outputdirectory)
            if [ "$2" ] && [ -d "$DIRECTORY" ]; then
                output_directory=$2
            else
                die 'ERROR: "--outputdirectory" requires a non-empty option argument and an existing directory.'
            fi
            ;;
        -v|--verbose)
            verbose=$((verbose + 1))  # Each -v adds 1 to verbosity. 
            ;;
        --)              # End of all options.
            shift
            break
            ;;
        -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
            ;;
        *) break         # Default case: No more options, so break out of the loop.
    esac
    shift
done


# arg 1: tex file
if [[ -n $1 ]]; then
    tex_filename_pattern=$1
    # cp $tex_filepath $output_directory
    # tex_file="$(basename -- $tex_filepath)"
    for tfile in "$input_directory/$tex_filename_pattern"*.tex; do
        echo "- file : $tfile"
        echo "sudo ./generate_pdf.sh  $tfile -t $output_format -o $output_directory"
        sudo ./generate_pdf.sh $tfile -t $output_format -o $output_directory
    done
else
    die 'ERROR: "TEX_FILENAME_PATTERN" is required.'
fi