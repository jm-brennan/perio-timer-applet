using Gtk;

namespace PerioTimer.Widgets {
public class Stage {
    public int hoursLeft = 0;
    public int minutesLeft = 0;
    public int secondsLeft = 0;
    public int64 lastUpdated = 0;
    public int64 timeLeft = 0;
    public string inputString = "";
    
    public bool active = false;
    public bool doSeconds = false;
    private Box? labelBox = null;
    private Label? label = new Label("0s");
    private Label? labelDot = null;
    
    private Box? textBox = null;
    private TextView? textView = null;
    //private TextView[] textViews = new TextView[6];
    private string[] smh = new string[3];
    public int hours = 0;
    public int minutes = 0;
    public int seconds = 0;
    
    public int colorOrder;
    private string cssColorTheme;
    private ColorManager colors = null;
    public Color color = {0,0,0};

    // only used for animation
    public int64 time = 0;
    
    public Stage(ColorManager colors, int colorOrder, bool doSeconds) {
        this.colors = colors;
        this.colorOrder = colorOrder;
        this.doSeconds = doSeconds;
        
        textView = new TextView();
        textBox = new Box(Orientation.HORIZONTAL, 0);
        update_color_theme();
        
        textView.get_style_context().add_class("ptimer-stage-time");
        update_display();
        textView.set_justification(Justification.CENTER);
        textView.cursor_visible = false;
        textView.set_editable(false);
        textView.show();

        // @TODO this causes a bug where the textview is not given the proper space to display.
        // I think it is a GTK bug, not me, will report soon
        //textView.set_halign(Align.CENTER);
        
        labelBox = new Box(Orientation.HORIZONTAL, 0);
        labelBox.set_spacing(10);
        label.get_style_context().add_class("ptimer-stage-label");
        labelBox.pack_end(label, false, false, 0); // pack end so that dot can be added to start
    }

    public void set_smh(string inputString) {
        this.inputString = inputString;
        smh[0] = ""; // seconds
        smh[1] = ""; // minutes
        smh[2] = ""; // hours
        int smhIndex = 0;
        
        for (int i = 0; i < inputString.length; i++) {
            smhIndex = (int)Math.floorf((inputString.length - 1 - i) / 2.0f);
            if (!doSeconds) {
                smhIndex += 1;
            }
            smh[smhIndex] = smh[smhIndex] + inputString.substring(i, 1);
        }
        
        if (!active) { 
            hours = int.parse(smh[2]);
            hoursLeft = hours;
            minutes = int.parse(smh[1]);
            minutesLeft = minutes;
            seconds = int.parse(smh[0]);
            secondsLeft = seconds;
            time = smh_to_unix();
            timeLeft = time;

            update_display();
            // It is unfortunate that this neds to be called twice with its different
            // settings, but it is necessary to get the different formatting correct at all
            // times, even after the original label has been made since it might get changed here.
            label.set_label(make_display_string(hours, minutes, seconds, true));

        }
    }

    public string string_from_timeLeft() {
        string inputStringForCurrentTime = "";
        if (hoursLeft > 0) inputStringForCurrentTime += hoursLeft.to_string();

        if (minutesLeft > 0) {
            if (minutesLeft < 10 && hoursLeft > 0) inputStringForCurrentTime += " ";
            inputStringForCurrentTime += minutesLeft.to_string();
        }

        if (secondsLeft > 0) {
            if (secondsLeft < 10 && minutesLeft > 0) inputStringForCurrentTime += " ";
            inputStringForCurrentTime += secondsLeft.to_string();
        }

        return inputStringForCurrentTime;
    }

