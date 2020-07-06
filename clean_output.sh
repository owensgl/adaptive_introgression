#ls | grep out1 | sed s/_out1.txt.gz//g | parallel -j 32 bash ../clean_output.sh
file=$1

for n in 1 2 3 6; do  if gzip -t ${file}_out${n}.txt.gz; then echo "OK $file"; else echo "BAD $file"; rm ${file}_out*; fi; done;
