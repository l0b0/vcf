#!/usr/bin/env bash
#
# NAME
#        vcf.sh - vCard find
#
# SYNOPSIS
#        vcf.sh [OPTION]... [--] FILE...
#
# DESCRIPTION
#        Prints the matching vCards. This works on the basis of BEGIN:VCARD
#        through END:VCARD blocks, so it will print the matching vCards rather
#        than the whole file if a match is found.
#
# OPTIONS
#        -h, --help
#               Display this help text.
#
#        -v, --verbose
#               Verbose output
#
# EXAMPLE
#        ./vcf.sh jane contacts.vcf
#               Print all vCards with "jane" (case-insensitively) in a property
#               value.
#
# BUGS
#        https://github.com/l0b0/vcf/issues
#
# COPYRIGHT AND LICENSE
#        Copyright (C) 2012 Victor Engmark
#
#        This program is free software: you can redistribute it and/or modify
#        it under the terms of the GNU General Public License as published by
#        the Free Software Foundation, either version 3 of the License, or
#        (at your option) any later version.
#
#        This program is distributed in the hope that it will be useful,
#        but WITHOUT ANY WARRANTY; without even the implied warranty of
#        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#        GNU General Public License for more details.
#
#        You should have received a copy of the GNU General Public License
#        along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
################################################################################

set -o errexit -o noclobber -o nounset -o pipefail

PATH="/usr/bin:/bin"

includes="$(dirname -- "$0")"/shell-includes
. "$includes"/error.sh
. "$includes"/usage.sh
. "$includes"/variables.sh
. "$includes"/verbose_echo.sh
unset includes

# Custom errors

# Process parameters
params="$(getopt --options h,v --longoptions help,verbose --name "$script" -- "$@")" || usage $ex_usage

eval set -- "$params"
unset params

grep_options=(--ignore-case)

while true
do
    case $1 in
        -h|--help)
            usage
            ;;
        -v|--verbose)
            verbose=--verbose
            shift
            ;;
        --)
            shift
            param=1
            ;;
        *)
            if [ -e "$1" ]
            then
                verbose_echo "Got a file: $1"
                break
            else
                verbose_echo "Got a search term: $1"
                grep_options+=(-e "$1")
            fi
            shift
            ;;
    esac
done

verbose_echo "Running $script at $(date)."

# Unrar files
cd -- "$(mktemp -d)"
cat "${@--}" | csplit --elide-empty-files --quiet - $'/^BEGIN:VCARD\r$/' {*}
for file in *
do
    verbose_echo "Processing file: $file"

    if grep "${grep_options[@]}" -- "$file"
    then
        cat -- "$file"
    fi
done

verbose_echo "Cleaning up."
rm "xx"*
rmdir -- "$PWD"

# End
verbose_echo "${script} completed at $(date)."
exit $ex_ok
