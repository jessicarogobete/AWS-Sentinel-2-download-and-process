# AWS-Sentinel-2-download-and-process

## What is it?
This project runs a python script on an AWS EC2 instance which downloads Sentinel-2 data, processes the L1C data to L2A data with Sen2cor, then estimates biophysical parameters from the L2A data. The main script uploads each level of data to your chosen S3 bucket. Currently an AMI which works with this script is available as Sentinel-2 SL2P.

## Use instructions

First you need an EC2 ubuntu instance configured to run all the processes required by the script. The public AMI mentioned earlier is the simplest way to prepare this, but instructions are also provided below to set up the instance from scratch.

### To access your EC2 Instance after set-up:
1.	Open PuTTy
2.	Click your saved session, then click Load
3.	Select Open
4.	When prompted for username, enter ubuntu
After connecting to the instance with PuTTy, the GUI can be accessed by:
1.	Opening VNCViewer
2.	Either loading the previously saved session OR typing localhost:5902 in the address bar
3.	It will prompt for your password before opening the GUI window

If something goes wrong with the GUI, close the window and in the PuTTy terminal window, type the following commands:
```
vncserver –kill :1
vncserver –geometry <the dimensions of your monitor> :1
```
This will restart the VNC connection and when  you re-connect through VNCViewer it should work properly.
 Once the instance is set up, you only need to alter the parameters for the data you wish to download at the start of the main script, then call the script in the terminal with 

```
$ python main.py
```

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
	- See https://medium.com/@s.on/running-ubuntu-desktop-gui-aws-ec2-instance-on-windows-3d4d070da434 for more detailed instructions
4.	Download Filezilla for file transfer between your computer and EC2 Instance
	- To connect to your instance, open the site manager and add a new site as follows:
		- Host: <your instance’s Public DNS>
		- Port: 22
		- Logon Type: Key File
		- User: ubuntu
	- Attach your instance key file

### Preparing your environment to run s2 toolbox processing
5.	Transfer 7_Sen2cor_SL2P directory to instance using Filezilla
6. Create an anaconda environment with python 2.7 and the necessary libraries
```
conda create -n <name of your environment (ex. 2.7)> python=2.7 gdal=2.1.0 pytables
source activate 2.7

```

With this way, we obtain a functional Production server for L2A sentinel products

Installation of SSH (for remote access to the server):
```
sudo apt-get install ssh
```

Test anaconda with the following terminal commands:
```
python
which python
```
This opens an interpreter with anaconda, then checks the path of python . My own path is, for example, (note this path for later)
: `/home/ubuntu/anaconda2/bin/python`

#### Installing SNAP:

    mkdir /home/ubuntu/SNAP
    cd /home/ubuntu/SNAP
    wget http://step.esa.int/downloads/6.0/installers/esa-snap_all_unix_6_0.sh
    sudo sh esa-snap_all_unix_6_0.sh -c

When snap asks about configuration of python, do it and enter the path of python you have noted during anaconda installation (in my case: /home/ubuntu/anaconda3/bin/python).
- allow /home/ubuntu/.snap folder to be modified by changing permissions
```
sudo chown -R ubuntu:ubuntu /home/ubuntu/.snap
```
- Navigate to SNAP installation directory, then run the snappy-conf file in the /bin directory to configure snap for python. This creates a snappy folder in conda environment
```
cd /opt/snap/bin
./snappy-conf /home/ubuntu/anaconda3/envs/py2.7/bin/python /home/ubuntu/anaconda3/envs/py2.7/lib/python2.7/site-packages
```
Re-name snappy folders to snappy_esa so there is no interference with dask package, then alter the dask file to call snappy_esa instead of snappy
```
mv /home/ubuntu/anaconda3/envs/py2.7/lib/python2.7/site-packages/snappy /anaconda3/envs/py2.7/lib/python2.7/site-packages/snappy_esa
mv /home/ubuntu/anaconda3/envs/py2.7/lib/python2.7/site-packages/snappy_esa/snappy.ini /anaconda3/envs/py2.7/lib/python2.7/site-packages/snappy_esa.ini
nano /home/ubuntu/anaconda3/envs/py2.7/lib/python2.7/site-packages/dask/bytes/compression.py
```
If in the folder /home/ubuntu/.snap/snap-python, there is no snappy folder, then copy it over
```
cp /anaconda3/envs/py2.7/lib/python2.7/site-packages/snappy_esa /home/ubuntu/.snap/snap-python
```
- Go to snappy folder and run
```
    python setup.py install
```

#### Installing SEN2COR:
	mkdir /home/ubuntu/SEN2COR
	cd /home/ubuntu/SEN2COR
	cd /home/ubuntu/SEN2COR
	copy over sen2cor-2.4.0.tar.gz file to instance from your computer
	tar xvzf sen2cor-2.4.0.tar.gz
	cd sen2cor-2.4.0
	python setup.py install
	
- If there is an error with the last step, you have probably a problem with your python path. 

- Define environment variables:
```
sudo nano /etc/bash.bashrc
```
- add the following lines at the end of the doc , save and quit:

  - export SEN2COR_HOME=/home/ubuntu/sen2cor
  - export SEN2COR_BIN=/home/ubuntu/anaconda2/lib/python2.7/site-packages/sen2cor-2.4.0-py2.7.egg/sen2cor
  - export GDAL_DATA=/home/ubuntu/anaconda2/lib/python2.7/site-packages/sen2cor-2.4.0-py2.7.egg/sen2cor/cfg/gdal_data

Install necessary python packages:
 ```
 pip install psutil
 pip install scipy
 pip install scikit-image
 pip install pebble
```
**********
Allow L2A_Process.py script to  be run:
```
chmod +x /home/ubuntu/anaconda2/lib/python2.7/site-packages/sen2cor-2.4.0-py2.7.egg/sen2cor/L2A_Process.py
```
**********
Now you can check sen2cor with this command line:
```
L2A_Process
```
###  Set-up for SL2P biophysical parameter estimation
8.	Install Matlab runtime from https://www.mathworks.com/products/compiler/matlab-runtime.html
```
mkdir /home/ubuntu/temp
wget http://ssd.mathworks.com/supportfiles/downloads/R2018b/deployment_files/R2018b/installers/glnxa64/MCR_R2018b_glnxa64_installer.zip
```
- The command line install instructions can be found at 
https://www.mathworks.com/help/compiler/install-the-matlab-runtime.html

 - After installation, add line to ~/.profile to append LD_LIBRARY_PATH environment variable with path given in installation
 ```
 sudo nano ~/.profile
 Export LD_LIBRARY_PATH=$LD_LIBRARY_PATH/<path given at end of installation>
```
9.	Install AWS CLI with ```pip install awscli --upgrade --user```
 - If pip gives error, open `/home/ubuntu/anaconda2/lib/python2.7/site-packages/pip/_vendor/distro.py`
 - edit the following line in __init__ method to be:
```
def __init__(self,
	    include_lsb=True,
	    os_release_file='',
	    distro_release_file=''):
```

### Set up AWS CLI
10.	Run aws configure

### Set up environment for downloading Sentinel-2 data from AWS S3 bucket
Create an anaconda environment with python 3.7
```
conda create -n 3.7 python=3.7
pip install sentinelhub
pip install matplotlib
pip install geopandas
pip install pebble
pip install pytest-shutil
```




