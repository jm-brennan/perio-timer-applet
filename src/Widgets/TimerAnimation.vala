
namespace PerioTimer.Widgets {

public class TimerAnimation : Gtk.Widget {
    private const int border = 15;
    private int width;
    private int height;
    private bool active = false;
    private bool needToDraw = true;
    
    private const int MIN_INTERVAL = 60; 
    // miliseconds per interval
    private int updateInterval = MIN_INTERVAL;
    // control quality of animation based on length of timer
    private const int UPDATES_PER_DEGREE = 10;

    private unowned Stage[] stages = null;
    private int64 totalTime = 0;
    private int numStages = 1;
    private double[] degreesPastLastUpdate = new double[4];

    public TimerAnimation(int width, int height, Stage[] stages) {
        set_has_window(false);
        this.width = width;
        this.height = height;
        this.stages = stages;

        set_inactive();
    }

    public void update_stages(int numStages) {
        this.numStages = numStages;
        totalTime = 0;
        for (int i = 0; i < numStages; i++) {
            totalTime += stages[i].time;
        }

        // set update interval such that there will be num UPDATES_PER_DEGREE
        int64 totalTimeMS = totalTime / 1000;
        int updateIntervalFromTime = (int)((float)(totalTimeMS / 360) / UPDATES_PER_DEGREE);
        updateInterval = int.max(MIN_INTERVAL, updateIntervalFromTime);

        redraw_canvas();
    }

    public void reset_stage(int stage) {
        degreesPastLastUpdate[stage] = 0.0;
    }

    private bool update() {
        if (!needToDraw) return false;
        if (active) redraw_canvas();
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
    }

    public override bool draw(Cairo.Context cr) {
        int xc = width / 2;
        int yc = height / 2;
        int radius = (width / 2) - border;
        cr.set_line_width(12.0);

        if (totalTime == 0 && !active) {
            // when nothing has been entered, still draw full circle
            cr.set_source_rgb(stages[0].color.r / (double)255, 
                              stages[0].color.g / (double)255, 
                              stages[0].color.b / (double)255);
            cr.arc(xc, yc, radius, -90 * Math.PI/180.0, 270 * Math.PI/180.0);
            cr.stroke();
        } else {
            double arcStart = 360.0;
            double arcEnd = 360.0;
            for (int i = 0; i < numStages; i++) {
                arcEnd = arcStart - (360.0 * (stages[i].time / (double)totalTime));
                if (stages[i].timeLeft > 0) {
                    cr.set_source_rgb(stages[i].color.r / (double)255, 
                                      stages[i].color.g / (double)255, 
                                      stages[i].color.b / (double)255);
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
        needToDraw = false;
        redraw_canvas();
    }

    public void set_active() {
        if (active) return;

        active = true;
        needToDraw = true;
        redraw_canvas();
        Timeout.add(updateInterval, update); 
    }

    public void set_need_to_draw(bool toDrawOrNotToDraw) {
        needToDraw = toDrawOrNotToDraw;
        if (needToDraw) {
            redraw_canvas();
            Timeout.add(updateInterval, update);
        }
    }
}

} // end namespace