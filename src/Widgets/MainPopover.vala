using Gtk;

namespace PatternTimer.Widgets {

    public class MainPopover : Budgie.Popover {
        private Stack? stack = null;
        private StackSwitcher? stackSwitcher = null;
        //private Notebook? notebook = null;
        private Box? mainView = null;
        private Box? header = null;
        private Label? headerLabel = null;
        private Button? headerNew_b = null;
        private PTimer[] timers = new PTimer[3];
        private int currentTimer = 0;

        public MainPopover(Widget? window_parent) {
            Object(relative_to: window_parent);
            this.set_size_request(300,200);
            add_events(Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.BUTTON_RELEASE_MASK);
            add_events(Gdk.EventMask.KEY_PRESS_MASK | Gdk.EventMask.KEY_RELEASE_MASK);
            
            stack = new Stack();
            stack.set_transition_type(StackTransitionType.SLIDE_LEFT_RIGHT);
            stackSwitcher = new StackSwitcher();
            stackSwitcher.stack = stack;

            mainView = new Box(Orientation.VERTICAL, 0);
            mainView.set_homogeneous(false);

            header = new Box(Orientation.HORIZONTAL, 0);
            header.height_request = 32;
            //Header.get_style_context().add_class("trash-applet-header");
            headerLabel = new Label("Timer!");
            
            header.pack_start(headerLabel, true, true, 0);
            headerNew_b = new Button.from_icon_name("tab-new-symbolic", IconSize.MENU);
            headerNew_b.clicked.connect(() => {
                if (currentTimer == 2) {
                    return;
                } else {
                    timers[currentTimer].set_inactive();
                    stdout.printf("toggled %d", currentTimer);

                    currentTimer++;
                    if (currentTimer == 1) {
                        mainView.pack_start(stackSwitcher, true, true, 0);
                        mainView.reorder_child(stackSwitcher, 1);
                    }
                    timers[currentTimer] = new PTimer("43:21", "43:22", 1);
                    stack.add_titled(timers[currentTimer].timer_view(), currentTimer.to_string(), currentTimer.to_string());
                    mainView.show_all();
                    stack.set_visible_child_name(currentTimer.to_string());
                }
            });
            header.pack_end(headerNew_b, false, false, 0);
            //header.show_all();
            mainView.pack_start(header, false, false, 0);
            
            timers[0] = new PTimer("12:34", "12:33", 0);
            stack.add_titled(timers[0].timer_view(), currentTimer.to_string(), currentTimer.to_string());

            //mainView.pack_start(stackSwitcher, true, true, 0);
            mainView.pack_start(stack, false, false, 0);
            mainView.show_all();
            add(mainView);
        }

        public void set_page(string page) {
            //this.stack.set_visible_child_name(page);
        }

        public override bool key_press_event (Gdk.EventKey event) {
            timers[currentTimer].set_display_text(event.str);
            return Gdk.EVENT_PROPAGATE;
        }
    } // End class
} // End namespace