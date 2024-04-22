# Abstract

Our main objective was to create a home automation system within the scope and time duration of the EECS 3216 course. We used two DE-10 Lite FPGA boards, a set of sensors and two VGA displays. Our system consists of 6 core functionalities essential for enhancing home security and user convenience, our home automation system consists of ambient light sensing, temperature and humidity sensing, motion sensing and tampering security, sound monitoring, camera surveillance, and emergency/intruder alerts. We dedicated one display to the system’s control panel and the other to the camera display for security monitoring. The project is written in System Verilog. we developed a versatile system capable of integrating all these diverse features into a fully automated user-friendly interface. As a result, we have implemented and delivered a practical home automation and security system. In terms of the scope of the project, we took advantage of all the features and components available on DE-10 Lite to implement this project namely using ADC sensors, GSensor for tamper detection, VGA for display, on-board DRAM and GPIO pins for FIFO camera implementation and Arduino pins to connect the two boards. To access more processing power we utilized two DE-10 Lite FPGA boards and connected them to work seamlessly as one processing unit with all the sensors on board and the security system on another board. This enabled our system to handle complex computation and data processing tasks while making sure that optimal performance was achieved and the design could fit and be implemented on the board. As a result, our strategic approach enhanced the system's efficiency and we were able to deliver a well-scoped, functional project implementation.

# Introduction

The system comprises various features and components usually seen in a smart home, including light automation, Temperature control, home security, and sound data. In addition to these main four subsystems, we have included two more advanced subsystems: camera surveillance and emergency notifications. We used two DE-10 Lite boards, an IR sensor, an analog LM 35 temperature sensor (for board level/internal temp), a digital DHT 11 temperature and relative humidity sensor, analog grove light and sound sensor, and two VGA-compatible monitor. The user can observe all the data regarding the system on the VGA display. Also, the HEX displays and LEDs on the DE-10 Lite are used to show the related information of each subsystem. 

The system architecture uses two DE 10 lite boards, with one serving as the central control unit responsible for sensor data acquisition and processing, while the other focused on motion detection, camera functionality, and tampering detection. Communication between the boards was facilitated through Arduino pins, for the control to show the respective state of the security system. The system leveraged Altera IP library's SDRAM module and SDRAM clock module for efficient data storage and retrieval, while integrating a OV7670 camera module to use the camera which we adapted to use the SDRAM on the board and the RGB 444 standard (4-bit color) on the DE 10 lites VGA output. Adapted SPI and VGA controller files were utilized for camera interface and display functionalities. Additionally, ADC Altera IP was employed for analog sensor data detection and processing. The system also featured UART for transmitting intruder alert notifications to a connected computer system. User interaction was facilitated through a VGA display, presenting sensor data, time, and calendar information. Wireless control and arming/disarming functionality were achieved via smartphone integration using IR sensors. Throughout development, rigorous testing was conducted to optimize sensor data processing and ensure reliable system performance across diverse environments, while prioritizing efficient hardware resource utilization.

# Explanation

Below is a highlight of the functionality and significance of each module within the smart home control panel and security system, illustrating how they contribute to the overall monitoring and security capabilities of the system: 

## SPI Accelerometer (Security System)

In this system, we used an SPI controller [5] and built a system that serves as a tamper detection mechanism. It detects any movement or orientation changes of the board, indicating potential tampering or unauthorized access. By monitoring these changes, the system triggers appropriate security measures and alerts the user by flashing a message on the VGA to notify users of possible intrusion attempts.

## ASCII ROM Text Generation onto VGA Display (Control Panel)

We developed a Text Generation module which generates text and numeric characters on the VGA display using an ASCII ROM [7] which stores an 8x16 bit representation of the characters efficiently on the DE10 Lite Board. It allows the system to present sensor data and system status in a readable format on the screen. By generating characters and numbers at specific coordinates on the display, users can easily interpret the information provided by the system. Then by connecting it to a VGA Module [4] the smart home control panel system provides a visual interface for users to monitor various parameters and receive alerts. It displays real-time data such as light status (using light sensor), room sound level (using sound sensor), internal and external temperatures (using temperature sensors [LM35 and DHT11]), humidity levels (using DHT11 temperature sensor), and motion detection (using motion sensor) and tampering alerts (using on board accelerometer).

