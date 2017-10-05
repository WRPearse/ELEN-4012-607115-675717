#!/bin/bash -ue
plink --bfile hapmap1 --assoc --allow-no-sex --remove-fam hapmap1Family6.fam --out hapmap1Family6.fam
