using Gtk;

namespace PerioTimer.Widgets {

public class MainPopover : Budgie.Popover {
    private Stack? pageStack = null;
    private ColorManager? colors = null;
    private SoundManager? sounds = null;
    private const string HELP_LINK = "https://github.com/jm-brennan/perio-timer-applet/blob/master/GUIDE.md";

    private Stack? timerStack = null;
    private StackSwitcher? stackSwitcher = null;
    private ScrolledWindow? stackSwitcherScroller = null;
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

    public MainPopover(Widget? window_parent, int width, int height) {
        Object(relative_to: window_parent);
        this.width = width;
        this.height = height;
        this.set_resizable(false);
        add_events(Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.BUTTON_RELEASE_MASK);
        add_events(Gdk.EventMask.KEY_PRESS_MASK | Gdk.EventMask.KEY_RELEASE_MASK);
        
        // Page stack shows either the main timer page or various settings pages
        pageStack = new Stack();
        pageStack.set_transition_type(StackTransitionType.SLIDE_LEFT_RIGHT);
                
        mainView = new Box(Orientation.VERTICAL, 0);
        mainView.set_homogeneous(false);

        // header holds menu and delete timer/add timer buttons
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
        var soundLink = new Gtk.MenuItem.with_label("Sounds");
        var helpLink = new Gtk.MenuItem.with_label("Help");
        colorLink.activate.connect(() => {
            pageStack.set_visible_child_name("colors");
        });
        soundLink.activate.connect(() => {
            pageStack.set_visible_child_name("sounds");
        });
        helpLink.activate.connect(() => {
            try {
                show_uri_on_window(null, HELP_LINK, Gdk.CURRENT_TIME);
            } catch (Error e) {
                warning("Failed to open link to help page: %s\n", e.message);
            }
        });
        menu.add(colorLink);
        menu.add(soundLink);
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
        mainView.pack_start(header, false, false, 0);

        timerStack = new Stack();
        timerStack.set_transition_type(StackTransitionType.SLIDE_LEFT_RIGHT);
        stackSwitcher = new StackSwitcher();
        stackSwitcher.stack = timerStack;
        stackSwitcher.set_homogeneous(true);
        stackSwitcher.get_style_context().add_class("ptimer");

        stackSwitcherScroller = new ScrolledWindow(null, null);
        stackSwitcherScroller.height_request = 30;
        var viewport = new Viewport(null, null);

        viewport.add(stackSwitcher);
        stackSwitcherScroller.add(viewport);

        timerStack.notify["visible-child"].connect(() => {
            // @TODO this is a temporary way of naming the stacks/setting which one is 
            // visible, will be changed when new naming technique is decided/implemented
            var visibleChild = timerStack.get_visible_child();
            for (int i = 0; i < numTimers; i++) {
                if (timers[i].get_view() == visibleChild) {
                    currentTimer = i;
                    return;
                }
            }
        });

        colors = new ColorManager(pageStack, timers);
        sounds = new SoundManager(pageStack);
        timers[0] = new PTimer(this, colors, sounds, width, height);
        timerStack.add_titled(timers[0].get_view(), currentTimer.to_string(), "Timer 0");
        
        mainView.pack_start(timerStack, false, false, 0);

        pageStack.add_named(mainView, "main");
        pageStack.add_named(colors.get_view(), "colors");
        pageStack.add_named(sounds.get_view(), "sounds");
        pageStack.set_visible_child_name("main");
        pageStack.show_all();

        add(pageStack);
    }

    public void add_timer() {
        if (numTimers == MAX_TIMERS) return;
        
        if (numTimers == 1) {
            mainView.pack_start(stackSwitcherScroller, true, true, 0);
            mainView.reorder_child(stackSwitcherScroller, 1);
        }
        currentTimer = numTimers;
        numTimers++;

        // @TODO make this less bad once new stack implemention is done
        timers[currentTimer] = new PTimer(this, colors, sounds, width, height);
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
            timers[currentTimer] = new PTimer(this, colors, sounds, width, height);
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
                mainView.remove(stackSwitcherScroller);
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