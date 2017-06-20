



Change the dataset to TF-Records:

python tf_convert_data.py --dataset_name=pascalvoc --dataset_dir=VOC2007_/ --output_name=train  --output_dir=./tfrecords/TrafficSign


Eval:
python eval_ssd_network.py --eval_dir=./logs/ --dataset_dir=./VOC2007/test/ --dataset_name=pascalvoc_2007 --dataset_split_name=test --model_name=ssd_300_vgg --checkpoint_path=./checkpoints/VGG_VOC0712_SSD_300x300_ft_iter_120000.ckpt  --batch_size=1

Train:
python train_ssd_network.py --train_dir=./logs/ --dataset_dir=./tfrecords --dataset_name=pascalvoc_2007 --dataset_split_name=train --model_name=ssd_300_vgg --checkpoint_path=./checkpoints/ssd_300_vgg.ckpt --save_summaries_secs=60 --save_interval_secs=600 --weight_decay=0.0005 --optimizer=adam --learning_rate=0.001 --batch_size=8
python train_ssd_network.py --train_dir=./logs2/ --dataset_dir=./tfrecords --dataset_name=pascalvoc_2012 --dataset_split_name=train --model_name=ssd_300_vgg --checkpoint_path=./checkpoints/ssd_300_vgg.ckpt --save_summaries_secs=60 --save_interval_secs=600 --weight_decay=0.0005 --optimizer=adam --learning_rate=0.001 --batch_size=8


python tf_convert_data.py --dataset_name=TrafficSign --dataset_dir=E:/Tensorflow/darkflow/pascal/VOCdevkit/VOC2007/ --output_name=Traffic_sign  --output_dir=./tfrecords