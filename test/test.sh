perl ../simulateLinkedReads.pl -r ./ecoli.fa -p ./test1 -c fragmentSizesList -x 1 -f 50 -t 1 -m 10 -o -4 1 -7 1

#Run Supernova on simulated data
#supernova run --id=supernovaRun1 --fastqs=./

# Expected results on Supernova
# --------------------------------------------------------------------------------
# SUMMARY
# --------------------------------------------------------------------------------
# - Sun Dec 18 11:20:11 2016
# - [run1]- commit hash = 0fde026
# - assembly checksum = 477,846,445,156,571
# --------------------------------------------------------------------------------
# INPUT
# -    2.00 M   = READS          = number of reads; ideal 800-1200 for human
# -  139.00 b   = MEAN READ LEN  = mean read length after trimming; ideal 140
# -   73.66 %   = READ TWO Q30   = fraction of Q30 bases in read 2; ideal 75-85
# -    0.34 kb  = MEDIAN INSERT  = median insert size; ideal 0.35-0.40
# -  100.00 %   = PROPER PAIRS   = fraction of proper read pairs; ideal >=75
# -   68.50 kb  = MOLECULE LEN   = weighted mean molecule size; ideal 50-100
# -    1.66 kb  = HETDIST        = mean distance between heterozygous SNPs
# -    0.00 %   = UNBAR          = fraction of reads that are not barcoded
# - 1084.00     = BARCODE N50    = N50 reads per barcode
# -    0.12 %   = DUPS           = fraction of reads that are duplicates
# -   90.23 %   = PHASED         = nonduplicate and phased reads; ideal 45-50
# --------------------------------------------------------------------------------
# OUTPUT
# -    0.01 K   = LONG SCAFFOLDS = number of scaffolds >= 10 kb
# -    6.08 kb  = EDGE N50       = N50 edge size
# -    7.09 kb  = CONTIG N50     = N50 contig size
# -    3.47 Mb  = PHASEBLOCK N50 = N50 phase block size
# -    2.39 Mb  = SCAFFOLD N50   = N50 scaffold size
# -    1.57 Mb  = SCAFFOLD N60   = N60 scaffold size
# -    0.00 Gb  = ASSEMBLY SIZE  = assembly size (only scaffolds >= 10 kb)
# --------------------------------------------------------------------------------
