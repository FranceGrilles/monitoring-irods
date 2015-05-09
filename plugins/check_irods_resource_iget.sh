#!/bin/bash

# Copyright (C) 2015 CNRS
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Description:
#  Nagios Probe to check if a file can be retrieved from an iRODS resource
#
# Changelog:
# * Sat May 09 2015 Emmanuel Medernach <emmanuel.medernach@iphc.cnrs.fr> 1.0-1

HELP="This script is used by Nagios to retrieve a file from an iRODS resource."

# Initialisation                                                                
NVERSION=0.1
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

PROGNAME=`basename $0`
PWARNING=$1
PCRITICAL=$2

DIR=/tmp

print_usage() {
    echo "Usage: $PROGNAME --help"
    echo "Usage: $PROGNAME --version"
}

print_help() {
    echo "Command : $PROGNAME"
    echo $HELP
    echo
    echo "Usage: $PROGNAME [-R <resource>] -d <destination>"
}

get_file() {
    
    RESOURCEOPTION="-R $RESOURCE"

    if [ -n "$DESTINATION" ]
    then
        DESTINATIONOPTION="-f $DESTINATION/DATE.$RESOURCE"
    else
        DESTINATIONOPTION="-f DATE.$RESOURCE"
    fi

    iget $RESOURCEOPTION $DESTINATIONOPTION $FILE.iget 2>&1 || exit $STATE_CRITICAL

}

DESTINATION=""
RESOURCE=""

# Parse the arguments                                                           
while [ -n "$1" ]; do
    case "$1" in
        --help)
            print_help
            exit $STATE_OK
            ;;
        -h)
            print_help
            exit $STATE_OK
            ;;
        --version)
            echo "Version: $NVERSION"
            exit $STATE_OK
            ;;
        -V)
            echo "Version: $NVERSION"
            exit $STATE_OK
            ;;
        -R)
            RESOURCE=$2
            shift
            ;;
        -d)
            DESTINATION=$2
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            print_usage
            exit $STATE_UNKNOWN
            ;;
    esac
    shift
done

if [ -z $RESOURCE ]
then
    echo "Resource option not set: -R <resource>"
    exit $STATE_WARNING
fi

FILE="$DIR/DATE.$RESOURCE"

get_file
diff $FILE $FILE.iget > /dev/null
if [ $? -eq 0 ]; then
    echo Ok
    exit $STATE_OK
else
    echo Files are different
    exit $STATE_WARNING
fi



