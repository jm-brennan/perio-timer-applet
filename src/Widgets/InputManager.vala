using GLib;

namespace PerioTimer.Widgets {

enum KeyCode {
    RIGHT = 65363,
    LEFT  = 65361,
    ENTER = 65293,
    TAB   = 65289,
    BACK  = 65288,
    COLON = 58,
    SPACE = 32,
    m = 109,
    n = 110,
    r = 114
}


public class InputManager {
    private string inputString = "";
    private int allowedInputLength = 4;
    private PTimer? timer = null;
    private bool doSeconds = false;

    public InputManager(PTimer pt) {
        this.timer = pt;
    }

    public void keypress(Gdk.EventKey event) {
        switch (event.keyval) {
            case KeyCode.RIGHT:
                timer.switch_stage_editing(1);
                break;
            case KeyCode.LEFT:
                timer.switch_stage_editing(-1);
                break;
            case KeyCode.ENTER:
                timer.set_active();
                break;
            case KeyCode.SPACE:
                timer.toggle_active();
                break;
            case KeyCode.TAB:
                new_stage();
                break;
            case KeyCode.BACK:
                backspace();
                break;
            default:
                handle_regular_key(event.keyval, event.str);
                break;
        }
    }

    private void handle_regular_key(uint keyval, string key) {
        // if keyval is numeric, send to time string
        // else process for keybindings
        if (keyval >= 48 && keyval <= 57) {
            if (inputString.length < allowedInputLength) {
                inputString += key;
                timer.set_input_time(inputString);
            }
        } else {
            // set to lowercase ascii
            if (keyval >= 65 && keyval <= 90) { keyval += 32; }
            
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
                case KeyCode.m:
                    timer.toggle_volume();
                    break;
                case KeyCode.n:
                    timer.toggle_notification();
                    break;
                case KeyCode.r:
                    timer.toggle_repeat();
                    break;
            }
        }
        
    }
    
    private void backspace() {
        inputString = inputString.substring(0, inputString.length - 1);
        timer.set_input_time(inputString);
    }

    private void new_stage() {
        timer.new_stage();
        inputString = "";
        timer.set_input_time(inputString);
    } 
}

} // end namespace