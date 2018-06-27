#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Deploys sample to Amazon S3
#
# S3 bucket name must be defined in a .s3-file for each sample
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
# BASIS

LOGFILE="${APPNAME}_`date +"%Y%m%d"`.log"

declare -a SAMPLES=(
    "example/browser"
)

DOW=$(date +"%u")
PUBLISH_ONLY_ON_DAY=1

#------------------------------------------------------------------------------
# Functions
#

sampleFunction() {
    MESSAGE=${1?sampleFunction muss mind. einen Param haben}
    OPTIONAL=${2-default value}
    #OPTIONAL=${2}

    # Test if Var exists (the right way) https://goo.gl/jaUpJ8
    if [ -n "${2+set}" ]
    then
        echo "${MESSAGE} - ${OPTIONAL}"
    else
        echo "${MESSAGE}"
    fi
}

#
# Usage: listSamples "${SAMPLES[@]}"
#
listSamples() {
    local SAMPLES=("${@}")

    echo $OPTION

    # Loop Through ARRAY
    for SAMPLE in "${SAMPLES[@]}"
    do
        local S3BUCKET=$(cat "${SAMPLE}/.s3" | sed -e "s/^#.*$//g" -e "/^$/d" | head -n 1)
        echo "${SAMPLE} / S3-Bucket: ${S3BUCKET}..."
    done
}

#
# Usage: publishSamples "${SAMPLES[@]}"
#
publishSamples() {
    local SAMPLES=("${@}")

    #
    # Strings: if [ "$x" == "valid" ]; then
    #          if [ "$x" != "valid" ]; then
    # Numbers: if [ (("$x" == 99)) ]; then 
    #          if [ (("$x" != 99)) ]; then
    # 
    if [[ "${OPTION}" == "" && (("${DOW}" != "${PUBLISH_ONLY_ON_DAY}")) ]]; then
        echo "Sorry - today is not a publishing day. "
        echo "To force publishing use '--force'"
        exit 0
    fi
    

    # Loop Through ARRAY
    for SAMPLE in "${SAMPLES[@]}"
    do
        local S3BUCKET=$(cat "${SAMPLE}/.s3" | sed -e "s/^#.*$//g" -e "/^$/d" | head -n 1)

        cd ${SAMPLE}

        # Update pub
        pub update

        # Set current date in index.html
        sed -i.bak -e "s#<span class=\"pubdate\">[^<]*</span>#<span class=\"pubdate\">$(date +"%Y-%m-%d / %H:%M:%S")</span>#g" web/index.html
        rm -f web/index.html.bak
    
        # Dart build
        rm -rf deploy
        pub run build_runner build --release --output web:deploy

        # Sync is to slow
        # aws s3 sync --delete deploy/ s3://${S3BUCKET}

        # Copies to Amazon bucket
        # Uses 'Bucket-all-samples-for-mikemitterer.at' policy on AWS
        # e.g. aws s3 cp deploy/ s3://samples.m4d.router.mikemitterer.at --recursive
        aws s3 rm s3://${S3BUCKET}/
        aws s3 cp deploy/ s3://${S3BUCKET} --recursive
    done
}

#------------------------------------------------------------------------------
# Options
#

usage() {
    echo
    echo "Usage: ${APPNAME} [ options ]"
    echo -e "\t-l | --list                Shows all samples"
    echo -e "\t-p | --publish [--force]   Publish samples to AWS/S3 (only on day ${PUBLISH_ONLY_ON_DAY})"
    echo -e "\t                           use --force to ignore Monday as publishing day"
}


CMDLINE=${1:-}
OPTION=${2:-}
case "${CMDLINE}" in
    -l|list|-list|--list)
        listSamples "${SAMPLES[@]}"
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
