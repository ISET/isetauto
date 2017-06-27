import tensorflow as tf
from Yolo import *
from Solver import *
from scipy import misc

def main(argv=None):

    network = Yolo()
    # network.initialize_weights_darknet("/home/hblasins/Documents/NN_Camera_Generalization/Architectures/Yolo/weights")
    # network.save_weights("/home/hblasins/Documents/NN_Camera_Generalization/Architectures/Yolo/yolo-full-tfv4")
    network.checkpoint_path = "/home/hblasins/Documents/NN_Camera_Generalization/Architectures/Yolo/yolo-full-tfv4"

    image = misc.imread("dog.jpg")

    result = network.detect(image)

    print result

    for bbox in result:
       print bbox

    # result = network.get_weights(network.layer_names[30])

    # print result
    # print result[0].shape, result[1].shape




    print 'Bye!'

if __name__ == '__main__':
    print "Tensorflow version: %s" % tf.__version__
    tf.app.run()