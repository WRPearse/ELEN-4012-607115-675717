#!/bin/bash -ue
plink --bfile hapmap1 --keep-fam hapmap1Family8.fam --score hapmap1Family8.fam.assocSqueezed.assoc --out hapmap1Family8
