#!/usr/bin/env python
from __future__ import print_function
import sys
import subprocess
from subprocess import call
import math
import os
import logging
# Called as a template from nextflow
if len(sys.argv) == 1:
    sys.argv=["kFold.py","hapmap1","10","/home/wpearse/Documents/Nextflow/input"]

from itertools import (takewhile,repeat)

setName = sys.argv[1]
noFolds = int(sys.argv[2])
workDir = sys.argv[3]

workPath = os.path.dirname(os.path.realpath(__file__))

def file_len(fname):
    os.chdir(workDir)
    p = subprocess.Popen(['wc', '-l', fname], stdout=subprocess.PIPE,
                                              stderr=subprocess.PIPE)
    result, err = p.communicate()
    if p.returncode != 0:
        raise IOError(err)
    return int(result.strip().split()[0])

fileName = sys.argv[1]+".fam"
numberOfLines=file_len(fileName)

subsetSize1 = numberOfLines % (noFolds)
subsetValue1 = int(math.ceil(numberOfLines/float(noFolds)))
subsetValue2 = int(math.floor(numberOfLines/float(noFolds)))
lowerbound = 1

for i in range(1,noFolds+1):
    if i <= subsetSize1:
        os.chdir(workDir)
        cmdStr = "sed -n '" + str(lowerbound) + "," + str(lowerbound + subsetValue1 -1) + "p' " + setName + ".fam > " + setName + "Family" + str(i) + ".fam; mv " + setName + "Family" + str(i) + ".fam " + workPath + "/output"
        subprocess.call(cmdStr,shell=True)
        lowerbound += subsetValue1
    else:
        cmdStr = "sed -n '" + str(lowerbound) + "," + str(lowerbound + subsetValue2 -1) + "p' " + setName + ".fam > " + setName + "Family" + str(i) + ".fam; mv " + setName + "Family" + str(i) + ".fam " + workPath + "/output"
        os.chdir(workDir)
        subprocess.call(cmdStr,shell=True)
        lowerbound += subsetValue2
