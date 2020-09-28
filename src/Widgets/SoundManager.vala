using Gtk;
using GLib;
using PerioTimer.Widgets;

namespace PerioTimer {

public class SoundManager {
    private Stack? pageStack = null;
    private string soundPath = "";
    private Box? view = null;
    private Box? soundList = null;
    private const string SOUND_DIR = "/usr/share/sounds/perio-timer";

    public SoundManager(Stack pageStack) {
        this.pageStack = pageStack;

        view = new Box(Orientation.VERTICAL, 0);
        view.set_homogeneous(false);
        var header = new HeaderBar();
        var title = new Label("Sounds");
        title.get_style_context().add_class("ptimer-title");
        header.set_custom_title(title);

        var back = new Button.from_icon_name("go-previous-symbolic", IconSize.MENU);
        back.clicked.connect(() => {
            pageStack.set_visible_child_name("main");
        });
        header.pack_start(back);
        
        // making soundList stuff now so that it will be scoped for making refresh button
        var scroll = new ScrolledWindow(null, null);
        var viewport = new Viewport(null, null);
        soundList = new Box(Orientation.VERTICAL, 5);
        // @TODO load from defaults
        soundPath = "/usr/share/sounds/perio-timer/Toaster Oven.oga";
        build_sound_list();

        var refresh = new Button.from_icon_name("view-refresh-symbolic", IconSize.MENU);
        refresh.set_tooltip_text("Refresh Files");
        refresh.clicked.connect(() => {
            viewport.remove(soundList);
            soundList = new Box(Orientation.VERTICAL, 5);
            build_sound_list();
            viewport.add(soundList);
            view.show_all();
        });
        header.pack_end(refresh);

        view.pack_start(header, false, false, 0);
        
        viewport.add(soundList);
        scroll.add(viewport);
        view.pack_start(scroll);
    }

    private void build_sound_list() {
        var folderMessage = new Label("");
        folderMessage.set_line_wrap(true);
        folderMessage.set_justify(Justification.CENTER);
        folderMessage.get_style_context().add_class("ptimer-folder-message");
        soundList.pack_end(folderMessage, false, false);
        
        Dir dir;
        try {
            dir = Dir.open(SOUND_DIR, 0);
            folderMessage.set_label("Loading from:\n%s".printf(SOUND_DIR));
        } catch (FileError e) {
            folderMessage.set_label("Could not load sound folder:\n%s".printf(SOUND_DIR));
            return;
        }

        var radioButtonGroup = new RadioButton(null); // wont ever use this one but it will define the group
        string? filename = dir.read_name();
        while (filename != null) {
            var filepath = Path.build_filename(SOUND_DIR, filename);
            var soundBox = new Box(Orientation.HORIZONTAL, 0);
            
            var playIcon = new Image.from_icon_name("media-playback-start-symbolic", IconSize.MENU);
            var playBut = new Button();
            playBut.set_tooltip_text("Play Sound");
            playBut.set_image(playIcon);
            playBut.set_data("filePath", filepath);
            playBut.clicked.connect(() => {
                play_sound(false, playBut.get_data("filePath"));
            });

            var soundName = new Label(filename.split(".")[0]);
            soundName.get_style_context().add_class("ptimer-text");
            soundName.set_line_wrap(true);
            var radio = new RadioButton.from_widget(radioButtonGroup);
            radio.set_data("file", filepath);
            if (filepath == soundPath) radio.set_active(true);
            radio.toggled.connect(() => {
                if (radio.get_active()) {
                    soundPath = radio.get_data("file");
                }
            });

            soundBox.pack_start(playBut, false, false, 3);
            soundBox.pack_start(soundName, false, false, 3);
            soundBox.pack_end(radio, false, false, 3);
            soundList.pack_start(soundBox);

            filename = dir.read_name();
        }
    }

    public void play_sound(bool useStored, string? file) {
        var fileToPlay = this.soundPath;
        if (!useStored) fileToPlay = file;
        var cmd = "paplay '" + fileToPlay + "'";

        try {
            Process.spawn_command_line_async(cmd);
        } catch (GLib.SpawnError e) {
            stderr.printf("Error playing sound: %s\n", e.message);
            return;
        }
    }

    public Box get_view() {
        return view;
    }
}

} // end namespace