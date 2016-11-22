#!/usr/bin/perl

# The MIT License (MIT)
# Copyright (c) 2016 Ruibang Luo <aquaskyline@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is furnished
# to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

use File::Basename;
use lib "./lib";
use lib dirname($0)."/lib";
use strict;
use warnings;
use feature 'state';
use threads;
use threads::shared;
use IO::Handle;
use Getopt::Std;
use Data::Dumper;
use Cwd 'abs_path';
use Math::Random qw(random_poisson random_uniform_integer);
use Inline 'C';

# Check dependencies
my $absPath = dirname(abs_path($0));
die "DWGSIM executable not found\n" if  (!-e "$absPath/dwgsim");
die "SURVIVOR executable not found\n" if  (!-e "$absPath/SURVIVOR");
die "SURVIVOR parameter list not found\n" if  (!-e "$absPath/parameter");
die "msort executable not found\n" if  (!-e "$absPath/msort");
die "extractReads executable not found\n" if  (!-e "$absPath/extractReads");
die "samtools executable not found\n" if  (!-e "$absPath/samtools");
die "fa_filter executable not found\n" if  (!-e "$absPath/faFilter.pl");
# Check dependencies end

# atExit
my $amazingGrace = 0;
my %fnToBeUnlinkAtExit = ();
sub signal_handler
{
  &log("Caught Cntl-C, cleaning up and exiting ...");
  if(not $amazingGrace) {foreach(keys %fnToBeUnlinkAtExit) { unlink("$_") || warn "unable to delete $_ at exit\n"; }}
  die;
}
sub signal_handler_wait { &log("Caught Cntl-C, but critical step is in progress, please wait a moment."); }
$SIG{INT} = $SIG{TERM} = \&signal_handler;
END { if(not $amazingGrace) { foreach(keys %fnToBeUnlinkAtExit) { unlink("$_") || warn "unable to delete $_ at exit\n"; }}}
# atExit end

&main;
0;

