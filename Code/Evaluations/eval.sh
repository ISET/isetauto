#! /bin/bash

TRAIN_DATA='MC_luxLevel_mix'

# TEST_DATA=('voc07'\
#         'voc07car'\
#         'sRGB'\
#         'fullResRGB'\
#         'linearRGB'\
#         'rawRGB'\
#         'synthia')
# TEST_DATA=('voc07'\
#           'sRGB'\
#           'fullResRGB'\
#           'rawRGB'\
#           'linearRGB')

# TEST_DATA=('voc07')

TEST_DATA=('sRGB_15_luxLevel_0.0'\
           'sRGB_15_luxLevel_0.1'\
           'sRGB_15_luxLevel_1.0'\
           'sRGB_15_luxLevel_10.0')

TEST_DATA=('sRGB_15_luxLevel_100.0'\
           'sRGB_15_luxLevel_1000.0'\
           'sRGB_15_luxLevel_10000.0')

TEST_DATA=('MC_15_luxLevel_0.0'\
           'MC_15_luxLevel_0.1'\
           'MC_15_luxLevel_1.0'\
           'MC_15_luxLevel_10.0')

TEST_DATA=('MC_15_luxLevel_100.0'\
           'MC_15_luxLevel_1000.0'\
           'MC_15_luxLevel_10000.0')

TEST_DATA=('MC_2_15_luxLevel_0.0'\
           'MC_2_15_luxLevel_0.1'\
           'MC_2_15_luxLevel_1.0'\
           'MC_2_15_luxLevel_10.0')

TEST_DATA=('MC_2_15_luxLevel_100.0'\
           'MC_2_15_luxLevel_1000.0'\
           'MC_2_15_luxLevel_10000.0')

TEST_DATA=('sRGB_2_15_luxLevel_0.0'\
           'sRGB_2_15_luxLevel_0.1'\
           'sRGB_2_15_luxLevel_1.0'\
           'sRGB_2_15_luxLevel_10.0')

TEST_DATA=('sRGB_2_15_luxLevel_100.0'\
           'sRGB_2_15_luxLevel_1000.0'\
           'sRGB_2_15_luxLevel_10000.0')

TEST_DATA=('MC_15_luxLevel_1.0')

# TEST_DATA=('rawMC_2_15_luxLevel_100.0'\
#           'rawMC_2_15_luxLevel_1000.0'\
#           'rawMC_2_15_luxLevel_10000.0')

NETWORK='faster_rcnn_inception_resnet_v2_atrous'

# 'faster_rcnn_inception_resnet_v2_atrous'
# 'faster_rcnn_resnet101' \
# 'rfcn_resnet101' \
# 'ssd_inception_v2' \
# 'ssd_mobilenet_v1')

CURRENT_DIR=`pwd`

AVAILABLE_CARDS=('4', '10', '10', '10', '10', '10')

for ID in $(seq 1 ${#TEST_DATA[@]})
do
    ID=`expr $ID - 1`
    # CARD_ID=`expr $ID + 4`
    CARD_ID=${AVAILABLE_CARDS[ID]}
    T_DATA=${TEST_DATA[ID]}
    CMD=$CURRENT_DIR"/evalSingle.sh "$CARD_ID" "$NETWORK" "$TRAIN_DATA" "$T_DATA" "$CURRENT_DIR
    echo $CMD
    lxterminal -t $NETWORK"_"$TRAIN_DATA"_"$T_DATA -l -e "bash -c env; $CMD" &
    sleep 1
done