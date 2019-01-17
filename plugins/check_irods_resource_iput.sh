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
DESCRIPTION="A Nagios probe that check the copy of a file to an iRODS resource"

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
    echo "                        the irods resource to copy the file to"
    echo "  -d                    DIRECTORY"
    echo "                        the DIRECTORY on the iRODS server to copy the file to"
    echo "  -f                    FILENAME"
    echo "                        the name of the file to copy"
}

put_file() {
    # Check if the file exists
    OUTPUT=`ils ${FILE} 2>&1`
    if [ $? -eq 0 ]; then
        echo "The ${FILE} file already exist"
        exit ${STATE_CRITICAL}
    fi

    OUTPUT=`iput -R ${RESOURCE} ${FILENAME} ${DIRECTORY} 2>&1`
    if [ $? -gt 0 ]; then
        echo "The ${FILENAME} file cannot be copied to the ${RESOURCE} iRODS resource"
        exit $STATE_CRITICAL
    fi
}

DESTINATION=""
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

if [ ! -f ${FILENAME} ]; then
   echo "The ${FILENAME} file does not exist"
   exit ${STATE_UNKNOWN}
fi

put_file

echo "The \`${FILENAME}\` file has been successfully copied to the \`${RESOURCE}\` iRODS resource"
exit ${STATE_OK}

