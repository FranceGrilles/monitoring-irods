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
#   Main iRODS Resource probe.
#
# Changelog:
# * Sat May 09 2015 Jerome Pansanel <jerome.pansanel@iphc.cnrs.fr> 1.0-1

RESOURCE=""

NVERSION=0.1
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

RETURN_MESSAGE="Ok"
RETURN_CODE=0

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
        -H)
            HOST=$2
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

if [ -z $HOST ]
then
    echo "Host option not set: -H <host>"
    exit $STATE_WARNING
fi

echo "HOST: $HOST; RESOURCE: $RESOURCE" >> /tmp/nag.log
echo "HOME: $HOME" >> /tmp/nag.log
echo "whoami: `whoami`" >> /tmp/nag.log
#
# iput test
#

DATE=`date +%s`
IPUT_PLUGIN_OUTPUT=`/usr/local/bin/check_irods_iput.sh -R $RESOURCE`
IPUT_RETURN_CODE=$?

if [ ${IPUT_RETURN_CODE} -gt ${RETURN_CODE} ]; then
  RETURN_CODE=${IPUT_RETURN_CODE}
  RETURN_MESSAGE="Metric failed"
fi

echo "[${DATE}] PROCESS_SERVICE_CHECK_RESULT;${HOST};org.irods.irods3.Resource-Iput;${IPUT_RETURN_CODE};${IPUT_PLUGIN_OUTPUT}" > /var/spool/nagios/cmd/nagios.cmd


#
# iget test
#

DATE=`date +%s`
if [ ${IPUT_RETURN_CODE} -eq 0 ]; then
  IGET_PLUGIN_OUTPUT=`/usr/local/bin/check_irods_iget.sh -R $RESOURCE`
  IGET_RETURN_CODE=$?
else
  IGET_PLUGIN_OUTPUT="WARNING: Masked by iRODS-iput - ${IPUT_PLUGIN_OUTPUT}"
  IGET_RETURN_CODE=1
fi

if [ ${IGET_RETURN_CODE} -gt ${RETURN_CODE} ]; then
  RETURN_CODE=${IGET_RETURN_CODE}
  RETURN_MESSAGE="Metric failed"
fi

echo "[${DATE}] PROCESS_SERVICE_CHECK_RESULT;${HOST};org.irods.irods3.Resource-Iget;${IGET_RETURN_CODE};${IGET_PLUGIN_OUTPUT}" > /var/spool/nagios/cmd/nagios.cmd

#
# irm test
#

DATE=`date +%s`

if [ ${IPUT_RETURN_CODE} -eq 0 ]; then
  IRM_PLUGIN_OUTPUT=`/usr/local/bin/check_irods_irm.sh -R $RESOURCE`
  IRM_RETURN_CODE=$?
else
  IRM_PLUGIN_OUTPUT="WARNING: Masked by iRODS-iput - ${IPUT_PLUGIN_OUTPUT}"
  IRM_RETURN_CODE=1
fi

if [ ${IRM_RETURN_CODE} -gt ${RETURN_CODE} ]; then
  RETURN_CODE=${IRM_RETURN_CODE}
  RETURN_MESSAGE="Metric failed"
fi

echo "[${DATE}] PROCESS_SERVICE_CHECK_RESULT;${HOST};org.irods.irods3.Resource-Irm;${IRM_RETURN_CODE};${IRM_PLUGIN_OUTPUT}" > /var/spool/nagios/cmd/nagios.cmd 

#
# Global status
#
echo ${RETURN_MESSAGE}
exit ${RETURN_CODE}
