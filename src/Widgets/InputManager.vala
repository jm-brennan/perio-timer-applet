using GLib;

namespace PatternTimer.Widgets {
enum KeyCode {
    ENTER = 65293,
    SPACE = 32
}


public class InputManager {
    //private string displayString = "";
    private string inputString = "";
    private PTimer? timer = null;

    public InputManager(PTimer pt) {
        this.timer = pt;
    }

    public void send_key(string key) {
        inputString += key;
        timer.set_display_text(inputString);
    }


}


}