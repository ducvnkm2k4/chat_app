import ai.onnxruntime.*;
import android.content.Context;
import java.nio.FloatBuffer;
import java.io.InputStream;
import java.io.IOException;
import java.util.*;

public class URLPredictor {
    private OrtEnvironment env;
    private OrtSession session;

    // Constructor nhận vào context để truy cập AssetManager
    public URLPredictor(Context context, String modelPath) throws OrtException, IOException {
        env = OrtEnvironment.getEnvironment();
        // Đọc mô hình ONNX từ thư mục assets
        InputStream modelStream = context.getAssets().open(modelPath);
        byte[] modelBytes = new byte[modelStream.available()];
        modelStream.read(modelBytes);
        modelStream.close();

        // Tạo phiên làm việc từ mô hình ONNX
        OrtSession.SessionOptions options = new OrtSession.SessionOptions();
        session = env.createSession(modelBytes, options);
    }

    // Hàm dự đoán với danh sách các đặc trưng
    public float predict(List<Double> features) throws OrtException {
        int featureLength = features.size();
        float[] inputData = new float[featureLength];

        // Chuyển đổi các đặc trưng từ Double sang float
        for (int i = 0; i < featureLength; i++) {
            inputData[i] = features.get(i).floatValue();
        }

        // Tạo Tensor đầu vào
        OnnxTensor inputTensor = OnnxTensor.createTensor(env, FloatBuffer.wrap(inputData), new long[]{1, featureLength});

        // Tạo map input cho mô hình
        Map<String, OnnxTensor> inputs = new HashMap<>();
        String inputName = session.getInputNames().iterator().next();
        inputs.put(inputName, inputTensor);

        // Chạy mô hình và lấy kết quả đầu ra
        OrtSession.Result output = session.run(inputs);

        // Lấy kết quả dự đoán (giả sử mô hình trả về một giá trị xác suất)
        float[][] result = (float[][]) output.get(0).getValue();

        return result[0][0];  // Giả sử model trả về 1 giá trị xác suất
    }
}
