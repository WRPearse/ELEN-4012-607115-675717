#!/bin/bash -ue
plink --bfile hapmap1 --assoc --allow-no-sex --remove-fam hapmap1Family4.fam --out hapmap1Family4.fam
