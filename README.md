# wptagent-control

## Description:

This is the server-side part of a data collection automation project. This should be deployed at a server where WebPageTest collection and other automation data should be stored at and works for any debian-based system. 

It integrates with a client-side part of this project, which is located in https://github.com/danielatk/wptagent-automation. The server-side deployment is agnostic as to which kind of data is being sent by the clients, which can have it's suite of experiments extended using the standard that has been developed for the current tools. The server is responsible for the automatic scheduling of WebPageTest jobs for each of the clients. The jobs include webpage visits and youtube video reproductions. A list of top 100 visited websites in Brazil as well as 147 videos with 4K resolution options are given, but these can be easily customized.. The server maintains the current state of each of the clients, which regularly update their testing status via an SSH connection, to avoid concurrent tests. Since only one WebPageTest job can be active at any moment, if there are many clients it is recommended that more than one instance of the WebPageTest server is used.

## Deployment:

Download the setup script with the following command:
`curl https://raw.githubusercontent.com/danielatk/wptagent-control/main/scripts/first_setup.sh > first_setup.sh`
To run the script execute the following command:
`sh first_setup.sh`

This script simply clones the repository to the `~/` directory. Once that is done fill in the wptagents file with one agent ID per line. Before doing this please run the setup automation script in the wptagent device, from the client-side project:
```
curl https://raw.githubusercontent.com/danielatk/wptagent-automation/main/scripts/first_setup.sh
sh first_setup.sh
```
Get the device's MAC address, which is gathered by this script, and add it to the wptagents list as that wptagent's ID.
After running the script the MAC address will be located in:
`~/wptagent-automation/mac`

For the agents to communicate effectively to avoid concurrent tests an SSH server must be configured in the collection server machine. This must be done manually before continuing.

After doing this download and run the automation script of the server side:
```
curl https://raw.githubusercontent.com/danielatk/wptagent-control/main/scripts/automation_setup.sh > automation_setup.sh
sh automation_setup.sh
```