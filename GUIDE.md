# Premise
Perio Timer introduces the notion of stages within a timer. A simple 5 minute timer would consist of a single stage that runs and then stops 5 minutes later as you would expect of any other timer application. However, more complex timer behavior can be created by using stages that is not easily done with traditional timers. A timer with two stages, one 30 minutes and one 5 minutes will run for a total of 35 minutes, with a notification after each stage's completion. A timer like that could then be set to repeat such that when the two stages and two notifications have finished, they will automatically start again. In this way, you can make timers to deal with more complex tasks like pomodoro workflows or trying to remind yourself to stretch or look away from your screen at regular intervals.


# Controls
Keypresses will automatically be captured, no need to click on any text boxes. All these controls have a gui alternative (except toggling show seconds), and the buttons that do these things all have tooltips. Clicking within the bounding box of the circle with toggle play/pause as well.


## Editing    
Add a new stage:</br>
&emsp;<kbd>Tab</kbd>

Add a new timer:</br>
&emsp;<kbd>Ctrl</kbd> + <kbd>Tab</kbd>

Delete a stage:</br>
&emsp;<kbd>Del</kbd>

Delete a timer:</br>
&emsp;<kbd>Ctrl</kbd> + <kbd>Del</kbd>

Switch stage editing:</br>
&emsp;<kbd>&#8592;</kbd> / <kbd>&#8594;</kbd>

Switch timer viewing:</br>
&emsp;<kbd>Ctrl</kbd> + <kbd>&#8592;</kbd> / <kbd>&#8594;</kbd>

Toggle show seconds:</br>
&emsp;<kbd>:</kbd>

Start timer:</br>
&emsp;<kbd>Enter</kbd>


## Running
Play/Pause (after started):</br>
&emsp;<kbd>Space</kbd>

Skip to next stage:</br>
&emsp;<kbd>Alt</kbd> + <kbd>&#8592;</kbd> / <kbd>&#8594;</kbd>


## Timer Behavior
Toggle mute:</br>
&emsp;<kbd>m</kbd>

Toggle repeat:</br>
&emsp;<kbd>r</kbd>

Toggle notification:</br>
&emsp;<kbd>n</kbd>
