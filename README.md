# Real-Time Heartbeat Monitoring Using an ECG Sensor
## Overview
This project focuses on the development of a system for real-time monitoring of heartbeats using an Electrocardiogram (ECG) sensor. It processes and displays various metrics derived from ECG signals, providing a graphical interface for visualization ([Download and Watch Video of the ECG APP](ECG_App.mp4)).

## Key Features
### System Capabilities
1. _Metrics Computed:_
- Heartbeats per minute (BPM)
- Average heartbeat
- ECG characteristic waves and complexes (P, T waves, QRS complex)
- Heart rate variability (HRV)
- Basic diagnostics (non-medically validated)

2. _Real-Time Visualization:_
- ECG signal (raw and pre-processed)
- Identification of key ECG features
- Overlay of cardiac segments for comparison

### System Components
1. _Hardware:_
- Arduino MKR1000 microcontroller
- AD8232 ECG Heart Rate Monitor
- H124SG electrodes and connection cables

2. _Software:_
- Arduino IDE for data collection
- MATLAB for data processing and GUI development
- Wireless communication setup for data transfer

## How It Works
1. Data Collection:
The circuit captures ECG signals using the AD8232 module and electrodes.

2. Data Processing:
Pre-processing includes baseline removal and low-pass filtering.
MATLAB algorithms identify ECG features and calculate metrics.

3. Visualization:
The GUI displays the processed ECG signal and computed metrics in real-time.

## Usage Instructions
Assemble the proposed circuit using the components listed.
Upload the Arduino code through the Arduino IDE.
Run the MATLAB scripts to process and display the data.
Use the GUI to interact with and analyze the ECG metrics.

## Challenges and Solutions
### Challenges:
- Limited knowledge of electronics hindered circuit design.
- Difficulty in developing algorithms for ECG comparison with normalized conditions.
- Establishing stable Wi-Fi communication between Arduino and the PC.
- Slow real-time graphical representation due to processing overhead.

### Solutions:
- Research similar circuit designs to overcome hardware issues.
- Develop thresholds for distinguishing pathological and normal ECG conditions.
- Optimize communication protocols and sampling frequencies for smoother data transfer and visualization.

## Conclusions
The project successfully delivered a working prototype with real-time monitoring capabilities.
It provides a solid foundation for further research and development in ECG signal analysis.
