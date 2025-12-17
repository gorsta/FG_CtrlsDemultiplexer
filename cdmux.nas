##############################################################################
# This program is free software: you can redistribute it and/or modify it    #
# under the terms of the GNU General Public License as published by the      #
# Free Software Foundation, either version 2 of the License, or (at your     #
# option) any later version.                                                 #
#                                                                            #
# This program is distributed in the hope that it will be useful, but        #
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY #
# or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License    #
# for more details.                                                          #
#                                                                            #
# You should have received a copy of the GNU General Public License along    #
# with this program. If not, see <https://www.gnu.org/licenses/>.            #
##############################################################################

print('*** cdmux *** : loading cdmux');

var duration = 0.5; # popup duration
var longpress = 0.4; # button down duration required for "long" press

var fghome = getprop("/sim/fg-home");
var matchingpatternsfile = "dmuxmatchmodel.nas";
var shiftPropertyPath = "/devices/status/joysticks/modifier";


# 1st run of this code?
var init = !contains(caller(0)[0], "init");
# setlistener on 1st run only
var jslistener = func init and call(setlistener, arg);
        
##
# 'shift' input to the demultiplexer. shiftPropertyPath must match the 
# property path for the joystick shift button as specified joystick xml file
#
var shift = 0;
var m = props.globals.initNode(shiftPropertyPath, shift, "INT");
			jslistener(m, func(n) shift = n.getValue());


##
# Compile and load a .nas scriptfile into a local hash
#
var load_into = func (hash, nasfile) {
    if (io.stat(nasfile) != nil) {

	     var code = call(compile, [io.readfile(nasfile), nasfile], var err = []);
	     if (size(err)) { 			# check err
	         debug.dump(err);
	         print('. . in file: ', nasfile);
	         return 0;
			   }

	     call(bind(code, globals), nil, nil, hash, var err = []);
	     if (size(err)) { 			# check err2
	         debug.dump(err);
	         print('. . in file: ', nasfile);
	         return 0;
			   }

        return 1;
        }
    else {
        print('File: ', nasfile, ' does not exist');
        return 0;
        }
    }	


##
# Demultiplexer actions
#

var showPopup = func(str, fmt=nil, prop=nil) {
# Show popup
    if (size(str) > 0 ) {
        if (prop==nil) {
            # no property given, just print string
            gui.popupTip(str, duration);
            }
        else if (string.match(str, "*%*")) {
            # string has format specificaation print string and property value
            gui.popupTip(sprintf(str, getprop(prop)), duration);
            }
        else if (string.match(str, "* ")) {
            # string ends with space: add format and print string and property value
            if (fmt==nil) {fmt = "%u";}
			   gui.popupTip(sprintf(str~fmt, getprop(prop)), duration);
			   }
        else {
            # print string and property
            gui.popupTip(str, duration);
#            gui.popupTip(sprintf(str, getprop(prop)), duration);
            }
        }
    }

var script = func(popup, function) {
# Run a script
    var f = function;
    call(f, nil, nil, nil, var err = []);
	 if (size(err)) { 			# check err
	     debug.dump(err);
	     print('. . when "', popup, '". See demux scriptfile');
	     }
	 else {
        showPopup(popup);
	     }
    return 1; # Task is completed regardless wether the script was successful or not
    }

var adjust = func(popup, property, step=1, minval=0, maxval=1) {
# Adjust a property within bounds
    var min = minval;
    var max = maxval;
    var p = property;
    var s = step;
    var t = getprop(p);
    if (t != nil ) {
        t += s;
        if (s < 0) {
            t = t < min ? min : t;
            }
        else {
            t = t > max ? max : t;
            }
        setprop(p, t);
        }
    showPopup(popup, "%.2f", p);
    return 1; # Task is completed regardless wether a property was changed or not
    }

var toggle = func(popup, property) {
# Toggle a property
    var p = property;
    var t = getprop(p);
    if(t != nil ) {setprop(p, math.mod(t += 1, 2))}
    showPopup(popup, "%u", p);
    return 1; # Task is completed regardless wether a property was toggled or not
    }

##
# Class for group of sim controls
#
# A field: name of the group
# A field: items (vector of items i.e. control groups or controls within a group)
# A field: focus (index pointer for vector of items)
# A field: skip (boolean)
# A method: set_skip to set skip true/false
# Several 
#   field: representing an event that is associated with an action: event (key)/action (value)
#     The action is incr/decr the focus, or no action if skip is true
#
# Thus, the skip flag determines wether the matching event is captured to 
# increment/decrement the focus or just ignored.
#
var FGctrl = {
    class_name: "FGctrl", # "static"/"shared variable"

    new: func() {
        #create an instance / object
        var obj = { parents: [FGctrl] };
        obj.name = "";
        obj.fcs = 0;
        obj.skip = 0;
        obj.items = [{}]; # Even with no items the size is 1
        obj.set_skip = func (par) {
#                    if (par == "shift") {me.skip = !shift();}
                    if (par == "shift") {me.skip = !shift;}
                    else if (par) {me.skip = 1;}
                    else {me.skip = 0;}
                    # print(me.name, ": skip = ", me.skip);
                    return 1;
                    };
        obj.aa_short = [func {if (!me.skip) 
                    {me.fcs = math.mod(me.fcs -= 1, size(me.items)); return 1}
                   else {return 0}
                   }, [], "show"];
        obj.bb_short = [func {if (!me.skip) 
                    {me.fcs = math.mod(me.fcs += 1, size(me.items)); return 1}
                   else {return 0}
                   }, [], "show"];

        obj.init();
        return obj;
        },

    init: func () {
         print("Object created: ", me.class_name);
         return ;
        },
    };


