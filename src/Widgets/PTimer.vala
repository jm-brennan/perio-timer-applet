using Gtk;

namespace PatternTimer.Widgets {
public class PTimer {
    private Overlay? overlay = null;
    private TimerAnimation? ta = null;
    public InputManager? im = null;
    private TextView? textView = null;
    private Box? timerView = null;
    private Box? settingsView = null;
    private bool active = false;
    private int update_interval = 1000;
    private bool repeat = false;
    private bool mute = false;
    private int64 timerDuration = 0;
    private int64 startTime = 0;
    private int64 endTime = 0;
    private int hours = 0;
    private int minutes = 0;
    private int seconds = 0;
    private string displayString = "";

    // button setup for settings:
    // repeat: default off
    // notification: default on
    // volume: default on
    // TODO make defaults configurable in settings
    private bool repeatStatus = false;
    private Button repeatBut = null;
    private Image repeatImOn = new Image.from_icon_name("media-playlist-consecutive-symbolic", IconSize.MENU);
    private Image repeatImOff = new Image.from_icon_name("media-playlist-repeat-symbolic", IconSize.MENU);

    private bool notificationStatus = true;
    private Button notificationBut = null;
    private Image notificationImOn = new Image.from_icon_name("notification-alert-symbolic", IconSize.MENU);
    private Image notificationImOff = new Image.from_icon_name("notification-disabled-symbolic", IconSize.MENU);

    private bool volumeStatus = true;
    private Button volumeBut = null;
    private Image volumeImOn = new Image.from_icon_name("audio-volume-high-symbolic", IconSize.MENU);
    private Image volumeImOff = new Image.from_icon_name("audio-volume-muted-symbolic", IconSize.MENU);


    // figuring out the multi stage stuff
    //private Stage[]

    public PTimer(int width, int height, int colorset) {
        im = new InputManager(this);
        timerView = new Box(Orientation.VERTICAL, 0);
        
        overlay = new Overlay();
        overlay.add_events(Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.BUTTON_RELEASE_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK);
        overlay.set_size_request(width, height);
        ta = new TimerAnimation(width, height, colorset);
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
    
        // textview needs to be wrapped in center of a 3x3 box grid to get the 
        // bottom border attribute to appear properly. Because it is added to an overlay,
        // can't just pack_start with expand=false to get proper vertical alignment,
        // and need empty widgets (just chose labels) to make left and right boundaries.
        // There may be better ways to accomplish this, but I am a gtk novice.  
        var textViewBoxV = new Box(Orientation.VERTICAL, 0);
        textViewBoxV.set_homogeneous(true);
        var textViewBoxH = new Box(Orientation.HORIZONTAL, 0);
        textViewBoxH.set_homogeneous(false);
        var rlabel = new Label("");
        var llabel = new Label("");

        textView = new TextView();
        textView.set_justification(Justification.CENTER);
        textView.cursor_visible = false;
        textView.set_editable(false);
        
        textViewBoxH.pack_start(llabel, false, false, 0);
        textView.set_halign(Align.CENTER);
        textView.set_valign(Align.CENTER);
        // this needs the expand properties=true so that calling set_halign will matter
        textViewBoxH.pack_start(textView, true, true, 0);
        textViewBoxH.pack_start(rlabel, false, false, 0);

        textViewBoxV.pack_start(textViewBoxH, false, false, 0);
        
        overlay.add(textViewBoxV);
        overlay.add_overlay(ta);
        make_display_string();
        timerView.pack_start(overlay, false, false, 0);
        
        settingsView = new Box(Orientation.HORIZONTAL, 0);

        repeatBut = new Button();
        repeatBut.set_image(repeatImOff);
        repeatBut.clicked.connect(this.toggle_repeat);
        settingsView.pack_start(repeatBut, true, false, 0);

        volumeBut = new Button();
        volumeBut.set_image(volumeImOn);
        volumeBut.clicked.connect(this.toggle_volume);
        settingsView.pack_start(volumeBut, true, false, 0);

        notificationBut = new Button();
        notificationBut.set_image(notificationImOn);
        notificationBut.clicked.connect(this.toggle_notification);
        settingsView.pack_start(notificationBut, true, false, 0);

        /*  repeat_b.set_image(repeat_i);
        volume_b.set_image(volume_i);
        volume_b.toggled.connect(() => {
            if (volume_b.get_active() == true) {
                //volume_image = new Image.from_file("/home/jacob/projects/code/pattern-timer/applet/style/manual-mute-symbolic.svg");
                volume_i = new Image.from_icon_name("audio-volume-low-symbolic", IconSize.LARGE_TOOLBAR);
                volume_b.set_image(volume_i);
            } else {
                volume_i = new Image.from_icon_name("audio-volume-high-symbolic", IconSize.LARGE_TOOLBAR);
                volume_b.set_image(volume_i);
            }
        });  */

        timerView.pack_start(settingsView, true, true, 10);
    }

