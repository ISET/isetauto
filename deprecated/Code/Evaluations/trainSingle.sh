#! /bin/bash

ID=$1
NETWORK=$2
DATASET=$3
CURRENT_DIR=$4

echo $ID $NETWORK $DATASET

MODEL_PATH='/home/hblasins/Documents/tensorflow/models/'
export PYTHONPATH=$PYTHONPATH:$MODEL_PATH:$MODEL_PATH/slim
cd $MODEL_PATH

python object_detection/builders/model_builder_test.py

TRAIN_DIR="/scratch/Results/"$NETWORK"_"$DATASET"/train"
if [ ! -d "$TRAIN_DIR" ] 
then
    mkdir -p $TRAIN_DIR
fi

if [ $DATASET == 'kitti' ]
then
    ARCH_DIR="NetworksKITTI"
else
    ARCH_DIR="Networks"
fi

CUDA_VISIBLE_DEVICES=$ID python object_detection/train.py \
    --logtostderr \
    --train_dir=$TRAIN_DIR \
    --model_config_path=$CURRENT_DIR"/"$ARCH_DIR"/"$NETWORK.config \
    --train_config_path=$CURRENT_DIR"/Training/"$NETWORK.config \
    --input_config_path=$CURRENT_DIR"/Datasets/"$DATASET"_trainval.config" |& tee $TRAIN_DIR"/log.txt"