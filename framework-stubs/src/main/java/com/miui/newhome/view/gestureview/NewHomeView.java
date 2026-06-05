package com.miui.newhome.view.gestureview;
import android.content.Context;
import android.content.Intent;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
public class NewHomeView extends View {
    public NewHomeView(Context context) { super(context); }
    public void changeState(NewHomeState state) {}
    public boolean dispatchKeyEvent(KeyEvent event) { return false; }
    public NewHomeState getNewHomeState() { return NewHomeState.HIDE; }
    public int getVisibility() { return View.GONE; }
    public boolean isAppBarLayoutScroll() { return false; }
    public boolean isViewPagerScorll() { return false; }
    public boolean onBackPressed() { return false; }
    public void onDestory() {}
    public void onNewIntent(Intent intent) {}
    public void onPause() {}
    public void onResume() {}
    public void onTransProgress(float progress) {}
    public void setFeedActionListener(FeedActionListener listener) {}
    public void setTranslationY(float y) { super.setTranslationY(y); }
    public void setVisibility(int visibility) { super.setVisibility(visibility); }
    public boolean shouldContainerScroll(MotionEvent event) { return false; }
}