public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "url_detector";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("predictURL")) {
                        String url = call.argument("url");

                        try {
                            // Gọi xử lý URL và predict
                            URLFeatureExtractor extractor = new URLFeatureExtractor(this);
                            URLPredictor predictor = new URLPredictor("model.onnx");
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
