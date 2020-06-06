import argparse
import pickle
import json

from tqdm import tqdm
from waymo_open_dataset import dataset_pb2
from waymo_open_dataset import label_pb2
from waymo_open_dataset.protos import metrics_pb2

parser = argparse.ArgumentParser(description='Make submission')
parser.add_argument('pkl', type=str)
parser.add_argument('--annotation', type=str, default="../data/annotations/test_annotation.json")
parser.add_argument('--output', type=str, default="submission.proto")
parser.add_argument('--threshold', type=float, default=0.0)
if __name__ == '__main__':
    args = parser.parse_args()

    with open(args.pkl, 'rb') as f:
        predicts = pickle.load(f)

    with open(args.annotation, "r") as f:
        ann = json.load(f)

    images = [i['file_name'] for i in ann['images']]

    objects = metrics_pb2.Objects()
    threshold = args.threshold
    for image_name, predict in tqdm(zip(images, predicts), total=len(images)):
        image_name_parts = image_name[:-4].split("#")
        context_name = image_name_parts[0]
        timestamp = int(image_name_parts[1])
        camera_name = image_name_parts[2]
        for idx, object_type in enumerate(["TYPE_VEHICLE", "TYPE_PEDESTRIAN", "TYPE_SIGN", "TYPE_CYCLIST"]):
            p = predict[idx]
            if p.shape[0] > 0:
                scores = p[:, 4]
                p = p[scores >= threshold]
                for bbox in p:
                    o = metrics_pb2.Object()
                    # The following 3 fields are used to uniquely identify a frame a prediction
                    # is predicted at. Make sure you set them to values exactly the same as what
                    # we provided in the raw data. Otherwise your prediction is considered as a
                    # false positive.

                    o.context_name = context_name
                    # The frame timestamp for the prediction. See Frame::timestamp_micros in
                    # dataset.proto.
                    o.frame_timestamp_micros = timestamp
                    # This is only needed for 2D detection or tracking tasks.
                    # Set it to the camera name the prediction is for.
                    o.camera_name = getattr(dataset_pb2.CameraName, camera_name)

                    # Populating box and score.
                    x0, y0, x1, y1, score = bbox
                    box = label_pb2.Label.Box()
                    box.center_x = int((x0+x1)/2)
                    box.center_y = int((y0+y1)/2)
                    # box.center_z = 0
                    # box.length = 0
                    box.length = x1 - x0
                    box.width = y1 - y0
                    # box.heading = 0
                    o.object.box.CopyFrom(box)
                    # This must be within [0.0, 1.0]. It is better to filter those boxes with
                    # small scores to speed up metrics computation.
                    o.score = score
                    # For tracking, this must be set and it must be unique for each tracked
                    # sequence.
                    # o.object.id = ''
                    # Use correct type.
                    o.object.type = getattr(label_pb2.Label, object_type)

                    objects.objects.append(o)
            #     break
            # break

    # Add more objects. Note that a reasonable detector should limit its maximum
    # number of boxes predicted per frame. A reasonable value is around 400. A
    # huge number of boxes can slow down metrics computation.

    # Write objects to a file.
    with open(args.output, 'wb') as f:
        f.write(objects.SerializeToString())