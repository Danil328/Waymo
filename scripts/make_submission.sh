#!/usr/bin/env bash
set -ex

cfg_name="cascade_rcnn_hrnetv2p_w32_HD"

cd ../../mmdetection
./tools/dist_test.sh /Projects/Waymo/configs/${cfg_name}.py \
                    /Projects/Waymo/work_dirs/${cfg_name}/epoch_22.pth \
                    1 \
                    --out /Projects/Waymo/work_dirs/${cfg_name}/test_predicts.pkl

cd ../Waymo/src
python make_submission.py ../work_dirs/${cfg_name}/test_predicts.pkl \
                            --annotation ../data/annotations/test_annotation.json \
                            --output ../work_dirs/${cfg_name}/test_predicts.bin

cd ../waymo-open-dataset/

sub_dir=/Projects/Waymo/work_dirs/${cfg_name}/submission
if [[ -d ${sub_dir} ]]; then rm -Rf ${sub_dir}; fi
mkdir ${sub_dir}

./bazel-bin/waymo_open_dataset/metrics/tools/create_submission \
            --input_filenames /Projects/Waymo/work_dirs/${cfg_name}/test_predicts.bin \
            --output_filename /Projects/Waymo/work_dirs/${cfg_name}/submission/model \
            --submission_filename /Projects/Waymo/waymo-open-dataset/waymo_open_dataset/metrics/tools/submission.txtpb

tar czvf /Projects/Waymo/work_dirs/${cfg_name}/submission.tar.gz /Projects/Waymo/work_dirs/${cfg_name}/submission/