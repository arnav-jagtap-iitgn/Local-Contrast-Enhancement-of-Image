import serial
import matplotlib.pyplot as plt
import numpy as np

# Open COM port (make sure the port is correct)
ComPort = serial.Serial('COM19') 
ComPort.baudrate = 9600
ComPort.bytesize = 8
ComPort.parity   = 'N'
ComPort.stopbits = 1  

# Total number of pixels from all 3 images
total_pixels = 22500 + 37636 + 22500

# Read all bytes
arr = []
for i in range(total_pixels):
    ot = ComPort.read(size=1)
    arr.append(ot)
    print(i, ":", ot)

print("Completed transmission.")

# Convert bytes to integer values
arr1 = [int.from_bytes(i, byteorder='little') for i in arr]

# Save all pixel values to a file (optional)
with open("obtained_image.txt", 'w') as f:
    for idx, pixel in enumerate(arr1):
        f.write(f"{int(pixel)}\n")

# Extract individual images
img1 = np.array(arr1[0:22500]).reshape((150, 150))
img2 = np.array(arr1[22500:22500+37636]).reshape((194, 194))
img3 = np.array(arr1[22500+37636:]).reshape((150, 150))

# Display all three images
plt.figure(figsize=(12, 4))

plt.subplot(1, 3, 1)
plt.title("Image 1 (150x150)")
plt.imshow(img1, cmap='gray')
plt.axis('off')

plt.subplot(1, 3, 2)
plt.title("Image 2 (194x194)")
plt.imshow(img2, cmap='gray')
plt.axis('off')

plt.subplot(1, 3, 3)
plt.title("Image 3 (150x150)")
plt.imshow(img3, cmap='gray')
plt.axis('off')

plt.tight_layout()
plt.show()
