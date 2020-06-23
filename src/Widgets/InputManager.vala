using GLib;

namespace PatternTimer.Widgets {
enum KeyCode {
    ENTER = 65293,
    SPACE = 32,
    BACK = 65288,
    TAB = 65289,
    COLON = 58,

    // these codes are for the lowercase version of these letters,
    // the convention of capitalized enum values is confusing here
    M = 109,
    N = 110,
    R = 114
}


public class InputManager {
    //private string displayString = "";
    private string inputString = "";
    private int allowedInputLength = 4;
    private PTimer? timer = null;
    private bool doSeconds = false;

    public InputManager(PTimer pt) {
        this.timer = pt;
    }

    public void send_key(uint keyval, string key) {
        // if keyval is numeric, send to time string
        // else process for keybindings
        if (keyval >= 48 && keyval <= 57) {
            if (inputString.length < allowedInputLength) {
                inputString += key;
                timer.set_input_time(inputString);
            }
        } else {
            // set to lowercase
            if (keyval >= 65 && keyval <= 90) {
                keyval += 32;
            }
            switch (keyval) {
                case KeyCode.COLON:
                    doSeconds = !doSeconds;
                    if (doSeconds) {
                        allowedInputLength = 6;
                    } else {
                        allowedInputLength = 4;
                        if (inputString.length > allowedInputLength) {
                            inputString = inputString.substring(0, allowedInputLength);
                        }
                    }
                    timer.toggle_seconds();
                    timer.set_input_time(inputString);
                    break;
                case KeyCode.M:
                    timer.toggle_volume();
                    break;
                case KeyCode.N:
                    timer.toggle_notification();
                    break;
                case KeyCode.R:
                    timer.toggle_repeat();
                    break;
            }
        }
        
    }

    public void backspace() {
        inputString = inputString.substring(0, inputString.length - 1);
        timer.set_input_time(inputString);
    }
}


}