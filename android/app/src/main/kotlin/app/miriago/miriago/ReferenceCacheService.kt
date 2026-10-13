package app.miriago.miriago

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat

/**
 * Keeps the process alive while Dart caches a plan's reference images, so
 * caching continues with the screen locked or another app in front. The
 * downloads themselves run in Dart; this only owns the notification.
 */
class ReferenceCacheService : Service() {
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_CANCEL) {
            // Dart stops starting new downloads and then calls finish(). With
            // no Dart side left there is nothing to wait for.
            onCancel?.invoke() ?: stopSelf()
            return START_NOT_STICKY
        }
        title = intent?.getStringExtra(EXTRA_TITLE).orEmpty()
        cancelLabel = intent?.getStringExtra(EXTRA_CANCEL_LABEL).orEmpty()
        val notification = progressNotification(this, 0, 0)
        ServiceCompat.startForeground(
            this,
            PROGRESS_ID,
            notification,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
            } else {
                0
            },
        )
        return START_NOT_STICKY
    }

    // Swiping Koma away ends the Dart side, so the notification must go too.
    override fun onTaskRemoved(rootIntent: Intent?) {
        stopSelf()
    }

    // Android 15 caps dataSync services at six hours a day.
    override fun onTimeout(startId: Int, fgsType: Int) {
        stopSelf()
    }

    companion object {
        private const val CHANNEL_ID = "reference_cache"
        private const val PROGRESS_ID = 0x5E1D
        private const val RESULT_ID = 0x5E1E
        private const val EXTRA_TITLE = "title"
        private const val EXTRA_CANCEL_LABEL = "cancelLabel"
        private const val ACTION_CANCEL = "app.miriago.miriago.CANCEL_REFERENCE_CACHE"

        /** Set by the activity: tells Dart the user tapped Cancel. */
        var onCancel: (() -> Unit)? = null

        private var title = ""
        private var cancelLabel = ""

        fun start(context: Context, channelName: String, title: String, cancelLabel: String) {
            ensureChannel(context, channelName)
            NotificationManagerCompat.from(context).cancel(RESULT_ID)
            ContextCompat.startForegroundService(
                context,
                Intent(context, ReferenceCacheService::class.java)
                    .putExtra(EXTRA_TITLE, title)
                    .putExtra(EXTRA_CANCEL_LABEL, cancelLabel),
            )
        }

        fun update(context: Context, processed: Int, total: Int) {
            notify(context, PROGRESS_ID, progressNotification(context, processed, total))
        }

        fun finish(context: Context, title: String, text: String) {
            context.stopService(Intent(context, ReferenceCacheService::class.java))
            notify(
                context,
                RESULT_ID,
                builder(context, title)
                    .setSmallIcon(android.R.drawable.stat_sys_download_done)
                    .setContentText(text)
                    .setAutoCancel(true)
                    .build(),
            )
        }

        private fun progressNotification(
            context: Context,
            processed: Int,
            total: Int,
        ): Notification = builder(context, title)
            .setSmallIcon(android.R.drawable.stat_sys_download)
            .setContentText(if (total > 0) "$processed / $total" else null)
            .setProgress(total, processed, total == 0)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .addAction(
                0,
                cancelLabel,
                PendingIntent.getService(
                    context,
                    0,
                    Intent(context, ReferenceCacheService::class.java).setAction(ACTION_CANCEL),
                    PendingIntent.FLAG_IMMUTABLE,
                ),
            )
            .build()

        private fun builder(context: Context, title: String) =
            NotificationCompat.Builder(context, CHANNEL_ID)
                .setContentTitle(title)
                .setContentIntent(openApp(context))
                .setPriority(NotificationCompat.PRIORITY_LOW)

        private fun openApp(context: Context): PendingIntent? {
            val launch = context.packageManager.getLaunchIntentForPackage(context.packageName)
                ?: return null
            return PendingIntent.getActivity(context, 0, launch, PendingIntent.FLAG_IMMUTABLE)
        }

        private fun ensureChannel(context: Context, name: String) {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
            context.getSystemService(NotificationManager::class.java).createNotificationChannel(
                NotificationChannel(CHANNEL_ID, name, NotificationManager.IMPORTANCE_LOW),
            )
        }

        // Without notification permission the service still runs; the
        // notification just isn't shown.
        private fun notify(context: Context, id: Int, notification: Notification) {
            try {
                NotificationManagerCompat.from(context).notify(id, notification)
            } catch (_: SecurityException) {
            }
        }
    }
}
