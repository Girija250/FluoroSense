import numpy as np
from PIL import Image
import tensorflow as tf
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input
from pathlib import Path

root = Path('../dataset')
with open('assets/labels.txt','r') as f:
    labels=[line.strip() for line in f.readlines()]

interpreter=tf.lite.Interpreter(model_path='assets/model.tflite')
interpreter.allocate_tensors()
input_details=interpreter.get_input_details()
output_details=interpreter.get_output_details()

correct=0
total=0
confidences=[]
for cls in sorted([p for p in root.iterdir() if p.is_dir()]):
    true_idx = labels.index(cls.name)
    for img_path in cls.glob('*'):
        if img_path.suffix.lower() not in {'.jpg','.jpeg','.png','.bmp','.tif','.tiff'}:
            continue
        total += 1
        img = Image.open(img_path).convert('RGB').resize((224, 224))
        arr = preprocess_input(np.array(img, dtype=np.float32)[None, ...])
        interpreter.set_tensor(input_details[0]['index'], arr)
        interpreter.invoke()
        probs = np.squeeze(interpreter.get_tensor(output_details[0]['index']))
        pred_idx = int(np.argmax(probs))
        if pred_idx == true_idx:
            correct += 1
        confidences.append(float(probs[pred_idx]))

print('accuracy', correct / total)
print('avg_conf', np.mean(confidences))
print('median_conf', np.median(confidences))
print('min_conf', np.min(confidences), 'max_conf', np.max(confidences))
