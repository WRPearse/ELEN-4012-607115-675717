#!/bin/bash -ue
plink --bfile hapmap1 --keep-fam hapmap1Family3.fam --score hapmap1Family3.fam.assocSqueezed.assoc --out hapmap1Family3
