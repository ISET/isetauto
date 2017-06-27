import tensorflow as tf
import glob
import os
import numpy as np
import re
import scipy

from Net import Net


class Yolo(Net):

    B = 2
    C = 20
    S = 7

    lambda_coord = 5
    lambda_noobj = .5

    dropout_prob = 0.5

    input_h = 448
    input_w = 448

    leak = 0.1

    thr = 0.2

    checkpoint_path = None

    class_names = ["aeroplane", "bicycle", "bird", "boat", "bottle", "bus", "car", "cat", "chair", "cow",
                   "dining table", "dog", "horse", "motorbike", "person", "potted plant", "sheep", "sofa", "train",
                   "TV monitor"]

    layer_names = ['1-Conv-7x7x64-s-2', '2-MaxPool-2x2-s-2', '3-Conv-3x3x192', '4-MaxPool-2x2-s-2', '5-Conv-1x1x128',
                   '6-Conv-3x3x256', '7-Conv-1x1x256', '8-Conv-3x3x512', '9-MaxPool-2x2-s-2', '10-Conv-1x1x256',
                   '11-Conv-3x3x512', '12-Conv-1x1x256', '13-Conv-3x3x512', '14-Conv-1x1x256', '15-Conv-3x3x512',
                   '16-Conv-1x1x256', '17-Conv-3x3x512', '18-Conv-1x1x512', '19-Conv-3x3x1024', '20-MaxPool-2x2-s-2',
                   '21-Conv-1x1x512', '22-Conv-3x3x1024', '23-Conv-1x1x512', '24-Conv-3x3x1024', '25-Conv-3x3x1024',
                   '26-Conv-3x3x1024-s-2', '27-Conv-3x3x1024', '28-Conv-3x3x1024', '29-Fc-4096', '30-Dropout',
                   '31-Fc-1470']

    def __init__(self, b=2, c=20, s=7, lambda_coord=5, lambda_noobj=0.5, dropout=0.5):
        super(self.__class__, self).__init__()

        self.B = b
        self.C = c
        self.S = s
        self.layer_names[-1] = '31-Fc-%i' % ((b * 5 + c) * s * s)
        self.lambda_coord = lambda_coord
        self.lambda_noobj = lambda_noobj
        self.dropout_prob = dropout

    def initialize_weights_darknet(self, weight_directory):

        files = glob.glob(os.path.join(weight_directory, '*.csv'))

        for current_file in files:
            print "Loading weights from: %s" % current_file
            data = np.genfromtxt(current_file, delimiter=',', dtype=np.float32)

            directory, filename = os.path.split(current_file)
            begin = filename.find('_')
            end = filename.find('_',begin+1)
            type = filename[begin+1:end]
            layer_id = int(re.findall("\d+?\d*[eE]?\d*", filename)[0])-1

            if type == "weight":
                layer_architecture = [int(i) for i in re.findall("\d+?\d*[eE]?\d*", self.layer_names[layer_id])]
                channels = np.prod(data.size) / (np.prod(layer_architecture[1:4]))

                kernel_size = layer_architecture[1:4]
                kernel_size.insert(2,channels)


                # data_array = np.swapaxes(data_array, 0, 1)

                if len(kernel_size) >= 3:
                    # Convolutional filter
                    data_array = np.reshape(data, kernel_size, order='F')
                    data_array = np.swapaxes(data_array,0,1)

                    # wght = np.zeros(kernel_size)
                    # for i in range(kernel_size[0]):
                    #    for j in range(kernel_size[1]):
                    #       for k in range(kernel_size[2]):
                    #           for l in range(kernel_size[3]):
                    #               wght[i,j,k,l] = data [l * kernel_size[0] * kernel_size[1] * kernel_size[2] +
                    #                                     k * kernel_size[0] * kernel_size[1] +
                    #                                    i * kernel_size[0] + j]

                    print "Done"

                else:
                    data_array = np.reshape(data, [kernel_size[1], kernel_size[0]], order='F')

                    # print "fc"
                    # Fully connected
                    # wght = np.zeros([kernel_size[1], kernel_size[0]])

                    # for i in range(kernel_size[1]):
                    #     for j in range(kernel_size[0]):
                    #         wght[i,j] = data [j * kernel_size[1] + i]

                    # print "Done"

                self.initializers[self.layer_names[layer_id] + "-weights"] = tf.constant_initializer(data_array)
            if type == "bias":
                self.initializers[self.layer_names[layer_id] + "-biases"] = tf.constant_initializer(data)





    def save_weights(self, file_name):

        with tf.Graph().as_default():
            img = tf.placeholder(tf.float32, shape=[1, self.input_h, self.input_w, 3], name="InputImage")
            self.inference(img)

            init = tf.global_variables_initializer()

            with tf.Session() as session:

                session.run(init)
                tf.train.Saver().save(session, save_path=file_name)





    def inference(self,inputs):

        conv1 = self.conv_2d(self.layer_names[0], inputs, shape=[7,7,64], strides=[1,2,2,1], leak=self.leak)
        mp1 = self.max_pool(self.layer_names[1], conv1)

        conv2 = self.conv_2d(self.layer_names[2], mp1, shape=[3,3,192], leak=self.leak)
        mp2 = self.max_pool(self.layer_names[3], conv2)

        conv3 = self.conv_2d(self.layer_names[4], mp2, shape=[1,1,128], leak=self.leak)
        conv4 = self.conv_2d(self.layer_names[5], conv3, shape=[3,3,256], leak=self.leak)
        conv5 = self.conv_2d(self.layer_names[6], conv4, shape=[1,1,256], leak=self.leak)
        conv6 = self.conv_2d(self.layer_names[7], conv5, shape=[3,3,512], leak=self.leak)
        mp6 = self.max_pool(self.layer_names[8], conv6)


        conv7 = self.conv_2d(self.layer_names[9], mp6, shape=[1,1,256], leak=self.leak)
        conv8 = self.conv_2d(self.layer_names[10], conv7, shape=[3,3,512], leak=self.leak)
        conv9 = self.conv_2d(self.layer_names[11], conv8, shape=[1,1,256], leak=self.leak)
        conv10 = self.conv_2d(self.layer_names[12], conv9, shape=[3,3,512], leak=self.leak)
        conv11 = self.conv_2d(self.layer_names[13], conv10, shape=[1,1,256], leak=self.leak)
        conv12 = self.conv_2d(self.layer_names[14], conv11, shape=[3,3,512], leak=self.leak)
        conv13 = self.conv_2d(self.layer_names[15], conv12, shape=[1,1,256], leak=self.leak)
        conv14 = self.conv_2d(self.layer_names[16], conv13, shape=[3,3,512], leak=self.leak)
        conv15 = self.conv_2d(self.layer_names[17], conv14, shape=[1,1,512], leak=self.leak)
        conv16 = self.conv_2d(self.layer_names[18], conv15, shape=[3,3,1024], leak=self.leak)
        mp16 = self.max_pool(self.layer_names[19], conv16)

        conv17 = self.conv_2d(self.layer_names[20], mp16, shape=[1, 1, 512], leak=self.leak)
        conv18 = self.conv_2d(self.layer_names[21], conv17, shape=[3, 3, 1024], leak=self.leak)
        conv19 = self.conv_2d(self.layer_names[22], conv18, shape=[1, 1, 512], leak=self.leak)
        conv20 = self.conv_2d(self.layer_names[23], conv19, shape=[3, 3, 1024], leak=self.leak)
        conv21 = self.conv_2d(self.layer_names[24], conv20, shape=[3, 3, 1024], leak=self.leak)
        conv22 = self.conv_2d(self.layer_names[25], conv21, shape=[3, 3, 1024], strides=[1,2,2,1], leak=self.leak)

        conv23 = self.conv_2d(self.layer_names[26], conv22, shape=[3, 3, 1024], leak=self.leak)
        conv24 = self.conv_2d(self.layer_names[27], conv23, shape=[3, 3, 1024], leak=self.leak)

        conv24shape = conv24.get_shape()
        conv24a = tf.reshape(tf.transpose(conv24, [0, 3, 1, 2]), [-1,  conv24shape[1].value * conv24shape[2].value * conv24shape[3].value])

        fc1 = self.fc(self.layer_names[28], conv24a, 4096, leak=self.leak)

        fc1drop = self.dropout(self.layer_names[29], fc1, keepProb=self.dropout_prob)

        size = self.S*self.S*(5*self.B + self.C)
        fc2 = self.fc(self.layer_names[30], fc1drop, size, leak=1.0)

        # out = tf.reshape(fc2,[-1, self.S, self.S, 5*self.B + self.C ], )
        out = fc2

        return out

    def loss(self, images, labels, reg):
        result = self.inference(images)

        return result

    def get_weights(self, layer_name):
        with tf.Graph().as_default() as graph:

            img = tf.placeholder(tf.float32, shape=[1, self.input_h, self.input_w, 3], name="InputImage")
            res = self.inference(img)

            with tf.variable_scope(layer_name) as scope:
                scope.reuse_variables()
                biases = tf.get_variable("biases")
                weights = tf.get_variable("weights")

            init = tf.global_variables_initializer()

            with tf.Session() as session:

                if self.checkpoint_path is not None:
                    tf.train.Saver().restore(session, save_path=self.checkpoint_path)
                else:
                    session.run(init)

                result = session.run([weights, biases])

        return result

    def plot_bounding_box(self, image, class_prob, box_conf, bbox, thr=0.2):
        probs = np.zeros((self.S, self.S, self.B, self.C))
        bounding_boxes = []
        for i in range(2):
            for j in range(self.C):
                probs[:, :, i, j] = np.multiply(class_prob[:, :, j], box_conf[:, :, i])

        for row in range(self.S):
            for col in range(self.S):
                for box_id in range(self.B):
                    score = np.amax(probs[row, col, box_id, :])
                    class_id = np.argmax(probs[row, col, box_id, :])
                    current_class = self.class_names[class_id]
                    if score > thr:
                        h = image.shape[0]
                        w = image.shape[1]
                        x = (bbox[row, col, box_id, 0] + col) / self.S * w
                        y = (bbox[row, col, box_id, 1] + row) / self.S * h
                        box_w = (bbox[row, col, box_id, 2] ** 2) * w
                        box_h = (bbox[row, col, box_id, 3] ** 2) * h
                        left = max(0, x - (box_w / 2))
                        right = min(w - 1, x + (box_w / 2))
                        top = max(0, y - (box_h / 2))
                        bottom = min(h - 1, y + (box_h / 2))

                        rectangle = [top, left, bottom, right]

                        bounding_boxes.append([rectangle, [score, current_class]])

        return bounding_boxes

    def detect(self, image):

        current_dropout = self.dropout_prob
        self.dropout_prob = 1.0

        img_out = image.copy()

        image = scipy.misc.imresize(image, size=[self.input_h, self.input_w])
        image = image.astype(np.float32)
        image /= (255 / 2)
        image -= 1

        image = np.expand_dims(image, axis=0)

        with tf.Graph().as_default() as graph:

            img = tf.placeholder(tf.float32, shape=[1, self.input_h, self.input_w, 3], name="InputImage")
            output = self.inference(img)

            init = tf.global_variables_initializer()


            with tf.Session() as session:

                if self.checkpoint_path is not None:
                    tf.train.Saver().restore(session, save_path=self.checkpoint_path)
                else:
                    session.run(init)

                result = session.run(output, feed_dict={img : image})

        network_output = np.squeeze(result, axis=0)

        print network_output

        # class_probabilities = network_output[:,:,0:self.C]
        # box_confidences = network_output[:,:,self.C:self.C+self.B]
        # bounding_boxes = np.reshape(network_output[:, :, self.C + self.B:],[self.S, self.S, self.B, 4 ])

        class_probabilities = np.reshape(network_output[0:(self.S * self.S * self.C)],[self.S, self.S, self.C])
        box_confidences = np.reshape(network_output[(self.S * self.S * self.C) : (self.S * self.S * self.C) + (self.S * self.S * self.B)],[self.S, self.S, self.B])
        bounding_boxes = np.reshape(network_output[(self.S * self.S * self.C) + (self.S * self.S * self.B):],[self.S, self.S, self.B, 4])

        result = self.plot_bounding_box(img_out, class_probabilities, box_confidences, bounding_boxes, thr = self.thr)

        self.dropout_prob = current_dropout
        return result



