//////////////////////////////////////////////////////////////////
// Simple Kinect SLAM demo
// by Daniel Herrera C.
//////////////////////////////////////////////////////////////////
#pragma once

#include <assert.h>
#include <math.h>
#include <iostream>

#include <pthread.h>
#include <libfreenect.h>
#include <libfreenect-registration.h>
#include <opencv2/opencv.hpp>

namespace kinect_capture {
//////////////////////////////////////////////////////////////////
// CFreenectModule: Handles all communication with the Freenect 
//   library. Acquires color and depth images from the Kinect and 
//   offers them to the other modules.
//////////////////////////////////////////////////////////////////
class Cfreenect_module
{
public:
    volatile bool die; //Set to true to make the thread exit.
    pthread_t thread;
    pthread_mutex_t mutex;
    pthread_cond_t data_ready_cond;

    freenect_frame_mode video_mode;
    freenect_frame_mode depth_mode;
    cv::Mat1s *depth_frame; //Newest depth image
    cv::Mat *video_frame;   //Newest color image
    int got_depth, got_video; //Indicate the number of frames obtained (1 if no frames were dropped)

    freenect_registration f_reg;

    Cfreenect_module();
    ~Cfreenect_module();

	void init();
    void start_thread();

private:
    freenect_context *f_ctx;
    freenect_device *f_dev;

    cv::Mat1s *depth_back; //Depth image buffers
    cv::Mat *video_back;   //Color image buffers

    void run();
    static void *thread_entry(void *instance);

    int video_format2mat_type(freenect_video_format format);
    void set_mode(freenect_frame_mode video, freenect_frame_mode depth);
    void depth_callback(freenect_device *dev, void *depth, uint32_t timestamp);
    void video_callback(freenect_device *dev, void *video, uint32_t timestamp);
    static void static_depth_callback(freenect_device *dev, void *depth, uint32_t timestamp);
    static void static_video_callback(freenect_device *dev, void *video, uint32_t timestamp);
};

}