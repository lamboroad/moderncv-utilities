#!/bin/bash
# inspired from: https://mywiki.wooledge.org/BashFAQ/035

# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} [-hv] [-t OUTPUT_FORMAT] [-o OUTPUT_DIR] [TEX_FILEPATH]...
Convert moderncv latex file to the desired format and write the result to standard output.

      -h|--help                         display help.
      -v|--verbose                      verbose.
      -t|--outputformat OUTFILE_FORMAT  output format is either pdf, dvi or ps (default=pdf).
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
    tex_filepath=$1
    cp $tex_filepath $output_directory
    tex_file="$(basename -- $tex_filepath)"
else
    die 'ERROR: "TEX_FILEPATH" is required.'
fi

cmd_options="-$output_format"
if [ $verbose -eq 0 ]; then
    cmd_options="$cmd_options -quiet"
fi

# enable extglob which include the negation for the rm command
shopt -s extglob
# exlude tex file to the cleanup
rm --force -- ${tex_filepath%.tex}.!(tex)

# build docker image
# sudo docker build --tag cv_builder .
# run docker image to convert latex file to pdf
# sudo docker run --user="$(id -u):$(id -g)" -i -v "$(pwd):/tmp" latex latexmk -f $cmd_options -outdir=/tmp /tmp/$tex_filename.tex
# echo "sudo docker run --user="$(id -u):$(id -g)" -i -v "$output_directory:/tmp" cv_builder miktex-pdflatex /tmp/$tex_file --quiet --output-directory="/tmp" --include-directory="/tmp" --output-format="$output_format""
sudo docker run --user="$(id -u):$(id -g)" -i -v "$output_directory:/tmp" cv_builder miktex-pdflatex /tmp/$tex_file --quiet --output-directory="/tmp" --include-directory="/tmp" --output-format="$output_format"
# cleanup again but keep generated pdf
rm --force -- ${tex_filepath%.tex}.!(tex|pdf|dvi|ps|log)