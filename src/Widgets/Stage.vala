using Gtk;

namespace PerioTimer.Widgets {
public class Stage {
    public int hoursLeft = 0;
    public int minutesLeft = 0;
    public int secondsLeft = 0;
    public int64 lastUpdated = 0;
    public int64 timeLeft = 0;
    public int64 time = 0; // only used for animation
    public string inputString = "";
    
    public bool active = false;
    // @TODO load doSeconds from settings
    public bool doSeconds = false;
    public Label? label = new Label("");
    
    private Box? view = null;
    private TextView? textView = null;
    private string[] smh = new string[3];
    public int hours = 0;
    public int minutes = 0;
    public int seconds = 0;
    private float r = 0.0f;
    private float g = 0.0f;
    private float b = 0.0f;
    
    public Stage(int stageIndex, bool doSeconds) {
        // init colors?
        this.doSeconds = doSeconds;

        // textview needs to be wrapped in center of a 3x3 box grid to get the 
        // bottom border attribute to appear properly. Because it is added to an overlay,
        // can't just pack_start with expand=false to get proper vertical alignment,
        // and need empty widgets (just chose labels) to make left and right boundaries.
        // There may be better ways to accomplish this, but I am a gtk novice.
        view = new Box(Orientation.VERTICAL, 0);
        view.set_homogeneous(true);
        var textViewBoxH = new Box(Orientation.HORIZONTAL, 0);
        textViewBoxH.set_homogeneous(false);
        var rlabel = new Label("");
        var llabel = new Label("");
        
        textView = new TextView();
        string styleClass = "";
        switch(stageIndex) {
            case 0:
                styleClass = "red";
                break;
            case 1:
                styleClass = "seagreen";
                break;
            case 2:
                styleClass = "yellow";
                break;
            case 3:
                styleClass = "greensheen";
                break;
        }
        textView.get_style_context().add_class(styleClass);
        textView.get_style_context().add_class("time_view");
        textView.buffer.text = make_display_string(hours, minutes, seconds);
        textView.set_justification(Justification.CENTER);
        textView.cursor_visible = false;
        textView.set_editable(false);
        
        textViewBoxH.pack_start(llabel, false, false, 0);
        textView.set_halign(Align.CENTER);
        textView.set_valign(Align.CENTER);
        // this needs the expand properties=true so that calling set_halign will matter
        textViewBoxH.pack_start(textView, true, true, 0);
        textViewBoxH.pack_start(rlabel, false, false, 0);
        view.pack_start(textViewBoxH, false, false, 0);

        label.get_style_context().add_class("stage_name");
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

            textView.buffer.text = make_display_string(hours, minutes, seconds);
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
        /*  if (displayString == "") {
            displayString = "DONE";   
        }  */

        return displayString;
    }

    // returns miliseconds until next update should be called, -1 if done
    public int update_time() {
        int64 currentTime = GLib.get_monotonic_time();
        int64 deltaTime = currentTime - lastUpdated;
        timeLeft -= deltaTime;
        lastUpdated = currentTime;
        // @TODO do i need this <= 100? or could it just be <= 0?? may be related to below todos
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
        textView.buffer.text = make_display_string(hoursLeft, minutesLeft, secondsLeft);
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

    public void set_active() {
        if (active) return;
        active = true;

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

        int64 currentTime = GLib.get_monotonic_time();
        timeLeft -= currentTime - lastUpdated;
        lastUpdated = currentTime;
    }

    public void reset() {
        hoursLeft   = hours;
        minutesLeft = minutes;
        secondsLeft = seconds;
        
        lastUpdated = 0;
        timeLeft = smh_to_unix();
        update_display();
    }

    public Box get_view() {
        return view;
    }

}
}