package miui.autoinstall.config.pm;
import android.content.Context;
import android.content.pm.PackageManager;
public class PackageManagerCompat {
    public PackageManagerCompat(Context context) {}
    public static boolean packageExists(PackageManager pm, String pkg) { return false; }
}