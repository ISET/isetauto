#! /bin/bash

ID=$1
NETWORK=$2
TRAIN_DATASET=$3
TEST_DATASET=$4
CURRENT_DIR=$5

MODEL_PATH='/home/hblasins/Documents/tensorflow/models/'
export PYTHONPATH=$PYTHONPATH:$MODEL_PATH:$MODEL_PATH/slim
cd $MODEL_PATH

python object_detection/builders/model_builder_test.py

EVAL_DIR="/scratch/Results/"$NETWORK"_"$TRAIN_DATASET"/eval_"$TEST_DATASET

if [ ! -d "$EVAL_DIR" ] 
then
    mkdir $EVAL_DIR
fi

if [ -d "$EVAL_DIR/images" ]
then
    rm -r "$EVAL_DIR/images"
fi

if [ $TRAIN_DATASET == "kitti" ]
then
    ARCH_DIR="NetworksKITTI"
else
    ARCH_DIR="Networks"
fi

echo "Evaluating network:     "$NETWORK
echo "Saving results in:      "$EVAL_DIR
echo "Architecture directory: "$ARCH_DIR

CUDA_VISIBLE_DEVICES=$ID python object_detection/eval.py \
    --logtostderr \
    --eval_config_path=$CURRENT_DIR"/Eval/"$TEST_DATASET"_eval.config" \
    --model_config_path=$CURRENT_DIR"/"$ARCH_DIR"/"$NETWORK.config \
    --input_config_path=$CURRENT_DIR"/Datasets/"$TEST_DATASET"_test.config" \
    --checkpoint_dir=/scratch/Results/$NETWORK\_$TRAIN_DATASET/train \
    --eval_dir=$EVAL_DIR |& tee $EVAL_DIR"/result.txt"


mv /scratch/$TEST_DATASET/images $EVAL_DIR
rm -r /scratch/$TEST_DATASET

cd $CURRENT_DIR