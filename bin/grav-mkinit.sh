#!/usr/bin/env bash
# ### #
# INIT #
# ### #
set -euo pipefail

if [ "$(set | grep xtrace)" -o ${DEBUG:-0} -ne 0 ]; then DEBUG=1; set -x; else DEBUG=0; set +x; fi

# #### #
# VARS #
# #### #
ARGC=$#
ARGV=("$@")
RC=0

CMD="$(basename ${0})"
NAME=$(echo ${CMD} | cut -d'.' -f1)
CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${CUR_DIR%/*}"

# Preset directories
ROOT_DIR="${HOME_DIR}/rootfs"
CACHE_DIR="${HOME_DIR}/cache"
DATA_DIR="${HOME_DIR}/data"
DOCK_DIR="${HOME_DIR}/docker"
CERT_DIR="${HOME_DIR}/cert"
BIN_DIR="${HOME_DIR}/bin"
CFG_DIR="${HOME_DIR}/cfg"
KEY_DIR="${HOME_DIR}/key"
LIB_DIR="${HOME_DIR}/lib"

# #### #
# LIBS #
# #### #
source "${LIB_DIR}"/libgrav_common
source "${LIB_DIR}"/libgrav_init

# ##### #
# FUNCS #
# ##### #
function main() {
   local _ARGC=${1}
   local _ARGV=("${@}")
   
   local _RC=0

   local _GRAV_CMD="${_ARGV[1]-""}"
   local _GRAV_STAGE="${_ARGV[2]-""}"

   local _GRAV_TEXT="Error: Arguments are not provided or are wrong!"
   local _GRAV_ARGS=" Args: ${CMD} mkinit-cmd init-name"
   local _GRAV_NOTE=" Note: (*) are default values, (#) are recommended values"
   local _GRAV_ARG1=" Arg1: mkinit-cmd: make|help - (*=help)"
   local _GRAV_ARG2=" Arg2:  init-name: any       - (#=init)"
   local _GRAV_INFO=" Info: ${CMD} make init"
   local _GRAV_HELP=" Help: ${CMD}: Use the 'init' command to initialize the project environment with context files under the ${CFG_DIR} directory. (See Note, Info and Args)"

   # Prerequisite checking
   local _UUID_MIN="-v4"
   local _DOCKER_MIN="20.10"
   local _BUILDX_MIN="0.5.0"
   local _JQ_MIN="1.5"
   local _OPENSSL_MIN="1.1.1"
   local _GIT_MIN="2.17"
   local _GETSSL_MIN="2.32"
   local _WGET_MIN="1.20"

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
         "${_GRAV_ARG2}"
   fi
   
   case "${_GRAV_CMD}" in
      "make")
         libgrav_init::mk_init \
            "${_GRAV_STAGE}" \
            "${_UUID_MIN}" \
            "${_DOCKER_MIN}" \
            "${_BUILDX_MIN}" \
            "${_JQ_MIN}" \
            "${_OPENSSL_MIN}" \
            "${_GIT_MIN}" \
            "${_GETSSL_MIN}" \
            "${_WGET_MIN}"
      ;;

      "help")
         libgrav_common::usage 1 \
            " Help: This arguments are currently valid!" \
            "${_GRAV_ARGS}" \
            "${_GRAV_NOTE}" \
            "${_GRAV_INFO}" \
            "${_GRAV_HELP}" \
            "${_GRAV_ARG1}" \
            "${_GRAV_ARG2}"
      ;;

      *)
         libgrav_common::usage 1 \
            "${_GRAV_TEXT}" \
            "${_GRAV_ARGS}" \
            "${_GRAV_NOTE}" \
            "${_GRAV_INFO}" \
            "${_GRAV_HELP}" \
            "${_GRAV_ARG1}" \
            "${_GRAV_ARG2}"
      ;;
   esac

   _RC=$?
   
   if [ ${_RC} -eq 0 ]; then libgrav_common::help " Info: Reload bash from the command line with 'source \${HOME}/.bashrc'" "${NAME}"; fi

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
