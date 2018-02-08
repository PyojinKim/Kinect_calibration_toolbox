function varargout = kinect_calib_gui(varargin)
% KINECT_CALIB_GUI M-file for kinect_calib_gui.fig
%      KINECT_CALIB_GUI, by itself, creates a new KINECT_CALIB_GUI or raises the existing
%      singleton*.
%
%      H = KINECT_CALIB_GUI returns the handle to a new KINECT_CALIB_GUI or the handle to
%      the existing singleton*.
%
%      KINECT_CALIB_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KINECT_CALIB_GUI.M with the given input arguments.
%
%      KINECT_CALIB_GUI('Property','Value',...) creates a new KINECT_CALIB_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before kinect_calib_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to kinect_calib_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help kinect_calib_gui

% Last Modified by GUIDE v2.5 08-Feb-2012 15:55:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @kinect_calib_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @kinect_calib_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before kinect_calib_gui is made visible.
function kinect_calib_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to kinect_calib_gui (see VARARGIN)

% Choose default command line output for kinect_calib_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes kinect_calib_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = kinect_calib_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in select_images_button.
function select_images_button_Callback(hObject, eventdata, handles)
% hObject    handle to select_images_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  do_select_images();

% --- Executes on button press in select_rgb_corners_button.
function select_rgb_corners_button_Callback(hObject, eventdata, handles)
% hObject    handle to select_rgb_corners_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  do_select_rgb_corners();
  
% --- Executes on button press in select_planes_button.
function select_planes_button_Callback(hObject, eventdata, handles)
% hObject    handle to select_planes_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  do_select_planes();
  
% --- Executes on button press in fixed_depth_calib_button.
function fixed_depth_calib_button_Callback(hObject, eventdata, handles)
% hObject    handle to fixed_depth_calib_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  do_initial_depth_calib(true);
  global calib0
  print_calib_depth(calib0);
      
% --- Executes on button press in initial_rgb_calib_button.
function initial_rgb_calib_button_Callback(hObject, eventdata, handles)
% hObject    handle to initial_rgb_calib_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  do_initial_rgb_calib();
  
% --- Executes on button press in calibrate_button.
function calibrate_button_Callback(hObject, eventdata, handles)
% hObject    handle to calibrate_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%   use_distorsion = get(hObject,'Value') returns toggle state of depth_distorsion_check
  use_depth_distorsion = get(handles.depth_distorsion_check,'Value');
  do_calib(use_depth_distorsion);

% --- Executes on button press in save_button.
function save_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  do_save_calib();

% --- Executes on button press in load_button.
function load_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  do_load_calib();

% --- Executes on button press in useful_fcn_button.
function useful_fcn_button_Callback(hObject, eventdata, handles)
% hObject    handle to useful_fcn_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  do_useful_fcn();


% --- Executes on button press in rgb_depthmap_button.
function rgb_depthmap_button_Callback(hObject, eventdata, handles)
% hObject    handle to rgb_depthmap_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  do_rgb_depthmap();


% --- Executes on button press in plot_rgb_corners_butten.
function plot_rgb_corners_butten_Callback(hObject, eventdata, handles)
% hObject    handle to plot_rgb_corners_butten (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  do_plot_rgb_corners();


% --- Executes on button press in plot_planes_button.
function plot_planes_button_Callback(hObject, eventdata, handles)
% hObject    handle to plot_planes_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  do_plot_depth_plane();


% --- Executes on button press in depth_distorsion_check.
function depth_distorsion_check_Callback(hObject, eventdata, handles)
% hObject    handle to depth_distorsion_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of depth_distorsion_check
