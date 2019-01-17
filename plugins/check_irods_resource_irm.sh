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
DESCRIPTION="A Nagios probe that check the deletion of a file on an iRODS resource"

# Initialisation
NVERSION=1.0
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

PROGNAME=`basename $0`
PWARNING=$1
PCRITICAL=$2

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
    echo "  -f                    FILENAME"
    echo "                        the name of the file to delete"
}

delete_file() {
    if [ -z ${DIRECTORY} ]; then
        FILE="${FILENAME}"
    else
        FILE="${DIRECTORY}/${FILENAME}"
    fi

    # Check if the file exists
    OUTPUT=`ils ${FILE} 2>&1`
    if [ $? -gt 0 ]; then
        echo "The ${FILE} file does not exist"
        exit ${STATE_CRITICAL}
    fi

    # Check that it exists on the requested resource
    OUTPUT=`ils -l ${FILE} 2>&1 | head -1 | awk '{ print $3}' | cut -d';' -f1`
    if [ "x${OUTPUT}" != "x${RESOURCE}" ]; then
        echo "The ${FILE} file does not exist on the requested resource"
        exit ${STATE_CRITICAL}
    fi

    # Remove the file
    OUTPUT=`irm -f ${FILE} 2>&1`
    if [ $? -gt 0 ]; then
        echo "The ${FILE} file cannot be deleted"
        exit ${STATE_CRITICAL}
    fi
}

DIRECTORY=""
RESOURCE=""

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
        -f)
            FILENAME=$2
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

if [ -z ${FILENAME} ]; then
    echo "The filename option is not set"
    exit ${STATE_UNKNOWN}
fi

delete_file

echo "The \`${FILENAME}\` file has been successfully deleted from the \`${RESOURCE}\` iRODS resource"
exit ${STATE_OK}

