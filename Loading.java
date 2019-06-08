package com.example.linkedkwon.videoinpainting;

import android.content.Intent;
import android.os.Handler;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.widget.ImageView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.target.GlideDrawableImageViewTarget;

public class Loading extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_loading);
        setGUI();
        loading();
    }

    private void setGUI(){
        ImageView bgi=findViewById(R.id.loading_gif_img);
        GlideDrawableImageViewTarget gifImg=new GlideDrawableImageViewTarget(bgi);
        Glide.with(this).load(R.drawable.loading_bg).into(gifImg);
    }

    private void loading(){
        Handler handler=new Handler();
        handler.postDelayed(new Runnable(){
            @Override
            public void run(){
                Intent i=new Intent(getBaseContext(),Home.class);
                startActivity(i);
                finish();
            }
        },3000);
    }
}
