package miui.app;
import android.os.Binder;
import android.os.IBinder;
import android.os.IInterface;
import android.os.RemoteException;
public interface IMiuiFreeFormGuideTipServices extends IInterface {
    int getShowGuideClick() throws RemoteException;
    int getShowGuideController() throws RemoteException;
    int getShowGuideDock() throws RemoteException;
    int getShowGuideFreeform() throws RemoteException;
    int getShowGuideNotification() throws RemoteException;
    int getShowGuidePin() throws RemoteException;
    int getShowGuideSideBar() throws RemoteException;
    int getShowGuideSplit() throws RemoteException;
    boolean hasTipView() throws RemoteException;
    boolean hasTipViewType(int type) throws RemoteException;
    void removeFreeFormTipView(int type) throws RemoteException;
    void setShowGuideClick(int val) throws RemoteException;
    void setShowGuideController(int val) throws RemoteException;
    void setShowGuideFreeform(int val) throws RemoteException;
    void setShowGuideNotification(int val) throws RemoteException;
    void setShowGuidePin(int val) throws RemoteException;
    void setShowGuideSideBar(int val) throws RemoteException;
    void setShowGuideSplit(int val) throws RemoteException;
    void showFreeFormGuideDialog(int type) throws RemoteException;
    void showFreeFormTipView(int a, int b, int c, int d) throws RemoteException;
    void showFreeFormTipViewByClassName(int a, int b, int c, int d, String name) throws RemoteException;

    public static abstract class Stub extends Binder implements IMiuiFreeFormGuideTipServices {
        public static IMiuiFreeFormGuideTipServices asInterface(IBinder binder) { return null; }
        @Override public IBinder asBinder() { return this; }
    }
}