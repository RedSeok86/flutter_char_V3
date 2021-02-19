package com.tapick.chat


import android.app.PendingIntent
import android.content.ContentResolver
import android.content.Intent
import android.content.Intent.*
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.net.Uri
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import android.util.Log
import android.widget.Toast
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.work.OneTimeWorkRequest
import androidx.work.WorkManager
import com.github.florent37.assets_audio_player.notification.NotificationService
import com.github.florent37.assets_audio_player.notification.NotificationService.Companion.CHANNEL_ID
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import org.json.JSONObject


class MyFirebaseMessagingService : FirebaseMessagingService() {

    /**
     * Called when message is received.
     *
     * @param remoteMessage Object representing the message received from Firebase Cloud Messaging.
     */
    // [START receive_message]
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        // [START_EXCLUDE]
        // There are two types of messages data messages and notification messages. Data messages are handled
        // here in onMessageReceived whether the app is in the foreground or background. Data messages are the type
        // traditionally used with GCM. Notification messages are only received here in onMessageReceived when the app
        // is in the foreground. When the app is in the background an automatically generated notification is displayed.
        // When the user taps on the notification they are returned to the app. Messages containing both notification
        // and data payloads are treated as notification messages. The Firebase console always sends notification
        // messages. For more see: https://firebase.google.com/docs/cloud-messaging/concept-options
        // [END_EXCLUDE]

        // TODO(developer): Handle FCM messages here.
        // Not getting messages here? See why this may be: https://goo.gl/39bRNJ
        Log.d(TAG, "From: ${remoteMessage.from}")




        // Check if message contains a data payload.
        if (remoteMessage.data.isNotEmpty()) {
            Log.d(TAG, "Message data payload: ${remoteMessage.data}")


            if (/* Check if data needs to be processed by long running job */ true) {
                // For long-running tasks (10 seconds or more) use WorkManager.
                scheduleJob(remoteMessage.data.toString())
            } else {
                // Handle message within 10 seconds
                handleNow(remoteMessage.data.toString())
            }
        }

        // Check if message contains a notification payload.
        remoteMessage.notification?.let {
            Log.d(TAG, "Message Notification Body: ${it.body}")
        }

        // Also if you intend on generating your own notifications as a result of a received FCM
        // message, here is where that should be initiated. See sendNotification method below.
    }
    // [END receive_message]

    // [START on_new_token]
    /**
     * Called if InstanceID token is updated. This may occur if the security of
     * the previous token had been compromised. Note that this is called when the InstanceID token
     * is initially generated so this is where you would retrieve the token.
     */
    override fun onNewToken(token: String) {
        Log.d(TAG, "Refreshed token: $token")

        // If you want to send messages to this application instance or
        // manage this apps subscriptions on the server side, send the
        // Instance ID token to your app server.
        sendRegistrationToServer(token)
    }
    // [END on_new_token]

    /**
     * Schedule async work using WorkManager.
     */
    private fun scheduleJob(data: String = "") {
        // [START dispatch_job]
        val work = OneTimeWorkRequest.Builder(MyWorker::class.java).build()
        WorkManager.getInstance().beginWith(work).enqueue()
        // [END dispatch_job]
        newCall(data);
    }



    private fun newCall(data: String = ""){


        Handler(Looper.getMainLooper()).post {

            call_back(data)
//            if(back==0){
//                call_back(data)
//            }else {
//                try {
//                    mci.invokeMethod("didRecieveTranscript", data)
//                } catch (ee: UninitializedPropertyAccessException) {
//                    Log.d("KDS", "Error")
//
//                    call_back(data)
//                }
//            }
        }

    }

    private fun call_back(data: String = ""){
        val handlerThread = HandlerThread("other")
        handlerThread.start()
        val handler = Handler(handlerThread.looper)
        handler.post(Runnable {
            //Toast.makeText(this@MyFirebaseMessagingService.getApplicationContext(), "Call", Toast.LENGTH_SHORT).show()
            val jObjResponse: JSONObject = JSONObject(java.lang.String.valueOf(data.toString()))
            val _title = jObjResponse.getString("title")
            val _body = jObjResponse.getString("body")
            val _type = jObjResponse.getString("type")
            val _rid = jObjResponse.getString("rid")

            if (_type == "video") {

                Toast.makeText(this@MyFirebaseMessagingService.getApplicationContext(), "Papucon Voice Call", Toast.LENGTH_SHORT).show()
                val dialogIntent = Intent(applicationContext, VideoCall::class.java)
                dialogIntent.addFlags(FLAG_ACTIVITY_NEW_TASK)
                dialogIntent.putExtra("name", _title);
                dialogIntent.putExtra("body", _body);
                dialogIntent.putExtra("type", _type);
                dialogIntent.putExtra("rid", _rid);
                this.startActivity(dialogIntent)
            } else if (_type == "voice") {
                Toast.makeText(this@MyFirebaseMessagingService.getApplicationContext(), "Papucon Video Call", Toast.LENGTH_SHORT).show()
                val dialogIntent = Intent(applicationContext, VideoCall::class.java)
                dialogIntent.addFlags(FLAG_ACTIVITY_NEW_TASK)
                dialogIntent.putExtra("name", _title);
                dialogIntent.putExtra("body", _body);
                dialogIntent.putExtra("type", _type);
                dialogIntent.putExtra("rid", _rid);
                this.startActivity(dialogIntent)
            } else {
                notificationCall(_title, _body, 1);
            }

        })
    }
    /**
     * Handle time allotted to BroadcastReceivers.
     */
    private fun handleNow(data: String = "") {
        Log.d(TAG, "Short lived task is done.")
        newCall(data);
    }

    /**
     * Persist token to third-party servers.
     *
     * Modify this method to associate the user's FCM InstanceID token with any server-side account
     * maintained by your application.
     *
     * @param token The new token.
     */
    private fun sendRegistrationToServer(token: String?) {
        // TODO: Implement this method to send token to your app server.
        Log.d(TAG, "sendRegistrationTokenToServer($token)")
    }

    /**
     * Create and show a simple notification containing the received FCM message.
     *
     * @param messageBody FCM message body received.
     */

    companion object {

        private const val TAG = "KDS"
    }


    public fun notificationCall(title: String, text: String, id: Int){

        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        val pendingIntent: PendingIntent = PendingIntent.getActivity(this, 0, intent, 0)

        val notificationSound = RingtoneManager.getDefaultUri(R.raw.papupapu)

        val path = "android.resource://" + packageName + "/" + R.raw.papupapu

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

}
