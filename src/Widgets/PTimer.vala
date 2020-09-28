using Gtk;

namespace PerioTimer.Widgets {

public class PTimer {
    private Overlay? overlay = null;
    private TimerAnimation? ta = null;
    public InputManager? im = null;
    private Box? timerView = null;
    private Stack stageStack = null;
    private Box? stageLabels = null;
    private bool started = false;
    private bool restarted = false;
    private int updateInterval = 10;
    private int timeToRepeat = 2000;
    private int timeToSwitchStage = 1000;
    
    private bool doSeconds = false;
    
    private ToggleButton volumeBut = null;
    private Image volumeImOn = new Image.from_icon_name("periotimer-audio-volume-high-symbolic", IconSize.MENU);
    private Image volumeImOff = new Image.from_icon_name("periotimer-audio-volume-muted-symbolic", IconSize.MENU);

    private ToggleButton repeatBut = null;
    private Image repeatImOn = new Image.from_icon_name("periotimer-media-playlist-repeat-rtl-symbolic", IconSize.MENU);
    private Image repeatImOff = new Image.from_icon_name("periotimer-media-playlist-repeat-disabled-rtl-symbolic", IconSize.MENU);

    private ToggleButton notificationBut = null;
    private Image notificationImOn = new Image.from_icon_name("periotimer-notification-alert-symbolic", IconSize.MENU);
    private Image notificationImOff = new Image.from_icon_name("periotimer-notification-disabled-symbolic", IconSize.MENU);

    private Button stageLeft = null;
    private Image stageLeftDelete = new Image.from_icon_name("list-remove-symbolic", IconSize.MENU);
    private Image stageLeftSkip = new Image.from_icon_name("media-skip-backward-symbolic", IconSize.MENU);

    private Button stageCenter = null;
    private Image stageCenterPlay = new Image.from_icon_name("media-playback-start-symbolic", IconSize.MENU);
    private Image stageCenterPause = new Image.from_icon_name("media-playback-pause-symbolic", IconSize.MENU);

    private Button stageRight = null;
    private Image stageRightAdd = new Image.from_icon_name("list-add-symbolic", IconSize.MENU);
    private Image stageRightSkip = new Image.from_icon_name("media-skip-forward-symbolic", IconSize.MENU);

    private const int MAX_STAGES = 4;
    private Stage[] stages = new Stage[MAX_STAGES];
    private int currentStage = 0;
    private int numStages = 1;
    private GLib.Queue<int> stageColors = new GLib.Queue<int>();
    
    private ColorManager? colors = null;
    private SoundManager? sounds = null;

