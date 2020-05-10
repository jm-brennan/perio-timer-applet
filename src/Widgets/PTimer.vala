using Gtk;

namespace PatternTimer.Widgets {
public class PTimer {
    private Overlay? overlay = null;
    private TimerAnimation? ta = null;
    private TextView? textView = null;
    private Box? timerView = null;
    private Box? settingsView = null;
    private ToggleButton repeat_b = null;
    private ToggleButton volume_b = null;
    private Image volume_i = null;
    private Image repeat_i = null;
    private bool active = false;
    private int update_interval = 1000;

    // @temporary
    public string t1 = "";
    public string t2 = "";

    public PTimer(string t1, string t2, int colorset) {
        this.t1 = t1;
        this.t2 = t2;



        timerView = new Box(Orientation.VERTICAL, 0);
        
        overlay = new Overlay();
        overlay.add_events(Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.BUTTON_RELEASE_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK);
        ta = new TimerAnimation(colorset);
        overlay.button_press_event.connect((e) => {
            this.toggle_active();
            return true;
        });
        /*  overlay.button_release_event.connect((e) => {
            print("RELEASE\n");
            print(e.x.to_string());
            print("\n");
            print(e.y.to_string());
            return true;
        });
        overlay.leave_notify_event.connect(() => {
            print("LEFT");
            return true;
        });  */
        
        textView = new TextView();
        textView.set_size_request(150,300);
        textView.set_top_margin(90);
        textView.set_justification(Justification.CENTER);
        textView.buffer.text = t1;
        textView.cursor_visible = false;
        textView.set_editable(false);

        overlay.add(textView);
        overlay.add_overlay(ta);

        timerView.pack_start(overlay, false, false, 0);
        
        settingsView = new Box(Orientation.HORIZONTAL, 0);
        repeat_b = new ToggleButton();
        volume_b = new ToggleButton();
        repeat_i = new Image.from_icon_name("media-playlist-repeat-symbolic", IconSize.MENU);
        volume_i = new Image.from_icon_name("audio-volume-high-symbolic", IconSize.MENU);
        repeat_b.set_image(repeat_i);
        volume_b.set_image(volume_i);
        volume_b.toggled.connect(() => {
            if (volume_b.get_active() == true) {
                //volume_image = new Image.from_file("/home/jacob/projects/code/pattern-timer/applet/style/manual-mute-symbolic.svg");
                volume_i = new Image.from_icon_name("audio-volume-low-symbolic", IconSize.MENU);
                volume_b.set_image(volume_i);
            } else {
                volume_i = new Image.from_icon_name("audio-volume-high-symbolic", IconSize.MENU);
                volume_b.set_image(volume_i);
            }
        });

        settingsView.pack_start(repeat_b, true, false, 0);
        settingsView.pack_start(volume_b, true, false, 0);
        timerView.pack_start(settingsView, true, true, 10);
    }

    public Box timer_view() {
        return this.timerView;
    }

    public void toggle_active() {
        if (active) {
            set_inactive();
        } else {
            set_active();
        }
    }

    public void set_active() {
        active = true;
        Timeout.add(update_interval, update_time);
        ta.set_active();
    }

    public void set_inactive() {
        active = false;
        ta.set_inactive();
    }

    public void set_display_text(string newDisplay) {
        textView.buffer.text = newDisplay;
    }

    private bool update_time() {
        if (active) {
            if (textView.buffer.text == t1) {
                textView.buffer.text = t2;
            } else {
                textView.buffer.text = t1;
            }
        }
        return active;
    }

}


}