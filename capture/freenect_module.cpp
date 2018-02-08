//////////////////////////////////////////////////////////////////
// Kinect capture
// by Daniel Herrera C.
//////////////////////////////////////////////////////////////////
#include "freenect_module.h"
#include <stdlib.h>

namespace kinect_capture {

//////////////////////////////////////////////////////////////////
// Cfreenect_module members
//////////////////////////////////////////////////////////////////
Cfreenect_module::Cfreenect_module():
    die(false),
    mutex(PTHREAD_MUTEX_INITIALIZER),
    depth_frame(new cv::Mat1s()),
    video_frame(new cv::Mat()),
    got_depth(0), 
    got_video(0),
    f_ctx(NULL),
    f_dev(NULL),
    depth_back(new cv::Mat1s()),
    video_back(new cv::Mat())
{
    pthread_cond_init(&data_ready_cond, NULL);

    set_mode(
		freenect_find_video_mode(FREENECT_RESOLUTION_MEDIUM, FREENECT_VIDEO_YUV_RGB),
		//freenect_find_video_mode(FREENECT_RESOLUTION_HIGH, FREENECT_VIDEO_BAYER),
        freenect_find_depth_mode(FREENECT_RESOLUTION_MEDIUM, FREENECT_DEPTH_11BIT));
}

Cfreenect_module::~Cfreenect_module()
{
    pthread_cond_destroy(&data_ready_cond);
    delete video_frame;
    delete depth_frame;
    delete depth_back;
    delete video_back;
}

int Cfreenect_module::video_format2mat_type(freenect_video_format format) {
    switch(format){
    case FREENECT_VIDEO_RGB:
    case FREENECT_VIDEO_YUV_RGB:
        return CV_8UC3;
    case FREENECT_VIDEO_BAYER:
    case FREENECT_VIDEO_IR_8BIT:
        return CV_8UC1;
    }
}

void Cfreenect_module::set_mode(freenect_frame_mode video, freenect_frame_mode depth) {
    video_mode = video;
    depth_mode = depth;
        
    depth_frame->create(depth.height, depth.width);
    video_frame->create(video.height, video.width, Cfreenect_module::video_format2mat_type(video.video_format));
    depth_back->create(depth_mode.height, depth_mode.width);
    video_back->create(video_mode.height, video_mode.width, Cfreenect_module::video_format2mat_type(video_mode.video_format));
}

void Cfreenect_module::static_depth_callback(freenect_device *dev, void *depth, uint32_t timestamp) {
    Cfreenect_module *module = (Cfreenect_module*)freenect_get_user(dev);
    module->depth_callback(dev,depth,timestamp);
}
void Cfreenect_module::static_video_callback(freenect_device *dev, void *video, uint32_t timestamp) {
    Cfreenect_module *module = (Cfreenect_module*)freenect_get_user(dev);
    module->video_callback(dev,video,timestamp);
}

void Cfreenect_module::depth_callback(freenect_device *dev, void *depth, uint32_t timestamp) {
    assert(depth == depth_back->data);
    pthread_mutex_lock(&mutex);

    std::swap(depth_back, depth_frame); //Swap buffers

    freenect_set_depth_buffer(dev, depth_back->data);
    got_depth++;
    
    pthread_mutex_unlock(&mutex);
    pthread_cond_signal(&data_ready_cond);
}

void Cfreenect_module::video_callback(freenect_device *dev, void *video, uint32_t timestamp) {
    assert(video == video_back->data);    
    pthread_mutex_lock(&mutex);

    std::swap(video_back, video_frame); //Swap buffers

    freenect_set_video_buffer(dev, video_back->data);
    got_video++;

    pthread_mutex_unlock(&mutex);
    pthread_cond_signal(&data_ready_cond);
}

void Cfreenect_module::start_thread() {
    int res;
    res = pthread_create(&thread, NULL, thread_entry, this);
    if (res) 
        cerr << "Error creating freenect thread.\n";
}

void *Cfreenect_module::thread_entry(void *instance) {
    Cfreenect_module *p = (Cfreenect_module*)instance;
    p->run();
    return NULL;
}

void Cfreenect_module::init() {
    //Init freenect
    if (freenect_init(&f_ctx, NULL) < 0) {
        std::cerr << "freenect_init() failed\n";
        die = 1;
        return;
    }
    freenect_set_log_level(f_ctx, FREENECT_LOG_WARNING);

    int nr_devices = freenect_num_devices(f_ctx);
    std::cout << "Number of devices found: " << nr_devices << std::endl;

    if (nr_devices < 1) {
        die = true;
        return;
    }

    if (freenect_open_device(f_ctx, &f_dev, 0) < 0) {
        std::cerr << "Could not open device\n";
        die = true;
        return;
    }

    f_reg = freenect_copy_registration(f_dev);

    freenect_set_user(f_dev, this);
    freenect_set_led(f_dev,LED_GREEN);
    freenect_set_depth_callback(f_dev, static_depth_callback);
    freenect_set_depth_mode(f_dev, depth_mode);
    freenect_set_depth_buffer(f_dev, depth_back->data);
    freenect_set_video_callback(f_dev, static_video_callback);
    freenect_set_video_mode(f_dev, video_mode);
    freenect_set_video_buffer(f_dev, video_back->data);
}

void Cfreenect_module::run() {
    freenect_start_depth(f_dev);
    freenect_start_video(f_dev);
    
    std::cout << "Kinect streams started\n";

    while (!die && freenect_process_events(f_ctx) >= 0) {
        //Let freenect process events
    }

    std::cout << "Shutting down Kinect...";

    freenect_stop_depth(f_dev);
    freenect_stop_video(f_dev);

    freenect_close_device(f_dev);
    freenect_shutdown(f_ctx);

    std::cout << "done!\n";
    return;
}

}