# ISETAUTO

We hope to learn how well machine-learning algorithms (mainly convolutional networks) generalize for different types of cameras.  The camera variations include lenses, CFAs and other design possibilities.

This repository includes the work we are doing to produce realistic driving scenes and that are acquired with a variety of camera designs.  We use the data from multiple camera designs to evaluate how well trained object detection networks generalize across camera designs.

Over time, the repository will contain the analyses from multiple papers on this topic.  This repository will depend on the isetcam, iset3d and isetcloud repositories.  In some instances, we may also depend on the RenderToolbox4 repository.

## Directory structure

* Parameters - stores files describing different aspects of the camera, for 
example lens descriptions.
* Code/Rendering - Matlab code that uses RTB4 to render images of cars in
urban environments

## Network environment

Tensorflow

## Collection of networks tested

Yolo, SSD, ...

## Camera models tested

Pinhole, double gauss, fisheye, ....
RGBW, ...