sub main
{
  our %opts = (h=>undef, o=>undef, d=>2, r=>undef, p=>undef, b=>undef, u=>99,
              e=>"0.0001,0.002", E=>"0.0001,0.002", i=>350, s=>35, x=>600, f=>50, t=>1500, m=>10);
  &usage(\%opts) if (@ARGV < 1);
  getopts('hod:r:p:b:u:e:E:i:s:x:f:t:m:', \%opts);
  &usage(\%opts) if (defined $opts{h});

  #Check options
  die "Number of haplotypes should be between 1 to 3\n" if ($opts{d} < 1 || $opts{d} > 3); #3 is a soft limit
  die "Please provide a reference genome with -r\n" if (not defined $opts{r});
  die "Please provide a output prefix with -p\n" if (not defined $opts{p});
  die "Output prefix (-p) cannot end with a /\n" if ($opts{p} =~ /\/$/);
  die "Please provide a barcodes file with -b\n" if (not defined $opts{b});
  die "Reference genome $opts{r} not exist\n" if (!-s "$opts{r}");
  die "Reference genome index $opts{r}.fai not exist\n" if (!-s "$opts{r}.fai");
  die "Barcodes file $opts{b} not exist\n" if (!-s "$opts{b}");
  die "Please provide a output prefix for this read simulation job with -p\n" if (not defined $opts{p});
  foreach(split /,/, $opts{e}) { die "The value of -e should be set between 0 and 1\n" if ( $_ < 0 || $_ > 1 ); }
  foreach(split /,/, $opts{E}) { die "The value of -E should be set between 0 and 1\n" if ( $_ < 0 || $_ > 1 ); }
  if(not defined $opts{o})
  {
    die "The value of -i should be set between 350 and 400\n" if ( $opts{i} < 350 || $opts{i} > 400 );
    die "The value of -s should be set between 35 and 40\n" if ( $opts{s} < 35 || $opts{s} > 40 );
    die "The value of -x should be set between 800 and 1200\n" if ( $opts{x} < 800 || $opts{x} > 1200 );
    die "The value of -f should be set between 20 and 150\n" if ( $opts{f} < 20 || $opts{f} > 150 );
    die "The value of -t should be set between 400 and 800\n" if ( $opts{t} < 400 || $opts{t} > 800 );
    die "The value of -m should be set between 5 and 15\n" if ( $opts{m} < 5 || $opts{m} >15 );
  }
  warn "$opts{p}.status exists\n" if (-e "$opts{p}.status");
  #Check options end

  #Global variables
  &Log("$opts{p}.status"); #Initializing Log routine
  our %barcodeErrorRateFromMismatchObv1 = (
  0=>{ "A"=>0.00243200183210607, "C"=>0.00265226825720049, "G"=>0.00238252487266703, "T"=>0.00247859241604291},
  1=>{ "A"=>9.84518532280806e-05,"C"=>0.000105418767099898,"G"=>0.00012024540587624, "T"=>0.000149312364560738},
  2=>{ "A"=>6.43035178977319e-05,"C"=>8.69887571314547e-05,"G"=>7.63701208403244e-05,"T"=>7.50233544318644e-05},
  3=>{ "A"=>7.23176133316617e-05,"C"=>8.47922299523897e-05,"G"=>7.09183994956776e-05,"T"=>9.2661673292949e-05},
  4=>{ "A"=>6.0728820107815e-05, "C"=>8.68149497299812e-05,"G"=>6.71073268524629e-05,"T"=>0.000104612297544355},
  5=>{ "A"=>5.75798861973855e-05,"C"=>6.53444346828966e-05,"G"=>6.45765176008781e-05,"T"=>9.95650559011039e-05},
  6=>{ "A"=>0.000113841438435535,"C"=>0.000140194463619207,"G"=>0.000193938780289159,"T"=>0.000151948068667371},
  7=>{ "A"=>0.000337649068858504,"C"=>0.000249891993056765,"G"=>0.000186216398571565,"T"=>0.000232127896750806},
  8=>{ "A"=>0.000208871197414734,"C"=>0.000252154220076128,"G"=>0.000218352053830969,"T"=>0.000268515970157629},
  9=>{"A"=>0.000220690984209116,"C"=>0.000171472165707382,"G"=>0.000161881515059254,"T"=>0.000244160685961411},
  10=>{"A"=>0.000217392257875513,"C"=>0.000222952327734294,"G"=>0.000193974762597782,"T"=>0.000228887240080449},
  11=>{"A"=>0.000200543541862804,"C"=>0.000196424451019658,"G"=>0.000162242944498548,"T"=>0.000226064717112528},
  12=>{"A"=>0.000204301845807882,"C"=>0.00021033089044356, "G"=>0.000204731464934722,"T"=>0.000255853410228468},
  13=>{"A"=>0.000201081348868472,"C"=>0.000242918171866774,"G"=>0.000236683915627231,"T"=>0.000240610244102754},
  14=>{"A"=>0.000213428902961876,"C"=>0.00025577076336335, "G"=>0.000205504040440625,"T"=>0.000223785784021304},
  15=>{"A"=>0.000376832758819433,"C"=>0.000361701876772859,"G"=>0.000321297197848344,"T"=>0.000475347661405257});
  our %barcodeErrorRateFromMismatchObv2 = (
  0=>{A=>{C=>0.0150060806230109,G=>0.0372176929088549,T=>0.0456575461284543,N=>1},C=>{A=>0.018543294755385,G=>0.038966807605046,T=>0.0544988281077176,N=>1},
      G=>{A=>0.0199607426916924,C=>0.0283670224586378,T=>0.0606673270456195,N=>1},T=>{A=>0.0114106115349607,C=>0.0240909626615095,G=>0.066435695729253,N=>1}},
  1=>{A=>{C=>0.248391841609553,G=>0.452225152780146,T=>0.563918024508456,N=>1},C=>{A=>0.271759809161439,G=>0.383139952595116,T=>0.596635639908786,N=>1},
      G=>{A=>0.253201640746953,C=>0.356231919488245,T=>0.612659080115662,N=>1},T=>{A=>0.0867939772665535,C=>0.315210731658511,G=>0.681413839419953,N=>1}},
  2=>{A=>{C=>0.35875670578243,G=>0.646852731962304,T=>0.73066954778514,N=>1},C=>{A=>0.343760589219978,G=>0.479971081907819,T=>0.793895808076938,N=>1},
      G=>{A=>0.285338081360802,C=>0.396841355796019,T=>0.763238404334643,N=>1},T=>{A=>0.105581623902801,C=>0.316107883346555,G=>0.785941934496185,N=>1}},
  3=>{A=>{C=>0.381603629518156,G=>0.720009551363568,T=>0.809796811399441,N=>1},C=>{A=>0.310711927790844,G=>0.494214799315343,T=>0.833901512819323,N=>1},
      G=>{A=>0.304626183783441,C=>0.425403239506486,T=>0.811649040628603,N=>1},T=>{A=>0.115669720635526,C=>0.338093421976441,G=>0.854613457687941,N=>1}},
  4=>{A=>{C=>0.422569262592116,G=>0.8786178694049,T=>0.993668893861723,N=>1},C=>{A=>0.418755753334043,G=>0.699391707797705,T=>0.994838536583109,N=>1},
      G=>{A=>0.416612808249673,C=>0.598519013218052,T=>0.994178503549868,N=>1},T=>{A=>0.171887212260899,C=>0.408418695997334,G=>0.995999176955996,N=>1}},
  5=>{A=>{C=>0.455596441354606,G=>0.890908380782869,T=>0.999912121879978,N=>1},C=>{A=>0.413720923086378,G=>0.692969916725563,T=>0.999904126847556,N=>1},
      G=>{A=>0.385448512090586,C=>0.537184675888728,T=>0.999902986763912,N=>1},T=>{A=>0.143105140923864,C=>0.376153257273678,G=>0.99994272535355,N=>1}},
  6=>{A=>{C=>0.406327122386922,G=>0.826869104480771,T=>0.997881317068697,N=>1},C=>{A=>0.374638212546548,G=>0.705784016041249,T=>0.998169578917216,N=>1},
      G=>{A=>0.310655760448629,C=>0.673039164730911,T=>0.998758410649673,N=>1},T=>{A=>0.238939465779065,C=>0.481877157622821,G=>0.998489829208511,N=>1}},
  7=>{A=>{C=>0.195755343642281,G=>0.597418219800039,T=>0.9999027098749,N=>1},C=>{A=>0.306706272884354,G=>0.623375596535977,T=>0.999887185275846,N=>1},
      G=>{A=>0.425573183339738,C=>0.644636465230306,T=>0.999868880685305,N=>1},T=>{A=>0.268149141057318,C=>0.583011172880877,G=>0.999894468159314,N=>1}},
  8=>{A=>{C=>0.518582892018808,G=>0.784930884223576,T=>0.999240164825784,N=>1},C=>{A=>0.27197526200349,G=>0.677298530767374,T=>0.999459461525574,N=>1},
      G=>{A=>0.298843598520712,C=>0.566920693914455,T=>0.999250351099056,N=>1},T=>{A=>0.206940109327211,C=>0.453842829047238,G=>0.999488510173712,N=>1}},
  9=>{A=>{C=>0.310375812444249,G=>0.711274446114916,T=>0.995279006975584,N=>1},C=>{A=>0.33198496434301,G=>0.682154642434746,T=>0.994291602749511,N=>1},
       G=>{A=>0.326298575650106,C=>0.623180862865886,T=>0.993958370958107,N=>1},T=>{A=>0.245572771549946,C=>0.509869938136896,G=>0.995911758726658,N=>1}},
  10=>{A=>{C=>0.328380850761973,G=>0.787038692763321,T=>0.999824876157147,N=>1},C=>{A=>0.314533542852326,G=>0.761671785760346,T=>0.999832485674823,N=>1},
       G=>{A=>0.394375376537983,C=>0.67886273624847,T=>0.999770609437724,N=>1},T=>{A=>0.215190322042968,C=>0.459559438903071,G=>0.999832267459712,N=>1}},
  11=>{A=>{C=>0.351088558521034,G=>0.789439220146743,T=>0.998694370574477,N=>1},C=>{A=>0.313613251580904,G=>0.711908553951083,T=>0.998681302505116,N=>1},
       G=>{A=>0.359368440646015,C=>0.617058478744723,T=>0.998362884254382,N=>1},T=>{A=>0.209646159907881,C=>0.468978015961584,G=>0.998889020344748,N=>1}},
  12=>{A=>{C=>0.393658697481948,G=>0.792198525518021,T=>0.999928449922612,N=>1},C=>{A=>0.410475580222229,G=>0.722234908570464,T=>0.999931264601499,N=>1},
       G=>{A=>0.374465971655011,C=>0.658098282400073,T=>0.99992428468644,N=>1},T=>{A=>0.253478004683067,C=>0.534648200183392,G=>0.99995165622933,N=>1}},
  13=>{A=>{C=>0.356711759499212,G=>0.728725231428964,T=>0.999992410855512,N=>1},C=>{A=>0.382426264718291,G=>0.663486603263781,T=>0.999997354906714,N=>1},
       G=>{A=>0.35486390882733,C=>0.602597758689963,T=>0.999991516359174,N=>1},T=>{A=>0.232284719632891,C=>0.495108208909138,G=>0.999995994302563,N=>1}},
  14=>{A=>{C=>0.319898694544483,G=>0.731679405112689,T=>1,N=>1},C=>{A=>0.37096552352182,G=>0.706085746854284,T=>1,N=>1},
       G=>{A=>0.390778933035154,C=>0.642144404001968,T=>1,N=>1},T=>{A=>0.273646850490209,C=>0.52192922481363,G=>1,N=>1}},
  15=>{A=>{C=>0.2932143024609,G=>0.710902898260362,T=>0.999975702185524,N=>1},C=>{A=>0.354878944582217,G=>0.677907230816238,T=>0.999974463693145,N=>1},
       G=>{A=>0.383118046981612,C=>0.670801741155919,T=>0.999968252627095,N=>1},T=>{A=>0.258755909167866,C=>0.495252896670793,G=>0.999974824047124,N=>1}});
  our %substitute = ( "A"=>["C", "G", "T", "N"], "C"=>["A", "G", "T", "N"], "G"=>["A", "C", "T", "N"], "T"=>["A", "C", "G", "N"] );
  #Global variables end

  #Goto checkpoint
  if($opts{u} == 1) { goto CHKPOINT1; }
  elsif($opts{u} == 2) { goto CHKPOINT2; }
  elsif($opts{u} == 3) { goto CHKPOINT3; }
  elsif($opts{u} == 4) { goto CHKPOINT4; }
  elsif($opts{u} == 5) { goto CHKPOINT5; }
  elsif($opts{u} == 6) { goto CHKPOINT6; }
  #Goto checkpoint end

  #Generate copies of haplotypes
  #Caveat: SURVIVOR supports only two haplotypes
  CHKPOINT1:
  {
    our $survivorPostprocess = 0;
    if(-e "$opts{p}.survivorA.fasta" && -e "$opts{p}.survivorB.fasta" &&
       -e "$opts{p}.survivor.hetA.insertions.fa" && -e "$opts{p}.survivor.hetB.insertions.fa" && -e "$opts{p}.survivor.homAB.insertions.fa" &&
       -e "$opts{p}.survivor.hetA.bed" && -e "$opts{p}.survivor.hetB.bed" && -e "$opts{p}.survivor.homAB.bed")
    { &Log("SURVIVOR done already"); }
    else
    {
      &Log("SURVIVOR start");
      ++$fnToBeUnlinkAtExit{"$opts{p}.survivorA.fasta"};
      ++$fnToBeUnlinkAtExit{"$opts{p}.survivorB.fasta"};
      ++$fnToBeUnlinkAtExit{"$opts{p}.survivor.hetA.insertions.fa"};
      ++$fnToBeUnlinkAtExit{"$opts{p}.survivor.hetB.insertions.fa"};
      ++$fnToBeUnlinkAtExit{"$opts{p}.survivor.homAB.insertions.fa"};
      ++$fnToBeUnlinkAtExit{"$opts{p}.survivor.hetA.bed"};
      ++$fnToBeUnlinkAtExit{"$opts{p}.survivor.hetB.bed"};
      ++$fnToBeUnlinkAtExit{"$opts{p}.survivor.homAB.bed"};
      ++$survivorPostprocess;
      &Log("Running: $absPath/SURVIVOR 0 $opts{r} $absPath/parameter 0 $opts{p}.survivor 1000");
      system("$absPath/SURVIVOR 0 $opts{r} $absPath/parameter 0 $opts{p}.survivor 1000 1>/dev/null");
      if(!-s "$opts{p}.survivorA.fasta")
      { &LogAndDie("SURVIVOR error on missing $opts{p}.survivorA.fasta"); }
      if(!-s "$opts{p}.survivor.hetA.insertions.fa")
      { &LogAndDie("SURVIVOR error on missing $opts{p}.survivorA.insertions.fa"); }
      if(!-s "$opts{p}.survivor.hetA.bed")
      { &LogAndDie("SURVIVOR error on missing $opts{p}.survivorA.bed"); }
      delete $fnToBeUnlinkAtExit{"$opts{p}.survivorA.fasta"};
      delete $fnToBeUnlinkAtExit{"$opts{p}.survivorB.fasta"};
      delete $fnToBeUnlinkAtExit{"$opts{p}.survivor.hetA.insertions.fa"};
      delete $fnToBeUnlinkAtExit{"$opts{p}.survivor.hetB.insertions.fa"};
      delete $fnToBeUnlinkAtExit{"$opts{p}.survivor.homAB.insertions.fa"};
      delete $fnToBeUnlinkAtExit{"$opts{p}.survivor.hetA.bed"};
      delete $fnToBeUnlinkAtExit{"$opts{p}.survivor.hetB.bed"};
      delete $fnToBeUnlinkAtExit{"$opts{p}.survivor.homAB.bed"};
      &Log("SURVIVOR end");
    }
    for(my $i = 0; $i < $opts{d}; ++$i)
    {
      if($survivorPostprocess != 0)
      {
        my $aOrb = $i % 2 == 0 ? 'A': 'B';
        system("ln $opts{p}.survivor$aOrb.fasta $opts{p}.survivor.$i.fasta");
      }
    }
  }
  #Generate copies of haplotypes end

  #Build genome index
  CHKPOINT2:
  {
    {
      &Log("Build genome index start");
      sub cleanUpFasta
      {
        $SIG{'INT'} = $SIG{'TERM'} = $SIG{'KILL'} = sub { threads->exit(); };
        my $i = shift @_;
        if(-e "$opts{p}.survivor.$i.clean.fasta")
        { &Log("faFilter round $i done already"); return; }
        &Log("$absPath/faFilter.pl $opts{p}.survivor.$i.fasta 0 > $opts{p}.survivor.$i.clean.fasta");
        ++$fnToBeUnlinkAtExit{"$opts{p}.survivor.$i.clean.fasta"};
        system("$absPath/faFilter.pl $opts{p}.survivor.$i.fasta 0 > $opts{p}.survivor.$i.clean.fasta");
        delete @fnToBeUnlinkAtExit{"$opts{p}.survivor.$i.clean.fasta"};
      }
      my @threadPool = ();
      for(my $i = 0; $i < $opts{d}; ++$i)
      {
        $threadPool[$i] = async{cleanUpFasta($i)};
      }
      for(my $i = 0; $i < $opts{d}; ++$i)
      {
        $threadPool[$i]->join();
      }
    }
    {
      sub createFaidx
      {
        $SIG{'INT'} = $SIG{'TERM'} = $SIG{'KILL'} = sub { threads->exit(); };
        my $i = shift @_;
        if(-e "$opts{p}.survivor.$i.clean.fasta.fai")
        { &Log("samtools faidx round $i done already"); return; }
        &Log("$absPath/samtools faidx $opts{p}.survivor.$i.clean.fasta");
        ++$fnToBeUnlinkAtExit{"$opts{p}.survivor.$i.clean.fasta.fai"};
        system("$absPath/samtools faidx $opts{p}.survivor.$i.clean.fasta");
        delete $fnToBeUnlinkAtExit{"$opts{p}.survivor.$i.clean.fasta.fai"};
      }
      my @threadPool = ();
      for(my $i = 0; $i < $opts{d}; ++$i)
      {
        $threadPool[$i] = async{createFaidx($i)};
      }
      for(my $i = 0; $i < $opts{d}; ++$i)
      {
        $threadPool[$i]->join();
      }
    }
    &Log("Build genome index end");
  }
  #Build genome index end

  #Generate reads for haplotypes
  CHKPOINT3:
  {
    my $threadsPerHaplotype = 12;
    our $needPostprocess :shared = 0;
    our $readsPerHaplotype = int($opts{x} * 1000 * 1000 / $opts{d} * 1.5 / $threadsPerHaplotype);
    sub dwgsimGenReads
    {
      $SIG{'INT'} = $SIG{'TERM'} = $SIG{'KILL'} = sub { threads->exit(); };
      my $i = shift @_;
      my $j = shift @_;
      my $readLenghtWithoutBarcode = 135;
      my $readLenghtWithBarcode = 151;
      ++$needPostprocess;
      # dwgsim command
      # ./dwgsim -N 1000 -e 0.02 -E 0.02 -d 350 -s 35 -1 151 -2 151 -S 0 -c 0 ref.fa ./test
      if(-e "$opts{p}.dwgsim.$i.12.fastq")
      { &Log("DWGSIM round $i done already"); return; }
      &Log("DWGSIM round $i thread $j start");
      &Log("$absPath/dwgsim -N $readsPerHaplotype -e $opts{e} -E $opts{E} -d $opts{i} -s $opts{s} -1 $readLenghtWithoutBarcode -2 $readLenghtWithBarcode -H -y 0 -S 0 -c 0 -m /dev/null $opts{p}.survivor.$i.clean.fasta $opts{p}.dwgsim.$i.$j");
      ++$fnToBeUnlinkAtExit{"$opts{p}.dwgsim.$i.$j.12.fastq"};
      system("$absPath/dwgsim -N $readsPerHaplotype -e $opts{e} -E $opts{E} -d $opts{i} -s $opts{s} -1 $readLenghtWithoutBarcode -2 $readLenghtWithBarcode -H -y 0 -S 0 -c 0 -m /dev/null $opts{p}.survivor.$i.clean.fasta $opts{p}.dwgsim.$i.$j");
      delete $fnToBeUnlinkAtExit{"$opts{p}.dwgsim.$i.$j.12.fastq"};
      if(!-s "$opts{p}.dwgsim.$i.$j.12.fastq")
      { &LogAndDie("DWGSIM round $i error on missing $opts{p}.dwgsim.$i.$j.12.fastq"); }
      &Log("DWGSIM round $i thread $j end");
    }
    my @threadPool = ();
    for(my $i = 0; $i < $opts{d}; ++$i)
    {
      for(my $j = 0; $j < $threadsPerHaplotype; ++$j)
      {
        $threadPool[$i*$threadsPerHaplotype+$j] = async{dwgsimGenReads($i, $j)};
      }
    }
    for(my $i = 0; $i < $opts{d}; ++$i)
    {
      for(my $j = 0; $j < $threadsPerHaplotype; ++$j)
      {
        $threadPool[$i*$threadsPerHaplotype+$j]->join();
        $SIG{INT} = $SIG{TERM} = \&signal_handler_wait;
        if($needPostprocess != 0)
        {
          if($j == 0)
          {
            rename("$opts{p}.dwgsim.$i.0.12.fastq","$opts{p}.dwgsim.$i.12.fastq");
          }
          else
          {
            &Log("cat $opts{p}.dwgsim.$i.$j.12.fastq >> $opts{p}.dwgsim.$i.12.fastq");
            system("cat $opts{p}.dwgsim.$i.$j.12.fastq >> $opts{p}.dwgsim.$i.12.fastq");
            unlink("$opts{p}.dwgsim.$i.$j.12.fastq");
          }
        }
        $SIG{INT} = $SIG{TERM} = \&signal_handler;
      }
    }
  }
  #Generate reads for haplotypes end

  #Simulate reads
  CHKPOINT4:
  {
    &Log("Simulate reads start");

    #Load barcodes
    our $barcodeLength = 16;
    our @barcodes = ();
    our $barcodesMutexLock :shared = 0;
    our $numBarcodes = 0;
    &Log("Load barcodes start");
    open my $fh, "$opts{b}" or &LogAndDie("Barcodes file $opts{b} not exist");
    @barcodes = <$fh>; chomp(@barcodes);
    $numBarcodes = scalar(@barcodes);
    close $fh;
    &Log("Load barcodes end");
    #Load barcodes end

    # depthPerMol * molLength * #molPerPartition * Partitions = reads * length
    # ? * 50k * 10 * 1.5M = 1000M * 270
    # ? = 0.36x
    # readsPerParition = depthPerMol * molLength * #molPerPartition / length
    # ? = 0.36x * 50k * 10 / 270
    # ? = 666.6
    #
    our $readsPerMolecule = int(0.499 + ($opts{x} * 1000 * 1000) / ($opts{t} * 1000 / $opts{d}) / $opts{m} / $opts{d});
    &Log("readPairsPerMolecule: $readsPerMolecule");

    # For every Haplotype
    sub simReads
    {
      $SIG{'INT'} = $SIG{'TERM'} = $SIG{'KILL'} = sub { threads->exit(); };
      my $i = shift;
      &Log("Simulating on haplotype: $i");

      if(-e "$opts{p}.$i.manifest")
      { &Log("Simulating on haplotype $i done already"); return; }

      &Log("Load read positions haplotype $i");
      my @defaultBarcodeQualAry = split //, "AAAFFFKKKKKKKKKK";
      my %faidx = ();
      my @boundary = ();
      my $genomeSize = &LoadFaidx(\%faidx, \@boundary, "$opts{p}.survivor.$i.clean.fasta");
      &LogAndDie("Failed loading genome index $opts{p}.survivor.$i.clean.fasta.fai") if ($genomeSize == 0);
      my $readPositionsInFile = mallocAry($genomeSize);
      initAryFF($readPositionsInFile, $genomeSize);
      if(-e "$opts{p}.$i.fp")
      {
        &Log("Importing $opts{p}.$i.fp");
        importAry($readPositionsInFile, "$opts{p}.$i.fp", $genomeSize);
        &Log("Imported $opts{p}.$i.fp");
      }
      else
      {
        open my $fh, "$opts{p}.dwgsim.$i.12.fastq" or &LogAndDie("Error opening $opts{p}.dwgsim.$i.12.fastq");
        my $l1; my $l2; my $l3; my $l4; my $l5; my $l6; my $l7; my $l8;
        my $newFpos;
        my $fpos = tell($fh); &LogAndDie("Fail to tell file position") if $fpos == -1;
        my $failedRegistration = 0;
        my $rt;
        while($l1=<$fh>)
        {
          $l2=<$fh>; $l3=<$fh>; $l4=<$fh>; $l5=<$fh>; $l6=<$fh>; $l7=<$fh>; $l8=<$fh>;
          $newFpos = tell($fh);
          unless($l1=~/@(\S+)_(\d+)_\d+_\d_\d_\d_\d_\d+:\d+:\d+_\d+:\d+:\d+_\S+\/1/) { &LogAndDie("Cannot find correct chromosome and position in $l1."); }
          my $gCoord = &GenomeCoord2Idx(\%faidx, "$1", $2);
          if($gCoord < 0 || $gCoord >= $genomeSize)
          { &LogAndDie("$1 $2 $gCoord $fpos"); }
          $rt = writeToPos($readPositionsInFile, $gCoord, $fpos);
          ++$failedRegistration if $rt == 0;
          $fpos = $newFpos;
        }
        close $fh;
        &Log("$failedRegistration reads failed being loaded.");
        &Log("Exporting $opts{p}.$i.fp");
        ++$fnToBeUnlinkAtExit{"$opts{p}.$i.fp"};
        exportAry($readPositionsInFile, "$opts{p}.$i.fp", $genomeSize);
        delete $fnToBeUnlinkAtExit{"$opts{p}.$i.fp"};
        &Log("Exported $opts{p}.$i.fp");
      }

      open my $outputfh, "> $opts{p}.$i.manifest" or &LogAndDie("Error opening $opts{p}.$i.manifest");
      ++$fnToBeUnlinkAtExit{"$opts{p}.$i.manifest"};

      my $readsCountDown = int($opts{x} * 1000 * 1000 / $opts{d});
      &Log("readsCountDown: $readsCountDown");

      while($readsCountDown > 0)
      {
        #Pick a barcode
        my $selectedBarcode;
        {
          my $idx = int(rand($numBarcodes));
          lock($barcodesMutexLock);
          while(1)
          {
            if($barcodes[$idx] eq "")
            {
              ++$idx;
              $idx = 0 if $idx == $numBarcodes;
              next;
            }
            $selectedBarcode = $barcodes[$idx];
            $barcodes[$idx] = "";
            last;
          }
        }
        my @precreatedSelectedBarcodeAry = split //, $selectedBarcode;

        my $numberOfMolecules = &PoissonMoleculePerPartition($opts{m});
        #&Log("numberOfMolecules: $numberOfMolecules");
        my $readsToExtract = $readsPerMolecule;
        #&Log("readsToExtract: $readsToExtract");
        for(my $j = 0; $j < $numberOfMolecules; ++$j)
        {
          #Pick a starting position
          my $startingPosition = int(rand($genomeSize));
          #&Log("startingPosition: $startingPosition");
          #Pick a fragment size
          my $moleculeSize  = &PoissonMoleculeSize($opts{f}*1000);

          #Check and align to boundary
          my $lowerBoundary; my $upperBoundary;
          &bSearch($startingPosition, \@boundary, \$lowerBoundary, \$upperBoundary);
          if(($startingPosition + $moleculeSize) > $upperBoundary)
          {
            my $newMoleculeSize = $upperBoundary - $startingPosition;
            if($newMoleculeSize < 1000) #skip molecule with length < 1000
            {
              --$j;
              next;
            }
            $readsToExtract = int($readsToExtract * $newMoleculeSize / $moleculeSize);
            $moleculeSize = $newMoleculeSize;
          }

          #Get a list of read positions
          my @readPosToExtract = random_uniform_integer($readsToExtract, $startingPosition, $startingPosition+$moleculeSize-1);
          foreach my $gCoord (@readPosToExtract)
          {
            my $filePosToExtract = getFromPos($readPositionsInFile, $gCoord, $genomeSize);
            next if $filePosToExtract == -1;

            #Introduce barcode mismatch
            my @selectedBarcodeAry = @precreatedSelectedBarcodeAry;
            my @barcodeQualAry = @defaultBarcodeQualAry;
            for(my $k = 0; $k < $barcodeLength; ++$k)
            {
              my $isErr = rand() <= $barcodeErrorRateFromMismatchObv1{$k}{$selectedBarcodeAry[$k]} ? 1 : 0;
              if($isErr == 1)
              {
                my $rnd = rand();
                my $idx = 1;
                while($idx < 4)
                {
                  last if $rnd < $barcodeErrorRateFromMismatchObv2{$k}{$selectedBarcodeAry[$k]}{$substitute{$selectedBarcodeAry[$k]}[$idx]};
                  ++$idx;
                }
                --$idx;
                $selectedBarcodeAry[$k] = $substitute{$selectedBarcodeAry[$k]}[$idx];
                $barcodeQualAry[$k] = chr(35);
              }
            }

            #Output
            print $outputfh "$filePosToExtract\t".(join "", @selectedBarcodeAry)."\t".(join "", @barcodeQualAry)."\n";

            --$readsCountDown;
            if($readsCountDown % 100000 == 0)
            { &Log("$readsCountDown reads remaining"); }
          }
        }
      }
      close $outputfh;
      delete $fnToBeUnlinkAtExit{"$opts{p}.$i.manifest"};
      freeAry($readPositionsInFile);
      if(!-s "$opts{p}.$i.manifest")
      {
        &logAndDie("$opts{p}.$i.manifest empty");
      }
    }
    #my @threadPool = ();
    for(my $i = 0; $i < $opts{d}; ++$i)
    {
      #$threadPool[$i] = async{simReads($i)};
      simReads($i);
    }
    #for(my $i = 0; $i < $opts{d}; ++$i)
    #{
    #  $threadPool[$i]->join();
    #}

    &Log("Simulate reads end");
  }
  #Simulate reads end

  #Sort manifest
  CHKPOINT5:
  {
    &Log("Sort manifest start");
    sub sortManifest
    {
      $SIG{'INT'} = $SIG{'TERM'} = $SIG{'KILL'} = sub { threads->exit(); };
      my $i = shift @_;
      if(-e "$opts{p}.$i.sort.manifest")
      { &Log("Sort manifest round $i done already"); return; }
      &Log("$absPath/msort -kn1 $opts{p}.$i.manifest > $opts{p}.$i.sort.manifest");
      ++$fnToBeUnlinkAtExit{"$opts{p}.$i.sort.manifest"};
      system("$absPath/msort -kn1 $opts{p}.$i.manifest > $opts{p}.$i.sort.manifest");
      delete $fnToBeUnlinkAtExit{"$opts{p}.$i.sort.manifest"};
    }
    my @threadPool = ();
    for(my $i = 0; $i < $opts{d}; ++$i)
    {
      $threadPool[$i] = async{sortManifest($i)};
    }
    for(my $i = 0; $i < $opts{d}; ++$i)
    {
      $threadPool[$i]->join();
    }
    &Log("Sort manifest end");
  }
  #Sort manifest done

  #Extract reads
  CHKPOINT6:
  {
    &Log("Extract reads start");
    sub extractReads
    {
      $SIG{'INT'} = $SIG{'TERM'} = $SIG{'KILL'} = sub { threads->exit(); };
      my $i = shift;
      my $ii = $i + 1;
      if(-e "$opts{p}_S1_L00${ii}_R1_001.fastq.gz" && -e "$opts{p}_S1_L00${ii}_R2_001.fastq.gz")
      { &Log("Extract reads round $i done already"); return; }
      &Log("$absPath/extractReads $opts{p}.$i.sort.manifest $opts{p}.dwgsim.$i.12.fastq $opts{p}_S1_L00${ii}");
      ++$fnToBeUnlinkAtExit{"$opts{p}_S1_L00${ii}_R1_001.fastq.gz"};
      ++$fnToBeUnlinkAtExit{"$opts{p}_S1_L00${ii}_R2_001.fastq.gz"};
      system("$absPath/extractReads $opts{p}.$i.sort.manifest $opts{p}.dwgsim.$i.12.fastq $opts{p}_S1_L00${ii}");
      delete $fnToBeUnlinkAtExit{"$opts{p}_S1_L00${ii}_R1_001.fastq.gz"};
      delete $fnToBeUnlinkAtExit{"$opts{p}_S1_L00${ii}_R2_001.fastq.gz"};
    }
    my @threadPool = ();
    for(my $i = 0; $i < $opts{d}; ++$i)
    {
      $threadPool[$i] = async{extractReads($i)};
    }
    for(my $i = 0; $i < $opts{d}; ++$i)
    {
      $threadPool[$i]->join();
    }
    &Log("Extract reads end");
  }
  #Extract reads done
  
  0;
}

