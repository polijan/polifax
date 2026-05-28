#!/bin/sh

#-------------------------------------------------------------------------------
# Functions specific to this project
# dealing with KBITX files or with the Polifax or Fairfax fonts
#-------------------------------------------------------------------------------

# Usage: kbitx_non_pua KBITX_FILE
# Print every line definining a *non-PUA* glyph in the given kbitx file
kbitx_non_pua() {
   awk -v FS='"' '
       /^<g u="/ {
          code=$2

          # Assume glyphs are sorted in ascending order, thus
          # if glyph is in Plane 16+ (starting at U+F0000), we are done.
          if (code >= 983040) exit

          # Print line if glyph is not in the PUA of the BMP (U+E000..U+F88FF)
          if (code < 57344 || code > 63743) print
       }
       ' "$1"
}

# Usage: homoglyphs CODEPOINT
# For the character with the given *decimal* codepoint in *Polifax*,
# print the list of all other non-PUA characters from *Fairfax* which
# have the same visual representation.
fairfax_homoglyphs() {
   [ $# -eq 1 ] || return 2
   case $1 in ''|*[!0-9]*) return 2;; esac

   # If the character is in Polifax, gets its glyph declaration, which will act
   # as a pattern identifying the visual for the given code.
   visual=$(grep "^<g u=\"$1\" " "$POLIFAX" | cut -d '"' -f 3-)
   [ -n "$visual" ] || return

   kbitx_non_pua "$FAIRFAX"  |
   grep -F "$visual" | # <- get a list of all lines with the same visual
   cut -d '"' -f 2   | # <- extract the corresponding codepoints
   grep -v "^$1$"      # <- exclude the original code from the list
}

# Usage: polifax_homoglyphs CODEPOINT
# For the character with the given *decimal* codepoint in *Polifax*, print the
# list of all other Polifax characters which have the same visual
# representation.
polifax_homoglyphs() {
   [ $# -eq 1 ] || return 2
   case $1 in ''|*[!0-9]*) return 2;; esac

   visual=$(grep "^<g u=\"$1\" " "$POLIFAX" | cut -d '"' -f 3-)
   [ -n "$visual" ] || return

   grep -F "$visual" "$POLIFAX" | # <- all lines with the same visual
   cut -d '"' -f 2   | # <- extract the corresponding codepoints
   grep -v "^$1$"      # <- exclude the original code from the list
}


#-------------------------------------------------------------------------------
# Portable common functions
#-------------------------------------------------------------------------------

# Usage: exists COMMAND
# Return 0 iff the command is found
exists() { command -v "$@" >/dev/null; }

# Usage: die [-NUMBER] [--] [MESSAGE]...
# * Print the basename of the program,
# * Print the error message (or "Abort" if message is missing or empty)
# * Exit the program with the given error (or by default 1)
die() {
   # As this function is `exit`-ing and not returning, global variables can be
   # used without fear of polluting the environment
   DIE_EXIT_CODE=1
   DIE_START=''
   DIE_END=''

   case $1 in
               --) shift ;;
      -|-*[!0-9]*) ;; # not a number
                *) DIE_EXIT_CODE=${1#-}; shift;;
   esac

   [ -n "$*" ] || set -- 'Abort...'

   if [ -t 2 ]; then
      DIE_START='\033[1;38;5;9m'
      DIE_END='\033[0m'
   fi
   printf '%b%s%b: %s\n' "$DIE_START" "$(basename "$0")" "$DIE_END" "$*" >&2

   exit "$DIE_EXIT_CODE"
}

# Usage: requires COMMAND
# Exits the program (with err code 6) iff the command is not found
requires() { exists "$@" || die -6 "requires command $*"; }


# Usage: usage [DO_NOT_ABORT]...
# - Scan the program source for a 'comment block' starting with "Usage:",
# - Display the whole content of that block
# - While displaying the string $0 is replaced with the program (base)name,
# - Options:
#   * no args => print usage on standard error + EXIT the program (err code 2)
#   * any arg => print usage on standard input and does not exit
usage() {
   case $# in
      0) usage - >&2
         exit 2 ;;

      *) awk -v PROG_NAME="$(basename "$0")" '
             /^# Usage:/ { p=1 }
             /^#/        { if (p) {
                              sub("^# ?", "");
                              sub(/\$\<0\>/, PROG_NAME);
                              print; next;
                         } }
                         { if (p) exit }
             ' "$0" ;;
   esac
}


