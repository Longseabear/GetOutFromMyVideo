package com.example.linkedkwon.videoinpainting;

import android.content.Intent;
import android.graphics.Color;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;

public class Home extends AppCompatActivity {

    private ImageView edit_btn,history_btn,solution_btn,info_btn;
    private Intent i;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);

        init();
    }

    private void init(){
        edit_btn=findViewById(R.id.edit_btn);
        history_btn=findViewById(R.id.history_btn);
        solution_btn=findViewById(R.id.solution_btn);
        info_btn=findViewById(R.id.info_btn);

        edit_btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                i=new Intent(getApplicationContext(),Edit.class);
                startActivity(i);
            }
        });

        history_btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                i=new Intent(getApplicationContext(),History.class);
                startActivity(i);
            }
        });

        solution_btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                i=new Intent(getApplicationContext(),Solution.class);
                startActivity(i);
            }
        });

        info_btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                i=new Intent(getApplicationContext(),Info.class);
                startActivity(i);
            }
        });
    }

}
