#!/bin/sh

# $1 start frame index
# $2 end frame index
# $3 out dir
# $4 template file

# get the number of connected devices
numDevices=`./k4arecorder.exe --list | wc -l`

# create subfolders
for index in $(seq 0 $(($numDevices-1)))
do
	mkdir -p $3/$index/color
	mkdir -p $3/$index/ir
	mkdir -p $3/$index/ir16
	mkdir -p $3/$index/mkvs
done

#start captures
for f in $(seq $1 $2)
do
	# capture mean ir and color 
	./collect -mode=5 -res=6 -nv=1 -nc=10 -out=$3 -sf=$f
	for index in $(seq 0 $(($numDevices-1)))
	do
		# capture .mkv for depth and ir comparison
		./k4arecorder.exe --device $index -c 3072p -d WFOV_2X2BINNED -l 2 $3/$index/mkvs/dp$f.mkv 
		./k4arecorder.exe --device $index -c 3072p -d PASSIVE_IR -l 2 $3/$index/mkvs/ir$f.mkv 
	 	./transformation_eval.exe -i=$3/$index/mkvs/ir$f.mkv -d=$3/$index/mkvs/dp$f.mkv -t=$4 -out=$3/$index -s=1
 		[ -f $3/$index/checkered_pattern.png ] && mv $3/$index/checkered_pattern.png $3/$index/mkvs/checkered_pattern$f.png
 		[ -f $3/$index/results.txt ] && mv $3/$index/results.txt $3/$index/transfomation_eval_results$f.txt
		echo
		./depth_eval.exe -i=$3/$index/mkvs/ir$f.mkv -d=$3/$index/mkvs/dp$f.mkv -t=$4 -s=1 -out=$3/$index
 		[ -f $3/$index/charuco.png ] && mv $3/$index/charuco.png $3/$index/mkvs/charuco$f.png
 		[ -f $3/$index/color8.png ] && mv $3/$index/color8.png $3/$index/color8_$f.png
 		[ -f $3/$index/depth16.png ] && mv $3/$index/depth16.png $3/$index/depth16_$f.png
 		[ -f $3/$index/ir8.png ] && mv $3/$index/ir8.png $3/$index/ir8_$f.png
 		[ -f $3/$index/ir16.png ] && mv $3/$index/charuco.png $3/$index/ir16_$f.png
		echo
	done
done

# move generated images into subfolders to run calibrate and register
for index in $(seq 0 $(($numDevices-1)))
do
	mv $3/$index/color-*.png $3/$index/color
	mv $3/$index/ir8-*.png $3/$index/ir
	mv $3/$index/ir16-*.png $3/$index/ir16
done
