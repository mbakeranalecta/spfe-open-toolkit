spfe-open-toolkit
=================

The SPFE Open Toolkit

To make it run:

Unpack the archive to a suitable location.
Create an environment variable SPFEOT_HOME and set it to the location of the spfe-ot directory. For example: SPFEOT_HOME=/home/yourname/spfe/spfe-ot

1. Add the spfe-ot directory to your path.
2. If not already installed, install Java.
3. If not already installed, install Python 3.4 or later and add it to your path.
4. If not already installed, install the Python lxml and nltk libraries. 

An easy way to install Python 3.4 and the required libraries is to install a packaged 
version of Python that already includes the, such as Anaconda (http://continuum.io/downloads#py34). 

To build the SPFE docs:

1. Go to the directory spfe/spfe-docs/build.
2. Enter: spfe build spfe-docs-config.xml final. 

The build will create a directory spfebuild in your home directory. 
The SPFE docs will be in /spfebuild/spfe-docs/output.

