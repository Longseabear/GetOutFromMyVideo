package com.example.linkedkwon.videoinpainting;

import android.os.Environment;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.widget.MediaController;
import android.widget.VideoView;

public class Example extends AppCompatActivity {

    private VideoView test1,test2,test3,test4;
    private MediaController mc1,mc2,mc3,mc4;
    private String path;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_example);
        init();
    }

    private void init(){
        mc1=new MediaController(this);
        mc2=new MediaController(this);
        mc3=new MediaController(this);
        mc4=new MediaController(this);

        test1=findViewById(R.id.test1);
        test1.setMediaController(mc1);

        test2=findViewById(R.id.test2);
        test2.setMediaController(mc2);

        test3=findViewById(R.id.test3);
        test3.setMediaController(mc3);

        test4=findViewById(R.id.test4);
        test4.setMediaController(mc4);

        path= Environment.getExternalStorageDirectory().getAbsolutePath();

        test1.setVideoPath(path+"/DCIM/Camera/test1.mp4");
        test2.setVideoPath(path+"/DCIM/Camera/tst.mp4");
        test3.setVideoPath(path+"/DCIM/Camera/test3.mp4");
        test4.setVideoPath(path+"/DCIM/Camera/test4.mp4");
    }
}
