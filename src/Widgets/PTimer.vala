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

    public PTimer() {
        timerView = new Box(Orientation.VERTICAL, 0);
        
        overlay = new Overlay();
        overlay.add_events(Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.BUTTON_RELEASE_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK);
        ta = new TimerAnimation();
        overlay.button_press_event.connect((e) => {
            ta.toggle_state();
            active = !active;
            Timeout.add(1000, update_time);
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
        textView.buffer.text = "12:34";
        textView.cursor_visible = false;
        textView.set_editable(false);

        overlay.add(textView);
        overlay.add_overlay(ta);

        timerView.pack_start(overlay, false, false, 0);
        
        settingsView = new Box(Orientation.HORIZONTAL, 0);
        repeat_b = new ToggleButton();
        volume_b = new ToggleButton();
        repeat_i = new Image.from_icon_name("media-playlist-repeat-symbolic", Gtk.IconSize.MENU);
        volume_i = new Image.from_icon_name("audio-volume-high-symbolic", Gtk.IconSize.MENU);
        repeat_b.set_image(repeat_i);
        volume_b.set_image(volume_i);
        volume_b.toggled.connect(() => {
            if (volume_b.get_active() == true) {
                //volume_image = new Image.from_file("/home/jacob/projects/code/pattern-timer/applet/style/manual-mute-symbolic.svg");
                volume_i = new Image.from_icon_name("audio-volume-low-symbolic", Gtk.IconSize.MENU);
                volume_b.set_image(volume_i);
            } else {
                volume_i = new Image.from_icon_name("audio-volume-high-symbolic", Gtk.IconSize.MENU);
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
        active = !active;
    }

    public void update_display(string newDisplay) {
        textView.buffer.text = newDisplay;
    }

    private bool update_time() {
        if (active) {
            if (textView.buffer.text == "12:34") {
                textView.buffer.text = "12:35";
            } else {
                textView.buffer.text = "12:34";
            }
        }
        return active;
    }

}


}