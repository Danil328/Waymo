#!/usr/bin/env bash
set -ex

cd ../src/tracker
#python make_fake_tracking_submission.py --tf-root ../../data/validation \
#                                        --output /Projects/Waymo/work_dirs/retinanet_r50_fpn_fp16_1x/fake_tracking_predicts.bin

cd ../../waymo-open-dataset/
#rm -r /Projects/Waymo/work_dirs/retinanet_r50_fpn_fp16_1x/fake_tracking_submission
#mkdir /Projects/Waymo/work_dirs/retinanet_r50_fpn_fp16_1x/fake_tracking_submission
./bazel-bin/waymo_open_dataset/metrics/tools/create_submission \
            --input_filenames='/Projects/Waymo/work_dirs/retinanet_r50_fpn_fp16_1x/fake_tracking_predicts.bin' \
            --output_filename='/Projects/Waymo/work_dirs/retinanet_r50_fpn_fp16_1x/fake_tracking_submission/model' \
            --submission_filename='/Projects/Waymo/waymo-open-dataset/waymo_open_dataset/metrics/tools/tracking_submission.txtpb'

tar czvf /Projects/Waymo/work_dirs/retinanet_r50_fpn_fp16_1x/fake_tracking_submission.tar.gz /Projects/Waymo/work_dirs/retinanet_r50_fpn_fp16_1x/fake_tracking_submission/