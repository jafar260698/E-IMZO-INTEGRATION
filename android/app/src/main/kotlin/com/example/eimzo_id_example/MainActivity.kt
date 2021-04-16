package com.example.eimzo_id_example

import android.app.Activity
import android.content.Intent
import android.util.Base64
import androidx.annotation.NonNull
import com.example.eimzo_id_example.Constants.EXTRA_PARAM_API_KEY
import com.example.eimzo_id_example.Constants.EXTRA_PARAM_MESSAGE
import com.example.eimzo_id_example.Constants.EXTRA_PARAM_SERIAL_NUMBER
import com.example.eimzo_id_example.Constants.EXTRA_RESULT_PKCS7
import com.example.eimzo_id_example.Constants.EXTRA_RESULT_SERIAL_NUMBER
import com.example.eimzo_id_example.Constants.EXTRA_RESULT_SUBJECT_NAME
import com.example.eimzo_id_example.Constants.E_IMZO_ACTIVITY
import com.example.eimzo_id_example.Constants.E_IMZO_APP
import com.example.eimzo_id_example.Constants.RESULT_ACCESS_DENIED
import com.example.eimzo_id_example.Constants.RESULT_ERROR
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.util.*
import kotlin.collections.HashMap

class MainActivity : FlutterActivity() {

    val CHANNEL_NAME: String = "eimzoDemoChannel"

    lateinit var result: MethodChannel.Result
    lateinit var map: HashMap<String, String>

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME
        ).setMethodCallHandler { call, result ->
            this.result = result
            map = HashMap()
            when (call.method) {
                "eimzoData" -> {
                    if (call.hasArgument("message")) {
                        val message = call.argument<String>("message")
                        val androidApiKey = call.argument<String>("api_key")
                        val serialNumber = call.argument<String>("serial_number")

                        val intent = Intent()
                        intent.setClassName(E_IMZO_APP, E_IMZO_ACTIVITY)
                        intent.putExtra(EXTRA_PARAM_API_KEY, androidApiKey)
                        intent.putExtra(EXTRA_PARAM_SERIAL_NUMBER, serialNumber)
                        intent.putExtra(EXTRA_PARAM_MESSAGE, message)
                        startActivityForResult(intent, 100)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (data == null)
            return

        if (requestCode == 100) {
            when (resultCode) {
                RESULT_ACCESS_DENIED -> {

                    return
                }
                RESULT_ERROR -> {

                    return
                }
                Activity.RESULT_OK -> {
                    val sign = data.getByteArrayExtra(EXTRA_RESULT_PKCS7)
                    val xmlSign = Base64.encodeToString(sign, Base64.NO_WRAP)
                    val certificate =
                        data.getCharSequenceExtra(EXTRA_RESULT_SERIAL_NUMBER).toString()
                    val userData = data.getCharSequenceExtra(EXTRA_RESULT_SUBJECT_NAME).toString()
                    if (sign != null) map[EXTRA_RESULT_PKCS7] = xmlSign
                    map[EXTRA_RESULT_SERIAL_NUMBER] = certificate
                    map[EXTRA_RESULT_SUBJECT_NAME] = userData

                    result.success(JSONObject(map as Map<*, *>).toString())
                    return
                }
            }
        }

        super.onActivityResult(requestCode, resultCode, data)
    }

}
