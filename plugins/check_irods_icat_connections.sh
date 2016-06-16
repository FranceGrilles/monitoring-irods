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
#   Nagios probe to check the connection to an iRODS iCat server
#
# Changelog:
# * Sat May 09 2015 Emmanuel Medernach <emmanuel.medernach@iphc.cnrs.fr> 1.0-1

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


number_of_connection() {
    ips | grep -v '^Server:' | wc -l
}

number_of_connection
exit $STATE_OK

#EOF
