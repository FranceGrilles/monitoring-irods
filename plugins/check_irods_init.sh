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

USAGE="[-h] [-v]"
DESCRIPTION="A Nagios probe that check if all init files are present"

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
}

check_init() {
    if [ ! -d ~/.irods ]; then
        echo "The ~/.irods directory does not exist"
        exit ${STATE_CRITICAL}
    fi
    if [ ! -f ~/.irods/irods_environment.json ]; then
        echo "The ~/.irods/.irodsEnv file does not exist"
        exit ${STATE_CRITICAL}
    fi
    if [ ! -f ~/.irods/.irodsA ]; then 
        echo "The ~/.irods/.irodsA file does not exist"
        exit ${STATE_CRITICAL}
    fi
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
        *)
            print_usage
            exit ${STATE_UNKNOWN}
            ;;
    esac
    shift
done

check_init

echo "All init files are present"
exit ${STATE_OK}

