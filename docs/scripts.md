# General
Inorder for any script to run you need to `chmod +x` the script and have bash.

# init.sh
This script will turn on all the services inside the repository.

# stop.sh
This will compose down all the services that are running

# get_services.sh
It will create a txt file that will store all the services and compose names for the testing script to use. Inorder for this script to run you will need to have installed these commands
- `yq`
- `grep`
- `sed`

On Mac or linux use your package manager to install the commands ie:
- `brew install <command>` mac
- `sudo dnf install <command` Fedora/RHEL/Rocky Linux

On windows I don't know how you would do this. The commands need to be installed so the bash script can use them. Which is different from simply being able to use them in powershell.


# testing.sh
You need to have bash 4 or higher installed. On mac you need to install the new bash because mac only has 3.12.
> [!WARNING] Do not remove the old version of bash on your mac. If using brew `brew install bash` will get you what you need

This script has 3 parts
- Part 1 Startup
- Part 2 Rebuilding
- Part 3 Ending

Features of the script
- [Startup](#startup) specified services or composes
- [Rebuild](#rebuilding) specific services or composes
- [Run](#anycommand) any command inside the script
- [Saves](#saveinput) the what services you rebuild last
- [Stop](#ending) all running services

## terms
- **service**: This reverse to a single container
- **compose**: This referse to all services inside of a compose

<a id="startup"></a>
## How to run the script
This script takes command line arguments seperated by a space. They are the services or composes that you want to turn on at startup. By default the network compose gets spun up so you don't have to specify it.
`./testing.sh <service> <service> <service>`
> [!NOTE] No command line argument will turn everything on

<a id="rebuilding"></a>
## Rebuilding
If you are making changes to a single service use this to rebuild it to see if your change worked. Simply input the name of the service or compose you wish to rebuild into the script once running.
> [!NOTE] If you make a change to any of the networks you need to input network as a change along with any other things you changed. It will rebuild the networks

<a id="saveinput"></a>
If you hit Enter without any text the script will run the last rebuild inputs you used, or use the command line arguments you inputed if it's the first time at part 2 this run.

<a id="anycommand"></a>
To run any command simply put ! as the first character ie: `!docker ls` or `!ls -l enterprise`

To exit part 2 input `end`

<a id="ending"></a>
## Ending
You can either stop the services or compose down the services. Down stops them and deletes them so stop is generally preferable
