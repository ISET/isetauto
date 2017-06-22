import tensorflow as tf
from Yolo import *
from Solver import *
from scipy import misc

def main(argv=None):

    network = Yolo()
    network.initialize_weights_darknet("/home/hblasins/Documents/NN_Camera_Generalization/Architectures/Yolo/weights")
    network.save_weights("/home/hblasins/Documents/NN_Camera_Generalization/Architectures/Yolo/yolo-full-tf")
    network.checkpoint_path = "/home/hblasins/Documents/NN_Camera_Generalization/Architectures/Yolo/yolo-full-tf"

    # image = misc.imread("dog.jpg")

    # result = network.detect(image)

    result = network.get_weights(network.layer_names[5])

    print result[0].shape, result[1].shape

    print result


    print 'Bye!'

if __name__ == '__main__':
    print "Tensorflow version: %s" % tf.__version__
    tf.app.run()