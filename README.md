<h1>openhab-textual-configuration</h1>
I will share my configuration as an example for all of those, who will start with openHAB. On the other hand, I was often simply search for examples to configure a binding. Therefore its a pleasure for me to share my settings with hope, that you get an idea how to deal with it.</br></br>
Right from the beginnin, around 2016, i start with text base configuration. Today nearly all of my openhab configurations based on a textual setup. I'm sure some readers are wondering why. Well, I want to be able to test. The easiest way to do this is to edit my configuration or parts of it (e.g. a rule for sun protection) in my test environment. Once the change is running there, it is transferred to the productive environment.
I am convinced that an electrician or someone who has to implement such installations on the “assembly line” can do their work very effectively with this method.

This script or this approach should enable a simple and automated installation for openHAB. Without having to repeatedly reinstall the operating system on a different computer. The original idea behind this was a quick and effective installation of a test environment. In order to provide a test environment, the data of the “productive” installation must of course be transferred (backup). 

For more information about my "Smarthome" project, check my website <a href="http://www.berhorst.net/smarthome.html">www.berhorst.net</a>. There are more details about my environment, ideas and experiance i made. 

The next chapters should explain, how to work with this project.

<h3>Additional folder information</h3>

<h4>folder: default</h4>
Target for "default" is a fresh installation based on the initial setup of a new version of openHAB. The purpose is, when updating to a new version, where we can thus exclude potential errors during the upgrade.

<h4>folder: example</h4>
The example is a thin setup for a beginner, where i put some of my files into. It´s like a "DEMO" installation.

<h4>folder: binding-xxx</h4>
For each binding in this "environment", we have an extra folder with the corresponding files.
There are some exception: binding-a-main or binding-sgready</br>
They are not real binding, but contains some files which are indepndend from a real binding. "SG Ready" e.g. is a function for intelligent power management in connection with heat pumps and in my case photovoltaic.

<h4>about "z-backup"</h4>
I build my own simple backup solution. `backup.sh` is running at all server. `openhab-backup.sh` only at the prd and dev openhab server. This is required only for the function `back-restore-prd`. It can not run on the prd server, because i will prevent a mistack for the "production" environment.

<h3>about 1-setup.bash</h3>
This file is the primary installation script. If no parameters are specified, only the help will be displayed.

In my case, 3 different server are in use: production, development and sandbox.
In addition to my professional experience as an administrator in medium-sized and large companies, this has also developed with my use of openHAB for more than 10 years. The installation approach using scripts is certainly also a result of my professional experience.

You should/must set some parameter in your environment.  I recommend to set the following variables via /etc/profile per server/system you are plant to work with openhab. These are the /etc/profile for a sandbox. The following command should to all required things together :

```
cd
git clone https://github.com/rayb67/openhab-textual-config.git
echo "export OPENHAB_SETUP_SOURCE=/root/openhab-textual-config
export OPENHAB_SETUP_USERDATA=/var/lib/openhab
export OPENHAB_SETUP_ADDONS=/usr/share/openhab/addons
export OPENHAB_SETUP_CONF=/etc/openhab
export OPENHAB_SRV_TYPE=sand" >> /etc/profile
cd /root/openhab-textual-config
```

The variable `OPENHAB_SETUP_SOURCE` is the directory where the script itself and the other data “binding-...” etc. are located.
Keep in mind, today production and development run in a <a href="http://www.berhorst.net/docker.html">docker environment</a>. In case of docker i have other posiblities. Compare the `env.bash` Only a sandbox is running on a raspberry PI or in an VMware Fusion "virtual server" under my MacBook ;-) . 
Snapshot with VMware is really practical for testing e.g. the `1-setup.bash` script....

Of course everything is without guarantee. It's best to start with the “astro” binding and see how this approach works.

<h4>some rules</h4>
A few rules must be observed so that import and later automatic installation are possible.

a) Each .item and each .things file has the name e.g. of the binding. But the name is arbitrary and should help to organise the setup files. Especially in folder like items or rules, you are going to lost an overview very quickly. 

b) Each binding (or function) has a subfolder with the name `binding-<name>`

c) In the folder of the respective bindings there is an `install.bash` and a `backup.bash` file. The names of the associated files must be specified there. To create order, all files should start with the name of the binding. This also provides a certain overview of the many bindings you may be using. 

d) As with addons.cfg, runtime.cfg can also be distributed as the default. To do this, also store it in the directories (config-prd, example or default).

e) The settings for pages etc. in openHAB can also be “transferred”. However, this is not explicitly supported by openHAB! I have tested it and so far it works. To do this, I take the `uicomponents_ui_page.json` and `the uicomponents_ui_widget.json` files from the `/var/lib/openhab/jsondb` folder and put it in the config folder.

f) MariaDB or RRD4 is used as persistence in the installation. A database with the name `openhab` is used for this purpose. This can be installed with inst-db. Perhaps today i would switch to influx as a database.


**Example script call without parameter:**
```
root@server-dev:/nas/linux/install/openhab # ./1-setup.bash
env.bash - hostname mini
env.bash - Docker is : true

  ####################################################################
  #         parameter missing - try again ;-)                        # 
  ####################################################################

  Usage   :   ./1-setup.bash -c command [-b 'name name ...]

  Example : ./1-setup.bash -c inst-list
  Example : ./1-setup.bash -c inst-select -b astro
  Example : ./1-setup.bash -c inst-select -b astro systeminfo network

  -c  one of these commands

  env              - step 10 display the current variables in use

  ###############################################################
  inst-...         - 21-24 nativ installation into unix os
  inst-base        - step 21 prepare the environment
  inst-core        - step 22 install openhab core
  inst-default     - step 23 install openhab core
  inst-db          - step 24 install openhab database

  inst-example     - step 26 install an example setup

  inst-all         - step .. install 21,22,23,24 (experimental)

  ###############################################################

  inst-list        - step 50 list all addons from you source
                     (the list is detected by the folders name behind 'binding-'
  inst-select      - step 51 install bindings from parameter -b

  back-select      - stop 61 backup the selected files
                     (the list is detected by the folders name behind 'binding-'
  back-all         - step 70 backup configuration into the source folders

  ###############################################################

  docker-reset     - step 70 reset the installation
  docker-default   - step 71 install default

  back-restore-prd - step 80 restore last prd backup

  remove           - step 90 will remove / purge the installation

  -b  select bindings you will work on

root@server-dev:/nas/linux/install/openhab #
```
