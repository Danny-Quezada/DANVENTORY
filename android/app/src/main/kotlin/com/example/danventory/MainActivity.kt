package com.example.danventory
import android.os.Bundle
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterActivity



class MainActivity: FlutterActivity(){
    override fun onCreate(savedInstanceState: Bundle?) {
        installSplashScreen().setKeepOnScreenCondition {
            false
        }
        super.onCreate(savedInstanceState)
    }
  

   
}