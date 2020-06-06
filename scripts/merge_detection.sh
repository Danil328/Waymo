#!/usr/bin/env bash

cfg_name="cascade_rcnn_hrnetv2p_w32_HD"

set -ex

cd ../src
python merge_detection.py --pkls ../work_dirs/${cfg_name}/val_predicts_22.pkl ../work_dirs/${cfg_name}/val_predicts_23.pkl \
                          --out ../work_dirs/${cfg_name}/val_predicts_merged.pkl \
                          --iou_thr 0.9 \
                          --sigma 0.5 \
                          --min_score 0.05
