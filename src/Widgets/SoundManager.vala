using Gtk;
using GLib;
using PerioTimer.Widgets;

namespace PerioTimer {

public class SoundManager {
    private Stack? pageStack = null;
    private string soundPath = "";
    private Box? view = null;

    public SoundManager(Stack pageStack) {
        this.pageStack = pageStack;

        soundPath = "/usr/share/sounds/freedesktop/stereo/complete.oga";
        
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
        view.pack_start(header, false, false, 0);

        string[] soundList = {soundPath};
        var radioButtonGroup = new RadioButton(null);
        for (int i = 0; i < soundList.length; i++) {
            var soundBox = new Box(Orientation.HORIZONTAL, 0);
            
            var playIcon = new Image.from_icon_name("media-playback-start-symbolic", IconSize.MENU);
            var playBut = new Button();
            playBut.set_tooltip_text("Play Sound");
            playBut.set_image(playIcon);
            playBut.set_data("filePath", soundList[i]);
            playBut.clicked.connect(() => {
                play_sound(playBut.get_data("filePath"));
            });

            var soundDirs = soundList[i].split("/");
            var soundName = new Label(soundDirs[soundDirs.length - 1].split(".")[0]);
            var radio = new RadioButton.from_widget(radioButtonGroup);

            soundBox.pack_start(playBut, false, false, 0);
            soundBox.pack_start(soundName, false, false, 0);
            soundBox.pack_end(radio, false, false, 0);
            view.pack_start(soundBox);
        }
    }

    public void play_sound(string filePath = "test") {
        var cmd = "paplay " + filePath;

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
}