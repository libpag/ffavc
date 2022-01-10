package libpag.pagviewer;

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.WindowManager;

import org.ffavc.DecoderFactory;
import org.libpag.PAGFile;
import org.libpag.PAGView;
import org.libpag.VideoDecoder;

public class MainActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_main);
        VideoDecoder.RegisterSoftwareDecoderFactory(DecoderFactory.GetHandle());
        VideoDecoder.SetMaxHardwareDecoderCount(0);

        final PAGView pagView = (PAGView) findViewById(R.id.pagView);
        PAGFile pagFile = PAGFile.Load(getAssets(), "particle_video.pag");
        pagView.setRepeatCount(-1);
        pagView.setFile(pagFile);
        pagView.play();
    }
}
