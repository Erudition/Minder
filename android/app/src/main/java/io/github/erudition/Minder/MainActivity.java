package io.github.erudition.Minder;

import com.getcapacitor.BridgeActivity;

// C: added these imports for below onCreate 
import android.os.Bundle;
import android.util.Log;
import android.webkit.ServiceWorkerClient;
import android.webkit.ServiceWorkerController;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

public class MainActivity extends BridgeActivity {

    // https://github.com/ionic-team/capacitor/issues/5278#issuecomment-1653869040
    // can confirm this stops the SW from failing to register. still blocks capacitor though.
    // @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
        ServiceWorkerController swController = null;
        swController = ServiceWorkerController.getInstance();

        swController.setServiceWorkerClient(new ServiceWorkerClient() {
            @Override
            public WebResourceResponse shouldInterceptRequest(WebResourceRequest request) {
                Log.v("Java intercepting service worker for URL ", request.getUrl().toString());
                if (request.getUrl().toString().contains("index.html")) {
                    request.getRequestHeaders().put("Accept", "text/html");
                }
            return bridge.getLocalServer().shouldInterceptRequest(request);
            }
        });
        }
    }
}
