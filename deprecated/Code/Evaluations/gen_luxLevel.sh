#! /bin/bash

CURRENT_DIR=`pwd`

MODEL_PATH='/home/hblasins/Documents/tensorflow/models/'
export PYTHONPATH=$PYTHONPATH:$MODEL_PATH:$MODEL_PATH/slim

cd $MODEL_PATH

python object_detection/builders/model_builder_test.py

COLLECTION='MultiObject-Pinhole'

MODE=('rawMC_2_15')
LUX=('0.0' '0.1' '1.0' '10.0' '100.0' '1000.0' '10000.0')

for MD in "${MODE[@]}"
do
for LX in "${LUX[@]}"
do

echo $MD"_luxLevel_"$LX
python object_detection/create_rtb4_tf_record.py --data_dir=/scratch/Datasets/$COLLECTION \
       --mode=$MD"_luxLevel_"$LX \
       --set=test \
       --output_path=/scratch/Datasets/$COLLECTION/$MD"_luxLevel_"$LX"_test.record" \
       --label_map_path=/scratch/Datasets/$COLLECTION/$COLLECTION'_label_map.pbtxt'

python object_detection/create_rtb4_tf_record.py --data_dir=/scratch/Datasets/$COLLECTION \
       --mode=$MD"_luxLevel_"$LX \
       --set=trainval \
       --output_path=/scratch/Datasets/$COLLECTION/$MD"_luxLevel_"$LX"_trainval.record" \
       --label_map_path=/scratch/Datasets/$COLLECTION/$COLLECTION'_label_map.pbtxt'

done
done

cd $CURRENT_DIR