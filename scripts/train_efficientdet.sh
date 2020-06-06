#!/usr/bin/env bash

cd ../../EfficientDet
python train.py -c 3 -p waymo --batch_size 32 --lr 1e-5 --num_epochs 10 \
 --data_path /Projects/Waymo/data \
 --load_weights /Projects/EfficientDet/pretrainded_models/efficientdet-d3.pth \
 --head_only True

#python coco_eval.py -p waymo -c 3 -w logs/waymo/efficientdet-d3_2_51000.pth