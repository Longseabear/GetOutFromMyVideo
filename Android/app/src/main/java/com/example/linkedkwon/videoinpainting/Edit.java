package com.example.linkedkwon.videoinpainting;

import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.media.MediaMetadataRetriever;
import android.net.Uri;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.text.Editable;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class Edit extends AppCompatActivity {

    private final int SELECT_VIDEO=1;
    private String path="";
    private TransmitThread t;
    private Thread thread;

    //using of view
    private ImageView imageView;
    private Bitmap bitmap;
    private Bitmap canvasBitmap;
    private String pixelSet="";
    private Button submitBtn;

    private EditText tittleView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_edit);

        init();
        openGallery();
        humanSegmentationOnBitmap();
    }

    private void init(){
        imageView=findViewById(R.id.frameImgView);
        submitBtn=findViewById(R.id.edit_submit_btn);
        tittleView=findViewById(R.id.edt_title);

        submitBtn.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                t=new TransmitThread(path,pixelSet);
                thread=new Thread(t);
                thread.start();
                writeFile();
                finish();
            }
        });
    }

    private void openGallery(){
        Intent i=new Intent(Intent.ACTION_GET_CONTENT);
        i.setType("video/*");
        i.addFlags(i.FLAG_ACTIVITY_CLEAR_TOP);

        try{
            startActivityForResult(i,SELECT_VIDEO);
        }catch(android.content.ActivityNotFoundException e){e.printStackTrace();}
    }

    @Override
    public void onActivityResult(int requestCode,int resultCode,Intent intent){
        super.onActivityResult(requestCode,resultCode,intent);

        if(resultCode==RESULT_OK&&requestCode==SELECT_VIDEO){
            path+= Environment.getExternalStorageDirectory().getAbsolutePath();
            Uri uri=intent.getData();
            path+="/DCIM/Camera/"+getName(uri);
            setFrameOnImageView();
        }
    }

    private String getName(Uri uri){
        String[] projection={ MediaStore.Images.ImageColumns.DISPLAY_NAME};
        Cursor cursor = managedQuery(uri, projection, null, null, null);
        int column_index = cursor
                .getColumnIndexOrThrow(MediaStore.Images.ImageColumns.DISPLAY_NAME);
        cursor.moveToFirst();
        return cursor.getString(column_index);
    }

    private void setFrameOnImageView(){
        MediaMetadataRetriever mediaMetadataRetriever = new MediaMetadataRetriever();
        mediaMetadataRetriever.setDataSource( path );
        bitmap = mediaMetadataRetriever.getFrameAtTime(0);
        canvasBitmap=mediaMetadataRetriever.getFrameAtTime(0);
        imageView.setImageBitmap(bitmap);
    }

    private void humanSegmentationOnBitmap(){
        imageView.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent event) {

                Matrix matrix=new Matrix();

                int x=(int)event.getX();
                int y=(int)event.getY();
                pixelSet+=Integer.toString(x)+"/"+Integer.toString(y)+",";

                Canvas c=new Canvas(canvasBitmap);
                Paint p=new Paint();
                p.setColor(Color.RED);
                p.setStrokeWidth(10f);
                c.drawCircle(x,y,10,p);
                imageView.setImageBitmap(canvasBitmap);
                return false;
            }
        });
    }

    private void writeFile(){
        SimpleDateFormat mSimpleDateFormat = new SimpleDateFormat( "yyyy.MM.dd HH:mm:ss", Locale.KOREA );
        Date currentTime = new Date ();
        String mTime = mSimpleDateFormat.format ( currentTime );
        String title=tittleView.getText().toString();

        File saveFile=new File(Environment.getExternalStorageDirectory().getAbsolutePath()+"/history");
        if(!saveFile.exists()){
            saveFile.mkdir();
        }

        try {
            BufferedWriter buf = new BufferedWriter(new FileWriter(saveFile + "/final.txt",true));
            buf.append(path+","+title+","+mTime+"\n");
            buf.close();

        }catch(Exception e){}
    }
}
