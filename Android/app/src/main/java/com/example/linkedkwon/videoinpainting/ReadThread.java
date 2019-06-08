package com.example.linkedkwon.videoinpainting;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Environment;
import android.util.Log;

import java.io.BufferedOutputStream;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;

public class ReadThread implements Runnable {

    private static final int port =7777;
    private static final String server_ip = "172.20.10.2";
    private Socket socket;
    public String path;
    private String name="";
    private Context c;
    private Context CC=null;
    private Thread tht;
    
    public ReadThread(String name,Context c){
        this.name=name;
        this.c=c;
    }
    
    public ReadThread(String name){
        
    }
    
    public ReadThread(){
        
    }
    @Override
    public void run() {
        try {
            socket = new Socket(server_ip, port);
            OutputStream output = socket.getOutputStream();
            output.write(100);
            output.close();
            socket.close();

            socket=new Socket(server_ip,port);
            path= Environment.getExternalStorageDirectory().getAbsolutePath()+"/DCIM/Camera/"+name+".mp4";

            File f=new File(path);
            FileOutputStream fos=new FileOutputStream(f);

            InputStream is=socket.getInputStream();
            BufferedOutputStream baos=new BufferedOutputStream(fos);

            byte[] content=new byte[1024];
            int bytesRead=-1;
            int cnt=0;
            while((bytesRead=is.read(content))!=-1){
                Log.e("vnn",Integer.toString(cnt));
                cnt++;
                baos.write(content,0,bytesRead);
            }
            galleryAddPic(c,Environment.getExternalStorageDirectory().getAbsolutePath()+"/DCIM/Camera");
            fos.close();
            baos.close();
            is.close();
            socket.close();

        } catch (IOException e) {}
    }
    private void galleryAddPic(Context c,String currentPhotoPath) {
        Intent mediaScanIntent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
        File f = new File(currentPhotoPath); //새로고침할 사진경로
        Uri contentUri = Uri.fromFile(f);
        mediaScanIntent.setData(contentUri);
        c.sendBroadcast(mediaScanIntent);
    }
}

