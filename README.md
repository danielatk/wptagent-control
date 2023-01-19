# wptagent-control

Still pending:
* environment variables for wptserver url and full path of wpt control directory.

For the meanwhile it is necessary to run the script via command line. If the script should be run with cron then all the scripts must contain the full path of the wpt control directory.

It is also necessary to edit the 'wptagents' file with the MAC of each of the wptagents, one on each line. This MAC should also correspond with the wptagent location on the wptserver locations.ini file.
