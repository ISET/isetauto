#! /bin/bash

CURRENT_DIR=`pwd`

MODEL_PATH='/home/hblasins/Documents/tensorflow/models/'
export PYTHONPATH=$PYTHONPATH:$MODEL_PATH:$MODEL_PATH/slim

cd $MODEL_PATH

python object_detection/builders/model_builder_test.py

DATASETS=('sRGB_luxLevel_mix' 'MC_luxLevel_mix')
# DATASETS=('sRGB')

COLLECTION='MultiObject-Pinhole'

for DATASET in "${DATASETS[@]}"
do

python object_detection/create_rtb4_tf_record.py --data_dir=/scratch/Datasets/$COLLECTION \
       --mode=$DATASET \
       --set=test \
       --output_path=/scratch/Datasets/$COLLECTION/$DATASET"_test.record" \
       --label_map_path=/scratch/Datasets/$COLLECTION/$COLLECTION'_label_map.pbtxt'

python object_detection/create_rtb4_tf_record.py --data_dir=/scratch/Datasets/$COLLECTION \
       --mode=$DATASET \
       --set=trainval \
       --output_path=/scratch/Datasets/$COLLECTION/$DATASET"_trainval.record" \
       --label_map_path=/scratch/Datasets/$COLLECTION/$COLLECTION'_label_map.pbtxt'

done

cd $CURRENT_DIR