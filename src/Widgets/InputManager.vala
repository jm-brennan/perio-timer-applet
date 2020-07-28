using GLib;

namespace PerioTimer.Widgets {

enum KeyCode {
    DELETE = 65535,
    RIGHT  = 65363,
    LEFT   = 65361,
    ENTER  = 65293,
    TAB    = 65289,
    BACK   = 65288,
    COLON  = 58,
    SPACE  = 32,
    m = 109,
    n = 110,
    r = 114,
    v = 118
}


public class InputManager {
    private string inputString = "";
    private int allowedInputLength = 4;
    private PTimer? timer = null;
    private MainPopover? mp = null;
    private bool doSeconds = false;

    public InputManager(PTimer pt, MainPopover mp) {
        this.timer = pt;
        this.mp = mp;
    }

    public void keypress(Gdk.EventKey event) {
        Gdk.ModifierType modifiers = Gtk.accelerator_get_default_mod_mask();
        switch (event.keyval) {
            case KeyCode.DELETE:
                timer.delete_stage();
                break;
            case KeyCode.RIGHT:
                if ((event.state & modifiers) == Gdk.ModifierType.CONTROL_MASK) {
                    mp.switch_timer(1);
                } else {
                    timer.switch_stage_editing(1);
                }
                break;
            case KeyCode.LEFT:
                if ((event.state & modifiers) == Gdk.ModifierType.CONTROL_MASK) {
                    mp.switch_timer(-1);
                } else {
                    timer.switch_stage_editing(-1);
                }
                break;
            case KeyCode.ENTER:
                timer.start();
                break;
            case KeyCode.TAB:
                // so that trying to alt-tab out of the applet doesn't make a new stage
                // MOD1_MASK is (usually) alt according to docs
                if ((event.state & modifiers) == Gdk.ModifierType.MOD1_MASK) break;
                add_stage();
                break;
            case KeyCode.BACK:
                backspace();
                break;
            case KeyCode.COLON:
                toggle_seconds();
                timer.toggle_seconds();
                timer.set_input_time(inputString);
                break;
            case KeyCode.SPACE:
                timer.toggle_active();
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
            if (keyval >= 65 && keyval <= 90) keyval += 32;
            
            switch (keyval) {
                case KeyCode.m:
                    timer.toggle_volume();
                    break;
                case KeyCode.n:
                    timer.toggle_notification();
                    break;
                case KeyCode.r:
                    timer.toggle_repeat();
                    break;
                case KeyCode.v:
                    timer.toggle_volume();
                    break;
            }
        }
        
    }

    public void toggle_seconds() {
        doSeconds = !doSeconds;
        if (doSeconds) {
            allowedInputLength = 6;
        } else {
            allowedInputLength = 4;
            if (inputString.length > allowedInputLength) {
                inputString = inputString.substring(0, allowedInputLength);
            }
        }
        
    }
    
    private void backspace() {
        inputString = inputString.substring(0, inputString.length - 1);
        timer.set_input_time(inputString);
    }

    private void add_stage() {
        timer.add_stage();
    }

    public void set_inputString(string inputString) { this.inputString = inputString; }
}

} // end namespace