    public void set_input_time(int hours, int minutes, int seconds) {
        this.hours = hours;
        this.minutes = minutes;
        this.seconds = seconds;

        timerDuration = 0;
        timerDuration += hours * 36 * (int64)Math.pow10(8);
        timerDuration += minutes * 6 * (int64)Math.pow10(7);
        timerDuration += seconds * (int64)Math.pow10(6);
        make_display_string();
    }

    public Box timer_view() {
        return this.timerView;
    }

    public void toggle_active(bool startable = false) {
        if (active) {
            set_inactive();
        } else {
            // if this toggle call does not have start privileges
            // and timer hasn't been started, just return
            if (!startable && startTime == 0) return;
            set_active();
        }
    }

    public void set_active() {
        if (active) return;

        // this is starting a timer
        if (startTime == 0) {
            startTime = GLib.get_monotonic_time();
            endTime = startTime + timerDuration;
        }
        active = true;
        Timeout.add(update_interval, update_time);
        ta.set_active();
    }

    public void set_inactive() {
        if (!active) return;
        active = false;
        ta.set_inactive();
    }

    public void set_display_text(string newDisplay) {
        textView.buffer.text = newDisplay;
    }

    public void toggle_repeat() {
        if (repeatStatus) {
            repeatBut.set_image(repeatImOff);
        } else {
            repeatBut.set_image(repeatImOn);
        }
        repeatStatus = !repeatStatus;
    }

    public void toggle_notification() {
        if (notificationStatus) {
            notificationBut.set_image(notificationImOff);
        } else {
            notificationBut.set_image(notificationImOn);
        }
        notificationStatus = !notificationStatus;
    }

    public void toggle_volume() {
        if (volumeStatus) {
            volumeBut.set_image(volumeImOff);
        } else {
            volumeBut.set_image(volumeImOn);
        }
        volumeStatus = !volumeStatus;
    }

    public void make_display_string() {
        displayString = "";
        if (hours <= 0) {
            displayString += "0";
        } else {
            displayString += hours.to_string();
        }
        displayString += "h ";
        if (minutes <= 0) {
            displayString += "0";
        } else {
            displayString += minutes.to_string();
        }
        displayString += "m ";
        if (seconds <= 0) {
            displayString += "0";
        } else {
            displayString += seconds.to_string();
        }
        displayString += "s";
        textView.buffer.text = displayString;
    }

    public void decrement_time() {
        seconds--;
        if (seconds < 0 && minutes > 0) {
            seconds = 59;
            minutes--;
            if (minutes < 0 && hours > 0) {
                minutes = 59;
                hours--;
                if (hours < 0) {
                    hours = 0;
                }
            } else if (minutes < 0) {
                minutes = 0;
            }
        }
    }
    /*  
     time drifts by about 1/10 seconds every two minutes when just doing timeouts 
     */
    private bool update_time() {
        if (active) {
            decrement_time();
            if (seconds > 0) {
                make_display_string();
            } else {
                displayString = "DONE";
                textView.buffer.text = displayString;
                set_inactive();
            }
            
        }
        return active;
    }

}


}