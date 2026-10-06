package ph.eparada.mobile

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val PERMISSIONS_CHANNEL = "ph.eparada.mobile/permissions"
    private val RECORD_AUDIO_REQUEST_CODE = 4001
    private var pendingPermissionResult: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel()
    }

    private fun ensureBluetoothAudioSafety() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val btGranted = ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.BLUETOOTH_CONNECT
                ) == PackageManager.PERMISSION_GRANTED

                val manager = com.cloudwebrtc.webrtc.audio.AudioSwitchManager.instance
                if (manager != null) {
                    if (!btGranted) {
                        // Avoid SecurityException on Android 12+ if BLUETOOTH_CONNECT is not granted
                        manager.preferredDeviceList.removeAll { deviceClass ->
                            deviceClass.name.contains("Bluetooth", ignoreCase = true)
                        }
                    } else {
                        val hasBt = manager.preferredDeviceList.any { it.name.contains("Bluetooth", ignoreCase = true) }
                        if (!hasBt) {
                            manager.preferredDeviceList.add(0, com.twilio.audioswitch.AudioDevice.BluetoothHeadset::class.java)
                        }
                    }
                }
            }
        } catch (_: Throwable) {
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        ensureBluetoothAudioSafety()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PERMISSIONS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkMicrophonePermission" -> {
                    ensureBluetoothAudioSafety()
                    val granted = ContextCompat.checkSelfPermission(
                        this,
                        Manifest.permission.RECORD_AUDIO
                    ) == PackageManager.PERMISSION_GRANTED
                    result.success(granted)
                }
                "requestMicrophonePermission" -> {
                    ensureBluetoothAudioSafety()
                    val permissionsToRequest = mutableListOf<String>()

                    if (ContextCompat.checkSelfPermission(
                            this,
                            Manifest.permission.RECORD_AUDIO
                        ) != PackageManager.PERMISSION_GRANTED
                    ) {
                        permissionsToRequest.add(Manifest.permission.RECORD_AUDIO)
                    }

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
                        ContextCompat.checkSelfPermission(
                            this,
                            Manifest.permission.BLUETOOTH_CONNECT
                        ) != PackageManager.PERMISSION_GRANTED
                    ) {
                        permissionsToRequest.add(Manifest.permission.BLUETOOTH_CONNECT)
                    }

                    if (permissionsToRequest.isEmpty()) {
                        result.success(true)
                    } else {
                        pendingPermissionResult?.success(false)
                        pendingPermissionResult = result
                        ActivityCompat.requestPermissions(
                            this,
                            permissionsToRequest.toTypedArray(),
                            RECORD_AUDIO_REQUEST_CODE
                        )
                    }
                }
                "openAppSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                            data = Uri.fromParts("package", packageName, null)
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SETTINGS_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        ensureBluetoothAudioSafety()
        if (requestCode == RECORD_AUDIO_REQUEST_CODE) {
            val micIndex = permissions.indexOf(Manifest.permission.RECORD_AUDIO)
            val granted = if (micIndex != -1 && micIndex < grantResults.size) {
                grantResults[micIndex] == PackageManager.PERMISSION_GRANTED
            } else {
                ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.RECORD_AUDIO
                ) == PackageManager.PERMISSION_GRANTED
            }
            pendingPermissionResult?.success(granted)
            pendingPermissionResult = null
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelId = "eparada_alerts"
            val channelName = "E-Parada Alerts"
            val channelDescription = "Notifications for parking reservations, approvals, and status alerts"
            val importance = NotificationManager.IMPORTANCE_HIGH

            val channel = NotificationChannel(channelId, channelName, importance).apply {
                description = channelDescription
                enableVibration(true)
                enableLights(true)
            }

            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
}
