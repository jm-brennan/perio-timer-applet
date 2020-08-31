using Gtk;
using GLib;
using PerioTimer.Widgets;
namespace PerioTimer {

public class Plugin : Budgie.Plugin, Peas.ExtensionBase {
    public Budgie.Applet get_panel_widget(string uuid) {
        return new Applet(uuid);
    }
}
 
public class Applet : Budgie.Applet {
    private EventBox event_box;
    private MainPopover? mainPopover = null;
    private ColorManager? colors = null;
    private unowned Budgie.PopoverManager? manager = null;
    public string uuid { public set; public get; }

    public Applet(string uuid) {
        Object(uuid: uuid);
        // @TODO i beleive this doesn't work because this applet is not its own gtk application
        // and will instead follow the rules set by the taskbar. Is there any way to enforce dark mode?
        //Settings.get_for_screen(Gdk.Screen.get_default()).set("gtk-application-prefer-dark-theme", true);
        
        // load css from gresource file to set general css stuff, but does not
        // handle the colors of the stages which is controlled by the ColorSettings
        var cssProvider = new CssProvider();
        cssProvider.load_from_resource("/data/style/style.css");
        StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            cssProvider,
            STYLE_PROVIDER_PRIORITY_APPLICATION
        );

        colors = new ColorManager();

        event_box = new EventBox();
        Image icon = new Image.from_icon_name("appointment-soon-symbolic", IconSize.MENU);
        event_box.add(icon);

        mainPopover = new MainPopover(event_box, 282, 300, colors);
        this.add(event_box);
        this.show_all();

        // clicking on applet icon in panel opens main popover
        event_box.button_press_event.connect((e)=> {
            if (e.button == 1) {
                if (mainPopover.get_visible()) {
                    mainPopover.hide();
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
        manager.register_popover(event_box, mainPopover);
        this.manager = manager;
    }
}
 
} // end namespace

// boilerplate - all applets need this
[ModuleInit]
public void peas_register_types(TypeModule module) {
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type(typeof(Budgie.Plugin), typeof(PerioTimer.Plugin));
}
