from Net import Net

class Yolo(Net):

    B = 2
    C = 30
    S = 7

    def inference(self,inputs):

        conv1 = self.conv_2d('Conv-7x7x64-s-2',inputs,strides=[1,2,2,1])
        mp1 = self.max_pool('MaxPool-2x2-s-2',conv1)

        conv2 = self.conv_2d('Conv-3x3x192',mp1)
        mp2 = self.max_pool('MaxPool-2x2-s-2',conv2)

        c