sub usage {
  my $opts = shift @_;
  die(qq/
    Usage:   $0 -r <reference> -p <output prefix> -b <barcodes> [options]

    Other options:
    -d <int>    Haplotypes to simulate [$$opts{d}]
    -e <float>  Per base error rate of the first read [$$opts{e}]
    -E <float>  Per base error rate of the second read [$$opts{E}]
    -i INT      Outer distance between the two ends for pairs [$$opts{i}]
    -s INT      Standard deviation of the distance for pairs [$$opts{s}]
    -x INT      Number of million reads pairs in total to simulated [$$opts{x}]
    -f INT      Mean molecule length in kbp [$$opts{f}]
    -t INT      n*1000 partitions to generate [$$opts{t}]
    -m INT      Average # of molecules per partition [$$opts{m}]
    -u INT      Continue from a step [auto]
                  1. Variant simulation
                  2. Build fasta index
                  3. DWGSIM
                  4. Simulate reads
                  5. Sort reads extraction manifest
                  6. Extract reads
    /);
}

# Log routine
sub Log
{
  state $statusFH;
  if(not defined $statusFH)
  {
    open $statusFH, ">>$_[0]" or die "Error opening $_[0].\n";
  }
  my $time = localtime;
  print $statusFH "$time: $_[0]\n";
  print STDERR "$time: $_[0]\n";
}

