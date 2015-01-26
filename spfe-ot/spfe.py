__author__ = 'Mark Baker'
__copyright__ = "Analecta Communications Inc. 2015"

import os
from os.path import expanduser
import argparse
import subprocess
import sys
import shutil


def do_clean(clean_args):
    response = input("Are you sure you want to delete " + spfe_build_dir + "? [Y/N]")
    if response.upper() == "Y":
        shutil.rmtree(spfe_build_dir)
        print("Cleaning " + spfe_build_dir)


def do_build(build_args):
    if os.path.isfile(build_args.config_file):
        print("Creating a " + build_args.build_type + " build  for " + build_args.config_file + " in " + spfe_build_dir)
        subprocess.call(['java',
                         '-classpath',
                         spfe_ot_home + '/tools/saxon9he/saxon9he.jar',
                         'net.sf.saxon.Transform',
                         '-it:main',
                         '-xsl:' + spfe_ot_home + '/1.0/scripts/config/config.xsl',
                         '-o:' + spfe_temp_build_file,
                         'configfile=' + os.path.abspath(build_args.config_file),
                         'HOME=' + home,
                         'SPFEOT_HOME=' + spfe_ot_home,
                         'SPFE_BUILD_DIR=' + spfe_build_dir,
                         'SPFE_BUILD_COMMAND=' + build_args.build_type])

        subprocess.call(['ant',
                         build_args.build_type,
                         '-f',
                         spfe_temp_build_file,
                         '-lib',
                         spfe_ot_home + r'\tools\xml-commons-resolver-1.2\resolver.jar',
                         '-emacs'], shell=True)
    else:
        print("Config file not found: " + build_args.config_file)
        sys.exit(1)


home = expanduser("~")
spfe_build_dir = os.environ.get("SPFE_BUILD_DIR")
if spfe_build_dir is None:
    spfe_build_dir = home + "\spfebuild"
spfe_ot_home = os.environ.get("SPFEOT_HOME")
spfe_temp_build_file = spfe_build_dir + "/spfebuild.xml"
print(spfe_temp_build_file)



parser = argparse.ArgumentParser(prog='spfe')
parser.add_argument("-v", "--verbosity", help="increase output verbosity", choices=["warning", "unresolved", "info"])
subparsers = parser.add_subparsers(help='Select the function to run')

parser_build = subparsers.add_parser('build', help='build a content set')
parser_build.add_argument('config_file', help='The path to the configuration file for the content set to build')
parser_build.add_argument("build_type", help="The type of output to build.", choices=["draft", "final"])
parser_build.set_defaults(func=do_build)

parser_clean = subparsers.add_parser('clean', help='clean the build directory')
parser_clean.set_defaults(func=do_clean)

args = parser.parse_args()
args.func(args)