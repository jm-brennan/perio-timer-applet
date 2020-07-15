using Gtk;

namespace PerioTimer.Widgets {

public class PTimer {
    private Overlay? overlay = null;
    private TimerAnimation? ta = null;
    public InputManager? im = null;
    private Box? timerView = null;
    private Stack stageStack = null;
    private Box? stageLabels = null;
    private Box? settingsView = null;
    private bool started = false;
    private int updateInterval = 1000;
    
    private bool doSeconds = false;

    // @TODO load defaults from settings
    // button setup for timer behavior settings:
    // repeat: default off
    // notification: default on
    // volume: default on
    private bool repeatStatus = false;
    private Button repeatBut = null;
    private Image repeatImOn = new Image.from_icon_name("media-playlist-repeat-symbolic", IconSize.MENU);
    private Image repeatImOff = new Image.from_icon_name("media-playlist-consecutive-symbolic", IconSize.MENU);

    private bool notificationStatus = true;
    private Button notificationBut = null;
    private Image notificationImOn = new Image.from_icon_name("notification-alert-symbolic", IconSize.MENU);
    private Image notificationImOff = new Image.from_icon_name("notification-disabled-symbolic", IconSize.MENU);

    private bool volumeStatus = true;
    private Button volumeBut = null;
    private Image volumeImOn = new Image.from_icon_name("audio-volume-high-symbolic", IconSize.MENU);
    private Image volumeImOff = new Image.from_icon_name("audio-volume-muted-symbolic", IconSize.MENU);


    // @TODO testing hvaing a text box, need to figure out input redirection
    // public Entry te = null;

    // @TODO figuring out the multi stage stuff
    private const int MAX_STAGES = 4;
    private Stage[] stages = new Stage[MAX_STAGES];
    private int currentStage = 0;
    private int numStages = 1;

    public PTimer(int width, int height, int colorset) {
        im = new InputManager(this);
        timerView = new Box(Orientation.VERTICAL, 0);
        // @TODO input redirection
        timerView.set_focus_on_click(true);
        
        overlay = new Overlay();
        overlay.add_events(Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.BUTTON_RELEASE_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK);
        overlay.set_size_request(width, height);
        overlay.button_press_event.connect((e) => {
            this.toggle_active();
            return true;
        });
        // @TODO implement dragging leading edge of animation with this
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
        
        
        stages[0] = new Stage(0);
        stageStack = new Stack();
        stageStack.set_transition_type(StackTransitionType.SLIDE_LEFT_RIGHT);
        stageStack.add(stages[0].get_view());
        stageStack.set_visible_child(stages[0].get_view());
        overlay.add(stageStack);

        ta = new TimerAnimation(width, height, colorset);
        overlay.add_overlay(ta);
        timerView.pack_start(overlay, false, false, 0);
        
        stageLabels = new Box(Orientation.HORIZONTAL, 0);
        var placeholderLabel = new Label("");
        stageLabels.pack_start(placeholderLabel, false, false, 5);
        stageLabels.set_halign(Align.CENTER);
        timerView.pack_start(stageLabels, true, true, 0);
        
        // @TODO text entry for timer names? gotta figure out input redirection
        // te = new Entry();
        // timerView.pack_start(te, false, false, 0);

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

        timerView.pack_start(settingsView, true, true, 10);
    }

    public void set_input_time(string inputString) {
        stages[currentStage].set_smh(inputString);
    }

    public void new_stage() {
        if (numStages == MAX_STAGES) return;

        stageLabels.pack_start(stages[currentStage].label, false, false, 5);
        // @TODO make it so it can be added to middle of sequence (not linked list tho lol)
        currentStage = numStages;
        numStages++;

        stages[currentStage] = new Stage(currentStage);
        stageStack.add(stages[currentStage].get_view());
        timerView.show_all();
        stageStack.set_visible_child(stages[currentStage].get_view());
    }

    public void switch_stage_editing(int switchDirection) {
        if (!stages[currentStage].active) {
            currentStage += switchDirection;
            // don't walk off either end of defined stages
            currentStage = int.max(0, currentStage);
            currentStage = int.min(currentStage, numStages-1);
            stageStack.set_visible_child(stages[currentStage].get_view());
        }
    }

    public Box timer_view() { return this.timerView; }

    public void start() {
        if (!stages[currentStage].active) {
            // @TODO do we want this to be able to happen at other times?
            if (currentStage == numStages - 1) {
                stageLabels.pack_start(stages[currentStage].label, false, false, 5);
                timerView.show_all();
            }
            currentStage = 0;
            stageStack.set_visible_child(stages[currentStage].get_view());
            started = true;
            set_active();
        }
        
    }

    public void toggle_active() {
        if (stages[currentStage].active) {
            set_inactive();
        } else if (started) {
            set_active();
        }
        
        /*  if (stages[currentStage].active) {
            stages[currentStage].set_inactive();
        } else {
            // if this toggle call does not have start privileges
            // and timer hasn't been started, just return
            if (!startable && stages[currentStage].startTime == 0) return;
            stages[currentStage].set_active();
        }  */
    }

    public void set_active() {
        if (started) {
            if (!stages[currentStage].active) {
                Timeout.add(updateInterval, update_time);
            }
            stages[currentStage].set_active();
            ta.set_active();
        }
        
        /*  if (!stages[currentStage].active) {
            
            
        }  */
    }

    public void set_inactive() {
        if (started) {
            stages[currentStage].set_inactive();
            ta.set_inactive();
        }
        /*  if (stages[currentStage].active) {
            
        }  */
    }

    public void toggle_seconds() {
        // have to toggle doSeconds on all of them and update their text values
        // so that it will be correct when switching to view other stages
        if (!stages[currentStage].active){
            for (int i = 0; i < numStages; i++) {
                stages[i].doSeconds = !stages[i].doSeconds;
                stages[i].update_display();
            }
        }
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

    public void reset_stages() {
        for (int i = 0; i < numStages; i++) {
            stages[i].reset();
        }
    }

    /*  public void delete_stage(int stage) {
        stageLabels
    }   */  
     
    
    private bool update_time() {
        if (stages[currentStage].active) {
            bool stageFinished = stages[currentStage].decrement_time();
            if (!stageFinished) { return stages[currentStage].active; }
            
            if (currentStage < numStages - 1) {
                currentStage++;
                // @TODO add some buffer time when switching to next stage?
                //@restructure change stack display
                stages[currentStage].set_active();
                print("switch stages\n");
            } else if (repeatStatus) {
                currentStage = 0;
                reset_stages();
                // @TODO add some buffer time while restarting?
                stages[currentStage].set_active();
            } else {
                print("true end\n");
                stages[currentStage].update_display();
                stages[currentStage].set_inactive();
            }
        }
        return stages[currentStage].active;
    }

}

} // end namespace