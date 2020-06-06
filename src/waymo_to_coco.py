import argparse
import glob
import json
import os
import shutil
from itertools import zip_longest
from imagesize import get as get_size
import cv2
import tensorflow as tf
from tqdm import tqdm

from waymo_open_dataset import dataset_pb2 as open_dataset


def bbox2polygon(bbox):
    x0 = bbox[0]
    y0 = bbox[1]
    width = bbox[2]
    height = bbox[3]
    return [x0, y0, x0 + width, y0, x0 + width, y0 + height, x0, y0 + height]


def convert_my_dataset_to_coco_dataset(tf_root, output_root):
    os.makedirs(output_root, exist_ok=True)
    image_id = 0
    annotations = []
    imgs = []
    k = 0

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
                        x = label.box.center_x - 0.5 * label.box.length
                        y = label.box.center_y - 0.5 * label.box.width
                        width = label.box.length
                        height = label.box.width
                        bbox = [x, y, width, height]

                        annotations.append({"segmentation": [bbox2polygon(bbox)],
                                            "bbox": bbox,
                                            "id": k,
                                            "iscrowd": 0,
                                            "image_id": image_id,
                                            "area": width * height,
                                            "category_id": label.type-1})
                        k += 1

                image = tf.image.decode_jpeg(camera_image.image).numpy()
                image_name = f"{context_name}#{timestamp_micros}#{camera_name}.png"
                height, width = image.shape[:2]
                # width, height = get_size(os.path.join(output_root, image_name))
                img_anno = {"id": image_id,
                            "width": width,
                            "height": height,
                            "file_name": image_name,
                            }
                imgs.append(img_anno)
                cv2.imwrite(os.path.join(output_root, image_name), cv2.cvtColor(image, cv2.COLOR_RGB2BGR))
                image_id += 1

    cocodataset = {'images': imgs, 'annotations': annotations}
    categories = [
        # {"name": "TYPE_UNKNOWN", "id": 0},
        {"name": "TYPE_VEHICLE", "id": 1-1},
        {"name": "TYPE_PEDESTRIAN", "id": 2-1},
        {"name": "TYPE_SIGN", "id": 3-1},
        {"name": "TYPE_CYCLIST", "id": 4-1}
    ]
    cocodataset['categories'] = categories
    return cocodataset


parser = argparse.ArgumentParser(description='tfrecord2coco')
parser.add_argument('--tf-root', type=str)
parser.add_argument('--output-images', type=str)
parser.add_argument('--output-json', type=str)
if __name__ == '__main__':
    args = parser.parse_args()
    cocodataset = convert_my_dataset_to_coco_dataset(args.tf_root, args.output_images)
    with open(os.path.join("../data/", args.output_json), "w") as f:
        json.dump(cocodataset, f)
