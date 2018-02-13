# Kinect_calibration_toolbox


<section>

## Code

This toolbox contains some useful Matlab code for Kinect (ASUS Xtion) RGB and depth camera calibration.

This is a modified Matlab code from Herrera's _TPAMI_ paper ["Joint depth and color camera calibration with distortion correction"](http://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=6205765).

</section>


<section>

## Usage

Run [main_script.m](toolbox/main_script.m) to start, main code is quite easy to understand as long as you follow the command prompts.

Basically, it calibrates using your pre-obtained data (offline).

</section>


<section>

## Kinect v1 for Xbox 360 Model 1473

*   Environments: Windows 7 (64-bit) + Matlab R2013a (64-bit) + Kinect for Windows SDK v1.6

Note that Matlab, SDK 1.6 can be downloaded [here](https://www.mathworks.com/downloads/) and [here](https://www.microsoft.com/en-us/download/details.aspx?id=34808).


## Kinect v1 for Windows

*   Environments: ???

</section>


<section>

## Reference

This work originates from the University of Oulu, by:
Herrera C., D., Kannala J., Heikkila, J., "Joint depth and color camera calibration with distortion correction", _TPAMI_, 2012.
Please see link of the original code: [https://sourceforge.net/projects/kinectcalib/](https://sourceforge.net/projects/kinectcalib/), as well as corresponding [document](doc/doc_2_1.pdf).

```
@article{herrera2012joint,
  title={Joint depth and color camera calibration with distortion correction},
  author={Herrera, Daniel and Kannala, Juho and Heikkil{\"a}, Janne},
  journal={IEEE Transactions on Pattern Analysis and Machine Intelligence},
  volume={34},
  number={10},
  pages={2058--2064},
  year={2012},
  publisher={IEEE}
}
```

</section>