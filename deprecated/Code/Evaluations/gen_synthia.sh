#! /bin/bash

CURRENT_DIR=`pwd`

MODEL_PATH='/home/hblasins/Documents/tensorflow/models/'
export PYTHONPATH=$PYTHONPATH:$MODEL_PATH:$MODEL_PATH/slim

cd $MODEL_PATH

python object_detection/builders/model_builder_test.py

python object_detection/create_rtb4_tf_record.py --data_dir="/scratch/Datasets/SYNTHIA-VOC" \
       --mode="RAND" \
       --set="trainval" \
       --output_path=/scratch/Datasets/SYNTHIA-VOC/synthia_trainval.record \
       --label_map_path=/scratch/Datasets/SYNTHIA-VOC/synthia_label_map.pbtxt

python object_detection/create_rtb4_tf_record.py --data_dir="/scratch/Datasets/SYNTHIA-VOC" \
       --mode="RAND" \
       --set="test" \
       --output_path=/scratch/Datasets/SYNTHIA-VOC/synthia_test.record \
       --label_map_path=/scratch/Datasets/SYNTHIA-VOC/synthia_label_map.pbtxt


cd $CURRENT_DIR