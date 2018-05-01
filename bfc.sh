#!/bin/sh
# brainf*ck compiler (LLVM front-end)
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
OUT_FILE="${1%.*}.ll"
IDX=0

out_header() {
  echo "; ModuleID = '${IN_FILE}'"
  echo "source_filename = \"${IN_FILE}\""
  echo ""
  echo "define i32 @main() {"
  echo "  %ptr = alloca i8*, align 8"
  echo "  %buff = call noalias i8* @calloc(i64 30000, i64 1)"
  echo "  store i8* %buff, i8** %ptr, align 8"
  echo ""
}

out_footer() {
  echo "  call void @free(i8* %buff)"
  echo "  ret i32 0"
  echo "}"
  echo ""
  echo "declare noalias i8* @calloc(i64, i64)"
  echo "declare i32 @getchar()"
  echo "declare i32 @putchar(i32)"
  echo "declare void @free(i8*)"
  echo ""
  echo "!llvm.ident = !{!0}"
  echo "!0 = !{!\"${VERSION}\"}"
}

out_add_value() {
  echo "  %r${IDX} = load i8*, i8** %ptr, align 8"
  echo "  %r$((IDX+1)) = load i8, i8* %r${IDX}, align 1"
  echo "  %r$((IDX+2)) = add i8 %r$((IDX+1)), ${1}"
  echo "  store i8 %r$((IDX+2)), i8* %r${IDX}, align 1"
  echo ""
  IDX="$((IDX+3))"
}

out_move_ptr() {
  echo "  %r${IDX} = load i8*, i8** %ptr, align 8"
  echo "  %r$((IDX+1)) = getelementptr inbounds i8, i8* %r${IDX}, i32 ${1}" 
  echo "  store i8* %r$((IDX+1)), i8** %ptr, align 8"
  echo ""
  IDX="$((IDX+2))"
}

out_put_char() {
  echo "  %r${IDX} = load i8*, i8** %ptr, align 8"
  echo "  %r$((IDX+1)) = load i8, i8* %r${IDX}, align 1"
  echo "  %r$((IDX+2)) = sext i8 %r$((IDX+1)) to i32"
  echo "  %r$((IDX+3)) = call i32 @putchar(i32 %r$((IDX+2)))"
  echo ""
  IDX="$((IDX+4))"
}

out_get_char() {
  echo "  %r${IDX} = call i32 @getchar()"
  echo "  %r$((IDX+1)) = trunc i32 %r${IDX} to i8"
  echo "  %r$((IDX+2)) = load i8*, i8** %ptr, align 8"
  echo "  store i8 %r$((IDX+1)), i8* %r$((IDX+2)), align 1"
  echo ""
  IDX="$((IDX+3))"
}

out_loop_start() {
  echo "  br label %LOOP_COND${1}"
  echo ""
  echo "LOOP_COND${1}:"
  echo "  %r${IDX} = load i8*, i8** %ptr, align 8"
  echo "  %r$((IDX+1)) = load i8, i8* %r${IDX}, align 1"
  echo "  %r$((IDX+2)) = icmp ne i8 %r$((IDX+1)), 0"
  echo "  br i1 %r$((IDX+2)), label %LOOP_MAIN${1}, label %LOOP_END${1}"
  echo ""
  echo "LOOP_MAIN${1}:"
  IDX=$((IDX+3))
}

out_loop_end() {
  echo "  br label %LOOP_COND${1}"
  echo ""
  echo "LOOP_END${1}:"
}

out_header >"${OUT_FILE}"

LABEL=0
STACK=""
LINE_NUM=0
while IFS= read -r string ; do
  LINE_NUM=$((LINE_NUM + 1))
  COLUMN_NUM=0
  while [ "$string" != "" ] ; do
    COLUMN_NUM=$((COLUMN_NUM + 1))
    case "$string" in
    ">"*) out_move_ptr 1 ;;
    "<"*) out_move_ptr -1 ;;
    "+"*) out_add_value 1 ;;
    "-"*) out_add_value -1 ;;
    "."*) out_put_char ;;
    ","*) out_get_char ;;
    "["*)
      LABEL=$((LABEL+1))
      STACK="${LABEL},${STACK}"
      out_loop_start $LABEL
      ;;
    "]"*)
      if [ -z "${STACK}" ] ; then
        echo "$(basename $0):${LINE_NUM}:${COLUMN_NUM}: found loop-end without loop-start" 1>&2
        exit 1
      fi
      POP="${STACK%%,*}"
      STACK="${STACK#*,}"
      out_loop_end $POP
      ;;
    esac
    string="${string#?}"
  done
done < "${IN_FILE}" >>"${OUT_FILE}"

out_footer >>"${OUT_FILE}"
exit 0
