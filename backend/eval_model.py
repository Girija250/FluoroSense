import numpy as np
from PIL import Image
import tensorflow as tf
from pathlib import Path

root = Path('../dataset')
print('Dataset folders:', [p.name for p in root.iterdir() if p.is_dir()])
for cls in sorted([p for p in root.iterdir() if p.is_dir()]):
    print(cls.name, len(list(cls.glob('*'))))

with open('assets/labels.txt','r') as f:
    labels=[line.strip() for line in f.readlines()]
print('labels:', labels)

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
        total+=1
        img=Image.open(img_path).convert('RGB').resize((224,224))
        arr=np.array(img, dtype=np.float32)[None,...]/255.0
        interpreter.set_tensor(input_details[0]['index'], arr)
        interpreter.invoke()
        probs=np.squeeze(interpreter.get_tensor(output_details[0]['index']))
        pred_idx=int(np.argmax(probs))
        if pred_idx==true_idx:
            correct+=1
        confidences.append(float(probs[pred_idx]))
        print(f'{img_path.name}: true={cls.name}, pred={labels[pred_idx]}, conf={probs[pred_idx]:.3f}')

print('accuracy', correct/total)
print('avg_conf', np.mean(confidences))
print('min_conf', np.min(confidences), 'max_conf', np.max(confidences))
print('median_conf', np.median(confidences))
