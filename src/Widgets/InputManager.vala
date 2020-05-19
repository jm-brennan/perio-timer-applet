using GLib;

namespace PatternTimer.Widgets {
enum KeyCode {
    ENTER = 65293,
    SPACE = 32,
    BACK = 65288,
    TAB = 65289,
    COLON = 58,
    M = 109,
    R = 114
}


public class InputManager {
    //private string displayString = "";
    private string inputString = "";
    private PTimer? timer = null;
    private bool doSeconds = false;

    public InputManager(PTimer pt) {
        this.timer = pt;
    }

    public void send_key(uint keyval, string key) {
        if (keyval >= 48 && keyval <= 57) {
            if (inputString.length < 4) {
                inputString += key;
                timer.set_display_text(inputString);
            }
        } else {
            if (keyval >= 65 && keyval <= 90) {
                keyval += 32;
            }
            switch (keyval) {
                case KeyCode.COLON:
                    doSeconds = !doSeconds;
                    break;
                case KeyCode.R:
                    timer.toggle_repeat();
                    break;
                case KeyCode.M:
                    timer.toggle_mute();
                    break;
            }
        }
    }

    public void backspace() {
        inputString = inputString.substring(0, inputString.length - 1);
        timer.set_display_text(inputString);
    }

}


}