#!/bin/bash

# Print preview to screen
../../honeycombs.py stencil.jpg -w 140 -t 140 -p

# Dump data array to file
../../honeycombs.py stencil.jpg -w 140 -t 140 > ./generated.scad && cat ../../honeycombs.scad >> ./generated.scad

openscad ./generated.scad --camera=0,0,0,360,0,90,0 --viewall --colorscheme=Starnight -o ./generated.png