## Camera Display (Security System)

We also implemented a Camera Display module incorporating standalone camera functionality, providing motion-triggered recording and storage capabilities. This dedicated camera component enhances the security aspect of the system by facilitating continuous surveillance and real-time monitoring of designated areas within the smart home environment. Through motion detection, the camera autonomously captures relevant footage, enabling users to visually inspect any detected events or intrusions.

## I2C, FIFO, SDRAM Camera Surveillance Module (Security System)

We used an I2C (expanded with SCCB (Serial Camera Control Bus)) module [1] to connect the OV7670 camera and a FIFO module [1] to buffer data coming from the camera and store it onto the board's SDRAM using an adapted SDRAM module [2]. We developed the camera surveillance module which integrates the camera functionality into the system for surveillance purposes. It uses I2C communication to interface with the camera, FIFO buffers for temporary data storage, and SDRAM for storing recorded footage. This module enables motion-triggered recording and efficient storage of camera data, enhancing the security capabilities of the system and allows it to be compatible with the DE-10 Board.

## UART Emergency Notification System (Security System)

We used a UART module [3] for serial communication transmitting data to a connected laptop from the board to send warning messages. We developed the UART Emergency Notification System which handles emergency alerts by sending notifications to external systems upon detecting intruders or security breaches (sending an intruder alert message via a port at a specific baud rate). It utilizes UART communication to transmit alert messages to the designated machine allowing for timely responses to security incidents.

## ADC Sensors (Control Panel)

In this system, we used an Altera generated IP ADC module [8] to capture analog data from sensors such as the Grove sound and light and LM35 temperature sensors. These sensors provide inputs for monitoring room conditions, including sound levels and ambient light intensity. Thorough modeling and simulations were conducted to validate and calibrate the data obtained from the ADC sensors. These simulations aimed to ensure that the digital data accurately represented real-world environmental conditions by mimicking various scenarios such as different sound levels and ambient light intensities. Additionally, controlled testing in different environmental conditions further validated the accuracy and reliability of the sensor data to ensure the data we displayed was accurate.

## DHT11 Temperature and Humidity Module (Control Panel)



The DHT11 Temperature and Humidity is a sensor specifically designed to measure temperature and humidity levels in the surrounding environment. We adapted a DHT 11 module [6] to communicate with the sensor which utilizes a one-wire protocol to communicate with the FPGA and provide temperature and humidity data. In our system, the DHT11 module contributes to environmental monitoring by providing accurate readings of temperature and humidity levels, allowing users to monitor and detect any anomalies that may require attention.

## IR and Motion Sensor (Security System)

In this system, we developed an IR detector system module to arm and disarm our system using a wireless IR signal. We also developed a motion sensor module which serves to detect motion in front of the panel and depending if the system is on it would sound an alarm and if the system is off it turns on a light. This enhances the security of the smart home by detecting unauthorized entry or movement.

# Results

