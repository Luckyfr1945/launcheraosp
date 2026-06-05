package miui.module;
public class ModuleManager {
    private static ModuleManager sInstance;
    public static ModuleManager getInstance() {
        if (sInstance == null) {
            sInstance = new ModuleManager();
        }
        return sInstance;
    }
    public void loadModules(String[] modules) {}
    public void setModuleLoadListener(ModuleLoadListener listener) {}

    public interface ModuleLoadListener {
    }
}