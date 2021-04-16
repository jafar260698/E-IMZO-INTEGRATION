package com.example.eimzo_id_example

object Constants {
    //  E-IMZO
    const val E_IMZO_APP = "uz.yt.eimzo"
    const val E_IMZO_ACTIVITY = "uz.yt.eimzo_app.MainActivity"

    const val RESULT_ERROR = 9
    const val RESULT_ACCESS_DENIED = 10

    const val EXTRA_PARAM_ATTACH_TST = "tst"
    const val EXTRA_PARAM_ATTACH_PKCS7 = "attach_pkcs7"
    const val EXTRA_PARAM_ATTACH_SERIAL_NUMBER = "attach_serial_number"

    const val EXTRA_PARAM_API_KEY = "api_key"
    const val EXTRA_PARAM_APPEND_PKCS7 = "append_pkcs7"
    const val EXTRA_PARAM_SERIAL_NUMBER = "serial_number"
    const val EXTRA_PARAM_MESSAGE = "message"

    const val EXTRA_RESULT_PKCS7 = "pkcs7"
    const val EXTRA_RESULT_SERIAL_NUMBER = "serial_number"
    const val EXTRA_RESULT_SUBJECT_NAME = "subject_name"
    const val EXTRA_RESULT_SIGNATURE = "signature"
    const val EXTRA_RESULT_ERROR_CLASS = "error_class"
    const val EXTRA_RESULT_ERROR_MESSAGE = "error_message"

    const val CREATE_CODE = 100
    const val APPEND_CODE = 200
    const val ATTACH_CODE = 300

    const val SIGN_CODE = 900
    const val CANCEL_CODE = 901
    const val ACCEPT_CODE = 902
    const val REJECT_CODE = 903
}
