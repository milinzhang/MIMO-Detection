# MIMO-Detection
This is a term project for ELE851 - Detection & Estimation Theory - Spring 2021.
## Introduction
Multi-Input-Multi-Output (MIMO) technology, which can significantly improve the capacity and reliability of wireless systems, has been widely studied and applied to many wireless standards. Comparing with the Single-Input-Single-Output (SISO) systems, MIMO systems are supposed to detect multiple signals jointly. Due to the curse of dimension, the traditional ML criterion or MAP criterion suffers a higher computational complexity when the number of antennas increases. 

In order to solve the problem, many different detection methods are proposed, which can be classified into different families: Linear Detectors, Tree Search Based Detectors, Lattice Reduction Aided Detectors, etc. The most conventional and commonly used detectors are the linear detectors: Zero-Forcing (ZF) detector and Minimum Mean Square Error (MMSE) detector.

In this project, study will firstly base on the ZF and MMSE methods in small-scare MIMO. Depending on the progress of the study, other methods like Tree Search Based detector may be discussed, or it might be extended to the massive MIMO in the future.
## small-scale MIMO detection
- Implemented 2 most commonly used linear detectors in small-scale MIMO systems: Zero-Forcing (ZF) detector and Minimum-Mean-Square-Error (MMSE) detector.
- Since the Maximum Likehood (ML) detector corresponds to optimal performance, ML detector was also implemented as a reference.
- Due to the computational complexity of ML criterion in high dimension, the simulation was based on a 2 × 2 MIMO,  2-psk modulation and frequency flat channel model.
- According to the result, MMSE performs better than ZF. Thus, MMSE was used in the next simulation.
- simulation result:

![image text](https://github.com/milinzhang/MIMO-Detection/blob/main/small-scale%20MIMO%20detection/MIMOdetection_result.jpg)  

## large-scale MIMO detection
- Implemented MMSE detectors in 64x8,64x16,128x8,128x16 MIMO systems, using 64-qam modulation and frequency flat channel model.
- Due to the increasing dimension of matrices, linear detectors suffer high computational complexity. Thus, different methods are used to reduce the complexity: 
    1. Neumann Series (with its order n = 3)
    2. Newton Iteration (iteration number n=3)
    3. Gauss-Seidel (n=3)
    4. Jacobi Method (n=4)
    5. Conjugate Gradient(n=3)
    6. to be updated
- According to simulations, when the ratio of N (the number of receive antennas) and k (the number of user equipments) increased, the approximations converge faster.
- simulation result:

|| 64 receiver antennas | 128 reveiver antennas |
|:----:| :----: | :----: |
| 8 users | ![image text](https://github.com/milinzhang/MIMO-Detection/blob/main/large_scale%20MIMO%20detection/64x8.jpg)  | ![image text](https://github.com/milinzhang/MIMO-Detection/blob/main/large_scale%20MIMO%20detection/128x8.jpg)  |
|16 users | ![image text](https://github.com/milinzhang/MIMO-Detection/blob/main/large_scale%20MIMO%20detection/64x16.jpg) | ![image text](https://github.com/milinzhang/MIMO-Detection/blob/main/large_scale%20MIMO%20detection/128x16.jpg) |

