package com.miui.home.launcher.common;
public class HapticFeedbackCompat {
    private static HapticFeedbackCompat sInstance;
    public static HapticFeedbackCompat getInstance() {
        if (sInstance == null) {
            sInstance = new HapticFeedbackCompat();
        }
        return sInstance;
    }
    public void performGestureReadyBack() {}
}