sub LogAndDie
{
  &Log(@_);
  die $!;
}
# Log routine end

sub LoadFaidx
{
  my $faidx = shift;
  my $boundary = shift;
  my $fn = shift;
  open my $fh, "$fn.fai" or &LogAndDie("Error opening faidx: $fn.fai");
  my $accumulation = 0;
  while(<$fh>)
  {
    chomp;
    my @a = split;
    $$faidx{acc}{"$a[0]"} = $accumulation;
    $$faidx{size}{"$a[0]"} = $a[1];
    push @$boundary, $accumulation;
    $accumulation += $a[1];
  }
  push @$boundary, $accumulation;
  close $fh;
  return $accumulation;
}

sub getChrSize { return ${$_[0]}{size}{$_[1]}; }
sub getChrStart { return ${$_[0]}{acc}{$_[1]}; }
sub GenomeCoord2Idx { &logAndDie("not defined $_[1]") unless defined ${$_[0]}{acc}{$_[1]} ;return ${$_[0]}{acc}{$_[1]} + $_[2]; }

sub bSearch {
  my ( $elem, $list, $lowerLimit, $upperLimit ) = @_;
  my $max = $#$list;
  my $min = 0;

  my $index;
  while ( $max >= $min ) {
    $index = int( ( $max + $min ) / 2 );
    if    ( $list->[$index] < $elem ) { $min = $index + 1; }
    elsif ( $list->[$index] > $elem ) { $max = $index - 1; }
    else                              { last; }
  }
  if($elem >= $list->[$index]) { $$lowerLimit = $list->[$index]; $$upperLimit = $list->[$index+1]; }
  elsif($elem < $list->[$index]) { $$lowerLimit = $list->[$index-1]; $$upperLimit = $list->[$index]; }
  else {  die "bSearch: Should never reach here"; }
}

