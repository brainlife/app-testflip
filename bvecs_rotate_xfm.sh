#!/bin/bash

if [ "$3" == "" ] ; then 
 echo "Usage: <original bvecs> <rotated bvecs> <xfm>"
 echo ""
 echo "<xfm>	is the output xfm file from flirt"
 echo ""
 exit 1;
fi

i=$1
o=$2
xfm=$3

#
#i=8003202_JC_rotated_bvec.txt
#o=~/8003202_JC_rotated_bvec_TEST.txt
#xfm=../../FLIRTFA2T1_goodXFMs_9p9p/8003202_JC_XFM_FA2T1_9p_2mm.xfm

if [ ! -e $1 ] ; then
	echo "Source bvecs $1 does not exist!"
	exit 1
fi
if [ ! -e $xfm ]; then
	echo "Flirt xfm file $3 does not exist!"
	exit 1
fi

nline=$(cat $i | wc -l )
if [ $nline -gt 3 ]
then
echo "the file is vertical and will be transposed"
awk '
{
for (k=1; k<=NF; k++)  {
a[NR,k] = $k
}
}
NF>p { p = NF }
END {
for(j=1; j<=p; j++) {
str=a[1,j]
for(k=2; k<=NR; k++){
str=str" "a[k,j];
}
print str
}
}' $i > ${i}_horizontal

i=${i}_horizontal
fi

echo $i



rm -f $o
tmpo=${o}$$
cat ${xfm} | while read line; do
  #  echo $ii
    if [ "$line" == "" ];then break;fi
   echo $line  > $tmpo
    read line    
    echo $line >> $tmpo
    read line    
    echo $line >> $tmpo
    read line    
    echo $line >> $tmpo
    read line   
done
    
    m11=`${FSLDIR}/bin/avscale $tmpo | grep Rotation -A 1 | tail -n 1| awk '{print $1}'`
    m12=`${FSLDIR}/bin/avscale $tmpo | grep Rotation -A 1 | tail -n 1| awk '{print $2}'`
    m13=`${FSLDIR}/bin/avscale $tmpo | grep Rotation -A 1 | tail -n 1| awk '{print $3}'`
    m21=`${FSLDIR}/bin/avscale $tmpo | grep Rotation -A 2 | tail -n 1| awk '{print $1}'`
    m22=`${FSLDIR}/bin/avscale $tmpo | grep Rotation -A 2 | tail -n 1| awk '{print $2}'`
    m23=`${FSLDIR}/bin/avscale $tmpo | grep Rotation -A 2 | tail -n 1| awk '{print $3}'`
    m31=`${FSLDIR}/bin/avscale $tmpo | grep Rotation -A 3 | tail -n 1| awk '{print $1}'`
    m32=`${FSLDIR}/bin/avscale $tmpo | grep Rotation -A 3 | tail -n 1| awk '{print $2}'`
    m33=`${FSLDIR}/bin/avscale $tmpo | grep Rotation -A 3 | tail -n 1| awk '{print $3}'`
    


#ii=1
vecs=`awk -F' ' '{print NF; exit}' ${i}`
#echo $vecs
for (( ii=1; ii<=$vecs; ii++ ))
do
echo $ii
    X=`cat $i | awk -v x=$ii '{print $x}' | head -n 1 | tail -n 1 | awk -F"E" 'BEGIN{OFMT="%10.10f"} {print $1 * (10 ^ $2)}' `
    Y=`cat $i | awk -v x=$ii '{print $x}' | head -n 2 | tail -n 1 | awk -F"E" 'BEGIN{OFMT="%10.10f"} {print $1 * (10 ^ $2)}' `
    Z=`cat $i | awk -v x=$ii '{print $x}' | head -n 3 | tail -n 1 | awk -F"E" 'BEGIN{OFMT="%10.10f"} {print $1 * (10 ^ $2)}' `
    rX=`echo "scale=7;  ($m11 * $X) + ($m12 * $Y) + ($m13 * $Z)" | bc -l`
    rY=`echo "scale=7;  ($m21 * $X) + ($m22 * $Y) + ($m23 * $Z)" | bc -l`
    rZ=`echo "scale=7;  ($m31 * $X) + ($m32 * $Y) + ($m33 * $Z)" | bc -l`

    if [ "$ii" -eq 1 ];then
	echo $rX > $o;echo $rY >> $o;echo $rZ >> $o
    else
	cp $o $tmpo
	(echo $rX;echo $rY;echo $rZ) | paste $tmpo - > $o
    fi

done
rm -f $tmpo

