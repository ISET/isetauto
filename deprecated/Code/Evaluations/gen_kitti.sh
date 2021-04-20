#! /bin/bash

CURRENT_DIR=`pwd`

MODEL_PATH='/home/hblasins/Documents/tensorflow/models/'
export PYTHONPATH=$PYTHONPATH:$MODEL_PATH:$MODEL_PATH/slim

cd $MODEL_PATH

python object_detection/builders/model_builder_test.py

python object_detection/create_rtb4_tf_record.py --data_dir=/scratch/Datasets/KITTI-VOC \
       --mode=KITTIObject \
       --set=train \
       --output_path=/scratch/Datasets/KITTI-VOC/kitti_trainval.record \
       --label_map_path=/scratch/Datasets/KITTI-VOC/kitti_label_map.pbtxt


cd $CURRENT_DIR