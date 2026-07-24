import os
import random
from pathlib import Path
from PIL import Image, ImageOps, ImageEnhance, ImageFilter

random.seed(42)

SOURCE_ROOT = Path('../dataset')
OUTPUT_ROOT = Path('augmented_dataset')

IMAGE_EXTENSIONS = {'.jpg', '.jpeg', '.png', '.bmp', '.tif', '.tiff'}


def augment_image(img, index):
    img = img.convert('RGB')
    img = img.resize((224, 224))

    transforms = []
    transforms.append(('base', img.copy()))

    # Random brightness/contrast
    brightness = ImageEnhance.Brightness(img)
    transforms.append((f'bright_{index}', brightness.enhance(1.1 + 0.1 * random.random())))

    contrast = ImageEnhance.Contrast(img)
    transforms.append((f'contrast_{index}', contrast.enhance(1.05 + 0.1 * random.random())))

    # Slight rotation and shift
    rotated = img.rotate(random.uniform(-12, 12), expand=False, fillcolor=(255, 255, 255))
    transforms.append((f'rot_{index}', rotated))

    # Horizontal flip
    if random.random() > 0.5:
        transforms.append((f'flip_{index}', ImageOps.mirror(img)))

    # Gaussian blur occasionally
    if random.random() > 0.6:
        blurred = img.filter(ImageFilter.GaussianBlur(radius=0.6))
        transforms.append((f'blur_{index}', blurred))

    # Slight crop/resize to simulate scale variation
    if random.random() > 0.5:
        size = (200, 200)
        crop = img.resize(size)
        transforms.append((f'scale_{index}', crop.resize((224, 224))))

    return transforms


def main():
    if OUTPUT_ROOT.exists():
        for path in OUTPUT_ROOT.rglob('*'):
            if path.is_file():
                path.unlink()
        for path in sorted(OUTPUT_ROOT.rglob('*'), reverse=True):
            if path.is_dir():
                path.rmdir()
    OUTPUT_ROOT.mkdir(parents=True, exist_ok=True)

    for class_dir in sorted(SOURCE_ROOT.iterdir()):
        if not class_dir.is_dir():
            continue

        target_dir = OUTPUT_ROOT / class_dir.name
        target_dir.mkdir(parents=True, exist_ok=True)

        images = [p for p in class_dir.iterdir() if p.is_file() and p.suffix.lower() in IMAGE_EXTENSIONS]
        print(f"Augmenting {class_dir.name}: {len(images)} images")

        for idx, img_path in enumerate(images):
            image = Image.open(img_path).convert('RGB')
            variants = augment_image(image, idx)
            for suffix, variant in variants:
                output_path = target_dir / f"{img_path.stem}_{suffix}_{idx}.jpg"
                variant.save(output_path)

    print(f"Augmented dataset created at: {OUTPUT_ROOT}")


if __name__ == '__main__':
    main()
