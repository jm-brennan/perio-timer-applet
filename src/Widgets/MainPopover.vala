using Gtk;

namespace PerioTimer.Widgets {

public class MainPopover : Budgie.Popover {
    private Stack? pageStack = null;
    private ColorManager? colors = null;
    //private SettingsManager? settings = null;

    private Stack? timerStack = null;
    private StackSwitcher? stackSwitcher = null;
    private Box? mainView = null;
    private HeaderBar? header = null;
    private Label? headerTitle = null;
    private Button? headerAddTimer = null;
    private Button? headerDeleteTimer = null;
    private int width;
    private int height;

    private PTimer[] timers = new PTimer[3];
    private int currentTimer = 0;
    private int numTimers = 1;
    private const int MAX_TIMERS = 4;

    // The main popover consists of a vertical box that contains a header, a stack
    // switcher, and a stack of PTimers. It manages which timer is being shown and 
    // the creation/deletion of new timers and switching between them
    public MainPopover(Widget? window_parent, int width, int height) {
        Object(relative_to: window_parent);
        this.width = width;
        this.height = height;
        this.set_resizable(false);
        add_events(Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.BUTTON_RELEASE_MASK);
        add_events(Gdk.EventMask.KEY_PRESS_MASK | Gdk.EventMask.KEY_RELEASE_MASK);
        
        pageStack = new Stack();
        pageStack.set_transition_type(StackTransitionType.SLIDE_LEFT_RIGHT);
                
        mainView = new Box(Orientation.VERTICAL, 0);
        mainView.set_homogeneous(false);

        header = new HeaderBar();
        headerTitle = new Label("Perio Timer");
        headerTitle.get_style_context().add_class("ptimer-title");
        header.set_custom_title(headerTitle);
        
        var headerSettings = new MenuButton();
        headerSettings.set_tooltip_text("Show Menu");
        var menuImage = new Image.from_icon_name("open-menu-symbolic", IconSize.MENU);
        headerSettings.set_image(menuImage);

        var menu = new Gtk.Menu();
        var colorLink = new Gtk.MenuItem.with_label("Colors");
        var helpLink = new Gtk.MenuItem.with_label("Help");
        colorLink.activate.connect(() => {
            pageStack.set_visible_child_name("colors");
        });
        menu.add(colorLink);
        menu.add(helpLink);
        menu.show_all();
        headerSettings.set_popup(menu);
        
        headerAddTimer = new Button.from_icon_name("tab-new-symbolic", IconSize.MENU);
        headerAddTimer.clicked.connect(this.add_timer);
        headerAddTimer.set_tooltip_text("New Timer");
        
        headerDeleteTimer = new Button.from_icon_name("window-close-symbolic", IconSize.MENU);
        headerDeleteTimer.clicked.connect(this.delete_timer);
        headerDeleteTimer.set_tooltip_text("Delete Timer");
        
        header.pack_start(headerSettings);
        header.pack_end(headerAddTimer);
        header.pack_end(headerDeleteTimer);

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

        colors = new ColorManager(pageStack, timers);
        timers[0] = new PTimer(this, colors, width, height);
        timerStack.add_titled(timers[0].get_view(), currentTimer.to_string(), "Timer 0");
        
        mainView.pack_start(header, false, false, 0);
        mainView.pack_start(timerStack, false, false, 0);

        pageStack.add_named(mainView, "main");
        pageStack.add_named(colors.get_view(), "colors");
        pageStack.set_visible_child_name("main");
        pageStack.show_all();

        add(pageStack);
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
        timers[currentTimer] = new PTimer(this, colors, width, height);
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
            timers[currentTimer] = new PTimer(this, colors, width, height);
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