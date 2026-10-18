package dev.pesoflow.ocrprobe;

import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Rect;
import android.os.Bundle;
import android.widget.TextView;
import com.google.android.gms.tasks.Tasks;
import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.text.Text;
import com.google.mlkit.vision.text.TextRecognition;
import com.google.mlkit.vision.text.TextRecognizer;
import com.google.mlkit.vision.text.latin.TextRecognizerOptions;
import org.json.JSONArray;
import org.json.JSONObject;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.TimeUnit;

// Standalone test app: no financial storage, gallery permissions or network.
// Private output is read explicitly with adb run-as, never emitted to logcat.
public final class OcrProbeActivity extends Activity {
  private TextView status;

  @Override public void onCreate(Bundle state) {
    super.onCreate(state);
    status = new TextView(this);
    status.setText("Local OCR diagnostic running. PesoFlow data is not accessed.");
    setContentView(status);
    new Thread(this::runProbe).start();
  }

  private void runProbe() {
    TextRecognizer recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS);
    JSONArray results = new JSONArray();
    try {
      JSONArray inputs;
      try (InputStream stream = getAssets().open("inputs.json")) {
        inputs = new JSONArray(new String(stream.readAllBytes(), StandardCharsets.UTF_8));
      }
      for (int i = 0; i < inputs.length(); i++) {
        JSONObject input = inputs.getJSONObject(i);
        JSONObject result = new JSONObject();
        result.put("case", input.getString("case"));
        result.put("stage", input.getString("stage"));
        Bitmap bitmap = null;
        long start = android.os.SystemClock.elapsedRealtime();
        try (InputStream stream = getAssets().open(input.getString("file"))) {
          bitmap = BitmapFactory.decodeStream(stream);
          Text text = Tasks.await(recognizer.process(InputImage.fromBitmap(bitmap, 0)), 60, TimeUnit.SECONDS);
          result.put("text", text.getText());
          JSONArray blocks = new JSONArray();
          for (Text.TextBlock block : text.getTextBlocks()) {
            JSONObject b = new JSONObject();
            JSONArray lines = new JSONArray();
            for (Text.Line line : block.getLines()) {
              JSONObject l = cell(line.getText(), line.getBoundingBox());
              JSONArray elements = new JSONArray();
              for (Text.Element element : line.getElements()) {
                elements.put(cell(element.getText(), element.getBoundingBox()));
              }
              l.put("elements", elements);
              lines.put(l);
            }
            b.put("lines", lines);
            blocks.put(b);
          }
          result.put("blocks", blocks);
        } catch (Exception e) {
          result.put("error", e.getClass().getSimpleName());
        } finally {
          if (bitmap != null) bitmap.recycle();
        }
        result.put("recognition_ms", android.os.SystemClock.elapsedRealtime() - start);
        results.put(result);
      }
      File output = new File(getFilesDir(), "passes.json");
      try (FileOutputStream stream = new FileOutputStream(output)) {
        stream.write(results.toString().getBytes(StandardCharsets.UTF_8));
      }
      runOnUiThread(() -> status.setText("Diagnostic complete. Private results are ready for local analysis."));
    } catch (Exception e) {
      runOnUiThread(() -> status.setText("Diagnostic failed; no financial data was accessed."));
    } finally {
      recognizer.close();
    }
  }

  private static JSONObject cell(String text, Rect rect) throws Exception {
    JSONObject cell = new JSONObject();
    cell.put("text", text);
    if (rect != null) cell.put("box", new JSONArray(new int[]{rect.left, rect.top, rect.width(), rect.height()}));
    return cell;
  }
}
