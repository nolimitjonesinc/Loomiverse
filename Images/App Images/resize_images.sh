#!/bin/bash
counter=1
for image in *.[pP][nN][gG]; do  # Matches .png and .PNG
  convert "$image" -resize 64x64\> "${counter}_small.png"
  convert "$image" -resize 128x128\> "${counter}_medium.png"
  convert "$image" -resize 256x256\> "${counter}_large.png"
  let counter++
done
