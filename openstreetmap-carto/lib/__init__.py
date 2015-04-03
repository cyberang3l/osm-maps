#!/usr/bin/env python
# -*- coding: utf-8 -*-

import re
import sys

from os import unlink, makedirs
from json import loads, dumps
from glob import glob
from shutil import rmtree, copy
from os.path import join, isdir, expanduser, exists
from collections import defaultdict

if not exists('./configure.py'):
    sys.stderr.write('Error: configure.py does not exist, did you forget to create it from the sample (configure.py.sample)?\n')
    sys.exit(1)
elif exists('./configure.pyc'):
    unlink('./configure.pyc')

from configure import config
from lib.utils import copy_tree

config["path"] = expanduser(config["path"])
print config["path"]

def clean():
  if isdir("build"):
    rmtree("build")

  for f in glob("build/*.html"): unlink(f)

def build():
  #copy the osm-bright tree to a build dir
  makedirs("build")
  makedirs("build/symbols")
  for file in glob(r'*.mss'):
    copy(file, "build")

  copy_tree("symbols", "build/symbols")
  copy("project.mml", "build")

  #load the project template
  templatefile = open(join('build', 'project.mml'))
  template = loads(templatefile.read())

  #fill in the project template
  for layer in template["Layer"]:
    if layer["id"] == "world":
      layer["Datasource"]["file"] = config["world"]
    elif layer["id"] == "coast-poly":
      layer["Datasource"]["file"] = config["coast-poly"]
    elif layer["id"] == "builtup":
      layer["Datasource"]["file"] = config["builtup"]
    elif layer["id"] == "necountries":
      layer["Datasource"]["file"] = config["necountries"]
    elif layer["id"] == "nepopulated":
      layer["Datasource"]["file"] = config["nepopulated"]
    else:
      # Assume all other layers are PostGIS layers
      for opt, val in config["postgis"].iteritems():
        if (val == ""):
          if (opt in layer["Datasource"]):
            del layer["Datasource"][opt]
        else:
          layer["Datasource"][opt] = val

  template["name"] = config["name"]

  #dump the filled-in project template to the build dir
  with open(join('build', 'project.mml'), 'w') as output:
    output.write(dumps(template, sort_keys=True, indent=2))

def install():
  assert isdir(config["path"]), "Config.path does not point to your mapbox projects directory; please fix and re-run"
  sanitized_name = re.sub("[^\w]", "", config["name"])
  output_dir = join(config["path"], sanitized_name)
  print "installing to %s" % output_dir
  copy_tree("build", output_dir)

if __name__ == "__main__":
  if sys.argv[-1] == "clean":
    clean()
  elif sys.argv[-1] == "build":
    build()
  elif sys.argv[-1] == "install":
    install()
  else:
    clean()
    build()
    install()
