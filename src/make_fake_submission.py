import argparse
import glob
import os
from itertools import zip_longest

import tensorflow as tf
from tqdm import tqdm
from waymo_open_dataset import dataset_pb2
from waymo_open_dataset import dataset_pb2 as open_dataset
from waymo_open_dataset import label_pb2
from waymo_open_dataset.protos import metrics_pb2


def get_objects(tf_root):
    objects = metrics_pb2.Objects()
    frame = open_dataset.Frame()
    files = glob.glob(os.path.join(tf_root, "*.tfrecord"))
    for file_name in tqdm(files[:]):
        dataset = tf.data.TFRecordDataset(file_name, compression_type='')
        for idx, data in enumerate(dataset):
            frame.ParseFromString(bytearray(data.numpy()))
            context_name = frame.context.name
            timestamp_micros = frame.timestamp_micros
            for camera_image, camera_label in zip_longest(frame.images, frame.camera_labels):
                camera_name = open_dataset.CameraName.Name.Name(camera_image.name)
                if camera_label is not None:
                    for label in camera_label.labels:
                        o = metrics_pb2.Object()
                        o.context_name = context_name
                        o.frame_timestamp_micros = timestamp_micros
                        o.camera_name = getattr(dataset_pb2.CameraName, camera_name)

                        box = label_pb2.Label.Box()
                        box.center_x = label.box.center_x
                        box.center_y = label.box.center_y
                        box.length = label.box.length
                        box.width = label.box.width
                        o.object.box.CopyFrom(box)
                        # This must be within [0.0, 1.0]. It is better to filter those boxes with
                        # small scores to speed up metrics computation.
                        o.score = 1.0
                        # For tracking, this must be set and it must be unique for each tracked
                        # sequence.
                        o.object.id = ''
                        # Use correct type.
                        o.object.type = label.type
                        objects.objects.append(o)
    return objects


parser = argparse.ArgumentParser(description='FakeValSubmission')
parser.add_argument('--tf-root', type=str)
parser.add_argument('--output', type=str)
if __name__ == '__main__':
    args = parser.parse_args()
    objects = get_objects(args.tf_root)
    with open(args.output, 'wb') as f:
        f.write(objects.SerializeToString())
