
namespace PatternTimer.Widgets {

public class TimerAnimation : Gtk.Widget {
    private int64 degree = -90;
    private int64 timerLength = 30000000;
    private const int linewidth = 10;
    private int64 time;
    private int64 startTime;
    private bool active = false;
    private int update_interval = 60;
    
    // @temporary
    private double[] c0 = new double[3];
    private double[] c1 = new double[3];
    private int switchDegree;

    public TimerAnimation(int colorset) {
        set_has_window (false);
        startTime = GLib.get_monotonic_time();

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
        
        double xc = 150.0;
        double yc = 125.0;
        double radius = 105.0;
        
        cr.set_line_width(10.0);
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
        

        //double t = double(GLib.get_monotonic_time());
        //stdout.printf("%lld\n", t);
        //int64 diff = (this.time - this.startTime);
        //double perc = double(diff / timerLength);
        //stdout.printf("%lld\n", diff);
        //degree = -90 - (((this.time - this.startTime) / timerLength) * 360);
        
        //cr.arc(xc, yc, radius, 0, 180);
        //cr.arc(xc, yc, radius, -90 * (Math.PI/180.0), degree * (Math.PI/180.0));
        
        if (degree <= -450) {
            degree = -90;
        }
        cr.stroke();

        
        return true;
    }
    
    // I think its fine to just get rid of this, ideally the actuall timer
    // should just always be setting active or inactive
    /*  public void toggle_active() { 
        if (active) {
            active = false;
        } else {
            active = true;
            Timeout.add(update_interval, update);
        }
     }  */

    public void set_inactive() { active = false; }

    public void set_active() { active = true; Timeout.add(update_interval, update); }
}
}

/*  
    on_window_configure_event:
        if size is different:
            make new surface with new size
            redraw current surface on it
            set as current surface
        update stored sizes


    draw:
        while(update_signal):
            new, independent surface
            draw on it


    main:
        make thread that waits on update signal
        every 1/30 second:
            if not currently drawing
                send update
*/