#!/bin/bash -ue
plink --bfile hapmap1 --keep-fam hapmap1Family6.fam --score hapmap1Family6.fam.assocSqueezed.assoc.score --out hapmap1Family6
