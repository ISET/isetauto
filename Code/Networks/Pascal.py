import tensorflow as tf
import skimage.io as io
import matplotlib.pyplot as plt
slim = tf.contrib.slim



class Pascal(object):

    # Size of the input imnage
    image_height = 384
    image_width = 384

    num_classes = 21

    data_sources = ['/scratch/Datasets/PASCAL/2007/trainval/pascal_voc_trainval.tfrecords',
                    '/scratch/Datasets/PASCAL/2007/test/pascal_voc_test.tfrecords']

    features = {
        'image/encoded': tf.FixedLenFeature((), tf.string, default_value=''),
        'image/format': tf.FixedLenFeature((), tf.string, default_value='jpeg'),
        'image/height': tf.FixedLenFeature([1], tf.int64),
        'image/width': tf.FixedLenFeature([1], tf.int64),
        'image/channels': tf.FixedLenFeature([1], tf.int64),
        'image/shape': tf.FixedLenFeature([3], tf.int64),
        'image/object/bbox/xmin': tf.VarLenFeature(dtype=tf.float32),
        'image/object/bbox/ymin': tf.VarLenFeature(dtype=tf.float32),
        'image/object/bbox/xmax': tf.VarLenFeature(dtype=tf.float32),
        'image/object/bbox/ymax': tf.VarLenFeature(dtype=tf.float32),
        'image/object/bbox/label': tf.VarLenFeature(dtype=tf.int64),
        'image/object/bbox/difficult': tf.VarLenFeature(dtype=tf.int64),
        'image/object/bbox/truncated': tf.VarLenFeature(dtype=tf.int64),
    }

    items_to_handlers = {
        'image': slim.tfexample_decoder.Image('image/encoded', 'image/format'),
        'shape': slim.tfexample_decoder.Tensor('image/shape'),
        'object/bbox': slim.tfexample_decoder.BoundingBox(
            ['ymin', 'xmin', 'ymax', 'xmax'], 'image/object/bbox/'),
        'object/label': slim.tfexample_decoder.Tensor('image/object/bbox/label'),
        'object/difficult': slim.tfexample_decoder.Tensor('image/object/bbox/difficult'),
        'object/truncated': slim.tfexample_decoder.Tensor('image/object/bbox/truncated'),
    }

    def images_and_labels(self):

        decoder = slim.tfexample_decoder.TFExampleDecoder(self.features, self.items_to_handlers)

        dataset = slim.dataset.Dataset(
            data_sources = self.data_sources,
            reader = tf.TFRecordReader,
            num_samples = 100,
            decoder = decoder,
            items_to_descriptions = {},
            num_classes = self.num_classes)

        provider = slim.dataset_data_provider.DatasetDataProvider(
                dataset,
                num_readers=100,
                shuffle=False)

        [image, shape, glabels, gbboxes] = provider.get(['image', 'shape',
                                                             'object/label',
                                                             'object/bbox'])

        # Random transformations can be put here: right before you crop images
        # to predefined size. To get more information look at the stackoverflow
        # question linked above.

        resized_image = tf.image.resize_image_with_crop_or_pad(image=image,
                                       target_height=self.image_height,
                                       target_width=self.image_width)


        #shuffle_batch
        images, shape = tf.train.shuffle_batch( [resized_image, shape],
                                            batch_size=10,
                                             num_threads=4,
                                             capacity=2000,
                                             min_after_dequeue=1000)

        return images, shape



