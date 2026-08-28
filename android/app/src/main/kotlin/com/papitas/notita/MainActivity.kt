package com.papitas.notita

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val METHOD_CHANNEL =
            "com.papitas.notita/incoming_share"

        private const val EVENT_CHANNEL =
            "com.papitas.notita/incoming_share_events"
    }

    private var eventSink: EventChannel.EventSink? = null
    private var initialShare: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        initialShare = extractSharedText(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METHOD_CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "getInitialShare" -> {
                    val share = initialShare

                    // Evita procesar el mismo share dos veces.
                    initialShare = null

                    result.success(share)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENT_CHANNEL
        ).setStreamHandler(
            object : EventChannel.StreamHandler {

                override fun onListen(
                    arguments: Any?,
                    events: EventChannel.EventSink?
                ) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)

        setIntent(intent)

        val sharedText = extractSharedText(intent)

        if (sharedText != null) {
            eventSink?.success(sharedText)
        }
    }

    private fun extractSharedText(intent: Intent?): String? {

        if (intent == null) {
            return null
        }

        if (intent.action != Intent.ACTION_SEND) {
            return null
        }

        if (intent.type != "text/plain") {
            return null
        }

        return intent
            .getStringExtra(Intent.EXTRA_TEXT)
            ?.trim()
            ?.takeIf { it.isNotEmpty() }
    }
}