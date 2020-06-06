import argparse
import pickle

import numpy as np
from mmdet.ops.nms import soft_nms
from tqdm import tqdm

parser = argparse.ArgumentParser(description='Make submission')
parser.add_argument('--pkls', nargs='+', required=True)
parser.add_argument('--out', type=str, required=True)
parser.add_argument('--iou_thr', type=float, default=0.5)
parser.add_argument('--sigma', type=float, default=0.5)
parser.add_argument('--min_score', type=float, default=0.05)
if __name__ == '__main__':
    args = parser.parse_args()

    predicts = {}
    for idx, pkl in enumerate(args.pkls):
        with open(pkl, 'rb') as f:
            predicts[idx] = pickle.load(f)

    new_predicts = []

    for image_id in tqdm(range(len(predicts[0]))):
        new_predict = []
        for object_id, object_type in enumerate(["TYPE_VEHICLE", "TYPE_PEDESTRIAN", "TYPE_SIGN", "TYPE_CYCLIST"]):
            dets = [predicts[key][image_id][object_id] for key in predicts.keys()]
            dets = list(filter(lambda x: min(x.shape) > 0, dets))
            if len(dets) > 0:
                dets = np.concatenate(dets)
                new_dets, inds = soft_nms(dets, args.iou_thr, sigma=args.sigma, min_score=args.min_score)
            else:
                new_dets = np.zeros((0, 5))
            new_predict.append(new_dets)
        new_predicts.append(new_predict)

    with open(args.out, 'wb') as f:
        pickle.dump(new_predicts, f)
