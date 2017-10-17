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
    sys.argv=["kFold.py","$setName","$noFolds","$workDir","$noBootstraps"]

from itertools import (takewhile,repeat)

setName = sys.argv[1]
shufName = setName + "Shuffled"
noFolds = int(sys.argv[2])
workDir = sys.argv[3]
noBootstraps = int(sys.argv[4])

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

for j in range(1,noBootstraps+1):
    lowerbound = 1
    os.chdir(workDir)
    cmdStr = "shuf " + setName + ".fam > " + shufName + str(j) + ".fam"
    subprocess.call(cmdStr,shell=True)

    for i in range(1,noFolds+1):
        if i <= subsetSize1:
            os.chdir(workDir)
            cmdStr = "sed -n '" + str(lowerbound) + "," + str(lowerbound + subsetValue1 -1) + "p' " + shufName + str(j) + ".fam > " + setName + "Fold" + str(i) + "Boot" + str(j) + ".fam"
            subprocess.call(cmdStr,shell=True)
            cmdStr = "mv " + setName + "Fold" + str(i) + "Boot" + str(j) + ".fam " + workPath
            subprocess.call(cmdStr,shell=True)
            lowerbound += subsetValue1
        else:
            cmdStr = "sed -n '" + str(lowerbound) + "," + str(lowerbound + subsetValue2 -1) + "p' " + shufName + str(j) + ".fam > " + setName + "Fold" + str(i) + "Boot" + str(j) + ".fam"
            os.chdir(workDir)
            subprocess.call(cmdStr,shell=True)
            cmdStr = "mv " + setName + "Fold" + str(i) + "Boot" + str(j) + ".fam " + workPath
            subprocess.call(cmdStr,shell=True)
            lowerbound += subsetValue2

    os.chdir(workDir)
    cmdStr = "rm " + shufName + str(j) + ".fam"
    subprocess.call(cmdStr,shell=True)
