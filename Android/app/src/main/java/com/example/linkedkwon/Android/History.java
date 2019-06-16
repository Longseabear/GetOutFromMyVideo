package com.example.linkedkwon.videoinpainting;

import android.content.Intent;
import android.media.MediaMetadataRetriever;
import android.media.MediaPlayer;
import android.os.Environment;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.MediaController;
import android.widget.VideoView;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;

public class History extends AppCompatActivity {

    private ListView listView;
    private ImageView example_btn;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_history);
        init();
        dataSetting();

    }

    private void init(){
        listView=findViewById(R.id.listView);
        example_btn=findViewById(R.id.example_btn);
        example_btn.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View view){
                Intent i=new Intent(getApplicationContext(),Example.class);
                startActivity(i);
            }
        });
    }

    private void dataSetting(){

        final MyAdapter myAdapter=new MyAdapter();

        File saveFile=new File(Environment.getExternalStorageDirectory().getAbsolutePath()+"/history");
        if(!saveFile.exists()){
            saveFile.mkdir();
        }

        String line;
        try{
            BufferedReader buf=new BufferedReader(new FileReader(saveFile+"/final.txt"));
            while((line=buf.readLine())!=null){
                String tmp[]=line.split(",");
                myAdapter.addItem(ContextCompat.getDrawable(getApplicationContext(), R.drawable.camera_icon), tmp[1], tmp[2],tmp[0]);
            }
            buf.close();
        }catch(Exception e){}


        listView.setAdapter(myAdapter);
    }
}
