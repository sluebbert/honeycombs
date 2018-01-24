#!/bin/bash

# Print preview to screen
../../honeycombs.py moon.jpg -w 70 -t 140 -i -p

# Dump data array to file
../../honeycombs.py moon.jpg -w 70 -t 140 -i > ./generated.scad && cat ../../honeycombs.scad >> ./generated.scad

openscad ./generated.scad --camera=0,0,0,360,0,90,0 --viewall --colorscheme=Starnight -o ./generated.png
