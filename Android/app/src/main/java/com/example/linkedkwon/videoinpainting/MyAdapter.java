package com.example.linkedkwon.videoinpainting;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;
import android.media.MediaMetadataRetriever;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Environment;
import android.text.Layout;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.MediaController;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.VideoView;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.zip.Inflater;

public class MyAdapter extends BaseAdapter{

    private ArrayList<MyItem> mItems = new ArrayList<>();
    private Context c;
    private TextView tv_name;
    private TextView tv_contents;
    public VideoView vv;

    @Override
    public int getCount() {
        return mItems.size();
    }

    @Override
    public MyItem getItem(int position) {
        return mItems.get(position);
    }

    @Override
    public long getItemId(int position) {
        return 0;
    }

    @Override
    public View getView(int position, View convertView, final ViewGroup parent) {

        final Context context = parent.getContext();

        if (convertView == null) {
            LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            convertView = inflater.inflate(R.layout.listview, parent, false);
        }

        ImageView iv_img = (ImageView) convertView.findViewById(R.id.list_imgView) ;
        tv_name = (TextView) convertView.findViewById(R.id.list_title) ;
        tv_contents = (TextView) convertView.findViewById(R.id.list_date) ;
        Button store_btn=convertView.findViewById(R.id.list_store_btn);
        Button delete_btn=convertView.findViewById(R.id.list_delete_btn);
        vv=convertView.findViewById(R.id.list_videoView);

        store_btn.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                ReadThread thread=new ReadThread(tv_name.getText().toString(),context);
                Thread t=new Thread(thread);
                t.start();
            }
        });

        delete_btn.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){

                File saveFile=new File(Environment.getExternalStorageDirectory().getAbsolutePath()+"/history");
                String dummy = "";

                try {
                    BufferedReader buf=new BufferedReader(new FileReader(saveFile+"/final.txt"));
                    String line;
                    while((line=buf.readLine())!=null){
                        if(line.contains(tv_contents.getText()))
                            continue;
                        dummy += (line + "\n" );
                    }
                    FileWriter fw = new FileWriter(saveFile+"/final.txt");
                    fw.write(dummy);
                    fw.close();
                    buf.close();
                } catch (Exception e) {}
            }
        });

        /* 각 리스트에 뿌려줄 아이템을 받아오는데 mMyItem 재활용 */
        MyItem myItem = getItem(position);

        /* 각 위젯에 세팅된 아이템을 뿌려준다 */

        MediaMetadataRetriever mediaMetadataRetriever = new MediaMetadataRetriever();
        mediaMetadataRetriever.setDataSource( myItem.getPath() );
        Bitmap bitmap = mediaMetadataRetriever.getFrameAtTime(0);
        Bitmap canvasBitmap=mediaMetadataRetriever.getFrameAtTime(0);
        iv_img.setImageBitmap(bitmap);

        tv_name.setText(myItem.getName());
        tv_contents.setText(myItem.getContents());

        String path = Environment.getExternalStorageDirectory().getAbsolutePath();
        MediaController mc = new MediaController(context);
        vv.setMediaController(mc);
        vv.setVideoPath(path + "/DCIM/Camera/" + tv_name.getText().toString()+".mp4");

        vv.setOnErrorListener(new MediaPlayer.OnErrorListener() {
            @Override
            public boolean onError(MediaPlayer mediaPlayer, int i, int i1) {
                return true;
            }
        });
        return convertView;
    }

    /* 아이템 데이터 추가를 위한 함수. 자신이 원하는대로 작성 */
    public void addItem(Drawable icon, String name, String contents,String path) {

        MyItem mItem = new MyItem();

        /* MyItem에 아이템을 setting한다. */
        mItem.setIcon(icon);
        mItem.setName(name);
        mItem.setContents(contents);
        mItem.setPath(path);

        /* mItems에 MyItem을 추가한다. */
        mItems.add(mItem);
    }
}