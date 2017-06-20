# -*- coding: cp936 -*-
import numpy as np
import math
import cv2
import os
import xml.etree.ElementTree as ET
#from scipy.special import expit
#from darkflow.utils.box import BoundBox, box_iou, prob_compare
#from utils.box import prob_compare2, box_intersection
from darkflow.utils.box import BoundBox,box_iou
from darkflow.cython_utils.cy_yolo2_findboxes import box_constructor

def expit(x):
	return 1. / (1. + np.exp(-x))

def _softmax(x):
    e_x = np.exp(x - np.max(x))
    out = e_x / e_x.sum()
    return out

def findboxes(self, net_out):
	# meta
	meta = self.meta
	boxes = list()
	boxes=box_constructor(meta,net_out)
	return boxes
def bb_intersection_over_union(boxA, boxB):
	# determine the (x, y)-coordinates of the intersection rectangle
	xA = max(boxA[0], boxB[0])
	yA = max(boxA[1], boxB[1])
	xB = min(boxA[2], boxB[2])
	yB = min(boxA[3], boxB[3])

	# compute the area of intersection rectangle
	interArea = (xB - xA + 1) * (yB - yA + 1)

	# compute the area of both the prediction and ground-truth
	# rectangles
	boxAArea = (boxA[2] - boxA[0] + 1) * (boxA[3] - boxA[1] + 1)
	boxBArea = (boxB[2] - boxB[0] + 1) * (boxB[3] - boxB[1] + 1)

	# compute the intersection over union by taking the intersection
	# area and dividing it by the sum of prediction + ground-truth
	# areas - the interesection area
	iou = interArea / float(boxAArea + boxBArea - interArea)

	# return the intersection over union value
	return iou
IoU_all=[]
def postprocess(self, net_out, im, save = True):
	"""
	Takes net output, draw net_out, save to disk
	"""
	path = '/home/shun628/darkflow/pascal/Annotations/'
	file_path = os.path.split(im)
	lists = file_path[1].split('.')
	file_pro = lists[-2]
	xml_name=path+file_pro+'.xml'
	in_file = open(xml_name)
	tree=ET.parse(in_file)
	root = tree.getroot()
	jpg = str(root.find('filename').text)
	imsize = root.find('size')
	w = int(imsize.find('width').text)
	h = int(imsize.find('height').text)
	all = list()
	for obj in root.iter('object'):
		current = list()
		name = obj.find('name').text
		#if name not in pick:
                        #continue
		xmlbox = obj.find('bndbox')
		xn = int(float(xmlbox.find('xmin').text))
		xx = int(float(xmlbox.find('xmax').text))
		yn = int(float(xmlbox.find('ymin').text))
		yx = int(float(xmlbox.find('ymax').text))
		current = [name,xn,yn,xx,yx]
		all += [current]
		aaa=[xn,yn,xx,yx]
	
	boxes = self.findboxes(net_out)
	# meta
	meta = self.meta
	threshold = meta['thresh']
	colors = meta['colors']
	labels = meta['labels']
	if type(im) is not np.ndarray:
		imgcv = cv2.imread(im)
	else: imgcv = im
	h, w, _ = imgcv.shape
	
	textBuff = "["
	for b in boxes:
		boxResults = self.process_box(b, h, w, threshold)
		if boxResults is None:
			continue
		left, right, top, bot, mess, max_indx, confidence = boxResults
		thick = int((h + w) // 300)
		if self.FLAGS.json:
			line = 	('{"label":"%s",'
					'"confidence":%.2f,'
					'"topleft":{"x":%d,"y":%d},'
					'"bottomright":{"x":%d,"y":%d}},\n') % \
					(mess, confidence, left, top, right, bot)
			textBuff += line
			continue
		tagaa=mess+': '+str(round(confidence,3))
		cv2.rectangle(imgcv,
			(left, top), (right, bot),
			(0, 0, 255), thick)
		cv2.putText(imgcv, tagaa, (left, top - 12),
			0, 1e-3 * h, (0, 0, 255),thick//3)
		'''
		cv2.putText(imgcv, mess, (left, top - 12),
			0, 1e-3 * h, colors[max_indx],thick//3)
		'''
		if len(mess):
                	bbb=[left,top,right,bot]
		else:
			bbb=[1,2,3,4]
		IoU=bb_intersection_over_union(aaa,bbb)
		IoU=round(IoU,3)
		IoU_all.append(IoU)
		
	
	if not save: return imgcv
	# Removing trailing comma+newline adding json list terminator.
	textBuff = textBuff[:-2] + "]"
	outfolder = os.path.join(self.FLAGS.test, 'out')
	img_name = os.path.join(outfolder, im.split('/')[-1])
	if self.FLAGS.json:
		textFile = os.path.splitext(img_name)[0] + ".json"
		with open(textFile, 'w') as f:
			f.write(textBuff)
		return

	cv2.imwrite(img_name, imgcv)
	return IoU_all
