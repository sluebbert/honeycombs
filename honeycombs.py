#!/usr/bin/python

import imageio
import math
import argparse
import random
import os
import sys

parser = argparse.ArgumentParser(description='Convert image to honeycomb grid .scad data.')
parser.add_argument('imageFile', type=str, help='the image file to convert.')
parser.add_argument('-p', '--preview', action='store_true', dest='previewImage', help='display the converted image.')
parser.add_argument('-i', '--invert', action='store_true', dest='invert', help='invert the grayscale result.')
parser.add_argument('-w', '--width', type=int, dest='targetWidth', default=50, help='target width of 2d array (scale).')
parser.add_argument('-t', '--threshold', type=int, dest='threshold', default=255, help='threshold to use for grayscale clipping [0 - 255].')
parser.add_argument('-n', '--noise', type=float, dest='noise', default=0, help='probability of introducing noise [0.0 - 1.0].')
parser.add_argument('-s', '--seed', type=int, dest='seed', default=0, help='random seed.')
args = parser.parse_args()

if args.seed > 0:
	random.seed(args.seed)
else:
	args.seed = random.randint(1, 9999999)
	random.seed(args.seed)

im = imageio.imread(args.imageFile)

scale = math.ceil(im.shape[1] / args.targetWidth)
columnStepSize = scale
rowStepSize = scale

flattened = []

def toGrayScale(color):
	if not isinstance(color, list) and not isinstance(color, imageio.core.util.Image):
		return color

	alpha = 1
	if len(color) > 3:
		alpha = color[3] / 255
	if alpha == 0:
		return 255
	return color[0] * 0.3 + color[1] * 0.59 + color[2] * 0.11

def printArray(flattened):
	converted = []
	for y in flattened:
		row = []
		converted.append(row)
		for x in y:
			t = 0
			if x < 180:
				t = 1
			elif x < 255:
				t = 2
			row.append(t)

	print('// Input file: %s' % (os.path.basename(args.imageFile)))
	print('// Random Seed: %i' % (args.seed))
	print('// Command: %s' % (' '.join(sys.argv)))
	print()
	print('data = ', end = '')
	print(converted, end = '')
	print(';')

def previewImage(flattened):
	print(' image size: %ix%i' % (im.shape[1], im.shape[0]))
	print('  data size: %ix%i' % (len(flattened[0]), len(flattened)))
	print('random seed: %i' % (args.seed))

	for y in flattened:
		for x in y:
			# if x < 80:
			# 	print('██', end='')
			# elif x < 140:
			# 	print('▓▓', end='')
			if x < 180:
				print('██', end='')
			elif x < 255:
				print('▒▒', end='')
			else:
				print('  ', end='')
		print()

for rowIndex, row in enumerate(im[::rowStepSize]):
	flattened.append([])
	heightLimit = rowIndex * rowStepSize + rowStepSize
	if heightLimit > im.shape[0]:
		heightLimit = im.shape[0]

	for columnIndex, column in enumerate(row[::columnStepSize]):
		widthLimit = columnIndex * columnStepSize + columnStepSize
		if widthLimit > im.shape[1]:
			widthLimit = im.shape[1]

		sum = 0
		count = 0
		for yyi, yy in enumerate(im[rowIndex * rowStepSize:heightLimit]):
			for xxi, xx in enumerate(row[columnIndex * columnStepSize:widthLimit]):
				val = toGrayScale(xx)
				if val >= args.threshold:
					sum += 255
				count += 1

		value = sum / count
		if args.invert:
			value = 255 - value
		if value < args.threshold and args.noise > 0 and args.noise > random.random():
			value = random.randint(0, 255)

		flattened[rowIndex].append(value)


if args.previewImage:
	previewImage(flattened)
else:
	printArray(flattened)
