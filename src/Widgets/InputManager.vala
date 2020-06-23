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
                parse_and_update_time();
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
                    parse_and_update_time();
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
        parse_and_update_time();
    }

    public void parse_and_update_time() {
        string[] smh = new string[3];
        smh[0] = ""; // seconds
        smh[1] = ""; // minutes
        smh[2] = ""; // hours
        int smhIndex = 0;
        
        for (int i = 0; i < inputString.length; i++) {
            smhIndex = (int)Math.floorf((inputString.length - 1 - i) / 2.0f);
            if (!doSeconds) {
                smhIndex += 1;
            }
            smh[smhIndex] = smh[smhIndex] + inputString.substring(i, 1);
        }

        timer.set_input_time(int.parse(smh[2]), int.parse(smh[1]), int.parse(smh[0])); 
        
        /*  var index = 0;
        //var displayString = new StringBuilder();
        var displayString = "";
        for (int i = 1; i <= inputString.length; i++) {
            string s = inputString.substring(index, 1);
            displayString += s;
            if (i % 2 == 0 && i < inputString.length) {
                displayString += ":";
            }
            index++;
        }
        timer.set_display_text(displayString);  */

    }

}


}