In designing the camera display system, one of the primary challenges was ensuring that the image data could fit within the limited resources of the board. With only 189 M9K memory blocks available, it quickly became apparent that directly storing the entire image data in the FPGA's internal memory was not feasible. To assess the memory requirements, we calculated the total storage needed for a 680x480 image in RGB444 format. Each pixel in RGB444 format requires 12 bits, translating to 1.5 bytes per pixel. Thus, for the entire image: 
Total Pixels = 680 x 480 = 326,400 pixels 
Storage per Pixel = 12 bits = 1.5 bytes 
Total Storage for Image = 326,400 pixels x 1.5 bytes/pixel ≈ 489,600 bytes or approximately 0.47 MB. Converting to megabits (Mb), we get approximately 3.75 Mb. 
Given that each M9K block offers 9 Kb of storage, we determined the number of M9K blocks needed: 
Number of M9K blocks needed = Total Storage Needed / Storage per M9K block 
= 3.75 Mb / (9 Kb / 8 bits) ≈ 850 M9K blocks. 
However, the board only had 189 M9K blocks available, falling significantly short of the required 850 blocks. This shortage necessitated an alternative storage solution. Therefore, the system had to utilize Synchronous Dynamic Random Access Memory (SDRAM) to meet the storage demands. While SDRAM provides higher density and can handle larger datasets, its access times may be comparatively slower than internal memory. Nonetheless, leveraging SDRAM enabled the system to efficiently store and access the image data, albeit with additional considerations for managing memory access and optimizing performance. 
A big challenge and the need for using the SDRAM and FIFO arises from the mismatch in clock frequencies between the camera module and the VGA display. The camera operates at a clock frequency of 24 MHz, while the VGA display operates at 25 MHz. This frequency difference creates timing skew and synchronization challenges when directly interfacing the camera output with the VGA display. To overcome this issue, the SDRAM (operating at a faster clock speed of 100 MHz) acts as a buffer or intermediate storage for the camera data. The Camera Interface Module interfaces with the camera, reads the data at 24 MHz, and writes it into the SDRAM at a faster rate of 100 MHz. This allows for smoother and more efficient data transfer, ensuring that camera data is not lost or corrupted due to timing differences between the camera and VGA clock domains. Similarly, the Asynchronous FIFO Module serves as a buffer between different clock domains, allowing data to be written and read independently at their respective clock frequencies. This FIFO buffer helps in decoupling the camera data acquisition process from the VGA display process, ensuring the data can be transferred seamlessly without being affected by clock skew or timing discrepancies. 
Another significant challenge encountered during the project stemmed from the limitations of the board, specifically in sampling multiple ADC channels simultaneously. Given the constraints, only one ADC channel could be sampled at a time, presenting a hurdle in achieving the desired functionality of sampling multiple analog sensors concurrently. To overcome this limitation, we implemented a multiplexing solution, while using the Altera ADC module. By multiplexing the module with different channel inputs, we were able to route and output data to the correct registers, effectively enabling the simultaneous sampling of multiple ADC channels. However, this approach resulted in a trade-off, as the sampling speed was reduced from 10 MHz to 3.33 MHz. Despite this reduction in sampling speed, thorough testing revealed that the delay introduced was imperceptible, and the system successfully utilized multiple channels simultaneously. This innovative solution allowed us to overcome the board's limitations and achieve the desired functionality of sampling multiple ADC sensors concurrently.

# References

1. Camera Implementation and FIFO in Verilog Tutorial: G, A. (2022, January 29). Security camera \#4: Interfacing with ov7670 camera. element14 Community. [Link](https://community.element14.com/challenges-projects/design-challenges/summer-of-fpga/b/blog/posts/security-camera-3-interfacing-with-ov7670-camera)

2. Using the SDRAM on Altera’s DE2 Board with Verilog Designs (also works on DE-10 Lite): Using the SDRAM on Altera’s DE2 Board with Verilog ... (n.d.). [Link](https://wiki.eecs.yorku.ca/course_archive/2014-15/W/3215/_media/laboratory:using_the_sdram.pdf)

3. UART and FIFO Examples used from FPGA prototyping by Verilog Examples Textbook: Chu, P. P. (2018). FPGA prototyping by System Verilog examples. Wiley Blackwell.

4. UC David EEC180 VGA Controller for VGA display: [Link](https://www.ece.ucdavis.edu/~bbaas/180/tutorials/vga/)

5. UC David EEC180 SPI Controller for Accelerometer: [Link](https://www.ece.ucdavis.edu/~bbaas/180/tutorials/accelerometer.html)

6. Simple DHT 11 Sensor Module Adapted from: [Link](https://github.com/L4rralde/PLD_2020/tree/main/practica6/DHT11)

7. ASCII ROM: [Link](https://github.com/FPGADude/Digital-Design/blob/main/FPGA%20Projects/VGA%20Projects/VGA%20Full%20Screen%20Text%20Editor/ascii_rom.v)

8. MAX 10 – Toolkit ADC Example: [Link](https://faculty-web.msoe.edu/johnsontimoj/EE3921/files3921/max10_adc_toolkit_example.pdf)
