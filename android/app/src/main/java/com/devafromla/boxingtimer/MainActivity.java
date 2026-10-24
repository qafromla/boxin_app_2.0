package com.devafromla.boxingtimer;

import android.os.Bundle;
import android.view.View;

import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsControllerCompat;

import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Draw your UI edge-to-edge (Android 15 ready, backward-safe)
        WindowCompat.setDecorFitsSystemWindows(getWindow(), false);

        // Control system bar icon brightness (no deprecated color APIs)
        View decor = getWindow().getDecorView();
        WindowInsetsControllerCompat controller =
                WindowCompat.getInsetsController(getWindow(), decor);
        if (controller != null) {
            // true = dark icons (use when your background behind the bars is light)
            controller.setAppearanceLightStatusBars(true);
            controller.setAppearanceLightNavigationBars(true);
        }
    }
}