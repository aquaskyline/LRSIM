set -e

rm -f extractReads

cd DWGSIMSrc
make clean
rm -f ../dwgsim
rm -f ../samtools
cd ../

cd msortSrc
rm -f msort
rm -f ../msort
cd ../

cd SURVIVORSrc/Debug
make clean
rm -f ../../SURVIVOR
cd ../../

rm -rf _Inline

echo
echo "Done cleanning"
echo
