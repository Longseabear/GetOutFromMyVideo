package com.example.linkedkwon.videoinpainting;

import android.media.MediaPlayer;
import android.os.Environment;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.MediaController;
import android.widget.VideoView;

public class Solution extends AppCompatActivity {

    private VideoView video1,video2,video3,video22,video33;
    private MediaController mc1,mc2,mc3,mc22,mc33;
    private String path;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_solution);

        init();
    }

    private void init(){
        mc1=new MediaController(this);
        mc2=new MediaController(this);
        mc3=new MediaController(this);
        mc22=new MediaController(this);
        mc33=new MediaController(this);

        video1=findViewById(R.id.seg_video1);
        video1.setMediaController(mc1);

        video2=findViewById(R.id.seg_video2);
        video2.setMediaController(mc2);

        video3=findViewById(R.id.seg_video3);
        video3.setMediaController(mc3);

        video22=findViewById(R.id.seg_video22);
        video22.setMediaController(mc22);

        video33=findViewById(R.id.seg_video33);
        video33.setMediaController(mc33);

        path= Environment.getExternalStorageDirectory().getAbsolutePath();

        video1.setVideoPath(path+"/DCIM/Camera/segmentation.mp4");
       // video1.requestFocus();

        video2.setVideoPath(path+"/DCIM/Camera/optical.mp4");
        //video2.requestFocus();

        video3.setVideoPath(path+"/DCIM/Camera/refine.mp4");
        //video3.requestFocus();

        video22.setVideoPath(path+"/DCIM/Camera/optical2.mp4");
        //video22.requestFocus();

        video33.setVideoPath(path+"/DCIM/Camera/refine2.mp4");
        //video33.requestFocus();

    }


}
