# wptagent-control

## Description:

This is the server-side part of a wptagent automation project. This should be deployed  at a server where wptagent and other automation data should be stored at and works for any debian-based system.

The client-side part of this project is located in https://github.com/danielatk/wptagent-automation.

This executes WebPageTest jobs for a provided wptagent list. The jobs include webpage visits and youtube video reproductions. A list of top 100 visited websites in Brazil as well as 147 videos with 4K resolution options are given, but these can easily be customized to your necessities. 

## Deployment:

Download the setup script with the following command:
`curl https://raw.githubusercontent.com/danielatk/wptagent-control/main/setup.sh`
To run the script execute the following command:
`sh setup.sh`

Once the setup script has been executed fill in the wptagents file with one agent ID per line. Before doing this please run the setup automation script in the wptagent device, from the client-side project:
```
curl https://raw.githubusercontent.com/danielatk/wptagent-automation/main/scripts/setup_wptagent.sh
sh setup_wptagent.sh
```
Get the device's MAC address, which is gathered by this script, and add it to the wptagents list as that wptagent's ID.
After running the script the MAC address will be located in:
`~/wptagent-automation/mac`

To automate the execution of WPT jobs for each agent in the list, add a cronjob for the `execute_wpt.sh` script.
For example, to run a job every 5 minutes execute the following commands:
`crontab -e` (this opens the cron editor)
`*/5 * * * * bash ~/wptagent-control/execute_wpt.sh > ~/wptagent-control/crontab_log 2> ~/wptagent-control/crontab_error`

For the agents to communicate effectively an SSH server must be configured in the collection server machine.