#!/usr/bin/env bash
set -ex

cfg_name="cascade_rcnn_hrnetv2p_w32_HD"

cd ../../mmdetection
#./tools/dist_test.sh /Projects/Waymo/configs/${cfg_name}.py \
#                    /Projects/Waymo/work_dirs/${cfg_name}/epoch_17.pth \
#                    1 \
#                    --out /Projects/Waymo/work_dirs/${cfg_name}/val_predicts.pkl

cd ../Waymo/src
python tracker/make_submission.py ../work_dirs/${cfg_name}/val_predicts.pkl \
                            --annotation ../data/annotations/val_annotation.json \
                            --output ../work_dirs/${cfg_name}/val_tracking_predicts.bin \
                            --threshold 0.5 \
                            --min_square 100

cd ../waymo-open-dataset/

sub_dir=/Projects/Waymo/work_dirs/${cfg_name}/val_tracking_submission
if [[ -d ${sub_dir} ]]; then rm -Rf ${sub_dir}; fi
mkdir ${sub_dir}

./bazel-bin/waymo_open_dataset/metrics/tools/create_submission \
            --input_filenames /Projects/Waymo/work_dirs/${cfg_name}/val_tracking_predicts.bin \
            --output_filename /Projects/Waymo/work_dirs/${cfg_name}/val_tracking_submission/model \
            --submission_filename /Projects/Waymo/waymo-open-dataset/waymo_open_dataset/metrics/tools/tracking_submission.txtpb

tar czvf /Projects/Waymo/work_dirs/${cfg_name}/val_tracking_submission.tar.gz /Projects/Waymo/work_dirs/${cfg_name}/val_tracking_submission/