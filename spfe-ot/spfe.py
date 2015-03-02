__author__ = 'Mark Baker'
__copyright__ = "Analecta Communications Inc. 2015"

from datetime import datetime
start_time = datetime.now()
import os
import argparse
import sys
import shutil
import importlib

sys.path.append(sys.path[0] + '/1.0/scripts/python')
spfelib = importlib.import_module('spfelib')
#import spfelib


def do_clean(clean_args):
    response = input("Are you sure you want to delete " + spfe_build_dir + "? [Y/N]")
    if response.upper() == "Y":
        shutil.rmtree(spfe_build_dir)
        print("Cleaning " + spfe_build_dir)


def do_build(build_args):
    if os.path.isfile(build_args.config_file):
        print("Creating a " + build_args.build_type + " build  for " + build_args.config_file + " in " + spfe_build_dir)
        spfe_env = dict(((k, globals()[k]) for k in ('home', 'spfe_build_dir', 'spfe_ot_home', 'spfe_temp_build_file')))
        spfe_env.update({'spfe_build_command': build_args.build_type})
        config = spfelib.config.SPFEConfig(build_args.config_file, spfe_env)
        config.write_config_file()
        config.write_script_files()
        spfelib.build.build_content_set(config)
        end_time = datetime.now()
        print('Build completed in : {}'.format(end_time - start_time))
    else:
        print("Config file not found: " + build_args.config_file)
        sys.exit(1)

# Calculate the required directory names
home = os.path.expanduser("~").replace(os.path.sep, '/')
spfe_build_dir = os.environ.get("SPFE_BUILD_DIR")
if spfe_build_dir is None:
    spfe_build_dir = home + "/spfebuild"
spfe_build_dir.replace(os.path.sep, '/')
#spfe_ot_home = os.environ.get("SPFEOT_HOME").replace(os.path.sep, '/')
spfe_ot_home = os.path.dirname(os.path.realpath(__file__)).replace(os.path.sep, '/')
spfe_temp_build_file = spfe_build_dir + "/spfebuild.xml"


# Parse the command line
parser = argparse.ArgumentParser(prog='spfe')
parser.add_argument("-v", "--verbosity", help="increase output verbosity", choices=["warning", "unresolved", "info"])
subparsers = parser.add_subparsers(help='Select the function to run')

# build sub-command
parser_build = subparsers.add_parser('build', help='build a content set')
parser_build.add_argument('config_file', help='The path to the configuration file for the content set to build')
parser_build.add_argument("build_type", help="The type of output to build.", choices=["draft", "final"])
parser_build.set_defaults(func=do_build)

# clean sub-command
parser_clean = subparsers.add_parser('clean', help='clean the build directory')
parser_clean.set_defaults(func=do_clean)

# parse the args
args = parser.parse_args()
args.func(args)