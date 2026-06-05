package com.xiaomi.freeform;
import android.content.Context;
import android.app.ActivityOptions;
public class MiuiFreeformStub {
    private static MiuiFreeformStub sInstance;
    public static MiuiFreeformStub getInstance() {
        if (sInstance == null) {
            sInstance = new MiuiFreeformStub();
        }
        return sInstance;
    }
    public ActivityOptions getActivityOptions(Context context, String pkg, boolean a, boolean b) { return null; }
    public boolean supportFreeform() { return false; }
}