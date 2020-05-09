using Gtk;

namespace PatternTimer.Widgets {

    public class MainPopover : Budgie.Popover {
        private Stack? stack = null;
        private Box? main_view = null;
        private Box? title_header = null;
        private Box? settings_view = null;
        private Label? title_label = null;
        public TextView? text_view = null;
        public string display_text = "12:34";
        private Image? volume_image = null;
        private bool clock_continue = false;
        private PTimer[] timers = new PTimer[3];
        private int currentTimer = 0;

        public MainPopover(Widget? window_parent) {
            Object(relative_to: window_parent);
            this.set_size_request(300,200);
            add_events (Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.BUTTON_RELEASE_MASK);
            add_events (Gdk.EventMask.KEY_PRESS_MASK | Gdk.EventMask.KEY_RELEASE_MASK);
            
            this.stack = new Stack();
            stack.set_transition_type(StackTransitionType.SLIDE_LEFT_RIGHT);
            /* Views */
            this.main_view = new Box(Orientation.VERTICAL, 0);
            main_view.set_homogeneous(false);

            title_header = new Box(Orientation.HORIZONTAL, 0);
            title_header.height_request = 32;
            //title_header.get_style_context().add_class("trash-applet-header");
            title_label = new Label("Timer!");
            title_header.pack_start(title_label, true, true, 0);

            main_view.pack_start(title_header, false, false, 0);
            

            /*  Overlay over = new Overlay();
            over.add_events(Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.BUTTON_RELEASE_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK);
            TimerAnimation ta = new TimerAnimation(this);
            over.button_press_event.connect((e) => {
                print("PRESS\n");
                print(e.x.to_string());
                print("\n");
                print(e.y.to_string());
                ta.toggle_state();
                this.clock_continue = !this.clock_continue;
                Timeout.add(1000, update);
                return true;
            });
            /*  over.button_release_event.connect((e) => {
                print("RELEASE\n");
                print(e.x.to_string());
                print("\n");
                print(e.y.to_string());
                return true;
            });
            over.leave_notify_event.connect(() => {
                print("LEFT");
                return true;
            });
            
            text_view = new TextView();
            text_view.set_size_request(150,300);
            text_view.set_top_margin(90);
            text_view.set_justification(Justification.CENTER);
            text_view.buffer.text = display_text;
            text_view.cursor_visible = false;
            text_view.set_editable(false);

            over.add(text_view);
            over.add_overlay(ta);

            main_view.pack_start(over, false, false, 0);
            
            this.settings_view = new Box(Orientation.HORIZONTAL, 0);
            ToggleButton repeat_butt = new ToggleButton();
            ToggleButton volume_butt = new ToggleButton();
            Image repeat_image = new Image.from_icon_name("media-playlist-repeat-symbolic", Gtk.IconSize.MENU);
            this.volume_image = new Image.from_icon_name("audio-volume-high-symbolic", Gtk.IconSize.MENU);
            repeat_butt.set_image(repeat_image);
            volume_butt.set_image(volume_image);
            volume_butt.toggled.connect(() => {
                if (volume_butt.get_active() == true) {
                    //volume_image = new Image.from_file("/home/jacob/projects/code/pattern-timer/applet/style/manual-mute-symbolic.svg");
                    volume_image = new Image.from_icon_name("audio-volume-low-symbolic", Gtk.IconSize.MENU);
                    volume_butt.set_image(volume_image);
                } else {
                    volume_image = new Image.from_icon_name("audio-volume-high-symbolic", Gtk.IconSize.MENU);
                    volume_butt.set_image(volume_image);
                }
            });

            settings_view.pack_start(repeat_butt, true, false, 0);
            settings_view.pack_start(volume_butt, true, false, 0);
            main_view.pack_start(settings_view, true, true, 10);  */
            timers[0] = new PTimer();
            main_view.pack_start(timers[0].timer_view(), false, false, 0);

            
            stack.add_named(main_view, "main");

            stack.show_all();

            add(stack);
            
        }

        /*  private bool update() {
            if (this.clock_continue) {
                if (this.text_view.buffer.text == "12:34") {
                    this.text_view.buffer.text = "12:35";
                } else {
                    this.text_view.buffer.text = "12:34";
                }
            }
            return this.clock_continue;
        }  */

        public void set_page(string page) {
            this.stack.set_visible_child_name(page);
        }
        public override bool key_press_event (Gdk.EventKey event) {
            timers[currentTimer].update_display(event.str);
            return Gdk.EVENT_PROPAGATE;
        }
    } // End class
} // End namespace