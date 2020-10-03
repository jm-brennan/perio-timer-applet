using Gtk;
using GLib;
using PerioTimer.Widgets;

namespace PerioTimer {

public struct Color {
    public uint8 r;
    public uint8 g;
    public uint8 b;
}

public struct ColorTheme {
    string name;
    Color[] colors;
}

public class ColorManager {
    private Stack? pageStack = null;
    private ColorTheme[] themes;
    private int currentTheme = 0; // @TODO load default theme from user preferences
    private int numThemes;
    private string cssStyle = "";
    private Box? view = null;
    private PTimer[] timers = null;

    public ColorManager(Stack pageStack, PTimer[] timers) {
        this.pageStack = pageStack;
        this.timers = timers;
        load_color_file();
        generate_css();
        view = new Box(Orientation.VERTICAL, 0);
        view.set_hexpand(false);
        var header = new HeaderBar();
        var title = new Label("Colors");
        title.get_style_context().add_class("ptimer-title");
        header.set_custom_title(title);
        var back = new Button.from_icon_name("go-previous-symbolic", IconSize.MENU);
        back.clicked.connect(() => {
            pageStack.set_visible_child_name("main");
        });
        header.pack_start(back);
        view.pack_start(header, false, false, 0);

        var scroll = new ScrolledWindow(null, null);
        var viewport = new Viewport(null, null);
        var colorList = new Box(Orientation.VERTICAL, 0);

        var radioButtonGroup = new RadioButton(null); // wont ever use this one but it will define the group
        
        for (int i = 0; i < numThemes; i++) {
            var themeEventBox = new EventBox();
            var themeBox = new Box(Orientation.VERTICAL, 0);
            var nameBox = new Box(Orientation.HORIZONTAL, 0);
            var themeName = new Label(themes[i].name);
            themeName.set_halign(Align.START);
            themeName.get_style_context().add_class("ptimer-text");
            var radio = new RadioButton.from_widget(radioButtonGroup);
            radio.set_data("themeIndex", i);
            if (i == currentTheme) radio.set_active(true);
            radio.toggled.connect(() => {
                if (radio.get_active()) {
                    currentTheme = radio.get_data("themeIndex");
                    generate_css();
                    for (int t = 0; t < 4; t++) {
                        if (timers[t] != null) timers[t].update_theme();
                    }
                }
            });
            themeEventBox.button_press_event.connect(() => {
                radio.set_active(true);
                return false;
            });
            var swatches = new Box(Orientation.HORIZONTAL, 0);
            swatches.set_hexpand(false);
            for (int j = 0; j < 4; j++) {
                var but = new Button();
                but.set_size_request(-1,30);
                add_css_swatch_class(i, j);
                but.get_style_context().add_class("ptimer-swatch-%s".printf(themes[i].name + j.to_string()));
                but.set_sensitive(false);
                swatches.pack_start(but, true, true, 3);
            }
            nameBox.pack_start(themeName, false, false, 3);
            nameBox.pack_end(radio, false, false, 3);
            // Really should be wrapped around the whole themeBox, but the swatches, because they
            // are buttons, punch holes in the eventBox. Its dumb because set_sensitive(false) makes
            // the buttons unable to connect to the clicked event, but it still captures the click
            themeEventBox.add(nameBox);
            themeBox.pack_start(themeEventBox, false, false, 2);
            themeBox.pack_start(swatches, false, false, 2);
            colorList.pack_start(themeBox, false, false, 10);
        }

        viewport.add(colorList);
        scroll.add(viewport);
        view.pack_start(scroll);
        
        update_css();
    }

    public ColorTheme get_current_theme() {
        return themes[currentTheme];
    }

    private void load_color_file() {
        try {
            InputStream colorsFile = resources_open_stream("/data/colors/colors.json", ResourceLookupFlags.NONE);
            var parser = new Json.Parser();
            parser.load_from_stream(colorsFile);

            var root = parser.get_root().get_object();
            var colorThemes = root.get_array_member("color-themes");

            for (int i = 0; i < colorThemes.get_length(); i++) {
                var colorTheme = colorThemes.get_element(i).get_object();
                string themeName = colorTheme.get_string_member("name");
                
                var colorList = colorTheme.get_array_member("colors");
                Color[] themeColors = new Color[4];
                for (int j = 0; j < colorList.get_length(); j++) {
                    var color = colorList.get_element(j);
                    themeColors[j] = Color() { r = (uint8)color.get_array().get_int_element(0),
                                               g = (uint8)color.get_array().get_int_element(1), 
                                               b = (uint8)color.get_array().get_int_element(2)};
                }
                themes += ColorTheme() { name = themeName, colors = themeColors };
                numThemes++;
            }
        } catch (GLib.Error e) {
            // just run on default hardcoded color scheme if there was error in json
            Color[] defaultColors = { Color() {r = 242, g =  95, b =  92},
                                      Color() {r =   0, g = 253, b = 220},
                                      Color() {r = 255, g = 224, b = 102},
                                      Color() {r = 112, g = 193, b = 179}
                                    };
            themes = { ColorTheme() { name = "Default", colors = defaultColors } };
            numThemes = 1;
            warning("Error parsing JSON colors: %s\n", e.message);
        }
    }

    public void generate_css() {
        for (int i = 0; i < themes[currentTheme].colors.length; i++) {
            add_css_border_class(themes[currentTheme].name, i);
        }
        update_css();
    }

    private void add_css_border_class(string name, int index) {
        var newClass = """
            textview.ptimer-%s text {
                border-bottom-width: 3px;
                border-bottom-style: solid;
                border-bottom-color: rgb(%d, %d, %d);
            }
            """.printf(name + index.to_string(), 
                    themes[currentTheme].colors[index].r,
                    themes[currentTheme].colors[index].g,
                    themes[currentTheme].colors[index].b);
        cssStyle += newClass;
    }

    private void add_css_swatch_class(int themeIndex, int colorIndex) {
        var newClass = """
            button.ptimer-swatch-%s {
                background-color: rgb(%d, %d, %d);
            }
            """.printf(themes[themeIndex].name + colorIndex.to_string(),
                    themes[themeIndex].colors[colorIndex].r,
                    themes[themeIndex].colors[colorIndex].g,
                    themes[themeIndex].colors[colorIndex].b);
        cssStyle += newClass;
    }

    private void update_css() {
        try {
            var cssProvider = new CssProvider();
            cssProvider.load_from_data(cssStyle);
            StyleContext.add_provider_for_screen(
                Gdk.Screen.get_default(),
                cssProvider,
                STYLE_PROVIDER_PRIORITY_APPLICATION
            );
        } catch (Error e) {
            warning("Failed to parse css style : %s", e.message);
        }
    }
    
    public Box get_view() {
        return view;
    }

}

} // end namespace