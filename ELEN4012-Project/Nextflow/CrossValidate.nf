#!/usr/bin/env nextflow

bedDir = params.inputDir + "/" + params.setName + ".bed"
bimDir = params.inputDir + "/" + params.setName + ".bim"
famDir = params.inputDir + "/" + params.setName + ".fam"

maxPlinkCores = params.maxCores

input_ch = Channel.create()
input_ch2 = Channel.create()
Channel
    .from(file(bedDir),file(bimDir),file(famDir))
    .buffer(size:3)
    .separate( input_ch, input_ch2) { it -> [it,it] }

process generateFolds {
   output:
    file(params.setName+"Fold*.fam") into families_ch1
    file(params.setName+"Fold*.fam") into families_ch2
   script:
    setName = params.setName
    noFolds = params.numFolds
    noBootstraps = params.numBootstraps
    workDir = params.inputDir
    template "kFold.py"
}

process associationTest {
   cpus maxPlinkCores
   foldName = params.setName+"Fold*"

   input:
    set file(params.setName+'.bed'),file(params.setName+'.bim'),file(params.setName+'.fam') from input_ch
    each file(foldName) from families_ch1

   output:
      file(foldName+".assoc") into assoc_ch
   script:
   setName = params.setName
   foldNameStr = foldName.getName()
   assocFile = foldNameStr.replaceFirst(/.fam/,"")

   """
   plink --threads $maxPlinkCores --bfile $setName --assoc --allow-no-sex --remove-fam ${foldName} --out $assocFile
   """
}

process squeeze {
   foldAssoc = params.setName+"Fold*.assoc"
   input:
    file(foldAssoc) from assoc_ch

   output:
      file(params.setName+"*Squeezed.assoc") into squeeze_ch
   script:
   foldAssocName = foldAssoc.getName()
   squeezeFile = foldAssocName.replaceFirst(/.assoc/,"")
   """
   tr -s \\  < ${foldAssoc} > ${squeezeFile}Squeezed.assoc
   """
}

process makeScoreFile {
   echo = true
   foldScore = params.setName+"*.assoc"
   input:
    file(foldScore) from squeeze_ch

   output:
      file(params.setName+"*.score") into score_ch
   script:
   foldScoreName = foldScore.getName()
   scoreFile = foldScoreName.replaceFirst(/Squeezed.assoc/,"")

   """
   awk '(NR==1) || ( (\$9 >= ${params.pLower}) && (\$9 < ${params.pHigher}) )' ${foldScore} >  ${scoreFile}Temp
   cut -f 3,5,11 -d\\  ${scoreFile}Temp >  ${scoreFile}.score
   """
}

process scoreFamily {
   cpus maxPlinkCores
   scoreFile = params.setName+"*.score"

   input:
    set file(params.setName+'.bed'),file(params.setName+'.bim'),file(params.setName+'.fam') from input_ch2
    each file(scoreFile) from score_ch
    file(families) from families_ch2

   output:
      file(params.setName+"Fold*.profile") into result_ch

   script:
   setName = params.setName
   fileNameStr = scoreFile.getName()
   famFile = fileNameStr.replaceFirst(/.score/,".fam")
   outFile = fileNameStr.replaceFirst(/.score/,"")
   """
   plink --threads $maxPlinkCores --bfile $setName --keep-fam $famFile --score $scoreFile --out $outFile
   """
}

process mergeProfile {
  echo true
  input:
    file(profiles) from result_ch.toList()

  output:
    file(params.setName + ".result") into merge_ch

  publishDir params.outputDir, overwrite:true, mode:'copy'

  script:
    setName = params.setName
    noHeadlines = (params.numFolds*params.numBootstraps)-1
    """
    cat *.profile >> ${setName}.result
    tr -s \\  < ${setName}.result > ${setName}.temp
    sort -k 1 ${setName}.temp > ${setName}.result
    sed -i -e '1,${noHeadlines}d' ${setName}.result
    """
}

process BootstrapAnalysis {
  input:
    file(results) from merge_ch

  output:
    file(params.setName + ".output") into finish_ch

  publishDir params.outputDir, overwrite:true, mode:'copy'

  script:
    setName = params.setName
    template "BootstrapAnalysis.py"
}


finish_ch.subscribe(){println "Analysis Complete"}
