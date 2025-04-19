import numpy as np
from PIL import Image
import math

# Safely formatted file path
txt_file = r'C:\IITGN 2nd year\ES 204 Digital Systems\Local-Contrast-Enhancement-of-Image\Python Codes\image_data.txt'

# Read intensity values from file
with open(txt_file, 'r') as f:
    data = f.read()

# Convert to list of integers
intensities = list(map(int, data.split()))

# Fixed width
width = 150

# Calculate required height
height = math.ceil(len(intensities) / width)

# Total number of pixels needed
required_pixels = width * height

# Pad with zeros if necessary
if len(intensities) < required_pixels:
    intensities += [0] * (required_pixels - len(intensities))

# Convert to 2D array
image_array = np.array(intensities, dtype=np.uint8).reshape((height, width))

# Convert to image and save
image = Image.fromarray(image_array, mode='L')
image.save('output_image.png')
image.show()
