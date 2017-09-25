#! /bin/bash

CURRENT_DIR=`pwd`

MODEL_PATH='/home/hblasins/Documents/tensorflow/models/'
export PYTHONPATH=$PYTHONPATH:$MODEL_PATH:$MODEL_PATH/slim

cd $MODEL_PATH

python object_detection/builders/model_builder_test.py

python object_detection/create_rtb4_tf_record.py --data_dir=/scratch/Datasets/PASCAL \
       --mode=VOC2007car \
       --set=test \
       --output_path=/scratch/Datasets/PASCAL/voc07car_test.record \
       --label_map_path=/home/hblasins/Documents/tensorflow/models/object_detection/data/pascal_label_map.pbtxt

python object_detection/create_rtb4_tf_record.py --data_dir=/scratch/Datasets/PASCAL \
       --mode=VOC2007car \
       --set=trainval \
       --output_path=/scratch/Datasets/PASCAL/voc07car_trainval.record \
       --label_map_path=/home/hblasins/Documents/tensorflow/models/object_detection/data/pascal_label_map.pbtxt



cd $CURRENT_DIR