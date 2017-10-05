#!/usr/bin/env nextflow

//---- General definitions --------------------------------------------------//

import java.nio.file.Paths

params.work_dir   = "$HOME/Documents/Nextflow"
params.input_dir  = "${params.work_dir}/input"
params.output_dir = "${params.work_dir}/output"

params.input_pat  = 'hapmap1'

params.no_folds = 10

params.plink_process_memory = '750MB' // how much plink needs for this
params.other_process_memory = '750MB' // how much other processed need

max_plink_cores = params.max_plink_cores = 1

plink_mem_req = params.plink_process_memory
other_mem_req = params.other_process_memory

//---- Modification of variables for pipeline -------------------------------//

// Checks if the file exists
checker = { fn ->
   if (fn.exists())
       return fn;
    else
       error("\n\n-----------------\nFile $fn does not exist\n\n---\n")
}

bed = Paths.get(params.input_dir,"${params.input_pat}.bed").toString()
bim = Paths.get(params.input_dir,"${params.input_pat}.bim").toString()
fam = Paths.get(params.input_dir,"${params.input_pat}.fam").toString()

process generateFolds {
   echo true
   input:
    set file(params.input_pat+'.fam') from params.input_dir
   publishDir params.output_dir, overwrite:true, mode:'copy'
   output:
      set file(params.input_pat+"Family*.fam") into families_ch1
      set file(params.input_pat+"Family*.fam") into families_ch2
   script:
    setName = params.input_pat
    noFolds = params.no_folds
    workDir = params.input_dir
    template "kFold.py"
}

input_ch = Channel.create()
Channel
    .from(file(bed),file(bim),file(fam))
    .buffer(size:3)
    .map { a -> [checker(a[0]), checker(a[1]), checker(a[2])] }
    .separate( input_ch ) { a -> [a,a] }

process associationTest {
   echo true
   family = params.input_pat+"Family*"
   input:
    set file(params.input_pat+'.bed'),file(params.input_pat+'.bim'),file(params.input_pat+'.fam') from input_ch
    each file(family) from families_ch1

   publishDir params.output_dir, overwrite:true, mode:'copy'
   output:
      file(family+".assoc") into assoc_ch
   script:
   setName = params.input_pat
   """
   plink --bfile $setName --assoc --allow-no-sex --remove-fam ${family} --out ${family}
   """
}

process squeeze {
   echo true
   fileName = params.input_pat+"Family*.fam.assoc"
   input:
    file(fileName) from assoc_ch
   publishDir params.output_dir, overwrite:true, mode:'copy'
   output:
      file(fileName+"Squeezed.assoc") into squeeze_ch
   script:
   """
   tr -s \\  < ${fileName} > ${fileName}Squeezed.assoc
   """
}

process makeScoreFile {
   echo true
   fileName = params.input_pat+"Family*.fam.assocSqueezed.assoc"
   input:
    file(fileName) from squeeze_ch
   publishDir params.output_dir, overwrite:true, mode:'copy'
   output:
      file(fileName+".score") into score_ch
   script:
   """
   cut -f 3,5,11 -d\\  ${fileName} >  ${fileName}.score
   """
}

input_ch2 = Channel.create()
Channel
    .from(file(bed),file(bim),file(fam))
    .buffer(size:3)
    .map { a -> [checker(a[0]), checker(a[1]), checker(a[2])] }
    .separate( input_ch2 ) { a -> [a,a] }

process scoreFamily {
   echo true
   fileName = params.input_pat+"Family*.fam.assocSqueezed.assoc.score"

   input:
    set file(params.input_pat+'.bed'),file(params.input_pat+'.bim'),file(params.input_pat+'.fam') from input_ch2
    set file(family) from families_ch2
    each file(fileName) from score_ch


   publishDir params.output_dir, overwrite:true, mode:'copy'
   output:
      file(params.input_pat+"Family*.profile") into result_ch
   script:
   setName = params.input_pat
   fileNameStr = fileName.getName()
   scoreFile = fileNameStr//.replaceFirst(/.score/,"")
   famFile = fileNameStr.replaceFirst(/.assocSqueezed.assoc.score/,"")
   outFile = fileNameStr.replaceFirst(/.fam.assocSqueezed.assoc.score/,"")
   """
   plink --bfile $setName --keep-fam $famFile --score $scoreFile --out $outFile
   """


}

//Channel.from(result_ch).subscribe onComplete { println "Cross trainign complete!!!" }
