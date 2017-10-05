#!/bin/bash -ue
plink --bfile cleaned --score assocScorer.score --out familyScore
