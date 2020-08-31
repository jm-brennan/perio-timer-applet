using Gtk;
using GLib;

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

public class ColorManager : Budgie.Popover {
    private ColorTheme[] themes;
    private int currentTheme = 0; // @TODO load default theme from user preferences
    private int numThemes;
    private string cssStyle = "";

    public ColorManager() {
        load_color_file();
        generate_css();
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

}


}