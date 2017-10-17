#!/usr/bin/env python
import sys
import logging
import csv
import math

if len(sys.argv) == 1:
    sys.argv=["BootstrapAnalysis.py","$setName"]


fileName = sys.argv[1] + '.result'
outputName = sys.argv[1] + '.output'

scores = []

with open(fileName) as inf:
    for row in csv.reader(inf, delimiter = " "):
        scores.append([row[1],row[6]])


newScores = []
scores.remove(scores[0])
previousID = scores[0][0]
tempScore = 0
counter = 0
variants =[]
minDev = 1
maxDev = 0
totalScore = 0
totalCount = 0
totalStdDev = 0

for x in range(len(scores)):
    if ( (scores[x][0] == previousID) or (x == len(scores)-1) ):
        variants.append(scores[x][1])
        tempScore += float(scores[x][1])
        counter += 1
        totalScore += float(scores[x][1])
        totalCount += 1
        previousID = scores[x][0]
    else:
        avgScore = tempScore/counter
        diffs = 0.0
        for y in range(len(variants)):
            diffs += math.pow( (avgScore-float(variants[y])), 2 )
        stdVar = math.sqrt(diffs/counter)
        newScores.append([previousID,avgScore,stdVar])
        tempScore = float(scores[x][1])
        counter = 1
        totalScore += float(scores[x][1])
        totalCount += 1
        totalStdDev += stdVar
        variants = []
        variants.append(scores[x][1])
        previousID = scores[x][0]

totalMean = totalScore/totalCount
avgStdDev = totalStdDev/totalCount
totalCV = 0

with open(outputName,'w') as f:
    f.write("FID\\tAVG_SCORE\\tSCORE_STD_DEV\\tCoefficient_of_Variation\\n")
    for line in range(len(newScores)):
        FID = newScores[line][0]
        AVG_SCORE = str("{:.8f}".format(newScores[line][1]))
        SCORE_STD_DEV = str("{:.10f}".format(newScores[line][2]))
        CVval = (newScores[line][2]/totalMean)
        totalCV += CVval
        CVstr = str("{:.10f}".format(CVval))
        f.write(FID + "\\t" + AVG_SCORE + "\\t" + SCORE_STD_DEV + "\\t" + CVstr + "\\n" )
    avgCV = totalCV/totalCount
    f.write("\\nAvgs:\\t" + str("{:.8f}".format(totalMean)) + "\\t" + str("{:.10f}".format(avgStdDev)) + "\\t" + str("{:.10f}".format(avgCV)))
