#!/usr/bin/env bash
# ### #
# INIT #
# ### #
set -euo pipefail

if [ "$(set | grep xtrace)" -o ${DEBUG:-0} -ne 0 ]; then DEBUG=1; set -x; else DEBUG=0; set +x; fi

CMD="$(basename ${0})"
NAME=$(echo ${CMD} | cut -d'.' -f1)
CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${CUR_DIR%/*}"

if [[ ! -e "${HOME_DIR}/.context" ]]; then echo -e "\nError: Context is not initialized!\nPlease run '<PROJECT_HOME>/bin/grav-mkinit.sh init' first... "; exit 1; fi

# Remove enclosing double quotes
CTX_DIR="$(cat ${HOME_DIR}/.context | tr -d '"' | cut -d'=' -f2)"
LIB_DIR="$(cat ${CTX_DIR}/.config.lib | tr -d '"' | cut -d'=' -f2)"

# #### #
# VARS #
# #### #
ARGC=$#
ARGV=("$@")
RC=0

# #### #
# LIBS #
# #### #
source "${LIB_DIR}"/libgrav_common
source "${LIB_DIR}"/libgrav_mk

# ##### #
# FUNCS #
# ##### #
function main() {
   # Initialize context
   libgrav_common::init

   local _ARGC=${1}
   local _ARGV=("${@}")

   local _RC=0

   local _GRAV_CMD="${_ARGV[1]-""}"
   local _GRAV_NAME="${_ARGV[2]-""}"
   local _GRAV_CACHE="${_ARGV[3]:-"${HOME_DIR}/${_GRAV_NAME}"}"

   local _GRAV_TEXT="Error: Arguments are not provided or are wrong!"
   local _GRAV_ARGS=" Args: ${CMD} mkcache-cmd cache-name [cache-file]"
   local _GRAV_NOTE=" Note: (*) are default values, (#) are recommended values"
   local _GRAV_ARG1=" Arg1:  mkcache-cmd: make|help - (*=help)"
   local _GRAV_ARG2=" Arg2:   cache-name: any       - (#=cache)"
   local _GRAV_ARG3=" Arg3: [cache-file]: any(*)    - (*=${CACHE_DIR-""})"
   local _GRAV_INFO=" Info: ${CMD} make cache ${CACHE_DIR-""}"
   local _GRAV_HELP=" Help: ${CMD}: Create the required cache directory depending from some entered arguments. (See Note, Info and Args)"

   # Check if docker is running
   libgrav_common::check_docker

   # If no arguments given show help otherwise usage
   if [ ${_ARGC} -lt 1 ] && [ ${_ARGV[1]} != "help" ]; then 
      libgrav_common::usage 1 \
         "${_GRAV_TEXT}" \
         "${_GRAV_ARGS}" \
         "${_GRAV_NOTE}" \
         "${_GRAV_INFO}" \
         "${_GRAV_HELP}" \
         "${_GRAV_ARG1}" \
         "${_GRAV_ARG2}" \
         "${_GRAV_ARG3}"
   fi

   case "${_GRAV_CMD}" in
      "make")
         libgrav_mk::mk_cache \
            "${_GRAV_NAME}" \
            "${_GRAV_CACHE}"
      ;;

      "help")
         libgrav_common::usage 1 \
            " Help: This arguments are currently valid!" \
            "${_GRAV_ARGS}" \
            "${_GRAV_NOTE}" \
            "${_GRAV_INFO}" \
            "${_GRAV_HELP}" \
            "${_GRAV_ARG1}" \
            "${_GRAV_ARG2}" \
            "${_GRAV_ARG3}"
      ;;

      *)
         libgrav_common::usage 1 \
            "${_GRAV_ARGS}" \
            "${_GRAV_TEXT}" \
            "${_GRAV_NOTE}" \
            "${_GRAV_INFO}" \
            "${_GRAV_HELP}" \
            "${_GRAV_ARG1}" \
            "${_GRAV_ARG2}" \
            "${_GRAV_ARG3}"
      ;;
   esac

   RC=$?

   return ${_RC}
}

# #### #
# MAIN #
# #### #
main ${ARGC} "${ARGV[@]:-"help"}"

RC=$?

# #### #
# EXIT #
# #### #
exit ${RC}
