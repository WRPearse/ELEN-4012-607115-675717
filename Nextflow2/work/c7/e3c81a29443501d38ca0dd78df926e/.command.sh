#!/bin/bash -ue
plink --bfile hapmap1 --assoc --allow-no-sex --remove-fam hapmap1Family9.fam --out hapmap1Family9.fam
