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
    private int allowedInputLength = 4;
    private PTimer? timer = null;
    private bool doSeconds = false;

    private string seconds = "";
    private string minutes = "";
    private string hours = "";

    public InputManager(PTimer pt) {
        this.timer = pt;
    }

    public void send_key(uint keyval, string key) {
        if (keyval >= 48 && keyval <= 57) {
            if (inputString.length < allowedInputLength) {
                inputString += key;
            }
        } else {
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
                    break;
                case KeyCode.R:
                    timer.toggle_repeat();
                    break;
                case KeyCode.M:
                    timer.toggle_mute();
                    break;
            }
        }
        parse_and_update_time();
    }

    public void backspace() {
        inputString = inputString.substring(0, inputString.length - 1);
        parse_and_update_time();
    }

    public void parse_and_update_time() {
        string[] smh = new string[3];
        smh[0] = "";
        smh[1] = "";
        smh[2] = "";
        int smhIndex = 0;
        
        for (int i = 0; i < inputString.length; i++) {
            smhIndex = (int)Math.floorf((inputString.length - 1 - i) / 2.0f);
            if (!doSeconds) {
                smhIndex += 1;
            }
            smh[smhIndex] = smh[smhIndex] + inputString.substring(i, 1);
        }
        
        print(smh[2]);
        print("h ");
        print(smh[1]);
        print("m ");
        print(smh[0]);
        print("s\n");
        
        var index = 0;
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
        timer.set_display_text(displayString);

    }

}


}