sub PoissonMoleculePerPartition
{
  state $mu = $_[0];
  state $i = 10000;
  state $pool;
  $i = 10000 if($mu != $_[0]);
  if($i == 10000)
  {
    @{$pool} = random_poisson(10000, $_[0]);
    $i = 0;
  }
  return ${$pool}[$i++];
}

sub PoissonMoleculeSize
{
  state $mu = $_[0];
  state $i = 10000;
  state $pool;
  $i = 10000 if($mu != $_[0]);
  if($i == 10000)
  {
    @{$pool} = random_poisson(10000, $_[0]);
    $i = 0;
  }
  return ${$pool}[$i++];
}

0;

__END__
__C__

#include<stdio.h>
#include<stdlib.h>
#include<unistd.h>
#include<string.h>
#include<limits.h>

#define AMP_ON_SLOTS 1
long mallocAry(long size)
{
  long ptr = (long)malloc(size * sizeof(size_t) * AMP_ON_SLOTS);
  if(ptr == (long)NULL)
  {
    fprintf(stderr, "Error allocation, size %l\n", size);
    return 0;
  }
  return ptr;
}

void initAryFF(long pptr, long size)
{
  size_t* ptr = (size_t*)pptr;
  memset(ptr, 0xFF, size * sizeof(size_t) * AMP_ON_SLOTS);
}

