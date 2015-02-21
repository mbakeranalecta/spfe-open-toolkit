__author__ = 'Mark Baker'
__copyright__ = 'Analecta Communications Inc. 2015'

import subprocess
import os

def run_XSLT2(script, env, infile=None, outfile=None, initial_template=None, **kwargs):
    """
    Encapsulate an XSLT call so we can change how they are run.
    :param script: The file name of the XSLT script to be run.
    :param infile: The file name of the input to process.
    :param outfile: The file name of the output to create.
    :param initial_template: The name of the initial XSLT template to run.
    :param kwargs: Any parameters to pass to the XSLT script.
    :return: The output of the XSLT processes, unless output is specified.
    """
    try:
        process_call = ['java',
                        '-classpath',
                        env["spfe_ot_home"] + '/tools/saxon9he/saxon9he.jar' + os.pathsep +
                        env["spfe_ot_home"] + '/tools/xml-commons-resolver-1.2/resolver.jar',
                        'net.sf.saxon.Transform',
                        '-xsl:{0}'.format(script),
                        '-catalog:{0}'.format('file:///'+env["spfe_ot_home"]+'/../catalog.xml;file:///'+env["home"]+'/.spfe/catalog.xml')
        ]
        if infile:
            process_call.append('-s:{0}'.format(infile))
        if outfile:
            process_call.append('-o:{0}'.format(outfile))
        if initial_template:
            process_call.append('-it:{0}'.format(initial_template))
        for key, value in kwargs.items():
            process_call.append("{0}={1}".format(key, value))
        if outfile:
            subprocess.check_call(process_call)
            return None
        else:
            return subprocess.check_output(process_call)
    except subprocess.CalledProcessError as err:
        if err.returncode == 1:
            exit("Build failed due to error reported by XSLT script.")
        raise
