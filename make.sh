set -e

g++ -std=c++11 extractReads.cpp -O3 -o extractReads

cd DWGSIMSrc
make -j
cp -f dwgsim ../
cp -f ./samtools/samtools ../
cd ../

cd msortSrc
g++ msort.c sort_funs.c stdhashc.cc -lm -m64 -fpermissive -o msort
cp -f msort ../
cd ../

cd SURVIVORSrc/Debug
make -j
cp -f SURVIVOR ../../
cd ../../

echo
echo "Done, please run perl main.pl"
echo
