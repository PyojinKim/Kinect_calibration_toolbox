#include <math.h>
#include <pthread.h>
#include <opencv2/opencv.hpp>

#include <GL/glut.h>
#include <GL/gl.h>
#include <GL/glu.h>
#include <GL/glext.h>

#include "freenect_module.h"

#include <boost/date_time.hpp>
using namespace boost::posix_time; 
#include <boost/lexical_cast.hpp>
#include <boost/filesystem.hpp>
using namespace boost::filesystem;

#define GLUI_NO_LIB_PRAGMA
#include <GL/glui.h>
#if defined(_DEBUG)
#pragma comment(lib, "glui32d.lib")  // Link automatically with GLUI library
#else
#pragma comment(lib, "glui32.lib")  // Link automatically with GLUI library
#endif

#include "kinect_calibration.h"

namespace kinect_capture {

class kinect_capture_app {
public:
    static kinect_capture_app instance;

    void run(int argc, char **argv);
private:
    /////////////////////////////////
    // Freenect
    Cfreenect_module freenect;
    cv::Mat1s *depth_frame;
    cv::Mat *video_frame;
    
    cv::Mat_<uint16_t> show_mat;
    uint16_t show_mat_min;
    uint16_t show_mat_max;

	//CBurrusCalibration calib;
	CHerreraCalibration calib;

    ///////////////////////////
    //Open gl variables
    int main_window;
    float xy_aspect;

	cv::Mat1b overlay_texture;
    cv::Mat1b depth_texture;
    GLuint gl_depth_tex;
    GLuint gl_rgb_tex;

    ///////////////////////////
    // UI state variables
    int auto_track_display_center;
    int show_z;
    int depth_display_center;
    int depth_display_range;
    bool save_pending;
	int overlay;
    ptime save_time;

    ///////////////////////////
    // UI control variables
    GLUI *glui;
    GLUI_Scrollbar *center_scroll;
    GLUI_Scrollbar *range_scroll;
    GLUI_Checkbox *auto_track_center_checkbox;
    GLUI_Checkbox *show_z_checkbox;
    GLUI_StaticText *mouse_over_text;

    ////////////////////////
    // Image saving
    int image_idx;
    std::string out_dir; //output directory where images are stored

    /////////////////////////////////////////////////////////////////////////
    // Member functions
    kinect_capture_app();

    static void swap_endiannes(uint16_t *out,const uint16_t *in, int size);
    void prepare_for_saving();
    void save_images();
    void save_registration();
    void disparity2depth(cv::Mat_<uint16_t> &depth, const cv::Mat_<uint16_t> &disp);

    void do_glutIdle();
    void do_glutDisplay();
    void do_glutKeyboard(unsigned char key, int x, int y);
    void do_glutMouse(int button, int state, int x, int y);
    void do_glutReshape(int width, int height);
    void init_glut(int width, int height);

    static void sdo_glutIdle() {instance.do_glutIdle();}
    static void sdo_glutDisplay() {instance.do_glutDisplay();}
    static void sdo_glutReshape(int Width, int Height) {instance.do_glutReshape(Width, Height);}
    static void sdo_glutKeyboard(unsigned char key, int x, int y) {instance.do_glutKeyboard(key,x,y);}
    static void sdo_glutMouse(int button, int state, int x, int y) {instance.do_glutMouse(button,state,x,y);}

    void init_glui();
    void set_auto_contrast(int id);
    static void sset_auto_contrast(int id) {instance.set_auto_contrast(id);}

    void usage();

    /////////////////////////////////////////////////////////////////////////
    // Helper functions
    template <class Tin, class Tout>
    Tout rescale_value(Tin value, Tin min_in, Tin max_in, Tout min_out, Tout max_out) {
        return static_cast<Tout>( (value-min_in)*(max_out-min_out)/(max_in-min_in) + min_out );
    }
};

}
