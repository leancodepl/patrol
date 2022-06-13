package pl.leancode.automatorserver

import android.util.Log

object Logger {
    private const val TAG = "Maestro"

    fun e(msg: String) {
        Log.e(TAG, msg)
    }

    fun e(msg: String, tr: Throwable?) {
        Log.e(TAG, msg, tr)
    }

    fun i(msg: String) {
        Log.i(TAG, msg)
    }

    fun d(msg: String) {
        Log.d(TAG, msg)
    }
}