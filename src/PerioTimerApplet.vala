/*  
    Creates the app as a budgie applet, just following all the same conventions/boilerplate
    as the other applets that are shipped, specifically the Nightlight applet  
*/
using PerioTimer.Widgets;
namespace PerioTimer {

public class Plugin : Budgie.Plugin, Peas.ExtensionBase {
    public Budgie.Applet get_panel_widget(string uuid) {
        return new Applet(uuid);
    }
}
 
public class Applet : Budgie.Applet {
    private Gtk.EventBox event_box;
    private MainPopover? popover = null;
    private unowned Budgie.PopoverManager? manager = null;
    public string uuid { public set; public get; }

    public Applet(string uuid) {
        Object(uuid: uuid);
        Gtk.Settings.get_default().set("gtk-application-prefer-dark-theme", true);
        // "textview" handles the actual text, while "textview text" handles the appearance
        // of the textview widget. It does not make sense but thats apparently just how gtk works.
        // @TODO All css styling stuff should be in a file
        var style = """
                textview {
                    font-family: lato;
                    font-weight: 300;
                    letter-spacing: 3px;
                    font-size: 40px;
                }
                label.app_title {
                    font-family: lato;
                    font-size: 15px;
                    opacity: 0.75;
                }
                label.stage_name {
                    font-family: lato;
                    font-size: 15px;
                    opacity: 0.75;
                }
                textview.red text {
                    border-bottom-width: 3px;
                    border-bottom-style: solid;
                    border-bottom-color: #F25F5C;
                }
                textview.seagreen text {
                    border-bottom-width: 3px;
                    border-bottom-style: solid;
                    border-bottom-color: #00FDDC;
                }
                textview.yellow text {
                    border-bottom-width: 3px;
                    border-bottom-style: solid;
                    border-bottom-color: #FFE066;
                }
                textview.greensheen text {
                    border-bottom-width: 3px;
                    border-bottom-style: solid;
                    border-bottom-color: #70C1B3;
                }
            """;

        var css_provider = new Gtk.CssProvider();

        try {
            css_provider.load_from_data(style, -1);
        } catch (GLib.Error e) {
            warning ("Failed to parse css style : %s", e.message);
        }

        Gtk.StyleContext.add_provider_for_screen(
                Gdk.Screen.get_default (),
                css_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );

        event_box = new Gtk.EventBox();
        Gtk.Image icon = new Gtk.Image.from_icon_name("alarm-symbolic", Gtk.IconSize.MENU);
        event_box.add(icon);

        popover = new MainPopover(event_box, 282, 300);
        this.add(event_box);
        this.show_all();

        // clicking on applet icon in panel opens main popover
        event_box.button_press_event.connect((e)=> {
            if (e.button == 1) {
                if (popover.get_visible()) {
                    popover.hide();
                } else {
                    this.manager.show_popover(event_box);
                }
            } else {
                return Gdk.EVENT_PROPAGATE;
            }

            return Gdk.EVENT_STOP;
        });
    }

    public override void update_popovers(Budgie.PopoverManager? manager) {
        manager.register_popover(event_box, popover);
        this.manager = manager;
    }
}
 
} // end namespace

[ModuleInit]
public void peas_register_types(TypeModule module) {
    // boilerplate - all modules need this
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type(typeof(Budgie.Plugin), typeof(PerioTimer.Plugin));
}
