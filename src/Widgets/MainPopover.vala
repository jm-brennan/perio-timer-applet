using Gtk;

namespace PatternTimer.Widgets {

    public class MainPopover : Budgie.Popover {
        private Stack? stack = null;
        private Box? main_view = null;
        private Box? title_header = null;
        private Label? title_label = null;

        public MainPopover(Widget? window_parent) {
            Object(relative_to: window_parent);
            
            // is there a way to set the width of the popover?
            // width_request = 300;

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
            /* End view creation */


            stack.add_named(main_view, "main");

            stack.show_all();


            add(stack);
        }

        public void set_page(string page) {
            this.stack.set_visible_child_name(page);
        }
    } // End class
} // End namespace