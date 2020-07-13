using Gtk;

namespace PerioTimer.Widgets {

public class MainPopover : Budgie.Popover {
    private Stack? timerStack = null;
    private StackSwitcher? stackSwitcher = null;
    private Box? mainView = null;
    private Box? header = null;
    private Label? headerLabel = null;
    private Button? headerNewButton = null;
    private PTimer[] timers = new PTimer[3];
    private int currentTimer = 0;
    private int numTimers = 1;
    private const int MAX_TIMERS = 3;

    public MainPopover(Widget? window_parent, int width, int height) {
        /*  
            The main popover consists of a vertical box that contains a header, a stack
            switcher, and a stack of PTimers. It manages which timer is being shown and 
            the creation/deletion (@TODO) of new timers  
        */

        Object(relative_to: window_parent);
        this.set_resizable(false);
        // need to intercept button presses for fancy animation
        add_events(Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.BUTTON_RELEASE_MASK);
        add_events(Gdk.EventMask.KEY_PRESS_MASK | Gdk.EventMask.KEY_RELEASE_MASK);
        
        mainView = new Box(Orientation.VERTICAL, 0);
        mainView.set_homogeneous(false);

        header = new Box(Orientation.HORIZONTAL, 0);
        header.height_request = 10;
        // @TODO style this
        headerLabel = new Label("Perio Timer");
        header.pack_start(headerLabel, false, false, 5);

        headerNewButton = new Button.from_icon_name("list-add-symbolic", IconSize.MENU);
        headerNewButton.clicked.connect(() => {
            if (numTimers == MAX_TIMERS) return;
            
            timers[currentTimer].set_inactive();
            currentTimer = numTimers;
            numTimers++;

            // @TODO make this less bad once new stack implemention is done
            timers[currentTimer] = new PTimer(width, height, 1);
            timerStack.add_titled(timers[currentTimer].timer_view(), currentTimer.to_string(), currentTimer.to_string());
            mainView.show_all();
            timerStack.set_visible_child_name(currentTimer.to_string());
        });
        header.pack_end(headerNewButton, false, false, 0);
        mainView.pack_start(header, false, false, 0);

        timerStack = new Stack();
        timerStack.set_transition_type(StackTransitionType.SLIDE_LEFT_RIGHT);
        stackSwitcher = new StackSwitcher();
        stackSwitcher.stack = timerStack;
        stackSwitcher.set_homogeneous(true);
        timerStack.notify["visible-child"].connect(() => {
            // @TODO this is a temporary way of naming the stacks/setting which one is 
            // visible, will be changed when new naming technique is decided/implemented
            string visibleChildName = timerStack.get_visible_child_name();
            if (visibleChildName == null) {
                visibleChildName = "0";
            }
            currentTimer = int.parse(visibleChildName);
        });

        timers[0] = new PTimer(width, height, 0);
        timerStack.add_titled(timers[0].timer_view(), currentTimer.to_string(), "Timer");
        mainView.pack_start(stackSwitcher, true, true, 0);

        mainView.pack_start(timerStack, false, false, 0);
        mainView.show_all();
        add(mainView);
    }

    public override bool key_press_event (Gdk.EventKey event) {
        timers[currentTimer].im.keypress(event);
        return Gdk.EVENT_PROPAGATE;
    }
} // end class

} // end namespace