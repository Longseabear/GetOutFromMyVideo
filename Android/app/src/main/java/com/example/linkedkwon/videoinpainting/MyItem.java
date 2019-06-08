package com.example.linkedkwon.videoinpainting;

import android.graphics.drawable.Drawable;
import android.view.View;

public class MyItem {

    private Drawable icon;
    private String name;
    private String contents;
    private String path;

    public void setIcon(Drawable icon) {
        this.icon = icon;
    }
    public void setPath(String path){
        this.path=path;
    }
    public String getPath(){return path;}

    public Drawable getIcon(){return icon;}

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getContents() {
        return contents;
    }

    public void setContents(String contents) {
        this.contents = contents;
    }

}
