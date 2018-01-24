#!/bin/bash

# Print preview to screen
../../honeycombs.py flower.gif -w 40 -n 0.4 -s 6621881 -p

# Dump data array to file
../../honeycombs.py flower.gif -w 40 -n 0.4 -s 6621881 > ./generated.scad && cat ../../honeycombs.scad >> ./generated.scad

openscad ./generated.scad --camera=0,0,0,360,0,90,0 --viewall --colorscheme=Starnight -o ./generated.png
