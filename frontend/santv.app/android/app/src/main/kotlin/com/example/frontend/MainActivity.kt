package com.santv.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        crearCanalDeNotificaciones()
    }

    // Canal de importancia alta para que las notificaciones push de SAN TV
    // aparezcan como aviso emergente. El id debe coincidir con el del
    // backend (pushService.js) y con el AndroidManifest.
    private fun crearCanalDeNotificaciones() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val canal = NotificationChannel(
                "santv_default",
                "SAN TV",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Contenido nuevo, transmisiones en vivo y pagos"
            }
            getSystemService(NotificationManager::class.java)
                .createNotificationChannel(canal)
        }
    }
}
