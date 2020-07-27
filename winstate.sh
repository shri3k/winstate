#!/usr/bin/env bash

s_flag=''
debug_flag=0

debug() {
  if [[ $debug_flag == 1 ]]; then
    $@
  fi
}

print_usage() {
  echo "winstate"
  echo "--------"
  printf "Usage: winstate [-l-s] <state_name> [<window_id>]"
}

save_to_file() {
  SAVE_NAME=${1}
  debug echo "First arg : $1"
  debug echo "Second arg : $2"
  WID=${2:-$(lsw | tail -1)}
  debug echo $WID
  wtf $WID
  read WX WY WW WH <<< $(wattr xywh $WID)
  if [[ -f ~/.winstaterc ]]; then
    touch ~/.winstaterc
  fi
  local state="$SAVE_NAME $WX $WY $WW $WH"
  echo "$state" >> ~/.winstaterc
  printf "Saved $state"
}

load_from_file() {
  debug echo "First arg : $1"
  debug echo "Second arg : $2"

  FILENAME="$1"
  WID=${2:-`pfw`}

  read WX WY WW WH <<< $(awk "/$FILENAME/{
    print \$2\" \"\$3\" \"\$4\" \"\$5
  }" ~/.winstaterc)
  wtp $WX $WY $WW $WH $WID
}

list_wmctrl() {
  wmctrl -l
}

if [[ $- =~ x ]]; then
  debug_flag=1
fi

while getopts 'sl' flag; do
  case "${flag}" in
    s) s_flag='true';;
    l) l_flag='true';;
    *)
  esac
done

if [[ $l_flag == 'true' ]]; then
  list_wmctrl
fi

ARG1="${@:$OPTIND:1}"
ARG2="${@:$OPTIND+1:1}"

if [ -z "$ARG1" ]; then
  print_usage
  exit 1
fi

if [[ $s_flag == 'true' ]]; then
  save_to_file "$ARG1" "$ARG2"
else
  load_from_file "$ARG1" "$ARG2"
fi
