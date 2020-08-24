using Gtk;

namespace PerioTimer.Widgets {

public class MainPopover : Budgie.Popover {
    private Stack? timerStack = null;
    private StackSwitcher? stackSwitcher = null;
    private Box? mainView = null;
    private Box? header = null;
    private Label? headerLabel = null;
    private Button? headerAddTimer = null;
    private Button? headerDeleteTimer = null;
    private int width;
    private int height;

    private PTimer[] timers = new PTimer[3];
    private int currentTimer = 0;
    private int numTimers = 1;
    private const int MAX_TIMERS = 4;
    private ColorManager colors = null;

    public MainPopover(Widget? window_parent, int width, int height, ColorManager colors) {
        /*  
            The main popover consists of a vertical box that contains a header, a stack
            switcher, and a stack of PTimers. It manages which timer is being shown and 
            the creation/deletion of new timers  
        */

        Object(relative_to: window_parent);
        this.width = width;
        this.height = height;
        this.colors = colors;
        this.set_resizable(false);
        add_events(Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.BUTTON_RELEASE_MASK);
        add_events(Gdk.EventMask.KEY_PRESS_MASK | Gdk.EventMask.KEY_RELEASE_MASK);
        
        mainView = new Box(Orientation.VERTICAL, 0);
        mainView.set_homogeneous(false);

        header = new Box(Orientation.HORIZONTAL, 0);
        header.height_request = 10;
        headerLabel = new Label("Perio Timer");
        headerLabel.get_style_context().add_class("ptimer_title");
        header.pack_start(headerLabel, false, false, 5);

        headerAddTimer = new Button.from_icon_name("list-add-symbolic", IconSize.MENU);
        headerAddTimer.clicked.connect(this.add_timer);
        header.pack_end(headerAddTimer, false, false, 0);
        
        headerDeleteTimer = new Button.from_icon_name("list-remove-symbolic", IconSize.MENU);
        headerDeleteTimer.clicked.connect(this.delete_timer);
        header.pack_end(headerDeleteTimer, false, false, 0);
        mainView.pack_start(header, false, false, 0);

        timerStack = new Stack();
        timerStack.set_transition_type(StackTransitionType.SLIDE_LEFT_RIGHT);
        stackSwitcher = new StackSwitcher();
        stackSwitcher.stack = timerStack;
        stackSwitcher.set_homogeneous(true);
        stackSwitcher.get_style_context().add_class("ptimer");
        timerStack.notify["visible-child"].connect(() => {
            // @TODO this is a temporary way of naming the stacks/setting which one is 
            // visible, will be changed when new naming technique is decided/implemented
            string visibleChildName = timerStack.get_visible_child_name();
            if (visibleChildName == null) {
                visibleChildName = "0";
            }
            currentTimer = int.parse(visibleChildName);
        });

        timers[0] = new PTimer(width, height, this, colors);
        timerStack.add_titled(timers[0].get_view(), currentTimer.to_string(), "Timer 0");

        mainView.pack_start(timerStack, false, false, 0);
        mainView.show_all();
        add(mainView);
    }

    public void add_timer() {
        if (numTimers == MAX_TIMERS) return;
        
        if (numTimers == 1) {
            mainView.pack_start(stackSwitcher, true, true, 0);
            mainView.reorder_child(stackSwitcher, 1);
        }
        currentTimer = numTimers;
        numTimers++;

        // @TODO make this less bad once new stack implemention is done
        timers[currentTimer] = new PTimer(width, height, this, colors);
        timerStack.add_titled(timers[currentTimer].get_view(), currentTimer.to_string(), "Timer " + currentTimer.to_string());
        
        mainView.show_all();
        timerStack.set_visible_child_name(currentTimer.to_string());
    }

    public void delete_timer() {
        if (timers[currentTimer].get_active()) return;

        // the call to remove triggers the timerStack.notify["visible-child"] callback
        // which sets currentTimer to the currently visible child but we don't want that
        // right now in order to use easy delete logic, so just copy the value across that call
        int ct = currentTimer;
        timerStack.remove(timers[currentTimer].get_view());
        currentTimer = ct;

        if (numTimers == 1) {
            timers[currentTimer] = new PTimer(width, height, this, colors);
            timerStack.add_titled(timers[currentTimer].get_view(), currentTimer.to_string(), "Timer " + currentTimer.to_string());
        } else {
            for (int i = currentTimer; i < numTimers - 1; i++) {
                timers[i] = timers[i + 1];
            }

            if (currentTimer == numTimers - 1) {
                switch_timer(-1);
            } else {
                switch_timer(0);
            }
            
            numTimers--;
            if (numTimers == 1) {
                mainView.remove(stackSwitcher);
            }
        }
        mainView.show_all();
    }

    public void switch_timer(int direction) {
        int prevTimer = currentTimer;
        currentTimer += direction;
        if (currentTimer < 0 || currentTimer >= numTimers) {
            currentTimer = prevTimer;
        }
        timerStack.set_visible_child(timers[currentTimer].get_view());
    }

    public override bool key_press_event (Gdk.EventKey event) {
        timers[currentTimer].im.keypress(event);
        return Gdk.EVENT_PROPAGATE;
    }
}

} // end namespace