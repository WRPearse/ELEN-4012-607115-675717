#!/bin/bash -ue
plink --bfile cleaned --threads 1 --assoc --out association
