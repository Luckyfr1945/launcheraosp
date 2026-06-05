package miui.os;
import java.io.File;
public class FileUtils {
    public static String getName(String path) {
        if (path == null) return null;
        return new File(path).getName();
    }
}