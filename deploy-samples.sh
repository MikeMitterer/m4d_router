#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Deploys sample to LightSail II
#
# rsync-destination must be defined in a .rsync-file for each sample
# -----------------------------------------------------------------------------

# Vars die in .bashrc gesetzt werden. ~ (DEV_DOCKER, DEV_SEC, DEV_LOCAL) ~~~~~~
# [] müssen entfernt werden (IJ Bug https://goo.gl/WJQGMa) 
if [ -z ${DEV_DOCKER+set} ]; then echo "Var 'DEV_DOCKER' nicht gesetzt!"; exit 1; fi
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Abbruch bei Problemen (https://goo.gl/hEEJCj)
#
# Wenn ein Fehler nicht automatisch zu einem exit führen soll dann
# kann 'command || true' verwendet werden
#
# Für die $1, $2 Abfragen kann 'CMDLINE=${1:-}' verwendet werden
#
# -e Any subsequent(*) commands which fail will cause the shell script to exit immediately
# -o pipefail sets the exit code of a pipeline to that of the rightmost command
# -u treat unset variables as an error and exit
# -x print each command before executing it
set -eou pipefail

APPNAME="`basename $0`"

SCRIPT=`realpath $0`           
SCRIPTPATH=`dirname ${SCRIPT}`

#------------------------------------------------------------------------------
# Einbinden der globalen Build-Lib
#   Hier sind z.B. Farben, generell globale VARs und Funktionen definiert
#

GLOBAL_DIR="${DEV_DOCKER}/_global"
LIB_DIR="${GLOBAL_DIR}/lib"

SAMPLES_LIB="samples.lib.sh"

if [[ ! -f "${LIB_DIR}/${SAMPLES_LIB}" ]]
then
    echo "Samples-lib ${LIB_DIR}/${SAMPLES_LIB} existiert nicht!"
    exit 1
fi

. "${LIB_DIR}/${SAMPLES_LIB}"

#------------------------------------------------------------------------------
# BASIS

declare -a SAMPLES=(
    "example/browser"
)

#------------------------------------------------------------------------------
# Functions
#


#------------------------------------------------------------------------------
# Options
#

usage() {
    echo
    echo "Usage: ${APPNAME} [ options ]"
    echo -e "\t-l | --list                Shows all samples"
    echo -e "\t-d | --deploy              Creates 'deploy'-dir for Dart"
    echo -e "\t-p | --publish [--force]   Publish samples to AWS/S3 (only on day ${PUBLISH_ONLY_ON_DAY})"
    echo -e "\t                           use --force to ignore Monday as publishing day"
}


CMDLINE=${1:-}
OPTION=${2:-}
case "${CMDLINE}" in
    -l|list|-list|--list)
        listSamples "${SAMPLES[@]}"
    ;;

    -d|deploy|-deploy|--deploy)
        deploySamples "${SAMPLES[@]}"
    ;;

    -p|publish|-publish|--publish)
        publishSamples "${SAMPLES[@]}"
    ;;

    -h|-help|--help|*)
        usage
    ;;

esac

#------------------------------------------------------------------------------
# Alles OK...

exit 0
