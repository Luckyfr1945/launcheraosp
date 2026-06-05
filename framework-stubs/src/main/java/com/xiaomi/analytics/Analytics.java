package com.xiaomi.analytics;
import android.content.Context;
public class Analytics {
    private static Analytics sInstance;
    public static Analytics getInstance(Context context) {
        if (sInstance == null) {
            sInstance = new Analytics();
        }
        return sInstance;
    }
    public Tracker getTracker(String name) { return new Tracker(); }
    public void setDontUseSystemAnalytics(boolean val) {}
}