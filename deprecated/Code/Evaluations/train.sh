#! /bin/bash

DATASET=('synthia')
# NETWORKS=('faster_rcnn_inception_resnet_v2_atrous' \
#         'faster_rcnn_resnet101' \
#         'rfcn_resnet101' \
#         'ssd_inception_v2' \
#         'ssd_mobilenet_v1')

NETWORKS=('faster_rcnn_inception_resnet_v2_atrous')

CURRENT_DIR=`pwd`

for ID in $(seq 1 ${#NETWORKS[@]})
do
    ID=`expr $ID - 1`
    GPU_ID=`expr $ID + 7`
    NETWORK=${NETWORKS[ID]}
    CMD=$CURRENT_DIR"/trainSingle.sh "$GPU_ID" "$NETWORK" "$DATASET" "$CURRENT_DIR
    echo $CMD
    lxterminal -t $NETWORK"_"$DATASET -l -e "bash -c env; $CMD"
    sleep 1
done
