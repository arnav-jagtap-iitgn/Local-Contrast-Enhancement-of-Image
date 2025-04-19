# 🖼️ Local Image Contrast Enhancement using SWAHE on FPGA

Welcome to the official repository for the **Local Image Contrast Enhancement** project using FPGA and the **SWAHE** (Sliding Window Adaptive Histogram Equalization) algorithm. This project was developed as part of the Electrical Engineering coursework under the guidance of **Prof. Joycee Meckie** at IIT Gandhinagar.

---

## 🚀 Project Overview

### 🎯 Vision & Motivation
Global contrast enhancement techniques often struggle to enhance details in low-light or unevenly lit regions of an image. This project aims to overcome this limitation by implementing a **local** contrast enhancement method—**SWAHE**—on hardware for **real-time image processing**.

---

## 📌 What is SWAHE?

**SWAHE** (Sliding Window Adaptive Histogram Equalization) enhances contrast by:
- Applying histogram equalization locally using a sliding window (e.g., 45×45).
- Adjusting each pixel's intensity based on its neighborhood.
- Preserving global brightness while improving local visibility.

### ✅ Benefits:
- Adapts to local intensity variations
- Enhances details without over-saturation
- Ideal for images with shadows and non-uniform lighting

---

## ⚙️ FPGA Implementation

The algorithm is designed and implemented using **Verilog HDL** on an FPGA platform. The system is modular and includes:

### 📦 Modules:
- **Padding Module**: Adds border pixels to preserve corners (150×150 ➝ 194×194).
- **Window Module**: Extracts 45×45 local regions for processing.
- **Histogram Module**: Computes intensity histogram of each window.
- **CDF Module**: Calculates cumulative distribution and maps new pixel values.
- **Top Module**: Integrates all components and manages control flow.
- **Controller Module**: Handles synchronization and sequencing of operations.

### 🧠 Features:
- Fully pipelined design for gray image throughput.
- Efficient memory management using BRAM.
- UART-based image output transmission.

---

## 📈 Results

- Significant enhancement of contrast in low-light regions
- Real-time performance verified through simulation and FPGA testing
- Output quality validated against MATLAB reference implementation

<p align="center">
  <img src="[https://github.com/arnav-jagtap-iitgn/Local-Contrast-Enhancement-of-Image/enhanced_image.png](https://github.com/arnav-jagtap-iitgn/Local-Contrast-Enhancement-of-Image/blob/main/enhanced_image.png)" width="60%">
  <br><i>Before and after local contrast enhancement</i>
</p>

---

## 📁 Project Structure

📂 Verilog/ │ ├── top_module.v │ └── controller_module.v │ ├── padding_module.v │ ├── window_module.v │ ├── histogram_module.v │ ├── cdf_module.v  📄 Project presentation.pptx 📄 README.md

---

## 🛠️ Tools & Technology

- 🖥️ **Language**: Verilog HDL
- 🔧 **Platform**: Xilinx Vivado
- 🧮 **Simulation**: Vivado Simulator
- 📤 **Transmission**: UART
- 📊 **Reference**: Python for validation

---

## 📜 How to Use

1. Clone the repo:
   ```bash
   git clone https://github.com/arnav-jagtap-iitgn/Local-Contrast-Enhancement-of-Image.git

## References
- Images are taken from the kaggle data set
