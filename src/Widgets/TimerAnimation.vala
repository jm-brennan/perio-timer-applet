
namespace PatternTimer.Widgets {

public class TimerAnimation : Gtk.Widget {
    private int64 degree = -90;
    private int64 timerLength = 30000000;
    private const int linewidth = 10;
    private const int border = 15;
    private int width;
    private int height;
    private int64 time;
    private int64 startTime;
    private bool active = false;
    private int update_interval = 60;
    
    // @TODO temporary way of doing colors
    private double[] c0 = new double[3];
    private double[] c1 = new double[3];
    private int switchDegree;

    public TimerAnimation(int width, int height, int colorset) {
        set_has_window (false);
        this.width = width;
        this.height = height;
        startTime = GLib.get_monotonic_time();

        // @TODO temporary way of doing colors
        if (colorset == 0) {
            c0[0] = 0.8;
            c0[1] = 0.324;
            c0[2] = 0.203;

            c1[0] = 0.0898;
            c1[1] = 0.742;
            c1[2] = 0.73;
        } else if (colorset == 1) {
            c0[0] = 0.367;
            c0[1] = 0.691;
            c0[2] = 0.746;

            c1[0] = 0.953;
            c1[1] = 0.875;
            c1[2] = 0.3;
        }
        switchDegree = GLib.Random.int_range(-20,60);
    }

    private bool update () {
        if (active) {
            this.time = GLib.get_monotonic_time();
            redraw_canvas();
            return true;
        } else {
            return false;
        }
    }

    private void redraw_canvas() {
        var window = get_window();
        if (null == window) {
            return;
        }

        var region = window.get_clip_region();
        // redraw the cairo canvas completely by exposing it
        window.invalidate_region(region, true);
        window.process_updates(true);
    }

    public override bool draw(Cairo.Context cr) {
        if (this.active) {
            degree--;
        }
        
        double xc = width / 2;
        double yc = height / 2;
        double radius = (width / 2) - border;

        cr.set_line_width(12.0);
        cr.set_source_rgb(c0[0], c0[1], c0[2]);
        
        if (degree >= (-359 - switchDegree)) {
            cr.arc(xc, yc, radius, -1*switchDegree * (Math.PI/180.0), degree * (Math.PI/180.0));
            cr.stroke();

            cr.set_source_rgb(c1[0], c1[1], c1[2]);
            cr.arc(xc, yc, radius, -90 * (Math.PI/180.0), -1*switchDegree * (Math.PI/180.0));
        } else {
            cr.set_source_rgb(c1[0], c1[1], c1[2]);
            cr.arc(xc, yc, radius, -90 * (Math.PI/180.0), degree * (Math.PI/180.0));
        }
        
        if (degree <= -450) {
            degree = -90;
        }
        cr.stroke();
        return true;
    }
    
    public void set_inactive() { active = false; }

    public void set_active() { active = true; Timeout.add(update_interval, update); }
}

} // end namespace