# wptagent-control

This is the server-side part of a wptagent automation project. This should be deployed  at a server where wptagent and other automation data should be stored at.

This executes WebPageTest jobs for a provided wptagent list. The jobs include webpage visits and youtube video reproductions. A list of top 100 visited websites in Brazil as well as 147 videos with 4K resolution options are given, but these can easily be customized to your necessities. 

Download the setup script with the following command:
`curl https://raw.githubusercontent.com/danielatk/wptagent-control/main/setup.sh`
To run the script execute the following command:
`sh setup.sh`

Once the setup script has been executed fill in the wptagents file with one agent ID per line.

To automate the execution of WPT jobs for each agent in the list, add a cronjob gor the `execute_wpt.sh` script.
For example, to run a job every 5 minutes execute the following commands:
`crontab -e` (this opens the cron editor)
`*/5 * * * * bash ~/wptagent-control/execute_wpt.sh > ~/wptagent-control/crontab_log 2> ~/wptagent-control/crontab_error`