##
# Find aircraft demux configuration file
#
if (fghome != nil) {
    var file = fghome ~ "/Input/Joysticks/" ~ matchingpatternsfile;
    if (io.stat(file) != nil) {
        load_into(var patterns = {}, file);
        print('Loaded ' ~ file);
        }
    }

var aircraft = getprop('/sim/aircraft');
if (aircraft == nil) {
    aircraft = getprop('/sim/description');}

var demux = nil; # Name of aircraft demux configuration file

foreach (var pattern; patterns.aircrafts) {
    if (string.match(aircraft, pattern[0])) {
        demux = pattern[1];
        break;
        }
    }

	 
##
# Load demultiplexer setup
# Read from dmxconf and loads controlgroups and actions.
#
var dmxconf = {};

##
# Holds assignments between hid buttons and switch IDs
#
var button = {};  
var create_button = func (nbr, grp, sw) {
    # Test if button nbr already exist. Print error message
    if (contains(button, nbr)) {
        print('*** cdmux *** : Can not assign button no. ', nbr, ' of group ', grp, 'The number is already in use');
        return 0;
        }
    button[nbr] = {};
    button[nbr]["timer"] = nil;
    button[nbr]["long"] = 0;
    button[nbr]["controlGrp"] = grp;
    button[nbr]["sw"] = sw;
    return 1;
    }

##
# Holds the demultiplexer setup with control groups, events and actions
#
var data = {}; 
# Setup "Unused" Ctrls/group for maping buttons that are connected in 
# joystick xml bindings but unspecified in dmxconf
data["Unused"] = FGctrl.new();
data["Unused"].name = "Unused";
data["Unused"].items = [];
append(data["Unused"].items, FGctrl.new());
data["Unused"].items[0].name = "Ugroup";
data["Unused"].items[0].items = [{name	: "Non"}];

##
# Check object before loading it
#
var existNonEmpty = func(obj, type) {
    if (obj != nil) { # This test fails and throws '[INFO]:nasal   undefined symbol:' if obj is a namespace
        if (type == "vector" and size(obj) > 0 and isvec(obj)) { return 1;}
        if (type == "hash" and size(obj) > 0 and ishash(obj)) { return 1;}
        if (type == "str" and size(obj) > 0 and isstr(obj)) { return 1;} 
        # size(obj) fails if obj is integer, . . (integer has no size)
        return 0;
        }
    return 0;
    }

