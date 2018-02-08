#include "kinect_capture_app.h"

namespace kinect_capture {

kinect_capture_app kinect_capture_app::instance;

kinect_capture_app::kinect_capture_app():
    depth_frame(new cv::Mat1s()),
    video_frame(new cv::Mat()),
    depth_texture(480,640),
    save_pending(false)
{
}

void kinect_capture_app::run(int argc, char **argv) {
    int user_device_number=0;

    cout << "Kinect camera capture software\n";

    glutInit(&argc, argv);

	//Parse command line
	out_dir = "capture";
	int c=1;
	int unnamed_idx=0;
	while (c < argc) {
		if (strcmp(argv[c],"-h")==0)
			usage();
		else {
			switch(unnamed_idx++) {
			case 0:
				out_dir = argv[c];
				break;
			case 1:
				user_device_number = atoi(argv[c]);
				break;
			}
		}
		c++;
	}

	if (out_dir.length() == 0)
		usage();

	cout << "Saving images to: " << out_dir << "\n";
	prepare_for_saving();

    cout << "'space bar'-save images, 't'-save images with 5s delay\n";

	freenect.init();
    save_registration();

	freenect.start_thread();

	//Loading calib
	string calib_file = "C:\\datasets\\kinect\\calib_medium\\best_calib.yml";
	//calib.load("C:\\datasets\\kinect\\calib_fast\\best_calib.yml");
	//calib.load("C:\\datasets\\kinect_toolbox\\calibA1\\best_calib.yml");
	//calib.load("C:\\datasets\\kinect_toolbox\\calib_all\\best_calib.yml");
	if(boost::filesystem::exists(calib_file)) {
		cout << "Loading calibration file from: " << calib_file << "\n";
		calib.load(calib_file);
	} else
		cout << "Calibration file not found: " << calib_file << "\n";

    //Init buffers
    depth_frame->create(freenect.depth_frame->rows, freenect.depth_frame->cols);
    video_frame->create(freenect.video_frame->rows, freenect.video_frame->cols, freenect.video_frame->type());

    //Init GLUI
    init_glut(1280, 480);
	init_glui();
	glutMainLoop();
}

void kinect_capture_app::swap_endiannes(uint16_t *out,const uint16_t *in, int size) {
	for(int i=0; i<size; i++) {
        uint16_t value=in[i];
		out[i] = ((value & 0x00ff) << 8) | (value >> 8);
    }
}

void kinect_capture_app::prepare_for_saving() {
	create_directory(out_dir);

	image_idx = 0;
	for(directory_iterator it(out_dir); it != directory_iterator(); it++) {
		string name = it->path().filename().string();
		if(name.compare(4,2,"-c1")==0)
		{
			int idx = boost::lexical_cast<int>(name.substr(0,4).c_str())+1;
			if(idx > image_idx)
				image_idx = idx;
		}
	}
	cout << "Initial index for save images is " << image_idx << ".\n";
}

void kinect_capture_app::save_images() {
	unique_ptr<uint16_t[]> buffer(new uint16_t[640*480]);
	std::ostringstream s;
	string filename;

	s.fill('0');
	s << std::right << std::setw(4) << image_idx++;

    ///////////////
    // Color camera
	if(video_frame->channels() == 3) {
		//Rgb
		filename = s.str() + "-c1.ppm";
		cv::Mat3b im_rgb;
		cv::cvtColor(*video_frame,im_rgb,CV_BGR2RGB);
		cv::imwrite(out_dir + "/" + filename,im_rgb);
	}
	else {
		//Luminance
		filename = s.str() + "-c1.pgm";
		cv::imwrite(out_dir + "/" + filename,*video_frame);
	}

    ///////////////
	//Disparity
	filename = s.str() + "-d.pgm";
    {
	    ofstream f(out_dir + "/" + filename, ios_base::binary);
	    f << "P5 " << 640 << " " << 480 << " 2048\n"; //Header

        swap_endiannes((uint16_t*)buffer.get(),(uint16_t*)depth_frame->data,640*480); //Writing the buffer directly has endianness issues
	    f.write((char *)buffer.get(), 640*480*2);
    }

	cout << "Saved image:" << s.str() << std::endl;
}

void kinect_capture_app::save_registration() {
    string filename = out_dir + "/registration.yml";
    freenect_registration &f_reg = freenect.f_reg;

    cv::FileStorage fs(filename,cv::FileStorage::WRITE);
    cv::Mat_<uint16_t> raw_to_mm(1,2048,f_reg.raw_to_mm_shift,2048*sizeof(uint16_t));
    fs << "const_shift" << f_reg.const_shift;
    fs << "reference_pixel_size" << f_reg.zero_plane_info.reference_pixel_size;
    fs << "reference_distance" << f_reg.zero_plane_info.reference_distance;
    fs << "dcmos_rcmos_dist" << f_reg.zero_plane_info.dcmos_rcmos_dist;
    fs << "dcmos_emitter_dist" << f_reg.zero_plane_info.dcmos_emitter_dist;
    fs << "raw_to_mm_shift" << raw_to_mm;

    cout << "Kinect registration data saved to: " << filename << "\n";
}

void kinect_capture_app::disparity2depth(cv::Mat_<uint16_t> &depth, const cv::Mat_<uint16_t> &disp) {
    for(int v=0; v<disp.rows; v++)
        for(int u=0; u<disp.cols; u++) {
            const uint16_t &value = disp(v,u);
            uint16_t &dest = depth(v,u);

            dest = freenect.f_reg.raw_to_mm_shift[value];
            /*
            if(value == 2047)
                dest = 0;
            else
                dest = 1.0f / (  -0.0028505f     *  (value-1093.6f));
                */
        }
}

void kinect_capture_app::do_glutIdle()
{
	if(save_pending) {
		ptime now = second_clock::local_time();
        if(now > save_time)	{
			save_pending = false;
			save_images();
		}
	}

	if(freenect.got_depth == 0 && freenect.got_video == 0)
		return;

	bool is_depth_new=false, is_video_new=false;

	pthread_mutex_lock(&freenect.mutex);

	if(freenect.got_depth)
	{
        std::swap(depth_frame, freenect.depth_frame);
		freenect.got_depth = 0;
		is_depth_new = true;
	}

	if(freenect.got_video)
	{
		//Switch buffers
        std::swap(video_frame, freenect.video_frame);
		freenect.got_video = 0;
		is_video_new = true;
	}

	pthread_mutex_unlock(&freenect.mutex);

	if(is_depth_new)
	{
        uint16_t center_value;

		//Overlay
		if(overlay) {
			cv::Mat1f depth;
			cv::Mat1b mask;
			calib.compute_rgb_depthmap(*depth_frame, depth);
			mask = depth > 0 ;
			cv::Scalar mean,std;
			cv::meanStdDev(depth,mean,std,mask);

			depth.convertTo(overlay_texture,overlay_texture.type(),255.0/(6*std[0]),-255.0/(6*std[0])*(mean[0]-3*std[0]));
		}

		//Make depth texture
        if(show_z) {
            show_mat_min = 300;
            show_mat_max = 4000;

            show_mat.create(depth_frame->rows, depth_frame->cols);
            disparity2depth(show_mat, *depth_frame);
        } else {
            show_mat = *depth_frame;
            show_mat_min = 0;
            show_mat_max = 2046;
        }
            
		if(auto_track_display_center) {
			cv::Mat_<uint16_t> center_mat(show_mat, cv::Rect(640/2-10,480/2-10,20,20));
            center_value = cv::mean(center_mat)(0);
			center_scroll->set_int_val(rescale_value(center_value, show_mat_min, show_mat_max, 0, 100));
		}
        else
            center_value = rescale_value(depth_display_center, 0,100, show_mat_min, show_mat_max);

        float range_value = rescale_value(depth_display_range, 0,100, show_mat_min, show_mat_max);
        float minval = center_value-range_value;
        float maxval = center_value+range_value;
    	show_mat.convertTo(depth_texture,cv::DataDepth<uchar>::value, 255.0/(maxval-minval), -255*minval/(maxval-minval));
	}

	if(is_video_new) {
		//Nothing to do, just draw
	}

	if(is_video_new || is_depth_new) {
		if ( glutGetWindow() != main_window ) 
		    glutSetWindow(main_window);  
		glutPostRedisplay();
	}
}

void kinect_capture_app::do_glutDisplay() {
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glLoadIdentity();

	glEnable(GL_TEXTURE_2D);

	glBindTexture(GL_TEXTURE_2D, gl_depth_tex);

	//Depth texture	
	glTexImage2D(GL_TEXTURE_2D, 0, 1, depth_texture.cols, depth_texture.rows, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, depth_texture.data);

	glBegin(GL_TRIANGLE_FAN);
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	glTexCoord2f(0, 0); glVertex3f(0,0,0);
	glTexCoord2f(1, 0); glVertex3f(640,0,0);
	glTexCoord2f(1, 1); glVertex3f(640,480,0);
	glTexCoord2f(0, 1); glVertex3f(0,480,0);
	glEnd();

	//RGB texture
	glBindTexture(GL_TEXTURE_2D, gl_rgb_tex);
	GLint bytes;
	GLenum format;
	if(video_frame->channels() == 1) {
		bytes = 1;
		format = GL_LUMINANCE;
	} else {
		bytes = 3;
		format = GL_RGB;
	}
	glTexImage2D(GL_TEXTURE_2D, 0, bytes, video_frame->cols, video_frame->rows, 0, format, GL_UNSIGNED_BYTE, video_frame->data);

	glBegin(GL_TRIANGLE_FAN);
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	glTexCoord2f(0, 0); glVertex3f(640,0,0);
	glTexCoord2f(1, 0); glVertex3f(1280,0,0);
	glTexCoord2f(1, 1); glVertex3f(1280,480,0);
	glTexCoord2f(0, 1); glVertex3f(640,480,0);
	glEnd();

	//Overlay texture
	if(overlay) {
		glTexImage2D(GL_TEXTURE_2D, 0, 1, overlay_texture.cols, overlay_texture.rows, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, overlay_texture.data);

		
		//glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
		glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);

		/*
glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_REPLACE);
glTexEnvi(GL_TEXTURE_ENV, GL_SRC0_RGB, GL_PRIMARY_COLOR);
glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_SRC_COLOR);

glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_ALPHA, GL_REPLACE);
glTexEnvi(GL_TEXTURE_ENV, GL_SRC0_ALPHA, GL_TEXTURE);
glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_ALPHA, GL_SRC_ALPHA);
*/
		
		glBegin(GL_TRIANGLE_FAN); 
		glColor4f(1.0f, 1.0f, 0.0f, 0.5f);
		glTexCoord2f(0, 0); glVertex3f(640,0,0);
		glTexCoord2f(1, 0); glVertex3f(1280,0,0);
		glTexCoord2f(1, 1); glVertex3f(1280,480,0);
		glTexCoord2f(0, 1); glVertex3f(640,480,0);
		glEnd();

		//glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
	}
	glutSwapBuffers();
}

