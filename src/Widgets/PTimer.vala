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
    private bool restarted = false;
    private int updateInterval = 10;
    private int timeToRepeat = 2000;
    private int timeToSwitchStage = 1000;
    
    private bool doSeconds = false;

    // @TODO load defaults from settings
    // button setup for timer behavior settings:
    // repeat: default off
    // notification: default on
    // volume: default on
    private ToggleButton repeatBut = null;
    private Image repeatImOn = new Image.from_icon_name("media-playlist-repeat-symbolic", IconSize.MENU);
    private Image repeatImOff = new Image.from_icon_name("media-playlist-consecutive-symbolic", IconSize.MENU);

    private ToggleButton notificationBut = null;
    private Image notificationImOn = new Image.from_icon_name("notification-alert-symbolic", IconSize.MENU);
    private Image notificationImOff = new Image.from_icon_name("notification-disabled-symbolic", IconSize.MENU);

    private ToggleButton volumeBut = null;
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
        
        
        stages[0] = new Stage(0, doSeconds);
        stageStack = new Stack();
        stageStack.set_transition_type(StackTransitionType.SLIDE_LEFT_RIGHT);
        stageStack.add(stages[0].get_view());
        stageStack.set_visible_child(stages[0].get_view());
        overlay.add(stageStack);

        Stage* stagePtr = stages;
        ta = new TimerAnimation(width, height, colorset, stagePtr);
        overlay.add_overlay(ta);
        timerView.pack_start(overlay, false, false, 0);
        
        stageLabels = new Box(Orientation.HORIZONTAL, 0);
        stageLabels.height_request = 20;
        stageLabels.set_halign(Align.CENTER);
        timerView.pack_start(stageLabels, true, true, 0);
        
        // @TODO text entry for timer names? gotta figure out input redirection
        // te = new Entry();
        // timerView.pack_start(te, false, false, 0);

        settingsView = new Box(Orientation.HORIZONTAL, 0);

        repeatBut = new ToggleButton();
        repeatBut.set_image(repeatImOff);
        repeatBut.clicked.connect(() => {
            if (repeatBut.get_active()) {
                repeatBut.set_image(repeatImOn);
            } else {
                repeatBut.set_image(repeatImOff);
            }
        });
        settingsView.pack_start(repeatBut, true, false, 0);

        volumeBut = new ToggleButton();
        volumeBut.set_image(volumeImOff);
        volumeBut.clicked.connect(() => {
            if (volumeBut.get_active()) {
                volumeBut.set_image(volumeImOn);
            } else {
                volumeBut.set_image(volumeImOff);
            }
        });
        settingsView.pack_start(volumeBut, true, false, 0);

        notificationBut = new ToggleButton();
        notificationBut.set_image(notificationImOff);
        notificationBut.clicked.connect(() => {
            if (notificationBut.get_active()) {
                notificationBut.set_image(notificationImOn);
            } else {
                notificationBut.set_image(notificationImOff);
            }
        });
        settingsView.pack_start(notificationBut, true, false, 0);

        timerView.pack_start(settingsView, true, true, 10);
    }

    public void set_input_time(string inputString) {
        stages[currentStage].set_smh(inputString);
        ta.update_stages(numStages);
    }

    public void new_stage() {
        if (numStages == MAX_STAGES) return;
        if (numStages > 1) {
            stageLabels.pack_start(new Label("\u2022"), false, false, 5);
        }

        stageLabels.pack_start(stages[currentStage].label, false, false, 5);
        // @TODO make it so it can be added to middle of sequence (not linked list tho lol)
        currentStage = numStages;
        numStages++;

        stages[currentStage] = new Stage(currentStage, doSeconds);
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
            im.set_inputString(stages[currentStage].inputString);
            stageStack.set_visible_child(stages[currentStage].get_view());
        }
    }

    public Box timer_view() { return this.timerView; }

    public void start() {
        if (started) return;

        if (!stages[currentStage].active) {
            if (currentStage == numStages - 1 && !restarted) {
                if (numStages > 1) {
                    stageLabels.pack_start(new Label("\u2022"), false, false, 5);
                }
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
    }

    public void set_active() {
        if (started) {
            if (stageStack.get_visible_child() != stages[currentStage].get_view()) {
                stageStack.set_visible_child(stages[currentStage].get_view());
            }
            if (!stages[currentStage].active) {
                Timeout.add(0, update_time);
            }
            stages[currentStage].set_active();
            ta.set_active();
        }
    }

    public void set_inactive() {
        if (started) {
            stages[currentStage].set_inactive();
            ta.set_inactive();
        }
    }

    public void toggle_seconds() {
        // have to toggle doSeconds on all of them and update their text values
        // so that it will be correct when switching to view other stages
        doSeconds = !doSeconds;
        if (!stages[currentStage].active){
            for (int i = 0; i < numStages; i++) {
                stages[i].doSeconds = doSeconds;
                stages[i].update_display();
            }
        }
    }

    public void toggle_repeat() { repeatBut.set_active(!repeatBut.get_active()); }

    public void toggle_notification() { notificationBut.set_active(!notificationBut.get_active()); }

    public void toggle_volume() { volumeBut.set_active(!volumeBut.get_active()); }

    public void reset_timer() {
        started = false;
        restarted = true;
        for (int i = 0; i < numStages; i++) {
            stages[i].reset();
        }
        currentStage = 0;
        stageStack.set_visible_child(stages[currentStage].get_view());
        ta.update_stages(numStages);
    }

    /*  public void delete_stage(int stage) {
        stageLabels
    }   */  
     
    
    private bool update_time() {
        if (!stages[currentStage].active) return false;

        updateInterval = stages[currentStage].update_time();
        stages[currentStage].update_display();

        if (updateInterval != -1) { 
            Timeout.add(updateInterval, update_time);
        } else {
            // timer has ended, now decide between switching stages, repeating timer,
            // or coming to true end
            set_inactive();

            if (currentStage < numStages - 1) {
                // increment before timeout so that play can be pressed before the timeout
                // executes and it'll work properly
                currentStage++;
                //stageStack.set_visible_child(stages[currentStage].get_view());
                Timeout.add(timeToSwitchStage, () => {
                    set_active();
                    return false;
                });
            } else if (repeatBut.get_active()) {
                reset_timer();
                Timeout.add(timeToRepeat, () => {
                    start();
                    return false;
                });
            } else {
                Timeout.add(timeToSwitchStage, () => {
                    reset_timer();
                    return false;
                });
            }
        }
        return false;
    }
}

} // end namespace