    public string make_display_string(int hours, int minutes, int seconds, bool forLabel = false) {
        string displayString = "";
        
        // !active && !forLabel gives proper logic such that if the timer is paused (editing),
        // or if this function call is for the purpose of making the stage label then there
        // will not be any leading 0's in the output string. Apparently vala doesn't allow
        // the NOT to distribute so that it could be outisde the parens?
        
        if (hours > 0 || (!active && !forLabel)) {
            displayString += hours.to_string();
            displayString += "h ";
        }

        if (minutes > 0 || hours > 0 || (!active && !forLabel)) {
            displayString += minutes.to_string();
            displayString += "m";
        }

        if (seconds >= 0 || minutes > 0 || hours > 0 || (!active && !forLabel)) {
            if (doSeconds || active) {
                if (minutes > 0 || hours > 0 || (!active && !forLabel)) {
                    displayString += " ";
                }
                displayString += seconds.to_string();
                displayString += "s";
            }
        }
        // @TODO i dont know what i want to show when it ends, right now its just 0s
        if (forLabel && displayString == "") {
            displayString = "0s";   
        }

        return displayString;
    }

    // returns miliseconds until next update should be called, -1 if done
    public int update_time() {
        int64 currentTime = GLib.get_monotonic_time();
        int64 deltaTime = currentTime - lastUpdated;
        timeLeft -= deltaTime;
        lastUpdated = currentTime;
        // @TODO do i need this <= 100? or could it just be <= 0??
        if (timeLeft <= 100) {
            timeLeft = 0;
            return -1;
        } else {
            update_smhLeft_from_timeLeft();

            int milisecondsUntilUpdate = ((int)(timeLeft % 1000000) / 1000) + 1;
            return milisecondsUntilUpdate;
        }
    }

    public void update_display() {
        var buf = new TextBuffer(null);
        buf.set_text(make_display_string(hoursLeft, minutesLeft, secondsLeft));
        textView.set_buffer(buf);
    }

    public int64 smh_to_unix() {
        int64 tl = 0;
        tl += (int64)hours * 60 * 60 * 1000000;
        tl += (int64)minutes * 60 * 1000000;
        tl += (int64)seconds * 1000000;
        return tl;
    }

    public void update_smhLeft_from_timeLeft() {
        int64 timeLeftSeconds = timeLeft / 1000000;

        hoursLeft   = (int)(timeLeftSeconds / 3600);
        minutesLeft = (int)(timeLeftSeconds - (3600 * hoursLeft)) / 60;
        secondsLeft = (int)(timeLeftSeconds - (3600 * hoursLeft) - (minutesLeft*60));
    }

    public void add_label_dot() {
        labelDot = new Label("\u2022");
        labelBox.pack_start(labelDot, false, false, 0);
    }

    public void remove_label_dot() {
        labelBox.remove(labelDot);
        labelDot = null;
    }

    public void set_active() {
        if (active) return;
        active = true;

        //textView.get_style_context().remove_class("ptimer-stage-time-low-opacity");
        //textView.get_style_context().add_class("ptimer-stage-time");

        if (lastUpdated == 0) {
            timeLeft = smh_to_unix();
        }
        lastUpdated = GLib.get_monotonic_time();
        update_smhLeft_from_timeLeft();
        update_display();
    }

    public void set_inactive() {
        if (!active) return;
        active = false;

        //textView.get_style_context().remove_class("ptimer-stage-time");
        //textView.get_style_context().add_class("ptimer-stage-time-low-opacity");

        int64 currentTime = GLib.get_monotonic_time();
        timeLeft -= currentTime - lastUpdated;
        lastUpdated = currentTime;
    }

    public void end() {
        hoursLeft   = 0;
        minutesLeft = 0;
        secondsLeft = 0;
        timeLeft    = 0;
        lastUpdated = 0;
    }

    public void reset() {
        hoursLeft   = hours;
        minutesLeft = minutes;
        secondsLeft = seconds;
        
        lastUpdated = 0;
        timeLeft = smh_to_unix();
        update_display();
    }

    public void update_color_theme() {
        if (cssColorTheme != null) {
            textView.get_style_context().add_class(cssColorTheme);
        }
        ColorTheme theme = colors.get_current_theme();
        cssColorTheme = "ptimer-" + theme.name + colorOrder.to_string();
        color = theme.colors[colorOrder];
        textView.get_style_context().add_class(cssColorTheme);
    }

    public TextView get_view() {
        return textView;
    }

    public Box get_label() {
        return labelBox;
    }

    public string get_label_string() {
        return label.get_label();
    }

}

} // end namespace