##
# EXPORTED
# Function to load demultiplexer setup
#
var load_dmx_config = func (hid) {
	
    if (!demux) {demux = "default"}
    var alt = [demux, "default"];

    var f = 0;
    while (true) {
        if (f>1) {
            print('No dmx config found - demultiplexer can not load');
            return 0;
			}

        var dmxfile = fghome ~ "/Input/Joysticks/demux/" ~ hid ~ "/" ~ alt[f] ~ ".nas";
        if (load_into(dmxconf, dmxfile)) {
			   # debug.dump(dmxconf);
            print('Reading dmx config from: ', dmxfile);
            break;
            }
        
        f += 1;
    }
    
    if (!existNonEmpty(dmxconf.hidCtrls, "vector")) {
        print('*** cdmux *** : No hidCtrls (check aircraft file ', dmxfile);
        }
    else {
        # Load hid controls
        forindex(var i; dmxconf.hidCtrls) {
            var hidCtrl = dmxconf.hidCtrls[i];
            if (!existNonEmpty(hidCtrl, "str")) {
                print('*** cdmux *** : Item is not a valid string. Check hidCtrls in ', dmxfile);
                continue;}
    
            if (contains(data, hidCtrl)) {
                print('*** cdmux *** : hidCtrl ', hidCtrl, ' already in use. Check hidCtrls in ', dmxfile);
                continue;}
    
            data[hidCtrl] = FGctrl.new();
            data[hidCtrl].name = hidCtrl;
            data[hidCtrl].aa_down = [data[hidCtrl].set_skip, ["shift"]];
            data[hidCtrl].bb_down = [data[hidCtrl].set_skip, ["shift"]];
            data[hidCtrl].items = [];
    
            if (!existNonEmpty(dmxconf[hidCtrl~"buttons"], "hash")) {
                print('*** cdmux *** : Can not load ', hidCtrl~"buttons", '. Check ', dmxfile);
                continue;}
            
            # Load assignments of hid control buttons to switch IDs
            var buttons = dmxconf[hidCtrl~"buttons"];
            foreach(var b; keys(buttons)) {
                if (!create_button(b, hidCtrl, buttons[b])) {
                    print('*** cdmux *** : Can not assign button ', buttons[b], ' of ', hidCtrl~"buttons", '. Check ', dmxfile);
					     }
                }

            # Load control groups
            if (!existNonEmpty(dmxconf[hidCtrl~"items"], "vector")) {
                print('*** cdmux *** : Can not load ', hidCtrl~"items", '. Check ', dmxfile);
                continue;}
            
            var hidCtrlItems = dmxconf[hidCtrl~"items"];
            forindex(var j; hidCtrlItems) {
            
                if (!existNonEmpty(hidCtrlItems[j], "str")) {
                print('*** cdmux *** : Can not load ', hidCtrlItems[j], '. Check ', dmxfile);
                continue;}
            
                append(data[hidCtrl].items, FGctrl.new());
                var simControlGroup = data[hidCtrl].items[j];
                simControlGroup.name = hidCtrlItems[j];
                simControlGroup.cc_down = [simControlGroup.set_skip, [1]];
                simControlGroup.cc_up = [simControlGroup.set_skip, [0]];

                # Load event/action pairs of the group
                if (!existNonEmpty(dmxconf[hidCtrlItems[j]], "vector")) {
                print('*** cdmux *** : Can not load item from ', hidCtrlItems[j], '. Check ', dmxfile);
                continue;}
                
                simControlGroup.items = dmxconf[hidCtrlItems[j]];
                forindex(var k; simControlGroup.items) {
                    foreach(var key; keys(simControlGroup.items[k])) {
                        var act = simControlGroup.items[k][key];
                        if (key != "name") {
                            if (act[0] == "toggle") {
                                act[0] = toggle}
                            else if (act[0] == "adjust") {
                                act[0] = adjust}
                            else if (act[0] == "script") {
										  act[0] = script}
                            # When popup string is missing, prepend the item name 
                            # as popup string to the parameter vector
                            if (!isstr(act[1][0]) or string.match(act[1][0], "*/*")) {
                                var lst = act[1];
                                act[1] = [simControlGroup.items[k]["name"]];
                                forindex(var m; lst) {
										      append(act[1], lst[m]);
												}
										  } #else if (act[0] == "script") {act[0] = script}
                            }
                        }
                    }
                }
            }
        }
    return 1;
    }


##
# Function to find and perform the specified action (if any) for the specific 
# button and button event
#
var action = func(nbr, evnt) {
    # Button that was not defined in the demultiplexer setup, when pressed, 
    # causes "Nasal runtime error: non-objects have no members" written to 
    # the log. To prevent this, assign any such button to the "Unused" hidCtrls 
    # group. 
    if (!contains(button, nbr)) {
        #print("!!!!!!!!!!!!!!! this button is not defined !!!!!!!!!!!!!!!");
        create_button(nbr, "Unused", "void");
        }

    var ev = button[nbr].sw ~ "_" ~ evnt;
    #print(ev);
    var act = "";
    var item = {};
    
    for (var i=0; i < 3; i = i+1) {

        if (i == 0) {
            item = data[button[nbr].controlGrp]}
        else {
            item = item.items[item.fcs]}

        if (contains(item, ev)) {
            act = item[ev];
            if (call(act[0], act[1], item)) {
                if (i < 2) {                # show the item pointed to by the new focus
                    if (act[size(act)-1] == "show") {
                        gui.popupTip(item.items[item.fcs].name, 0.5)
                        }
                    }
                break;
                }
            }
        }
    }

##
# EXPORTED
# functions bdn (button down) and bup (button up) to bind with 
# every button that is to be connected to the demultiplexer
# E.g. to bind button 28 to the demultiplexer, 
# put in the joystick xml file:
# 
# <button n="28">
#   <desc>Button description (optional)</desc>
#   <binding>
#    <command>nasal</command><script>dmx.bdn(28);</script>
#   </binding>
#   <mod-up><binding>
#     <command>nasal</command><script>dmx.bup(28);</script>
#    </binding></mod-up>
# </button>
# 
var bdn = func(nbr) {
    action(nbr, "down");
    if (button[nbr].timer == nil) {
        button[nbr].timer = maketimer(longpress, func(){
            button[nbr].long = 1;
            action(nbr, "long");
            });
        button[nbr].timer.singleShot = 1;
        }
    button[nbr].long = 0;
    button[nbr].timer.start();
    }
     
var bup = func(nbr) {
    if (!button[nbr].long) {
        button[nbr].timer.stop();
        action(nbr, "short");
        }
    action(nbr, "up");
    }
