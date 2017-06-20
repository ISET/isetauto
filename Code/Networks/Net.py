import tensorflow as tf
import numpy as np

class Net:

    def __init__(self):
        # Initialize
        None

    def forward(self):
        # Forward pass
        None

    def loss(self):
        # Loss
        None

    def create_reg_variable(self, name, shape, stddev, param):
        var = self.create_cpu_variable(name, shape, tf.truncated_normal_initializer(stddev=stddev), True)
        if param is not None:
            penalty = tf.mul(tf.nn.l2_loss(var), param, name='weightL2norm')
            tf.add_to_collection('regularizationLosses', penalty)

        return var

    def create_cpu_variable(self, name, shape, init, tr):
        with tf.device('/cpu:0'):
            var = tf.get_variable(name, shape, initializer=init, trainable=tr)

        return var

    def conv_2d(self, name, input, shape, stddev, reg, strides=[1, 1, 1, 1]):
        with tf.variable_scope(name):
            W = self.create_reg_variable('weights', shape, stddev, reg)
            b = self.create_cpu_variable('biases', shape[3], tf.constant_initializer(0.0), True)
            conv = tf.nn.conv2d(input, W, strides=strides, padding='SAME', name='convOut')
            out = tf.nn.relu(conv + b, name='ReLUOut')

        return out

    def max_pool(self, name, input, stride=[1, 2, 2, 1]):
        with tf.variable_scope(name):
            out = tf.nn.max_pool(input, ksize=[1, 2, 2, 1], strides=stride, padding='SAME', name='maxPool')

        return out


    def fc(self, input, name, shape, stddev, reg, keepProb):
        with tf.variable_scope(name):
            W = self.create_reg_variable('weights', shape, stddev, reg)
            b = self.create_cpu_variable('biases', shape[1], tf.constant_initializer(0.0), True)
            mult = tf.add(tf.matmul(input, W), b, 'fcOut')
            multDrop = tf.nn.dropout(mult, keepProb)

        return multDrop

    def softmax(self, input, name, shape, stddev, reg):
        with tf.variable_scope(name):
            W = self.create_reg_variable('weights', shape, stddev, reg)
            b = self.create_cpu_variable('biases', shape[1], tf.constant_initializer(0.0), True)

            smax = tf.nn.softmax(tf.matmul(input, W) + b, 'softmaxOut')

        return smax

