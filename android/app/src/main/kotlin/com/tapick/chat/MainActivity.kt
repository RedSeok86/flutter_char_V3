package com.tapick.chat

import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.RingtoneManager
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.HandlerThread
import android.util.Log
import android.widget.Toast
import androidx.annotation.NonNull
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.github.florent37.assets_audio_player.notification.NotificationService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import org.json.JSONObject

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.tapick.chat/cn1"
    var ze = 10


    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        Log.d("KDS", "ready")
        mci = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        mci.setMethodCallHandler { call, result ->
            // Note: this method is invoked on the main thread.
            // TODO
            //zz()

            if(call.method == "stream"){
                Log.d("KDS", "Call")
                Log.d("KDS", call.arguments.toString())
                newCall(call.arguments.toString());

            }else if(call.method == "noti"){
                noti_id = call.arguments.toString();
                Log.d("KDS", "Set ID :" + call.arguments.toString())
            }else if(call.method == "clear"){
                Log.d("KDS", "Clear")
                notificationClear()
            }
            //result.success();
        }

    }

    override fun onStart() {
        super.onStart()
        back = 1
    }

    override fun onPause() {
        super.onPause()
        back = 0
    }

    override fun onResume() {
        super.onResume()
        back = 1
        Log.d("KDS", "onResume");
        notificationClear()
        noti_id = ""
    }

    private fun newCall(data: String = ""){


                call_back(data)

    }

    private fun call_back(data: String = ""){
        val handlerThread = HandlerThread("other")
        handlerThread.start()
        val handler = Handler(handlerThread.looper)
        handler.post(Runnable {
            //Toast.makeText(this.getApplicationContext(), "P", Toast.LENGTH_SHORT).show()
            val jObjResponse: JSONObject = JSONObject(java.lang.String.valueOf(data.toString()))
            val _title = jObjResponse.getString("title")
            val _body = jObjResponse.getString("body")
            val _type = jObjResponse.getString("type")
            val _rid = jObjResponse.getString("rid")

            if (_type == "video") {
                val dialogIntent = Intent(applicationContext, VideoCall::class.java)
                dialogIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                dialogIntent.putExtra("name", _title);
                dialogIntent.putExtra("body", _body);
                dialogIntent.putExtra("type", _type);
                dialogIntent.putExtra("rid", _rid);
                this.startActivity(dialogIntent)
            } else if (_type == "voice") {
                val dialogIntent = Intent(applicationContext, VideoCall::class.java)
                dialogIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                dialogIntent.putExtra("name", _title);
                dialogIntent.putExtra("body", _body);
                dialogIntent.putExtra("type", _type);
                dialogIntent.putExtra("rid", _rid);
                this.startActivity(dialogIntent)
            } else {
                try{

                    if (noti_id?.toString() != _rid) {
                        notificationCall(_title, _body, 1);
                    }
                }catch (e:UninitializedPropertyAccessException){
                    notificationCall(_title, _body, 1);
                }
            }

        })
    }


    public fun notificationCall(title: String, text: String, id: Int){

        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        val pendingIntent: PendingIntent = PendingIntent.getActivity(this, 0, intent, 0)

        val notificationSound = RingtoneManager.getDefaultUri(R.raw.papupapu)
//
//        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
//            val uri: Uri = VivarFileProvider.getUriForFile(context, BuildConfig.APPLICATION_ID, file)
//            context.grantUriPermission("com.android.systemui", uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
//            uri
//        } else {
//            Uri.parse("android.resource://" + context.packageName.toString() + "/" + R.raw.rington)
//        }

        val ruiRingtone = Uri.parse("android.resource://" + packageName + "/" + R.raw.papupapu)

        val rington = RingtoneManager.getRingtone(this, ruiRingtone)
        val builder = NotificationCompat.Builder(this, NotificationService.CHANNEL_ID)
                .setSmallIcon(R.drawable.app_icon)
                .setContentTitle("" + title)
                .setContentText("" + text)
                .setSound(null)
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                // Set the intent that will fire when the user taps the notification
                .setContentIntent(pendingIntent)
                .setAutoCancel(true)

        with(NotificationManagerCompat.from(this)) {
            // notificationId is a unique int for each notification that you must define
            notify(id, builder.build())
            rington.play()
        }
    }

    public fun notificationClear(){

        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancelAll()
    }


}