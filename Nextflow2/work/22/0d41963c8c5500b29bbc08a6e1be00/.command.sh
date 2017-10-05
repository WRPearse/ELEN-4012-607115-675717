#!/bin/bash -ue
plink --bfile hapmap1 --keep-fam hapmap1Family5.fam --score hapmap1Family5.fam.assocSqueezed.assoc --out hapmap1Family5