void printAry(long pptr, long size)
{
  size_t* ptr = (size_t*)pptr;
  long i;
  for(i = 0; i < size*AMP_ON_SLOTS; ++i)
  {
    fprintf(stderr, "%l\t%lu\n", i, ptr[i]);
  }
}

void importAry(long pptr, char* fn, long size)
{
  void* ptr = (void*)pptr;
  FILE* fh = fopen(fn, "rb");
  fread(ptr, sizeof(size_t), size * AMP_ON_SLOTS, fh);
  fclose(fh);
}

void exportAry(long pptr, char* fn, long size)
{
  size_t* ptr = (size_t*)pptr;
  FILE* fh = fopen(fn, "wb");
  fwrite(ptr, sizeof(size_t), size * AMP_ON_SLOTS, fh);
  fclose(fh);
}

void freeAry(long pptr)
{
  size_t* ptr = (size_t*)pptr;
  free(ptr);
}

#define CHK_PREV_SLOT_LIMIT (10*AMP_ON_SLOTS)
int writeToPos(long pptr, long pos, long toWrite)
{
  size_t* ptr = (size_t*)pptr;
  int limit = CHK_PREV_SLOT_LIMIT;
  pos = (pos + 1) * AMP_ON_SLOTS - 1;
  while(limit > 0)
  {
    if(ptr[pos] == ULLONG_MAX)
    {
      ptr[pos] = (size_t)toWrite;
      break;
    }
    --pos;
    if(pos < 0) { break; }
    --limit;
  }
  return limit;
}

long getFromPos(long pptr, long pos, long maxSize)
{
  size_t* ptr = (size_t*)pptr;
  int limit = 0;
  size_t result = ULLONG_MAX;
  if(pos >= maxSize) { pos = maxSize - 1; }
  if(pos < 0) { pos = 0; }
  pos = (pos + 1) * AMP_ON_SLOTS - 1;
  while(limit < CHK_PREV_SLOT_LIMIT)
  {
    if(ptr[pos] != ULLONG_MAX)
    {
      result = ptr[pos];
      ptr[pos] = ULLONG_MAX;
      break;
    }
    --pos;
    if(pos < 0) { break; }
    ++limit;
  }
  return (long)result;
}

