#!/bin/bash
# brainf*ck to c-lang translator
# date: 2018-04-24

VERSION="$(basename $0) version 0.0.1 (2018-04-24)"

if [ $# -ne 1 -o "$1" = "-h" -o "$1" = "--help" ] ; then
  echo "usage: $(basename $0) SOURCE_FILE"
  exit 1
elif [ "$1" = "-v" -o "$1" = "--version" ] ; then
  echo "${VERSION}"
  exit 0
fi

IN_FILE="$1"
OUT_FILE="${1%.*}.c"

cat >"${OUT_FILE}" <<EOD
#include <stdio.h>
#include <stdlib.h>
int main(){
 void *buff=calloc(30000,sizeof(char));
 char *ptr=(char*)buff;
EOD

NEST=0
LINE_NUM=0
while IFS= read -r string ; do
  LINE_NUM=$((LINE_NUM + 1))
  COLUMN_NUM=0
  while [ -n "$string" ] ; do
    COLUMN_NUM=$((COLUMN_NUM + 1))
    case "$string" in
    ">"*) echo " ptr++;" ;;
    "<"*) echo " ptr--;" ;;
    "+"*) echo " (*ptr)++;" ;;
    "-"*) echo " (*ptr)--;" ;;
    "."*) echo " putchar(*ptr);" ;;
    ","*) echo " *ptr=getchar();" ;;
    "["*)
      echo " while(*ptr){"
      NEST=$((NEST + 1))
      ;;
    "]"*)
      if [ ${NEST} -eq 0 ] ; then
        echo "$(basename $0):${LINE_NUM}:${COLUMN_NUM}: found loop-end without loop-start" 1>&2
        exit 1
      fi
      NEST=$((NEST - 1))
      echo " }"
      ;;
    esac
    string="${string#?}"
  done
done < "${IN_FILE}" >>"${OUT_FILE}"

cat >>"${OUT_FILE}" <<EOD
 free(buff);
 return 0;
}
EOD

exit 0
