"""
Command line tool for launching docker containers based on bjodah/bjodahimg
"""
from __future__ import (absolute_import, division, print_function)


import subprocess
import sys

import argh
import pkg_resources

from . import __version__


def _get_image(name):
    if name.startswith('.') or name.startswith('/'):
        # name is a path, let's invoke docker build:
        imgname = None
        token = 'Successfully built '  # hash of images follows this token
        proc = subprocess.Popen(['docker', 'build', name],
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        while proc.poll() is None:
            lout = proc.stdout.readline()
            if lout:
                print(lout, end='')
                if lout.startswith(token):
                    imgname = lout.rstrip('\n')[len(token):]
        if imgname is None:
            raise ValueError("Failed to catch %s" % token)
        return imgname
    else:
        return name


def conda_build(recipe, output, channels='', conda_py='',
                conda_npy='', image='bjodah/bjodahimgdev:latest'):
    conda_build_script = pkg_resources.resource_filename(
        __name__, 'scripts/conda-build.sh')
    subprocess.Popen(
        [conda_build_script, recipe, output, channels, conda_py, conda_npy,
         _get_image(image)], stderr=subprocess.STDOUT).communicate()


def build(inp='input/', out='output/', cmd="make",
          image='bjodah/bjodahimg18:latest', mounts='', envs=''):
    """ Build out-of-tree with readonly input """
    build_script = pkg_resources.resource_filename(
        __name__, 'scripts/build.sh')
    p = subprocess.Popen(
        [build_script, inp, out, cmd, _get_image(image)] +
        ['-v %s' % s for s in mounts.split(';') if s != ''] +
        ['-e %s' % s for s in envs.split(';') if s != ''],
        stderr=subprocess.STDOUT, stdin=subprocess.PIPE)
    p.communicate()


def jupyter_notebook(mount='./', port=8888, cmd="jupyter-notebook", image='bjodah/bjodahimg20:v1.1', envs=''):
    """ Start a jupyter notebook server """
    script = pkg_resources.resource_filename(
        __name__, 'scripts/jupyter-notebook.sh')
    p = subprocess.Popen(
        [script, mount, str(port), cmd, _get_image(image)] +
        ['-e %s' % s for s in envs.split(';') if s != ''],
        stderr=subprocess.STDOUT)
    out, err = p.communicate()

def work(mount='./', image="bjodah/bjodahimg20dot", command="bash"):
    work_script = pkg_resources.resource_filename(
        __name__, "scripts/work.sh")
    p = subprocess.Popen([work_script, mount, _get_image(image), command])
    out, err = p.communicate()

def version():
    print(__version__)


funcs = dict(filter(lambda kv: not kv[0].startswith('__') and callable(kv[1]),
                    locals().items()))


def main():
    sys.exit(argh.dispatch_commands(list(funcs.values())))