void kinect_capture_app::do_glutKeyboard(unsigned char key, int x, int y) {
	switch(key) {
	case 27:
		freenect.die = 1;
		pthread_join(freenect.thread, NULL);
		glutDestroyWindow(main_window);
        
        delete depth_frame;
        delete video_frame;

		pthread_exit(0);
		break;
	
	case ' ':
		save_images();
		break;
	
	case 't':
        save_time = second_clock::local_time() + seconds(5);
		save_pending = true;
		break;
	}	
}

void kinect_capture_app::do_glutMouse(int button, int state, int x, int y) {
    if(x < 640 && y < 480) {
        uint16_t value = show_mat(y,x);
        ostringstream s;
        
        s <<"Click for measurement: " << value << (show_z?"mm":" kinect units");
        mouse_over_text->set_text(s.str().c_str());
    }
}

void kinect_capture_app::do_glutReshape(int width, int height) {
	int tx, ty, tw, th;
	GLUI_Master.get_viewport_area( &tx, &ty, &tw, &th );
	glViewport( tx, ty, tw, th );

	xy_aspect = (float)tw / (float)th;

	glutPostRedisplay();

	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
    glOrtho (0, tw, th, 0, -1.0f, 1.0f);
	glMatrixMode(GL_MODELVIEW);
}

