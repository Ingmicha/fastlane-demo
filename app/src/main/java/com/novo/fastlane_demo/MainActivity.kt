package com.novo.fastlane_demo

import android.content.Context
import android.support.v7.app.AppCompatActivity
import android.os.Bundle
import com.microsoft.appcenter.crashes.Crashes
import com.microsoft.appcenter.analytics.Analytics
import com.microsoft.appcenter.AppCenter
import android.content.pm.PackageManager
import android.text.TextUtils
import android.content.pm.PackageInfo
import android.os.Build
import android.support.annotation.RequiresApi
import android.util.Base64
import android.util.Log
import android.widget.Toast
import java.security.MessageDigest


class MainActivity : AppCompatActivity() {

    @RequiresApi(Build.VERSION_CODES.N)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)


        if (checkAppSignature(this) == 0) {
            Toast.makeText(this, "Google Play", Toast.LENGTH_LONG).show()
        } else {
            Toast.makeText(this, "No Google Play", Toast.LENGTH_LONG).show()

        }

    }

    fun isPackageInstalled(context: Context): Boolean {
        val pm = context.getPackageManager()
        var app_installed = false
        try {
            val info = pm.getPackageInfo("com.android.vending", PackageManager.GET_ACTIVITIES)
            val label = info.applicationInfo.loadLabel(pm) as String
            app_installed = !TextUtils.isEmpty(label) && label.startsWith("Google Play")
        } catch (e: PackageManager.NameNotFoundException) {
            app_installed = false
        }

        return app_installed
    }

    private val VALID = 0

    private val INVALID = 1

    private val SIGNATURE = "478yYkKAQF+KST8y4ATKvHkYibo="


    @RequiresApi(api = Build.VERSION_CODES.N)
    fun checkAppSignature(context: Context): Int {

        try {
            val pm = context.getPackageManager()
            val packageInfo = context.packageManager

                .getPackageInfo(
                    context.packageName,

                    PackageManager.GET_SIGNATURES
                )

            for (signature in packageInfo.signatures) {

                val signatureBytes = signature.toByteArray()

                val md = MessageDigest.getInstance("SHA")

                md.update(signature.toByteArray())

                val currentSignature = Base64.encodeToString(md.digest(), Base64.DEFAULT)

                Log.d("REMOVE_ME", "Include this string as a value for SIGNATURE:$currentSignature")

                //compare signatures

                if (SIGNATURE.equals(currentSignature)) {

                    return VALID

                }

            }

        } catch (e: Exception) {


            return INVALID
            //assumes an issue in checking signature., but we let the caller decide on what to do.

        }

        return INVALID
    }


}
