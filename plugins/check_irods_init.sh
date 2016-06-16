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
#   Nagios probe to check an iRODS environment
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


check_init() {
# iinit must be done before invoking tests.
    [ -d ~/.irods ] || ( echo Directory ~/.irods does not exist; exit $STATE_CRITICAL )
    [ -f ~/.irods/.irodsEnv ] || ( echo File ~/.irods/.irodsEnv does not exist; return $STATE_CRITICAL )
    [ -f ~/.irods/.irodsA ] || ( echo File ~/.irods/.irodsA does not exist; return $STATE_CRITICAL ) 
    echo All init files present
}

check_init
exit $STATE_OK

#EOF
