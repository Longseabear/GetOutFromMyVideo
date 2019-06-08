package com.example.linkedkwon.videoinpainting;

import java.io.BufferedInputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.net.Socket;

public class TransmitThread implements Runnable {

    private static final int port = 7777;
    private static final String server_ip = "172.20.10.2";
    private String path;
    private String pixelSet;
    private Socket socket;

    public TransmitThread(String path, String pixelSet) {
        this.pixelSet = pixelSet;
        this.path = path;
    }

    @Override
    public void run() {

        byte[] byteArr = new byte[1024 * 16];

        try {
            socket = new Socket(server_ip, port);
            FileInputStream fis = new FileInputStream(path);
            OutputStream output = socket.getOutputStream();
            BufferedInputStream bis = new BufferedInputStream(fis);

            String tmp="flagForTransmitVideo";
            byte[] byteArrs=tmp.getBytes();
            output.write(byteArrs);

            //transmit video
            int readLength = -1;
            while ((readLength = bis.read(byteArr)) > 0)
                output.write(byteArr, 0, readLength);

            socket.close();
            fis.close();
            output.close();
            bis.close();

            socket = new Socket(server_ip, port);
            OutputStream output2 = socket.getOutputStream();

            byte[] byteArr2 = pixelSet.getBytes();
            output2.write(byteArr2, 0, byteArr2.length-1 );

            output2.close();
            socket.close();

        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}