void kinect_capture_app::init_glut(int width, int height) {
	glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_ALPHA | GLUT_DEPTH);
	glutInitWindowSize(1280, 680);
	glutInitWindowPosition(0, 0);

	main_window = glutCreateWindow("LibFreenect");

	glutDisplayFunc(&sdo_glutDisplay);
	/* We register the idle callback with GLUI, *not* with GLUT */
	GLUI_Master.set_glutIdleFunc( sdo_glutIdle );
	GLUI_Master.set_glutReshapeFunc( sdo_glutReshape );  
    GLUI_Master.set_glutMouseFunc( sdo_glutMouse );
	glutKeyboardFunc(&sdo_glutKeyboard);

    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	glClearDepth(1.0);
	glDepthFunc(GL_LESS);
	glDisable(GL_DEPTH_TEST);
	glEnable(GL_BLEND);
	glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glShadeModel(GL_SMOOTH);
	glGenTextures(1, &gl_depth_tex);
	glBindTexture(GL_TEXTURE_2D, gl_depth_tex);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glGenTextures(1, &gl_rgb_tex);
	glBindTexture(GL_TEXTURE_2D, gl_rgb_tex);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    do_glutReshape(width, height);
}

void kinect_capture_app::init_glui() {
  /****************************************/
  /*         Here's the GLUI code         */
  /****************************************/

  //GLUI *glui = GLUI_Master.create_glui( "GLUI", 0, 400, 50 ); /* name, flags,x, and y */
  glui = GLUI_Master.create_glui_subwindow(main_window, GLUI_SUBWINDOW_BOTTOM);
  new GLUI_StaticText( glui, "Kinect acquisition" );
 
  mouse_over_text = new GLUI_StaticText( glui, "Click for measurement: [value]");

  center_scroll = new GLUI_Scrollbar(glui,"Center of display range",GLUI_SCROLL_HORIZONTAL,&depth_display_center);
  center_scroll->set_int_limits(0,100,GLUI_LIMIT_CLAMP);
  center_scroll->set_int_val(50);

  range_scroll = new GLUI_Scrollbar(glui,"Range of display range",GLUI_SCROLL_HORIZONTAL,&depth_display_range);
  range_scroll->set_int_limits(1,100,GLUI_LIMIT_CLAMP);
  range_scroll->set_int_val(50);

  show_z = 1;
  show_z_checkbox = new GLUI_Checkbox(glui,"Show depth in meters",&show_z);

  auto_track_display_center = 1;
  auto_track_center_checkbox = new GLUI_Checkbox(glui,"Auto track center of display range",&auto_track_display_center);

  new GLUI_Button(glui,"Auto contrast",0,&sset_auto_contrast);
 
  overlay = 0;
  new GLUI_Checkbox(glui,"Overlay",&overlay);

  glui->set_main_gfx_window( main_window );
}

void kinect_capture_app::set_auto_contrast(int id) {
	uint16_t min=2048,max=0;

	for(int v=0; v<480; v++)
        for(int u=0; u<640; u++) {
			if(show_mat(v,u) > show_mat_max)
				continue;
			if(min > show_mat(v,u))
				min = show_mat(v,u);
			if(max < show_mat(v,u))
				max = show_mat(v,u);
		}

	center_scroll->set_int_val(rescale_value<uint16_t>((min+max)/2, show_mat_min,show_mat_max,0,100));
	range_scroll->set_int_val(rescale_value<uint16_t>((max-depth_display_center), show_mat_min,show_mat_max/2,0,100));
}

void kinect_capture_app::usage() {
	cout << "Views Kinect output and allows single frames to be recorded.\nOutput is in the same format as Fakenect.\nUsage:\n";
	cout << "  glview [-h] [target basename] [device #]\n";
	cout << "    <target basename> is the directory where files are stored (default=capture).\n";
	exit(0);
}


}