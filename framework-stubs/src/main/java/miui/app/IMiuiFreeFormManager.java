package miui.app;
import android.os.Binder;
import android.os.IBinder;
import android.os.IInterface;
import android.os.RemoteException;
import java.util.List;
public interface IMiuiFreeFormManager extends IInterface {
    List getAllFreeFormStackInfosOnDisplay(int displayId) throws RemoteException;
    List getAllPinedFreeFormStackInfosOnDisplay(int displayId) throws RemoteException;
    MiuiFreeFormManager.MiuiFreeFormStackInfo getFreeFormStackInfoByActivity(IBinder token) throws RemoteException;
    MiuiFreeFormManager.MiuiFreeFormStackInfo getFreeFormStackInfoByStackId(int stackId) throws RemoteException;
    MiuiFreeFormManager.MiuiFreeFormStackInfo getFreeFormStackInfoByWindow(IBinder token) throws RemoteException;
    MiuiFreeFormManager.MiuiFreeFormStackInfo getFreeFormStackToAvoid(int a, String pkg) throws RemoteException;
    boolean hasMiuiFreeformOnShellFeature() throws RemoteException;
    boolean isSupportPin() throws RemoteException;
    void notifyCameraStateChanged(String pkg, int state) throws RemoteException;
    boolean openCameraInFreeForm(String pkg) throws RemoteException;
    void registerFreeformCallback(IFreeformCallback callback) throws RemoteException;
    int startSmallFreeformFromNotification() throws RemoteException;
    void unregisterFreeformCallback(IFreeformCallback callback) throws RemoteException;

    public static abstract class Stub extends Binder implements IMiuiFreeFormManager {
        public static IMiuiFreeFormManager asInterface(IBinder binder) { return null; }
        @Override public IBinder asBinder() { return this; }
    }
}