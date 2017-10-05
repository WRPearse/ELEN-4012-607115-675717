#!/bin/bash -ue
plink --bfile hapmap1 --keep-fam hapmap1Family7.fam --score hapmap1Family7.fam.assocSqueezed.assoc --out hapmap1Family7
