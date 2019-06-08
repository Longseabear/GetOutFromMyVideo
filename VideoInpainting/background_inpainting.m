clear all;
straight_propagation('/home/server360/Desktop/video03','/home/server360/Desktop/WOW/inf_inf_JD__ds/masks_machine','temp_frames_result','temp_frames_resultMask',1, false);
straight_propagation('temp_frames_result','temp_frames_resultMask','Output','OutputMask',-1, true);
