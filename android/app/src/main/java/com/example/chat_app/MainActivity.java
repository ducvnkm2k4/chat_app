package com.example.chat_app;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import androidx.annotation.NonNull;
import java.util.List;
import java.util.Map;
import java.util.ArrayList;
import java.util.HashMap;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "url_detector";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(
            (call, result) -> {
                if (call.method.equals("predictURL")) {
                    String url = call.argument("url");

                    try {
                        // Gọi xử lý URL và predict
                        URLFeatureExtractor extractor = new URLFeatureExtractor(MainActivity.this);
                        URLPredictor predictor = new URLPredictor(MainActivity.this, "random_forest.onnx");
                        List<Double> features = extractor.extract(url);
                        float score = predictor.predict(features);

                        result.success(score);
                    } catch (Exception e) {
                        result.error("ERROR", e.getMessage(), null);
                    }
                } else {
                    result.notImplemented();
                }
            }
        );
    }
}
