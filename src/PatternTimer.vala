/*
 * This file is part of budgie-desktop
 *
 * Copyright © 2017-2019 Budgie Desktop Developers
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 */
 using PatternTimer.Widgets;

 namespace PatternTimer {
 
 public class Plugin : Budgie.Plugin, Peas.ExtensionBase {
     public Budgie.Applet get_panel_widget(string uuid) {
         return new Applet(uuid);
     }
 }
 
 public class Applet : Budgie.Applet {
     private Gtk.EventBox event_box;
     private MainPopover? popover = null;
     private unowned Budgie.PopoverManager? manager = null;
     public string uuid { public set; public get; }
 
     public Applet(string uuid) {
        Object(uuid: uuid);

        event_box = new Gtk.EventBox();
        Gtk.Image icon = new Gtk.Image.from_icon_name("alarm-symbolic", Gtk.IconSize.MENU);
        event_box.add(icon);

        popover = new MainPopover(event_box);

        this.add(event_box);
        this.show_all();

        event_box.button_press_event.connect((e)=> {
            if (e.button == 1) {
                if (popover.get_visible()) {
                    popover.hide();
                } else {
                    this.manager.show_popover(event_box);
                }
            } else {
                return Gdk.EVENT_PROPAGATE;
            }

            return Gdk.EVENT_STOP;
        });
     }
 
     public override void update_popovers(Budgie.PopoverManager? manager) {
         manager.register_popover(event_box, popover);
         this.manager = manager;
     }
 }
 
 } // End namespace
 
 
 
 [ModuleInit]
 public void peas_register_types(TypeModule module)
 {
     // boilerplate - all modules need this
     var objmodule = module as Peas.ObjectModule;
     objmodule.register_extension_type(typeof(Budgie.Plugin), typeof(PatternTimer.Plugin));
 }
 