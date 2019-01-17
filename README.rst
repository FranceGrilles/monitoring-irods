=======================
iRODS Monitoring Probes
=======================

This project aims to provide a set of probes for monitoring an
`iRODS <https://irods.org/>`_ infrastructure. These probes are designed for
being used with Nagios, but are also compatible with other monitoring solutions
like `Shinken <http://www.shinken-monitoring.org>`_ or
`Icinga <https://icinga.com>`_.


Pre-requisite
=============

To work correctly, the Nagios server should be able to access the iRODS
infrastructure. To achieve this, the following steps have to be performed:

1. Install the iRODS client software, as described in the `irods package documentation <https://irods.org/download/>`_.

2. Configure the iRODS client by setting the ``/var/spool/nagios/.irods/irods_environment.json`` file accordingly to the `iRODS user documentation <https://docs.irods.org/4.2.4/system_overview/configuration/#irodsirods_environmentjson>`_.

3. Iniatilize the iRODS connection with the **iinit** command.

If iRODS is properly, the following command should not return any error:

.. code-block:: console

   # su - nagios -c ils


Installation
============

The installation is straightforward. Simply copy the probes in the Nagios
plugins directory:

.. code-block:: console

   # cp plugins/* /usr/lib64/nagios/plugins/
   # chown -R nagios /usr/lib64/nagios/plugins/check_irods_*


Configuration
=============

Once the probes are correctly installed, the Nagios configuration has to be
modified to use them.

First, add the following command to Nagios:

.. code-block::

   define command{
           command_name            check_irods_icat_connections
           command_line            $USER3$/check_irods_icat_connections.sh
           }

   define command{
           command_name            check_irods_resource_all
           command_line            $USER3$/check_irods_resource_all.sh -H $HOSTNAME$ -r $ARG1$
           }

   define command{
           command_name            check_irods_passive
           command_line            $USER1$/check_dummy 3 "$ARG1$"
           }


Then, create a service definition for each resource to monitor:

.. code-block::

   define service{
           use                     service-template
           hostgroup_name          irods-resources
           service_description     org.irods.irods4.Resource-Iput
           servicegroups           irods-resource
           check_command           check_irods_passive!This metric is part of the iRODS-All bundle and cannot be executed indepentently
           passive_checks_enabled  1
           active_checks_enabled   0
           }

   define service{
           use                     service-template
           hostgroup_name          irods-resources
           service_description     org.irods.irods4.Resource-Iget
           servicegroups           irods-resource
           check_command           check_irods_passive!This metric is part of the iRODS-All bundle and cannot be executed indepentently
           passive_checks_enabled  1
           active_checks_enabled   0
           }

   define service{
           use                     service-template
           hostgroup_name          irods-resources
           service_description     org.irods.irods4.Resource-Irm
           servicegroups           irods-resource
           check_command           check_irods_passive!This metric is part of the iRODS-All bundle and cannot be executed indepentently
           passive_checks_enabled  1
           active_checks_enabled   0
           }

And the following templates:

.. code-block::

   define host{
           name                            irods-resource-template
           use                             host-template
           hostgroups                      irods-resources
           icon_image                      irods.png
           statusmap_image                 irods.gd2
           register                        0
           }

   define service{
           name                            irods-resource-template
           use                             service-template
           service_description             org.irods.irods4.Resource-All
           servicegroups                   irods-resource
           check_interval                  60
           retry_interval                  15
           register                        0
           }

This template can now be used to define a resource monitoring, like:

.. code-block::

   define host{
           use                     irods-resource-template
           host_name               irods.example.org
           alias                   iRODS Resource
           address                 192.168.1.2
           contact_groups          irods_admin
           }

   define service{
           use                     irods-resource-template
           host_name               irods.example.org
           check_command           check_irods_resource_all!demoResc
           }


License
=======

The iRODS monitoring probes are released under the Apache License, Version 2.0.


Hacking
=======

The source code is hosted on the `France-Grilles Github project <https://github.com/francegrilles/monitoring-irods>`_.

Issues are managed through the `Github ticketing system <https://github.com/francegrilles/monitoring-irods/issues>`_.

