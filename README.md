# AWS-Sentinel-2-download-and-process

## What is it?
This project downloads Sentinel-2 data using an AWS EC2 instance, processes the L1C data to L2A data, then estimates biophysical parameters from the L2A data. The main script uploads each level of data to your chosen S3 bucket.

## Installation Instructions

### Preparing your EC2 Instance
1. Log in to Amazon EC2 and launch new Ubuntu instance
    - Pick your instance type (I used t3.2xlarge) and storage. Uncheck the “Delete on Termination” box when adding your storage volume.
    - For Step 6: Configure Security group, add the following rule:
        Type: Custom TCP Rule
        Port Range: 5901
        Source: Anywhere
    - After review and launch, create a new key file and save it to your computer (note where it is saved)
2.	Download PuTTy to connect to the EC2 instance
    - In PuTTy, enter public DNS of instance under Host Name
	- Switch to Connection category and enter how many seconds you want between keepalives
	- Under Connection, expand the SSH sub-menu and go to Auth
	- Attach your instance private key file
	- Under Tunnels, add source port: 5902 with destination: <your instance’s IP address>:5901
	- Save the session then click open
	- When prompted for username, type ubuntu
3.	For a GUI, download TightVNC for Windows or VNCViewer for Linux
	- The address/name you want to connect to will be localhost:5902
	- https://medium.com/@s.on/running-ubuntu-desktop-gui-aws-ec2-instance-on-windows-3d4d070da434 for more detailed instructions
4.	Download Filezilla for file transfer between your computer and EC2 Instance
	- To connect to your instance, open the site manager and add a new site as follows:
		- Host: <your instance’s Public DNS>
		- Port: 22
		- Logon Type: Key File
		- User: ubuntu
	- Attach your instance key file

### Preparing your environment to run s2 toolbox processing
5.	Transfer 7_Sen2cor_SL2P directory to instance with Filezilla
6.	Remove Anaconda3 folder
    - $ rm -rf anaconda3
7. edit ~/.profile file to prepend /home/ubuntu/anaconda2 to PATH so that when you call python from the command line it is the right version
    - $ nano ~/.profile
    - cmd + X to save and close the file
    - restart your PuTTy session to trigger the new PATH

7.	Follow the next instructions: 
http://forum.step.esa.int/t/proposition-of-a-step-by-step-tuto-to-install-sen2cor-on-ubuntu-vm-16-10/4370

For installation of ubuntu 16.10 with sen2cor 2.4.0 and Snap
I will share all my command line.
With this way, we obtain a functional Production server for L2A sentinel products

#### Installation of SSH (for remote access to the server):
    - sudo apt-get install ssh

#### Test anaconda
in a terminal enter:
python
it will open an interpreter with anaconda mentionned
now check the path of python
which python
my own path is for example (note this path for later)
/home/ndjamai/anaconda2/bin/python

#### Installing SNAP:

mkdir /home/ndjamai/SNAP
cd /home/ndjamai/SNAP
wget http://step.esa.int/downloads/5.0/installers/esa-snap_all_unix_5_0.sh
sudo sh esa-snap_all_unix_5_0.sh -c

when snap ask about configuration of python, do it and enter the path of python you have noted during anaconda install(in my case: /home/geouser/anaconda2/bin/python)

go to snappy/snappy folder and run
python setup.py install
copy snappy folder to /home/ubuntu/anaconda2/lib/python2.7/site-packages

Installing SEN2COR:

mkdir /home/ndjamai/SEN2COR
cd /home/ndjamai/SEN2COR
cd /home/ndjamai/SEN2COR
copy over sen2cor-2.4.0.tar.gz file to instance from your computer
tar xvzf sen2cor-2.4.0.tar.gz
cd sen2cor-2.4.0

Be careful with the next step: if there is an error you have probably a problem with your python path...
python setup.py install

Next you have to define environment variables:
sudo nano /etc/bash.bashrc

add the following lines at the end of the doc , save and quit

export SEN2COR_HOME=/home/ndjamai/sen2cor
export SEN2COR_BIN=/home/ndjamai/anaconda2/lib/python2.7/site-packages/sen2cor-2.4.0-py2.7.egg/sen2cor
export GDAL_DATA=/home/ndjamai/anaconda2/lib/python2.7/site-packages/sen2cor-2.4.0-py2.7.egg/sen2cor/cfg/gdal_data

downgrade anaconda packages so they are compatible:
conda install gdal=2.1.0

allow L2A_Process.py script to  be run:
chmod +x /home/ndjamai/anaconda2/lib/python2.7/site-packages/sen2cor-2.4.0-py2.7.egg/sen2cor/L2A_Process.py

Now you can check sen2cor with this command line:
L2A_Process

### Set-up for SL2P biophysical parameter estimation
8.	Install Matlab runtime from https://www.mathworks.com/products/compiler/matlab-runtime.html
The command line install instructions are here:
https://www.mathworks.com/help/compiler/install-the-matlab-runtime.html

a.	After installation, add line to ~/.profile to append LD_LIBRARY_PATH environment variable with path given in installation
Export LD_LIBRARY_PATH=$LD_LIBRARY_PATH/<path given at end of installation>
9.	Install AWS CLI with pip install awscli –upgrade –user
a.	If pip gives error, open /home/ubuntu/anaconda2/lib/python2.7/site-packages/pip/_vendor/distro.py
b.	Edit line in __init__ method to be:
def __init__(self,
    include_lsb=True,
    os_release_file='',
    distro_release_file=''):
	
### Set up AWS CLI for upload of data to bucket
10.	Run aws configure
11.	Run main.py from 7_Sen2cor_SL2P


## To access your EC2 Instance after set-up:
1.	Open PuTTy
2.	Click your saved session, then click Load
3.	Select Open
4.	When prompted for username, enter ubuntu
After connecting to the instance with PuTTy, the GUI can be accessed by:
1.	Opening VNCViewer
2.	Either loading the previously saved session OR typing localhost:5902 in the address bar
3.	It will prompt for your password before opening the GUI window


If something goes wrong with the GUI, close the window and in the PuTTy terminal window, type the following commands:
vncserver –kill :1
vncserver –geometry <the dimensions of your monitor> :1
This will restart the VNC connection and when  you re-connect through VNCViewer it should work properly.
