#!/bin/bash
#
# Copyright 2015-2019 CNRS and University of Strasbourg
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

USAGE="[-h] [-v] [ -d DIRECTORY ] -r RESOURCE -f FILENAME"
DESCRIPTION="A Nagios probe that check if an iRODS resource is correctly working"

# Initialisation
NVERSION=1.0
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

RESOURCE=""

RETURN_MESSAGE="OK: success"
RETURN_CODE=0

DIRNAME="$( cd "$(dirname "$0")" ; pwd -P )"
NAGIOSCMD=/var/spool/nagios/cmd/nagios.cmd

print_usage() {
    echo "usage: ${PROGNAME} ${USAGE}"
}

print_help() {
    echo "usage: ${PROGNAME} ${USAGE}"
    echo ""
    echo "${DESCRIPTION}"
    echo ""
    echo "optional arguments:"
    echo "  -h, --help            show this help message and exit"
    echo "  -v, --version         show program's version number and exit"
    echo "  -r                    RESOURCE"
    echo "                        the irods resource to delete the file from"
    echo "  -d                    DIRECTORY"
    echo "                        the DIRECTORY containing the file to delete"
    echo "  -H                    HOST"
    echo "                        the name of the host serving the resource"
}

# Parse the arguments                                                           
while [ -n "$1" ]; do
    case "$1" in
        --help)
            print_help
            exit ${STATE_OK}
            ;;
        -h)
            print_help
            exit ${STATE_OK}
            ;;
        --version)
            echo "${NVERSION}"
            exit ${STATE_OK}
            ;;
        -v)
            echo "${NVERSION}"
            exit ${STATE_OK}
            ;;
        -r)
            RESOURCE=$2
            shift
            ;;
        -d)
            DIRECTORY=$2
            shift
            ;;
        -H)
            HOST=$2
            shift
            ;;
        *)
            print_usage
            exit ${STATE_UNKNOWN}
            ;;
    esac
    shift
done

if [ -z ${RESOURCE} ]; then
    echo "The resource option is not set"
    exit ${STATE_UNKNOWN}
fi

if [ -z ${HOST} ]; then
    echo "The host option is not set"
    exit ${STATE_UNKNOWN}
fi

IRODS_FILENAME="${TMPFILE}_${RESOURCE}.json"
LOCAL_FILENAME="/tmp/${IRODS_FILENAME}"

CONTENT=$(cat <<EOF
{
    "Probe": {
        "Source": "`hostname`",
        "Destination": "${HOST}",
        "Resource": "${RESOURCE}",
        "Home": "${HOME}",
        "Date": "`date`"
    }
}
EOF
)

echo ${CONTENT} >> ${LOCAL_FILENAME}

#
# iput test
#

DATE=`date +%s`
IPUT_PLUGIN_OUTPUT=`${DIRNAME}/check_irods_resource_iput.sh -r ${RESOURCE} -f ${LOCAL_FILENAME}`
IPUT_RETURN_CODE=$?

if [ ${IPUT_RETURN_CODE} -gt ${RETURN_CODE} ]; then
    RETURN_CODE=${IPUT_RETURN_CODE}
    RETURN_MESSAGE="ERROR: iput metric failed"
fi

echo "[${DATE}] PROCESS_SERVICE_CHECK_RESULT;${HOST};org.irods.irods4.Resource-Iput;${IPUT_RETURN_CODE};${IPUT_PLUGIN_OUTPUT}" > ${NAGIOSCMD}

#
# iget test
#

DATE=`date +%s`
if [ ${IPUT_RETURN_CODE} -eq 0 ]; then
    IGET_PLUGIN_OUTPUT=`${DIRNAME}/check_irods_resource_iget.sh -r ${RESOURCE} -f ${IRODS_FILENAME}`
    IGET_RETURN_CODE=$?
else
    IGET_PLUGIN_OUTPUT="WARNING: Masked by iRODS-iput - ${IPUT_PLUGIN_OUTPUT}"
    IGET_RETURN_CODE=${STATE_WARNING}
fi

if [ ${IGET_RETURN_CODE} -gt ${RETURN_CODE} ]; then
    RETURN_CODE=${IGET_RETURN_CODE}
    RETURN_MESSAGE="ERROR: iget metric failed"
fi

echo "[${DATE}] PROCESS_SERVICE_CHECK_RESULT;${HOST};org.irods.irods4.Resource-Iget;${IGET_RETURN_CODE};${IGET_PLUGIN_OUTPUT}" > $NAGIOSCMD

#
# irm test
#

DATE=`date +%s`

if [ ${IPUT_RETURN_CODE} -eq 0 ]; then
    IRM_PLUGIN_OUTPUT=`${DIRNAME}/check_irods_resource_irm.sh -r ${RESOURCE} -f ${IRODS_FILENAME}`
    IRM_RETURN_CODE=$?
else
    IRM_PLUGIN_OUTPUT="WARNING: Masked by iRODS-iput - ${IPUT_PLUGIN_OUTPUT}"
    IRM_RETURN_CODE=${STATE_WARNING}
fi

if [ ${IRM_RETURN_CODE} -gt ${RETURN_CODE} ]; then
    RETURN_CODE=${IRM_RETURN_CODE}
    if [ ${RETURN_CODE} -gt ${STATE_OK} ]; then
        RETURN_MESSAGE="${RETURN_MESSAGE}; ERROR: irm metric failed"
    else
        RETURN_MESSAGE="ERROR: irm metric failed"
    fi
fi

echo "[${DATE}] PROCESS_SERVICE_CHECK_RESULT;${HOST};org.irods.irods4.Resource-Irm;${IRM_RETURN_CODE};${IRM_PLUGIN_OUTPUT}" > $NAGIOSCMD

# Some cleanup
if [ -f ${LOCAL_FILENAME} ]; then
    rm -f ${LOCAL_FILENAME}
fi

#
# Global status
#
echo ${RETURN_MESSAGE}
exit ${RETURN_CODE}