#-------------------------------------------------------------------------------
# Portable functions to deal with UTF-8 characters
#-------------------------------------------------------------------------------

# Usage: utf8_ord character
# Print the codepoint (in decimal) of the given character.
# The character must be UTF-8 encoded!
utf8_ord() {
   # Note: printf %d "'$1"  would work in bash or in shells that support
   #       multibyte locales, but not all shells do (dash, busybox sh, ...)
   #       Here, there's no requirement on the locale.

   # Read UTF-8 bytes as decimal integers
   #shellcheck disable=SC2046 #(we want word splitting here)
   set -- $(printf '%s' "$1" | od -An -t u1)

   case $# in
      1) # ASCII
         printf '%d\n' "$1" ;;
      2) # 110xxxxx 10xxxxxx
         printf '%d\n' $((
                (($1 & 0x1f) << 6) |
                 ($2 & 0x3f)
         ));;
      3) # 1110xxxx 10xxxxxx 10xxxxxx
         printf '%d\n' $((
                (($1 & 0x0f) << 12) |
                (($2 & 0x3f) <<  6) |
                 ($3 & 0x3f)
         ));;
      4) # 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
         printf '%d\n' $((
                (($1 & 0x07) << 18) |
                (($2 & 0x3f) << 12) |
                (($3 & 0x3f) <<  6) |
                 ($4 & 0x3f)
         ));;
      *) return 1;;
    esac
}


# Usage: utf8_chr [-d] codepoint
# Print a sequence that can be used in POSIX "printf"'s format string or %b
# directive to output the UTF-8 encoded character corresponding to the given
# Unicode codepoint.
#
# With -d, the codepoint is given as a decimal number.
# Otherwise, it is given as hexadecimal.
#
# Examples:
#   printf '%b\n' "$(utf8_chr 20AC)"   # print the 'euro sign'    character
#   printf '%b\n' "$(utf8_chr -d 955)" # print the greek 'lambda' character
utf8_chr() {

   # Check arg(s) and set up $1 to contain the codepoint as a decimal number
   if [ "$1" = '-d' ]; then
      # ensure positive decimal integer
      case ${2#+} in ''|*[!0-9]*) return 2;; esac
      shift
   else
      # remove possible (useless) prefixes: U[+|-] or [0]x,
      # ensure hex number,
      # and convert to decimal.
      case $1 in
          u*|U*) set -- "${1#[u|U]}"; set -- "${1#[+|-]}";;
        0x*|0X*) set -- "${1#0[x|X]}";;
          x*|X*) set -- "${1#[x|X]}";;
      esac
      case $1 in ''|*[!0-9A-Fa-f]*) return 2;; esac
      set -- "$(printf %d "0x$1")"
   fi

   # Encode codepoint to a UTF8 sequence of 1,2,3,or 4 bytes
   # and output the sequence in \octal... format for POSIX printf
   if [ "$1" -le 127 ]; then
      printf '\%03o\n' "$1"
   elif [ "$1" -le 2047 ]; then
      printf '\%03o\%03o\n'              \
             $((192 + $1 / 64))          \
             $((128 + $1 % 64))
   elif [ "$1" -le 65535 ]; then
      printf '\%03o\%03o\%03o\n'         \
             $((224 + $1 / 4096))        \
             $((128 + ($1 / 64) % 64))   \
             $((128 + $1 % 64))
   elif [ "$1" -le 1114111 ]; then # (0x10FFFF = last valid codepoint)
      printf '\%03o\%03o\%03o\%03o\n'    \
             $((240 + $1 / 262144))      \
             $((128 + ($1 / 4096) % 64)) \
             $((128 + ($1 / 64) % 64))   \
             $((128 + $1 % 64))
   else
      return 2
   fi
}