    public PTimer(MainPopover parent, ColorManager colors, SoundManager sounds, int width, int height) {
        repeatImOn.set_pixel_size(16);
        repeatImOff.set_pixel_size(16);
        notificationImOn.set_pixel_size(16);
        notificationImOff.set_pixel_size(16);
        volumeImOn.set_pixel_size(16);
        volumeImOff.set_pixel_size(16);
    
        this.colors = colors;
        this.sounds = sounds;
        im = new InputManager(this, parent);

        stageColors.push_head(3);
        stageColors.push_head(2);
        stageColors.push_head(1);
        stageColors.push_head(0);
        
        timerView = new Box(Orientation.VERTICAL, 0);
        
        overlay = new Overlay();
        overlay.add_events(Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.BUTTON_RELEASE_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK);
        overlay.set_size_request(width, height);
        overlay.set_halign(Align.CENTER);
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
        
        
        stages[0] = new Stage(colors, stageColors.pop_head(), doSeconds);
        stageStack = new Stack();
        stageStack.set_transition_type(StackTransitionType.SLIDE_LEFT_RIGHT);
        stageStack.add(stages[0].get_view());
        stageStack.set_visible_child(stages[0].get_view());
        stageStack.set_halign(Align.CENTER);
        stageStack.set_valign(Align.CENTER);
        
        ta = new TimerAnimation(width, height, stages);
        overlay.add_overlay(ta);
        overlay.add(stageStack);
        timerView.pack_start(overlay, false, false, 0);
        
        Box stageControlView = new Box(Orientation.HORIZONTAL, 0);
        stageControlView.set_halign(Align.CENTER);
        stageControlView.set_spacing(20);
        stageLeft = new Button();
        stageLeft.set_tooltip_text("Delete Stage");
        stageLeft.set_image(stageLeftDelete);
        stageLeft.clicked.connect(() => {
            if (stages[currentStage].active) {
                skip_stage(-1);
            } else {
                delete_stage();
            }
        });
        stageControlView.pack_start(stageLeft, false, false, 0);

        stageCenter = new Button();
        stageCenter.set_tooltip_text("Play");
        stageCenter.set_image(stageCenterPlay);
        stageCenter.clicked.connect(() => {
            if (started) {
                toggle_active();
            } else {
                start();
            }
        });
        stageControlView.pack_start(stageCenter, false, false, 0);
        
        stageRight = new Button();
        stageRight.set_tooltip_text("New Stage");
        stageRight.set_image(stageRightAdd);
        stageRight.clicked.connect(() => {
            if (stages[currentStage].active) {
                skip_stage(1);
            } else {
                add_stage();
            }
        });
        stageControlView.pack_start(stageRight, false, false, 0);
        timerView.pack_start(stageControlView, true, true, 0);

        stageLabels = new Box(Orientation.HORIZONTAL, 0);
        stageLabels.height_request = 20;
        stageLabels.set_halign(Align.CENTER);
        stageLabels.set_spacing(10);
        timerView.pack_start(stageLabels, true, true, 5);

        Box settingsView = new Box(Orientation.HORIZONTAL, 0);
        
        volumeBut = new ToggleButton();
        volumeBut.set_tooltip_text("Toggle Sound");
        // @TODO load from default
        volumeBut.set_active(true);
        volumeBut.set_image(volumeImOn);
        volumeBut.clicked.connect(() => {
            if (volumeBut.get_active()) {
                volumeBut.set_image(volumeImOn);
            } else {
                volumeBut.set_image(volumeImOff);
            }
        });
        settingsView.pack_start(volumeBut, true, false, 0);

        repeatBut = new ToggleButton();
        repeatBut.set_tooltip_text("Toggle Repeat");
        repeatBut.set_image(repeatImOff);
        repeatBut.clicked.connect(() => {
            if (repeatBut.get_active()) {
                repeatBut.set_image(repeatImOn);
            } else {
                repeatBut.set_image(repeatImOff);
            }
        });
        settingsView.pack_start(repeatBut, true, false, 0);

        notificationBut = new ToggleButton();
        notificationBut.set_tooltip_text("Toggle Notification");
        // @TODO load from default
        notificationBut.set_active(true);
        notificationBut.set_image(notificationImOn);
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

    public void start() {
        if (started || stages[currentStage].active) return;

        if (!restarted) add_label();

        currentStage = 0;
        stageStack.set_visible_child(stages[currentStage].get_view());
        started = true;

        // allows for proper editing of the stage when paused
        if (!doSeconds) {
            toggle_seconds();
            im.toggle_seconds();
        }
        set_active();
    }

    public void add_stage() {
        if (numStages == MAX_STAGES) return;
        
        add_label();
        started = false;
        
        // because the stageStack is an actual stack, can't just insert a new stage
        // into the middle of it. Have to pop off all the elements past the insertion
        // point and add them back on after making/adding the new stage
        GLib.Queue<int> stagesToReorder = new GLib.Queue<int>();
        for (int i = numStages; i > currentStage + 1; i--) {
            stages[i] = stages[i - 1];
            stagesToReorder.push_head(i);
            stageStack.remove(stages[i].get_view());
        }
        
        currentStage++;
        numStages++;
        
        stages[currentStage] = new Stage(colors, stageColors.pop_head(), doSeconds);
        stageStack.add(stages[currentStage].get_view());

        while (stagesToReorder.get_length() != 0) {
            stageStack.add(stages[stagesToReorder.pop_head()].get_view());
        }
        
        im.set_inputString("");
        ta.update_stages(numStages);
        stageStack.set_visible_child(stages[currentStage].get_view());
    }

    public void delete_stage() {
        if (stages[currentStage].active) return;

        remove_label();
        stageColors.push_head(stages[currentStage].colorOrder);
        stageStack.remove(stages[currentStage].get_view());
        started = false;

        if (numStages == 1) {
            stages[currentStage] = new Stage(colors, stageColors.pop_head(), doSeconds);
            stageStack.add(stages[currentStage].get_view());
        } else {
            for (int i = currentStage; i < numStages - 1; i++) {
                stages[i] = stages[i + 1];
            }
            numStages--;
        }

        ta.update_stages(numStages);
        stageStack.show_all();
        switch_stage_editing(-1, false);
    }

    public void switch_stage_editing(int switchDirection, bool addLabel = true) {
        if (stages[currentStage].active) return;
        int prevStage = currentStage;
        int newStage = prevStage + switchDirection;
        if (newStage < 0 || newStage >= numStages) {
            newStage = prevStage;
        } else if (addLabel) {
            // it is a little wasteful to try to add it every time there is a switching of stages
            // but doing it with minimum checking would add too much complexity
            add_label();
        }
        // have to wait to assign to currentStage so that possible call to add_label will
        // have the stage we are switching from still set as the currentStage
        currentStage = newStage;

        im.set_inputString(stages[currentStage].inputString);
        stageStack.set_visible_child(stages[currentStage].get_view());
    }

    public void skip_stage(int direction) {
        stages[currentStage].set_inactive();

        if (direction > 0) {
            stages[currentStage].end();
            ta.reset_stage(currentStage);
            currentStage++;
            currentStage %= numStages;
        } else {
            stages[currentStage].reset();
            ta.reset_stage(currentStage);
            currentStage--;
            if (currentStage < 0) { 
                currentStage = numStages - 1;
                for (int i = 0; i < currentStage; i++) {
                    stages[i].end();
                    ta.reset_stage(i);
                }
            }
        }

        // @TODO not sure this is necessary
        if (currentStage == 0) {
            reset_timer();
            start();
        } else {
            set_active();
        }
    }

    private void add_label() {
        var labels = stageLabels.get_children();
        for (int i = 0; i < labels.length(); i++) {
            var labelEventBox = (EventBox)labels.nth_data(i);
            if (stages[currentStage].get_label() == labelEventBox.get_child()) return;
        }

        // if its a dot-able stage and that stage does not already have a dot
        if (currentStage != 0 && stages[currentStage].get_label().get_children().length() < 2) {
            stages[currentStage].add_label_dot();
        }
        var eventBox = new EventBox();
        eventBox.set_data("listOrder", currentStage);
        eventBox.button_press_event.connect(() => {
            int listOrder = eventBox.get_data("listOrder");
            switch_stage_editing(listOrder - currentStage);
            return false;
        });
        eventBox.add(stages[currentStage].get_label());
        stageLabels.pack_start(eventBox);
        stageLabels.reorder_child(eventBox, currentStage);
        stageLabels.show_all();
    }

    private void remove_label() {
        var labels = stageLabels.get_children();
        for (int i = 0; i < labels.length(); i++) {
            var labelEventBox = (EventBox)labels.nth_data(i);
            if (stages[currentStage].get_label() == labelEventBox.get_child()) {
                stageLabels.remove(labelEventBox);
                if (currentStage == 0 && numStages > 1 && stages[currentStage+1].get_label().get_children().length() == 2) {
                    stages[currentStage+1].remove_label_dot();
                }
            }
        }
        stageLabels.show_all();
    }

    public void update_theme() {
        for (int i = 0; i < numStages; i++) {
            stages[i].update_color_theme();
        }
    }
    
    public bool get_active() { return stages[currentStage].active; }
    
    public void toggle_active() {
        if (stages[currentStage].active) {
            set_inactive();
        } else if (started) {
            set_active();
        }
    }

    public void set_active() {
        if (!started) return;

        stageLeft.set_image(stageLeftSkip);
        stageLeft.set_tooltip_text("Skip To Previous");
        stageCenter.set_image(stageCenterPause);
        stageCenter.set_tooltip_text("Pause");
        stageRight.set_image(stageRightSkip);
        stageRight.set_tooltip_text("Skip To Next");

        if (stageStack.get_visible_child() != stages[currentStage].get_view()) {
            stageStack.set_visible_child(stages[currentStage].get_view());
        }
        if (!stages[currentStage].active) {
            Timeout.add(0, update_time);
        }
        stages[currentStage].set_active();
        ta.set_active();
    }

    public void set_inactive() {
        if (!started) return;

        stageLeft.set_image(stageLeftDelete);
        stageLeft.set_tooltip_text("New Stage");
        stageCenter.set_image(stageCenterPlay);
        stageCenter.set_tooltip_text("Play");
        stageRight.set_image(stageRightAdd);
        stageRight.set_tooltip_text("Delete Stage");

        stages[currentStage].set_inactive();
        
        // set the inputString of the inputManager as though we had
        // typed out the timeLeft being display so it can be edited
        string s = stages[currentStage].string_from_timeLeft();
        stages[currentStage].inputString = s;
        im.set_inputString(s);
        
        ta.set_inactive();
    }

    // called by inputManager, does not change inputManager's doSeconds
    public void toggle_seconds() {
        if (stages[currentStage].active) return;

        // have to toggle doSeconds on all of them and update their text values
        // so that it will be correct when switching to view other stages
        doSeconds = !doSeconds;
        for (int i = 0; i < numStages; i++) {
            stages[i].doSeconds = doSeconds;
            stages[i].update_display();
        }
    }

    public void reset_timer() {
        started = false;
        restarted = true;
        for (int i = 0; i < numStages; i++) {
            stages[i].reset();
        }
        currentStage = 0;
        stageStack.set_visible_child(stages[currentStage].get_view());
        // @TODO does this call need to happen at all? maybe it could just be to redraw_canvas?
        ta.update_stages(numStages);
    }

    private void notify(string summary, string body) {
        var cmd = "notify-send -a 'Perio Timer Applet' -i appointment-soon-symbolic '%s' '%s'".printf(summary, body);
        try {
            Process.spawn_command_line_async(cmd);
        } catch (GLib.SpawnError e) {
            stderr.printf("Error spawning notify process: %s\n", e.message);
            return;
        }
    }

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

            string notifySummary = "Timer (%s) done".printf(stages[currentStage].get_label_string());
            string notifyBody = "";
            if (currentStage < numStages - 1) {
                // increment before timeout so that play can be pressed before the timeout
                // executes and it'll work properly
                currentStage++;
                notifyBody = "Up next: %s.".printf(stages[currentStage].get_label_string());
                Timeout.add(timeToSwitchStage, () => {
                    set_active();
                    return false;
                });
            } else if (repeatBut.get_active()) {
                reset_timer();
                notifyBody = "Resetting timer. Up next: %s.".printf(stages[currentStage].get_label_string());
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
            if (notificationBut.get_active()) notify(notifySummary, notifyBody);
            if (volumeBut.get_active()) sounds.play_sound(true, null);
        }
        return false;
    }

    public void toggle_repeat() { repeatBut.set_active(!repeatBut.get_active()); }

    public void toggle_notification() { notificationBut.set_active(!notificationBut.get_active()); }

    public void toggle_volume() { volumeBut.set_active(!volumeBut.get_active()); }

    public Box get_view() { return this.timerView; }
}

} // end namespace