#! /bin/bash

CURRENT_DIR=`pwd`

MODEL_PATH='/home/hblasins/Documents/tensorflow/models/'
export PYTHONPATH=$PYTHONPATH:$MODEL_PATH:$MODEL_PATH/slim

cd $MODEL_PATH

python object_detection/builders/model_builder_test.py


MODE=('sRGB')
LEVEL=('100.0' '80.0' '60.0' '40.0' '20.0' '1.0')

for MD in "${MODE[@]}"
do
for LX in "${LEVEL[@]}"
do

echo $MD"_jpegLevel_"$LX
python object_detection/create_rtb4_tf_record.py --data_dir=/scratch/Datasets/Car-Complete-Pinhole \
       --mode=$MD"_jpegLevel_"$LX \
       --set=test \
       --output_path=/scratch/Datasets/Car-Complete-Pinhole/$MD"_jpegLevel_"$LX"_test.record" \
       --label_map_path=/scratch/Datasets/Car-Complete-Pinhole/Car-Complete-Pinhole_label_map.pbtxt

python object_detection/create_rtb4_tf_record.py --data_dir=/scratch/Datasets/Car-Complete-Pinhole \
       --mode=$MD"_jpegLevel_"$LX \
       --set=trainval \
       --output_path=/scratch/Datasets/Car-Complete-Pinhole/$MD"_jpegLevel_"$LX"_trainval.record" \
       --label_map_path=/scratch/Datasets/Car-Complete-Pinhole/Car-Complete-Pinhole_label_map.pbtxt

done
done

cd $CURRENT_DIR