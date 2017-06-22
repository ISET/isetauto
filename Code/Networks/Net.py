import tensorflow as tf
import numpy as np

class Net(object):

    def __init__(self):
        # Initialize
        self.initializers = dict()

    def forward(self):
        # Forward pass
        None

    def loss(self):
        # Loss
        None

    def create_reg_variable(self, name, shape, stddev, reg):
        var = self.create_cpu_variable(name, shape, tf.truncated_normal_initializer(stddev=stddev), True)
        if reg is not None:
            penalty = tf.mul(tf.nn.l2_loss(var), reg, name='weightL2norm')
            tf.add_to_collection('regularizationLosses', penalty)

        return var

    def create_cpu_variable(self, name, shape, init, tr):

        var_name = tf.get_variable_scope().name + "-" + name
        if var_name in self.initializers.keys():
            initializer = self.initializers[var_name]
        else:
            initializer = init


        with tf.device('/cpu:0'):
            var = tf.get_variable(name, shape, initializer=initializer, trainable=tr)

        return var

    def conv_2d(self, name, input, shape, stddev=None, reg=None, strides=[1, 1, 1, 1], leak = 0.0):

        input_shape = input.get_shape()

        in_channels = input_shape[3].value
        out_channels = shape[2]

        w_shape = shape[0:2]
        w_shape.append(in_channels)
        w_shape.append(out_channels)

        if stddev is None:
            stddev = np.sqrt(2.0 / (shape[0] * shape[1] * in_channels))

        with tf.variable_scope(name):
            W = self.create_reg_variable('weights', w_shape , stddev, reg)
            b = self.create_cpu_variable('biases', out_channels, tf.constant_initializer(0.0), True)
            conv = tf.nn.conv2d(input, W, strides=strides, padding='SAME', name='convOut') + b

            out = tf.nn.relu(conv) + (-leak*tf.nn.relu(-conv))


        return out

    def max_pool(self, name, input, stride=[1, 2, 2, 1]):
        with tf.variable_scope(name):
            out = tf.nn.max_pool(input, ksize=[1, 2, 2, 1], strides=stride, padding='SAME', name='maxPool')

        return out


    def fc(self, name, input, shape, stddev=None, reg=None, leak=0.0):

        input_shape = input.get_shape()
        w_shape = [input_shape[1].value, shape]

        if stddev is None:
            stddev = np.sqrt(2.0 / np.prod(w_shape))

        with tf.variable_scope(name):
            W = self.create_reg_variable('weights', w_shape, stddev, reg)
            b = self.create_cpu_variable('biases', shape, tf.constant_initializer(0.0), True)
            mult = tf.add(tf.matmul(input, W), b, 'fcOut')

            out = tf.nn.relu(mult) + (-leak*tf.nn.relu(-mult))

        return out

    def dropout(self, name, input, keepProb=1.0):
        drop = tf.nn.dropout(input, keepProb, name=name)

        return drop

    def softmax(self, input, name, shape, stddev, reg):
        with tf.variable_scope(name):
            W = self.create_reg_variable('weights', shape, stddev, reg)
            b = self.create_cpu_variable('biases', shape[1], tf.constant_initializer(0.0), True)

            smax = tf.nn.softmax(tf.matmul(input, W) + b, 'softmaxOut')

        return smax

