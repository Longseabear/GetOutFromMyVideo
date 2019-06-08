clear all;
straight_propagation('./temp_frames','./temp_frames_mask','temp_frames_result','temp_frames_resultMask',1, false);
straight_propagation('temp_frames_result','temp_frames_resultMask','Output','OutputMask',-1, true);