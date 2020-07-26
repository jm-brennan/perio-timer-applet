
namespace PerioTimer.Widgets {

public struct Color {
    float r;
    float g;
    float b;
}

public class TimerAnimation : Gtk.Widget {
    private const int border = 15;
    private int width;
    private int height;
    private bool active = false;
    private int update_interval = 60; // 60

    private unowned Stage[] stages = null;
    private int64 totalTime = 0;
    private int numStages = 1;
    private double[] degreesPastLastUpdate = new double[4];
    private Color[] colors = new Color[4];

    
    public TimerAnimation(int width, int height, int colorset, Stage* stages) {
        set_has_window(false);
        this.width = width;
        this.height = height;
        this.stages = (Stage[])stages;

        // @TODO temporary way of doing colors
        colors[0] = {0.949f, 0.3725f, 0.3608f};
        colors[1] = {0.0f, 0.9922f, 0.8627f};
        colors[2] = {1.0f, 0.8784f, 0.4f};
        colors[3] = {0.4392f, 0.7569f, 0.702f};

        set_inactive();
    }

    public void update_stages(int numStages) {
        this.numStages = numStages;
        totalTime = 0;
        for (int i = 0; i < numStages; i++) {
            totalTime += stages[i].time;
        }
        redraw_canvas();
    }

    private bool update () {
        if (active) { 
            redraw_canvas();
        }
        return active;
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
        int xc = width / 2;
        int yc = height / 2;
        int radius = (width / 2) - border;
        cr.set_line_width(12.0);

        if (totalTime == 0 && !active) {
            // when nothing has been entered, draw full circle
            cr.set_source_rgb(colors[0].r, colors[0].g, colors[0].b);
            cr.arc(xc, yc, radius, -90 * Math.PI/180.0, 270 * Math.PI/180.0);
            cr.stroke();
        } else {
            double arcStart = 360.0;
            double arcEnd = 360.0;
            for (int i = 0; i < numStages; i++) {
                arcEnd = arcStart - (360.0 * (stages[i].time / (double)totalTime));
                if (stages[i].timeLeft > 0) {
                    cr.set_source_rgb(colors[i].r, colors[i].g, colors[i].b);
                    // subtract off degrees known to have been covered, calculated
                    // as a porportion of how much time is left on the stage over the total time
                    // for that stage.
                    arcStart -= (1.0 - (stages[i].timeLeft / (double) stages[i].time)) * (stages[i].time / (double)totalTime) * 360;
                    
                    if (stages[i].active) {
                        double degPerSec = 360.0 / (double)totalTime;
                        int64 dt = GLib.get_monotonic_time() - stages[i].lastUpdated;   
                        degreesPastLastUpdate[i] = dt * degPerSec;
                    }
                    arcStart = double.max(arcStart - degreesPastLastUpdate[i], arcEnd);
                    
                    // the cairo arc has 12-o-clock as 270, 3-o-clock as 0. My implementation treats
                    // 12-o-clock as 360/0 so that i can assume the degrees are always decreasing,
                    // so just rotate by 90 degrees when actually
                    cr.arc(xc, yc, radius, (arcEnd - 90.0) * Math.PI/180.0, (arcStart - 90.0) * Math.PI/180.0);
                    cr.stroke();
                }
                arcStart = arcEnd;
            }
        }
        return true;
    }
    
    public void set_inactive() { 
        if (!active) return;
        for (int i = 0; i < numStages; i++) {
            degreesPastLastUpdate[i] = 0;
        }   
        active = false;
        redraw_canvas();
    }

    public void set_active() {  
        if (active) return;
        active = true;
        redraw_canvas();
        Timeout.add(update_interval, update); 
    }
}

} // end namespace