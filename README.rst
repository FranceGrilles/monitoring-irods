Monitoring - iRODS
==================

This repository aims to provide a set of Nagios probes for monitoring iRODS instances.


Install
-------

To work correctly, the Nagios server should be setup correctly to access iRODS, i.e. by installing [iRODS client RPMs](www.grand-est.fr/yum/irods/).
 
Then, configure Nagios to access the iRODS instance by adding the `/var/spool/nagios/.irods/.irodsEnv` file with the following content (replace the value with your settings):
```
irodsHost 'irods.example.org'
irodsPort 1247
irodsUserName 'monitoring'
irodsZone 'EXAMPLE'
irodsHome '/EXAMPLE/home/monitoring'
irodsDefResource 'example-disk0'
```

Check that the installation is working:
```
# sudo -u nagios iinit
# sudo -u nagios ils
```

Once iRODS commands are working fine, copy the Nagios probes in the plugins directory:
```
# cp plugins/* /usr/lib64/nagios/plugins/
```
