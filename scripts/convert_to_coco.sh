#!/usr/bin/env bash

cd ../src
#mkdir ../data/annotations
#mkdir ../data/images

#python waymo_to_coco.py --tf-root ../data/training --output-images ../data/images/training_images --output-json ../data/annotations/train_annotation.json
python waymo_to_coco.py --tf-root ../data/validation --output-images ../data/images/validation_images --output-json ../data/annotations/val_annotation.json
python waymo_to_coco.py --tf-root ../data/testing --output-images ../data/images/testing_images --output-json ../data/annotations/test_annotation.json
