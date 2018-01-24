#!/bin/bash

# Print preview to screen
../../honeycombs.py shell.jpg -w 65 -t 140 -n 0.4 -s 6046634 -p

# Dump data array to file
../../honeycombs.py shell.jpg -w 65 -t 140 -n 0.4 -s 6046634 > ./generated.scad && cat ../../honeycombs.scad >> ./generated.scad

openscad ./generated.scad --camera=0,0,0,360,0,90,0 --viewall --colorscheme=Starnight -o ./generated.png
