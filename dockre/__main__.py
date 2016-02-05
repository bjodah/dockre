#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Command line tool for launching docker containers based on bjodah/bjodahimg
"""
from __future__ import (absolute_import, division, print_function)


import argh
import subprocess
import pkg_resources

from . import __version__


def conda_build(recipe, output, tag='latest', channels='', conda_py='',
                conda_npy='', image='bjodah/bjodahimgdev'):
    conda_build_script = pkg_resources.resource_filename(
        __name__, 'scripts/conda-build.sh')
    subprocess.Popen(
        [conda_build_script, recipe, output, channels, conda_py, conda_npy,
         image, tag], stderr=subprocess.STDOUT).communicate()


def build(tag='latest', inp='input/', out='output/', cmd="make",
          image='bjodah/bjodahimg'):
    """ Build out-of-tree with readonly input """
    build_script = pkg_resources.resource_filename(
        __name__, 'scripts/build.sh')
    subprocess.Popen(
        [build_script, inp, out, cmd, image, tag],
        stderr=subprocess.STDOUT).communicate()


def jupyter_notebook(tag='latest', mount='./', port=8888,
                     cmd="jupyter-notebook", image='bjodah/bjodahimg'):
    """ Start a jupyter notebook server """
    script = pkg_resources.resource_filename(
        __name__, 'scripts/jupyter-notebook.sh')
    subprocess.Popen(
        [script, mount, str(port), cmd, tag, image],
        stderr=subprocess.STDOUT).communicate()

funcs = dict(filter(lambda (k, v): not k.startswith('__') and callable(v),
                    locals().items()))


def main():
    argh.dispatch_commands(list(funcs.values()))


if __name__ in ('__main__', 'dockre.__main__'):
    main()
