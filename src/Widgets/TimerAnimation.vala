
namespace PerioTimer.Widgets {

public struct Color {
    float r;
    float g;
    float b;
}


public class TimerAnimation : Gtk.Widget {
    private int64 degree = -90;
    private const int linewidth = 10;
    private const int border = 15;
    private int width;
    private int height;
    private int64 time;
    private int64 startTime;
    private bool active = false;
    private int update_interval = 60; // 60




    private unowned Stage[] stages = null;
    private int totalSeconds = 0;
    private int numStages = 1;
    private int[] secondsOfStages = new int[4];
    private int64[] lastUpdated = new int64[4];
    private float[] cummulativeDiff = new float[4];
    private Color[] colors = new Color[4];

    private int64 prevTime = 0;
    

    


    // @TODO temporary way of doing colors
    private double[] c0 = new double[3];
    private double[] c1 = new double[3];
    private int switchDegree;

    public TimerAnimation(int width, int height, int colorset, Stage* stages) {
        set_has_window (false);
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
        totalSeconds = 0;
        for (int i = 0; i < numStages; i++) {
            int currentSeconds = 0;
            currentSeconds += stages[i].seconds;
            currentSeconds += stages[i].minutes * 60;
            currentSeconds += stages[i].hours * 60 * 60;

            secondsOfStages[i] = currentSeconds;
            totalSeconds += currentSeconds;
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
        /*  if (this.active) {
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
        cr.stroke();  */
        
        /*  double xc = width / 2;
        double yc = height / 2;
        double radius = (width / 2) - border;

        cr.set_line_width(12.0);
        cr.set_source_rgb(c0[0], c0[1], c0[2]);
        cr.arc(xc, yc, radius, -65 * (Math.PI/180.0), -45 * (Math.PI/180.0));
        cr.stroke();  */
        double xc = width / 2;
        double yc = height / 2;
        double radius = (width / 2) - border;
        cr.set_line_width(12.0);

        if (numStages == 1 && !active) {
            cr.set_source_rgb(colors[0].r, colors[0].g, colors[0].b);
            cr.arc(xc, yc, radius, -90 * Math.PI/180.0, 270 * Math.PI/180.0);
            cr.stroke();
        } else {
            int64 dt = 0;
            int64 currentTime = GLib.get_monotonic_time();
            //stdout.printf("current time: %lld\n", currentTime);
            
            

            // @optimization
            // We know that only one of these is gonna change so we could
            // keep track of that and store their arcs until the timer gets to that stage
            float arcStart = 270.0f;
            float arcEnd = 270.0f;
            for (int i = 0; i < numStages; i++) {
                arcEnd = arcStart - (360 * (secondsOfStages[i] / (float)totalSeconds));
                if (stages[i].timeLeft > 0) {
                    cr.set_source_rgb(colors[i].r, colors[i].g, colors[i].b);
                    // @TODO decrement arcStart with stage progress here
                    if (stages[i].active) {
                        var tmp = 1.0f - stages[i].timeLeft / (float) stages[i].time;
                        //stdout.printf("removing since last pause: %f\n", tmp);
                        arcStart -= tmp;
                        // @TODO absolute values?
                        var degPerSec = (arcStart - arcEnd) / stages[i].time;
                        dt = currentTime - lastUpdated[i];
                        //stdout.printf("dt: %lld\n", dt);
                        
                        var tmp2 = (float)dt * degPerSec;
                        //stdout.printf("removing dt/time: %f\n", tmp2);
                        arcStart -= tmp2;
                        cummulativeDiff[i] += tmp2;
                    }
                    arcStart -= cummulativeDiff[i];
                    //stdout.printf("stage[%d] start: %f, end: %f\n", i, arcStart, arcEnd);
                    cr.arc(xc, yc, radius, arcEnd * Math.PI/180.0, arcStart * Math.PI/180.0);
                    cr.stroke();
                }
                arcStart = arcEnd;
                lastUpdated[i] = currentTime;
            }
            //stdout.printf("\n\n");
        }
        return true;
    }
    
    public void set_inactive() { 
        for (int i = 0; i < numStages; i++) {
            lastUpdated[i] = 0;
            cummulativeDiff[i] = 0;
        }   
        active = false; 
    }

    public void set_active() { 
        for (int i = 0; i < numStages; i++) {
            int64 currentTime = GLib.get_monotonic_time();
            if (lastUpdated[i] == 0) {
                lastUpdated[i] = currentTime;
            }
        }    
        active = true; 
        Timeout.add(update_interval, update); 
    }
}

} // end namespace