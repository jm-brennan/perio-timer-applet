
namespace PatternTimer.Widgets {

public class TimerAnimation : Gtk.Widget {
    private int64 degree = -90;
    private int64 timerLength = 30000000;
    private const int linewidth = 10;
    private int64 time;
    private int64 startTime;

/*      public TimerAnimation(PatternTimer.Timer[]) {

    }  */
    public TimerAnimation(Gtk.Widget? window_parent) {
        //Object(relative_to: window_parent);
        print("constructed");
        set_has_window (false);
        startTime = GLib.get_monotonic_time();
        //this.set_size_request(150,300);
        update();
        Timeout.add(1000, update);
    }

    private bool update () {
        print("update");
        this.time = GLib.get_monotonic_time();
        redraw_canvas();
        return true;
    }

    private void redraw_canvas() {
        var window = get_window();
        if (null == window) {
            print("no window");
            return;
        }

        var region = window.get_clip_region();
        // redraw the cairo canvas completely by exposing it
        window.invalidate_region(region, true);
        window.process_updates(true);
    }

    public override bool draw(Cairo.Context cr) {
        print("drawing");
        double xc = 150.0;
	    double yc = 125.0;
	    double radius = 100.0;
        
        cr.set_source_rgba(1, 0.2, 0.2, 0.7);
        cr.set_line_width(10.0);
        //double t = double(GLib.get_monotonic_time());
        //stdout.printf("%lld\n", t);
        //int64 diff = (this.time - this.startTime);
        //double perc = double(diff / timerLength);
        //stdout.printf("%lld\n", diff);
        //degree = -90 - (((this.time - this.startTime) / timerLength) * 360);
        
        //cr.arc(xc, yc, radius, 0, 180);
        cr.arc(xc, yc, radius, -90 * (Math.PI/180.0), degree * (Math.PI/180.0));
        degree--;
        if (degree >= 360) {
            degree = 0;
        }
        cr.stroke();

        return true;
    }
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