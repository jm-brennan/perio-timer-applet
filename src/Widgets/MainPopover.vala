using Gtk;

namespace PatternTimer.Widgets {

    public class MainPopover : Budgie.Popover {
        private Stack? stack = null;
        private Box? main_view = null;
        private Box? title_header = null;
        private Label? title_label = null;
        public TextView? text_view = null;
        public string display_text = "Default";

        public MainPopover(Widget? window_parent) {
            Object(relative_to: window_parent);
            
            // is there a way to set the width of the popover?
            // width_request = 300;
            add_events (Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.BUTTON_RELEASE_MASK);
            add_events (Gdk.EventMask.KEY_PRESS_MASK | Gdk.EventMask.KEY_RELEASE_MASK);
            
            this.stack = new Stack();
            stack.set_transition_type(StackTransitionType.SLIDE_LEFT_RIGHT);
            /* Views */
            this.main_view = new Box(Orientation.VERTICAL, 0);

            title_header = new Box(Orientation.HORIZONTAL, 0);
            title_header.height_request = 32;
            //title_header.get_style_context().add_class("trash-applet-header");
            title_label = new Label("Timer!");
            title_header.pack_start(title_label, true, true, 0);

            main_view.pack_start(title_header, false, false, 0);
            
            //var buffer = new Gtk.TextBuffer (null);
            //text_view = new TextView.with_buffer(buffer);
            
            text_view = new TextView();
            text_view.buffer.text = display_text;
            text_view.cursor_visible = false;
            main_view.pack_start(text_view, false, false, 0);


            stack.add_named(main_view, "main");

            stack.show_all();


            add(stack);
        }

        public void set_page(string page) {
            this.stack.set_visible_child_name(page);
        }
        public override bool key_press_event (Gdk.EventKey event) {
            text_view.buffer.text = event.keyval.to_string();
            print(event.keyval.to_string());
            return true;
        }
    } // End class
} // End namespace