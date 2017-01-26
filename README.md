## LRSIM: Simulator for Linked Reads

This package simulates whole genome sequencing using 10X Genomics Linked Read technology.  We have attempted to realistically capture all of the relevant steps of the 10X protocol so that it can be used to faithfully evaluate linked read sequencing of different genomes, mutation rates, input libraries, and short read sequencing conditions in silico. We have tested the package with both <a href="https://support.10xgenomics.com/genome-exome/software/pipelines/latest/what-is-long-ranger">LongRanger</a> and <a href="https://support.10xgenomics.com/de-novo-assembly/software/overview/welcome">SuperNova</a> to confirm that variant identifation, phasing, and de novo assembly are supported. We also encourage users to use these simulations to aid in the development of novel algorithms. Please feel free to contact us if your pipelines require additional features.

## Getting Started

```
git clone --recursive https://github.com/aquaskyline/LRSIM.git
cd 10xReadsSimulator
sh make.sh
cd test
sh test.sh
```

## Tips to run
1. Please review the <a href="https://www.10xgenomics.com/">10X Genomics</a> website for an overivew of the sequencing process and the definitions of the related terms. Note that 'Molecule' and 'Partition' are synonymous to 'Fragment' and 'Pool'.
2. The simulated reads were tested to be compaitible with LongRanger and SuperNova.
3. The default parameters are similar to 10x's standard protocal for human genome.
4. Set -z to run DWGSIM in parallel. For the human genome, each copy of DWGSIM takes 4GB memory. Set -z to the number of available cores if you have enough memory.
5. For the human genome, the memory consumption peaks at 48GB, and takes about 5 hours to finish with default parameters.
6. With the same output prefix `-p`, you can continue from step 4: Simulate reads using option `-u 4` with different `-f` (fragment size), `-t` (partitions to generate) and `-m` (average number of molecules per partition). This shortern the simulation from 5 hours to 1.5 hours for human.
7. Please use this pipeline for non-human genomes at your own risk. You may want to use `-o` to skip valid range check on parameters. You shouldn't set `-m` to over 4700, which is the number of available barcodes, or the program will not run to the end. Note that the default barcoding parameters do not perform well for small genomes (<100Mbp).
8. I hate asking users to install dependencies, so they are included in the repo (make sure to use git clone --recursive). If you still run into problem, please write to me.


## Parameters
```
  Usage:   ../../pgmT/simulateLinkedReads.pl -r <reference> -p <output prefix> [options]

  Reference genome and variants:
  -d INT      Haplotypes to simulate [2]
  -1 INT      1 SNP per INT base pairs [1000]
  -2 INT      Minimum length of Indels  [1]
  -3 INT      Maximum length of Indels  [50]
  -4 INT      # of Indels  [1000]
  -5 INT      Minimum length of Duplications, Translocations and Inversions [1000]
  -6 INT      Maximum length of Duplications, Translocations and Inversions [10000]
  -7 INT      # of Duplications, # of Translocations and # of Inversions [100]

  Illumina reads characteristics:
  -e FLOAT    Per base error rate of the first read [0.0001,0.0016]
  -E FLOAT    Per base error rate of the second read [0.0001,0.0016]
  -i INT      Outer distance between the two ends for pairs [350]
  -s INT      Standard deviation of the distance for pairs [35]

  Linked reads parameters:
  -b STRING   Barcodes list
  -x INT      # million reads pairs in total to simulated [600]
  -f INT      Mean molecule length in kbp [100]
  -t INT      n*1000 partitions to generate [1500]
  -m INT      Average # of molecules per partition [10]

  Miscellaneous:
  -u INT      Continue from a step [auto]
  1. Variant simulation
  2. Build fasta index
  3. DWGSIM
  4. Simulate reads
  5. Sort reads extraction manifest
  6. Extract reads
  -z INT      # of threads to run DWGSIM [8]
  -o          Disable parameter checking
  -h          Show this help
```
The ratio of homozygous to heterzygous variant is hardcoded as 1:2.

## Acknowledgement
The simulator uses a modified version of DWGSIM originally developed by Nils Homer (nh13/DWGSIM) and SURVIVOR by Fritz Sadlezeck (fritzsedlazeck/SURVIVOR).

## License
```
  The MIT License (MIT)
  Copyright (c) 2016 Ruibang Luo <aquaskyline@gmail.com>
 
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is furnished
  to do so, subject to the following conditions:
 
  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.
 
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```

