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
var ot = emexec.OperationTimer.new("VSD", 3);

var v = 0; # verbose messages print to terminal and log
var banner = '*** cdmux: ';
print(banner~'loading cdmux');

var fghome = getprop("/sim/fg-home");
var matchingpatternsfile = "dmuxmatchmodel.nas";
var shiftPropertyPath = "/devices/status/joysticks/modifier";

var duration = 2.5;  # duration of popup message
var longpress = 0.4; # button down duration required for "long" press
var delay = 0.2;     # skip flag reset delay. Set greater then 
                     # time to next pulse of encoder pulse train

##
# String delimiters. Changing any of these delimiters will require a revision 
# of the popup/sprintf format strings in each of the configuration files.
#
# DO NOT USE: var mk = "/"; # delimiter
# '/' must not be used in a popup message string! It is already in reserved 
# use as the identifying characteristic of a property path string.
#
var mk1 = ';'; # marker separating message string and replacement string(s), e.g.:
#               'L fuel valve\n%s;OFF|AUX RH|MAIN RH|MAIN LH|AUX LH|OFF'
#               'AP %2$s\n%1$u feet alt hold;:disengaged|altitude-hold:engaged;'
#
var mk2 = '%'; # Not used. Dont change or use! 
# Format marker '%' is hardcoded inline
#
var mk3 = '$'; # Not used. Dont change or use! 
# Argument reordering marker '$' is hard coded inline
#
var mk4 = '|'; # marker separating enum strings or str:replacement str pair(s), e.g.:		
#               'OFF|AUX RH|MAIN RH|MAIN LH|AUX LH|OFF'
#               ':disengaged|altitude-hold:engaged'
#
var mk5 = ':'; # marker separating str to replace and replacement str, e.g.:
#               ':disengaged'   (note: empty string is to be replaced by 'disengaged')
#               'altitude-hold:engaged'
#
#var mk = '`'; # alternative marker character
#var mk = '\'; # alternative marker character
#var mk = '@'; # alternative marker character


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
        print(banner~'Loaded ' ~ nasfile);
        return 1;
        }
    else {
        print(banner~'File: ', nasfile, ' does not exist');
        return 0;
        }
    }	


##
# Demultiplexer actions and supporting functions
#

var propexists = func(props) {
# Check existence of props
    if (isvec(props)) {
        forindex(var i; props) {
            if (getprop(props[i]) == nil){
                gui.popupTip(props[i]~"\ndoes not exist or value is NaN", duration);
                return 0}
            }
        }
    else {
        gui.popupTip('Not a property path. Check logfile', duration);
	     print(banner~'Not a property path:');
	     debug.dump(props);
	     return 0
        }
    return 1
    }

var showPopup = func(str, fmt=nil, props=nil) {
#print("showPopup parameters:");
#debug.dump([str, fmt, props]);    

    # Display message
    if (!size(str) > 0 ) {return}
    # Zero size string given: don't popup

    # Display message
    if (props==nil) {gui.popupTip(str, duration); return}
    # No property given, just popup
        
    # Message string and property path(s) are provided
    # Analyze and prepare sprintf argument vector
    #
    # str   popup message (including format string(s) and replacement(s) string(s))
    # msg   popup message (including format string(s)
    # rep   replacement(s) string(s)  
    str = split(mk1, str); # Separate msg from rep
    var msg = split('%', str[0]);
    var spfvec = [msg[0]];
    var rep = "";
    var replace = false;
    if (size(str) > 1) {
        rep = str[1:];
        replace = true
        }
    var argnum = 0;
    
    forindex (var i; msg) {
        if (i<1) {continue} # This index has no order info
        
        msg[i] = split('$', msg[i]);
        argnum = size(msg[i]) > 1 ? msg[i][0]-1 : i-1; # Automatic argument (re)ordering
        
        append(spfvec, getprop(props[argnum])); # Build sprintf argument vector
        spfvec[0] = spfvec[0] ~ '%' ~ msg[i][-1]; # Rebuild the message string without argument numbering

        if (replace and !string.match(rep[i-1], "")) { # replace AND current value replacement
            rep[i-1] = split(mk4, rep[i-1]);
            
            if (isstr(spfvec[-1])) { # string replace
                forindex (var j; rep[i-1]) {
                    rep[i-1][j] = split(mk5, rep[i-1][j]);
                    
                    if (string.match(rep[i-1][j][0], spfvec[-1])) {
                        spfvec[-1] = rep[i-1][j][1] # string replace
                        }
                    }
                }
            else { # enum strings
                spfvec[-1] = rep[i-1][spfvec[-1]]; # Replace value(s)
				    }
            }
        }
        
    # Display message
    if (size(msg) > 1) {gui.popupTip(call(sprintf, spfvec), duration); return}
    # Format code and property value(s) present. popup and return
        
    # Display message
    if (string.match(msg[0], "* ")) {
    # No format code but an ending space: Add format and property value, popup and return
        if (fmt==nil) {fmt = "%u"}
        gui.popupTip(sprintf(spfvec[0]~fmt, getprop(props[0])), duration);
        return;
        }

    # Display message
    else {gui.popupTip(spfvec[0], duration); return}
    # No format code, no ending space: popup message and return
    }


##
# Action
var popup = func(str, props=nil) {
# Wrapper for showPopup
    if (props==nil or propexists(props)) {showPopup(str, nil, props)}
    return 1; # Task is completed regardless wether a property was toggled or not
    }

##
# Action
var toggle = func(popup, props) {
# Toggle a property
    if (propexists(props)) {
        setprop(props[0], math.mod(getprop(props[0]) + 1, 2));
        showPopup(popup, "%u", props)
        }
    return 1; # Task is completed regardless wether a property was toggled or not
    }

##
# Action
var swap = func(popup, props) {
# Swap the values of two properties
    if (size(props)<2) { # popup error message
        showPopup("swap action needs two properties to act on", nil, nil);
        return 1; # Task is completed regardless wether a property was toggled or not
        }
    if (propexists(props)) {
    # swap values
        var val0 = getprop(props[0]); 
        var val1 = getprop(props[1]); 
        setprop(props[0], val1);
        setprop(props[1], val0);
        showPopup(popup, nil, props);
        }
    return 1; # Task is completed regardless wether a property was toggled or not
    }

##
# Action
var adjust = func(popup, props, step=1, min=0, max=1, wrap=0) {
# Adjust a property within bounds
    if (propexists(props)) {
        var t = getprop(props[0]);
        t += step;
        if (wrap) {
            if (t < min) {t = max}
            else if (t > max){t = min}
            } 
        else {
            if (t < min) {t = min}
            else if (t > max){t = max}
            } 
        setprop(props[0], t);
        showPopup(popup, "%.2f", props);
        }
    return 1; # Task is completed regardless wether a property was changed or not
    }

##
# Action
var script = func(popup, prop, function) {
# Run a script
    if (prop==nil or propexists(prop)) {
        call(function, nil, nil, nil, var err = []);
	     if (size(err)) { 			# check err
	         debug.dump(err);
	         print('. . when "', popup, '". See demux scriptfile');
	         }
	     else {
            showPopup(popup, nil, prop);
	         }
        }
    return 1; # Task is completed regardless wether the script was successful or not
    }


##
# Class 
# for a group of hid controls or sim controls.
# The object holds a list of items and manages an index pointing to one of the items
#
# items: (vector of items i.e. control groups or controls within a group)
# fcs  : focus (index pointer for list of items)
# skip : (boolean) determines wether a matching event is captured to 
#                         incr/decr the focus or just ignored.
# aa_short: event to decrease focus if not skip
# bb_short: event to increase focus if not skip
#
# Encoders on hid VKB-Sim (C) Alex Oz 2023 S-TECS MODERN THROTTLE STANDARD STEM
# and possibly others:
# When turning the encoder knob rapidly the hid queues up encoder pulses and transmits 
# them one after the other. The timer is implemented to delay re-setting the skip flag 
# until the next encoder pulse has arrived and reset the timer. This ensures that all 
# encoder pulses acts on the item (as intended) even if the encoder knob is released 
# (to reset the skip flag) before the pulse train is finished.
#
# used for skip flag reset delay:
# pre_skip
# timer
# delay
# level     0: hid level           - items: list of control groups
#           1: control group level - items: list of sim controls
#           (skip flag reset delay applied only to the control group level)

var FGctrl = {
    class_name: "FGctrl", # "static"/"shared variable"

    new: func() {
        #create an instance / object
        var obj = { parents: [FGctrl] };
        obj.name = "";
        obj.fcs = 0; # item pointer
        obj.items = [{}]; # Size is 1, prevents index (0) out of bounds
        obj.skip = 0; # actual skip value
        
        obj.pre_skip = 0; # requested skip value
        obj.level = nil; # 0: HID level           - items: vector of control groups
                         # 1: Control group level - items: vector of sim controls
        obj.timer = nil;
        obj.delay = delay; # Skip flag reset delay
      
        obj.set_skip = func (par) {
                    if (me.level) {
                        if                              # par=="delay", pre_skip==0,
                        (!me.pre_skip and par == "delay") {
                            me.timer.restart(me.delay)}
                        else if (par) {                 # par==1, 
                            me.pre_skip = 1;
                            me.skip     = 1}
                        else {                          # par==0, 
                            me.pre_skip = 0;
                            me.timer.restart(me.delay)}
                        }
                    else {if (par == "shift") {me.skip = !shift}}
                    return 1; 
                    };
                    
        obj.aa_short = [func {if (!me.skip) 
                    {me.fcs = math.mod(me.fcs -= 1, size(me.items)); return 1} # Task is completed
                    else {me.set_skip("delay"); return 0}                      # no action performed
                    }, [], "show"];
                    
        obj.bb_short = [func {if (!me.skip) 
                    {me.fcs = math.mod(me.fcs += 1, size(me.items)); return 1} # Task is completed
                    else {me.set_skip("delay"); return 0}                      # no action performed
                    }, [], "show"];

        obj.init();
        return obj;
        },

    init: func () {
         me.timer = maketimer(me.delay, func(){me.skip = 0; 
             #print(banner~'TIMER: ', me.name);
             });
         me.timer.singleShot = 1;
         #print(banner, me.class_name~' object instantiated');
         return ;
        },
             
    };


##
# Find aircraft demux configuration file
#
print(" ");
print(banner~'Aircraft demux matching file:');
if (fghome != nil) {
    var file = fghome ~ "/Input/Joysticks/" ~ matchingpatternsfile;
    if (io.stat(file) != nil) {load_into(var patterns = {}, file)}
    }

var aircraft = getprop('/sim/aircraft');
if (aircraft == nil) {
    aircraft = getprop('/sim/description')}

var demux = nil; # Name of aircraft demux configuration file

foreach (var pattern; patterns.aircrafts) {
    if (string.match(aircraft, pattern[0])) {
        demux = pattern[1];
        break;
        }
    }

	 
##
# Load demultiplexer setup
# Read from dmxconf and load controlgroups and actions.
#
var dmxconf = {};

##
# Holds assignments between hid buttons and switch IDs
#
var button = {};  
var create_button = func (nbr, grp, sw) {
    # Test if button nbr already exist. Print error message
    if (contains(button, nbr)) {
        print(banner~'Can not assign button no. ', nbr, ' of group ', grp, 'The number is already in use');
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
# Holds the demultiplexer setup(s) with control groups, events and actions
#
var data = {}; 
# Setup "Unused" Ctrls/group for maping buttons that are connected in 
# joystick xml bindings but unspecified in dmxconf
data["Unused"] = FGctrl.new();
data["Unused"].name = "Unused";
data["Unused"].items = [];
v and print(banner~'"'~data["Unused"].name~'" ('~data["Unused"].class_name~' object) created');
append(data["Unused"].items, FGctrl.new());
data["Unused"].items[0].name = "Ugroup";
data["Unused"].items[0].items = [{name	: "Non"}];
v and print(banner~' |-"'~data["Unused"].items[0].name~'" ('~data["Unused"].class_name~' object) created');

##
# Functions for checking objects before loading
#
var existNonEmpty = func(obj, type) {
    if (obj != nil) { # This test fails and throws '[INFO]:nasal   undefined symbol:' if obj is a namespace
        if (type == "vector" and size(obj) > 0 and isvec(obj)) { return 1}
        if (type == "hash" and size(obj) > 0 and ishash(obj)) { return 1}
        if (type == "str" and size(obj) > 0 and isstr(obj)) { return 1} 
        # size(obj) fails if obj is integer, . . (integer has no size)
        return 0;
        }
    return 0;
    }

var namestr = func(obj) {
    return (isstr(obj) and !string.match(obj, "*/*"));
    }

var ppath = func(obj) {
    if (isstr(obj) and string.match(obj, "*/*")) {
        if (!string.match(obj, "/*")) {
            print(banner~'property path "', obj, 
            '" should be absolute, starting with a "/" char')
            }
        return 1;
        }
    return 0;
    }

var propertypath = func(obj) {
    if (isvec(obj)) {
        var i = 1;
        forindex(var j; obj) { i = ppath(obj[j]) ? i : 0; }
        return i;
        }
    return ppath(obj);
    }


##
# EXPORTED
# Function to load a demultiplexer setup
#
var load_dmx_config = func (hid) {
    
    ##
    # Select a configuration file
    print(" ");
    print(banner~hid~'demux aircraft configuration file:');

    if (!demux) {demux = "default"}
    var alt = [demux, "default"];

    var f = 0;
    while (true) {
        if (f>1) {
            print(banner~'No dmx config found - demultiplexer can not load');
            return 0;
			}

        var dmxfile = fghome ~ "/Input/Joysticks/demux/" ~ hid ~ "/" ~ alt[f] ~ ".nas";
        if (load_into(dmxconf, dmxfile)) {
			   # debug.dump(dmxconf);
            print(banner~'Reading dmx config from: ', dmxfile);
            break;
            }
        
        f += 1;
    }
    
    if (!existNonEmpty(dmxconf.hidCtrls, "vector")) {
        print(banner~'No hidCtrls (check aircraft file ', dmxfile);
        return 0;
        }

    ##
    # Load hid controls
    print(" ");
    
    forindex(var i; dmxconf.hidCtrls) {
    # Looop hid controls
        var hidCtrl = dmxconf.hidCtrls[i];
        if (!existNonEmpty(hidCtrl, "str")) {
            print(banner~'Item is not a valid string. Check hidCtrls in ', dmxfile);
            continue}
    
        if (contains(data, hidCtrl)) {
            print(banner~'hidCtrl ', hidCtrl, ' already in use. Check hidCtrls in ', dmxfile);
            continue}
    
        data[hidCtrl] = FGctrl.new();
        data[hidCtrl].name = hidCtrl;
        data[hidCtrl].level = 0;
        data[hidCtrl].aa_down = [data[hidCtrl].set_skip, ["shift"]];
        data[hidCtrl].bb_down = [data[hidCtrl].set_skip, ["shift"]];
        data[hidCtrl].items = [];
        print(banner~'"'~data[hidCtrl].name~'" ('~data[hidCtrl].class_name~' object) created');
    
        if (!existNonEmpty(dmxconf[hidCtrl~"buttons"], "hash")) {
            print(banner~'Can not load ', hidCtrl~"buttons", '. Check ', dmxfile);
            continue}
            
        ##
        # Load assignments of hid control buttons to switch IDs
        var buttons = dmxconf[hidCtrl~"buttons"];
        foreach(var b; keys(buttons)) {
            if (!create_button(b, hidCtrl, buttons[b])) {
                print(banner~'Can not assign button ', buttons[b], ' of ', hidCtrl~"buttons", '. Check ', dmxfile);
                    }
            }

        ##
        # Load control groups
        if (!existNonEmpty(dmxconf[hidCtrl~"items"], "vector")) {
            print(banner~'Can not load ', hidCtrl~"items", '. Check ', dmxfile);
            continue}
            
        var hidCtrlItems = dmxconf[hidCtrl~"items"];

        # Loop control groups
        forindex(var j; hidCtrlItems) {
            
            if (!existNonEmpty(hidCtrlItems[j], "str")) {
                print(banner~'Can not load ', hidCtrlItems[j], '. Check ', dmxfile);
                continue}
            
            append(data[hidCtrl].items, FGctrl.new());
            var simControlGroup = data[hidCtrl].items[j];
            simControlGroup.name = hidCtrlItems[j];
            simControlGroup.level = 1;
            simControlGroup.cc_down = [simControlGroup.set_skip, [1]];
            simControlGroup.cc_up = [simControlGroup.set_skip, [0]];
            print(banner~' |-"'~simControlGroup.name~'" ('~data[hidCtrl].class_name~' object) created');

            var CGitems = dmxconf[hidCtrlItems[j]];
            ##
            # Load "name", "prop" and event/action pairs of each group
            if (!existNonEmpty(CGitems, "vector")) {
                print(banner~'Can not load item from ', hidCtrlItems[j], '. Check ', dmxfile);
                continue}
                
            # Loop control group items
            forindex(var k; CGitems) {

                # Grow the items vector if needed
                if (!(size(simControlGroup.items) > k)) {append(simControlGroup.items, {})}

                # Check and copy "name" key
                if (namestr(CGitems[k]["name"])) {
                    simControlGroup.items[k]["name"] = CGitems[k]["name"]}
                else {
                    simControlGroup.items[k]["name"] = "Check name string";
                    print(banner~'"name" string must not use the "/" character', 
                          ' in "', CGitems[k]["name"], 
                          '" in ', simControlGroup.name, ' group');
                    debug.dump(CGitems[k]["name"]);
                    }
                # Check and copy "prop" key
                if (contains(CGitems[k], "prop")) {
                    if (propertypath(CGitems[k]["prop"])) {
                        # convert "ppath" to ["ppath"]
                        if (isstr(CGitems[k]["prop"])) {CGitems[k]["prop"] = [CGitems[k]["prop"]]}
                        simControlGroup.items[k]["prop"] = CGitems[k]["prop"][:]} # FIX: slice copy
                    else {
                        print(banner~'"prop" value is not a valid property path in ', 
                        simControlGroup.name, ' group: ');
                        debug.dump(CGitems[k]["prop"])}
                    }
                
                v and print(banner~'    |-"'~simControlGroup.items[k]["name"]~'" (object) created');

                # Loop the keys of the item
                foreach(var key; keys(CGitems[k])) {
                    
                    # these keys are already processed
                    if (key == "name" or key == "prop") {continue} # Skip to next key
                    
                    # ignore unknown keys
                    if (!(string.match(key, "*_down") 
                       or string.match(key, "*_up") 
                       or string.match(key, "*_short") 
                       or string.match(key, "*_long"))) {
                        # Error message
                        print(banner~'key "', key, '" in ', 
                               simControlGroup.name, ' group is not valid');
                        continue; # Skip to next key
                        }

						  ##
                    # Process event key
                    # Check and complete the action parameter vector 
                    var act = CGitems[k][key];
                    
                    # Prepare an empty parameter vector      
                    if (size(act) > 1) {
                        # Action vector has both action string and action parameters
                        var pars = act[1];
                        act[1] = []; # start building the action parameter vector
                        }
                    else {
                        # Action vector has only the action string
                        var pars = [];
                        append(act, []);  # start building the action parameter vector
                        }
                                
                    var m = 0;
                    if (size(pars) > 1 and propertypath(pars[0]) and propertypath(pars[1])) {
                    # the first two parameters has the property path identifying char "/"
                        print(banner~'The first two parameters for the event "', key, 
                        '" looks like property paths. The 1st par should be a popup, and only the 2nd par should have "/" character(s).'
                        ' In "', simControlGroup.items[k]["name"], 
                        '" in ', simControlGroup.name, ' group');
                        continue;
                        }

                    if (size(pars) > m and namestr(pars[m])) { 
                    # pars has at least one item and item is a popup string
                        append(act[1], pars[m]);
                        m += 1;
                        }
                    else {
                    # use the item name string
                        append(act[1], simControlGroup.items[k]["name"]);
                        }
                            
                    # NOTE: the logic here will fail to detect the faulty 
                    # parameter if property path was omitted AND par[m] is 
                    # a string containing a "/".
                    if (size(pars) > m and propertypath(pars[m])) {
                    # pars has a next item and item is a prop path
                        # convert "ppath" to ["ppath"]
                        if (isstr(pars[m])) {pars[m] = [pars[m]]}
                        append(act[1], pars[m]);
                        m += 1;
                        }
                    else {
                        # try "prop" for property path(s)
                        if (contains(simControlGroup.items[k], "prop")){
                            append(act[1], simControlGroup.items[k]["prop"]);
                            }
                        else if (act[0] == "popup" or act[0] == "script") {
                        # do without property path                                
                            append(act[1], nil); 
                            }
                        else {
                        # print error message and skip the key
                            print(banner~'key "prop" is needed for the event ', key, 
                            ' in "', simControlGroup.items[k]["name"], 
                            '" in ', simControlGroup.name, ' group');
                            continue;
                            }
                        }
                            
                    # Copy the rest of the parameters.
                    while (size(pars) > m ) {
                        append(act[1], pars[m]);
                        m += 1;
                        }

                    # Replace the action labels with the corresponding functions
                    var act0 = act[0];
                    
                    if (     act[0] == "toggle") {act[0] = toggle}
                    else if (act[0] == "adjust") {act[0] = adjust}
                    else if (act[0] == "script") {act[0] = script}
                    else if (act[0] == "popup")  {act[0] = popup}
                    else if (act[0] == "swap")   {act[0] = swap}
                    else { # Ignore unknown action labels
                        print(banner~'unknown action "', act[0], 
                        '" in "', simControlGroup.items[k]["name"], 
                        '" in ', simControlGroup.name, ' group');
                        continue}
    
                    # (shallow) copy event/action to items
                    simControlGroup.items[k][key] = [act[0], act[1][:]];
                    # (deeper) manual copy if vector of property paths
                    if (isvec(act[1][1])) {simControlGroup.items[k][key][1][1] = act[1][1][:]}
                    #debug.dump(simControlGroup.items[k][key]);
                    v and print(banner~'       |-"'~key~'":'~act0~' (event:action) registered');
                    
                    # process event key finished
                    } # keys loop
                } # items loop
            } # groups loop
        print(banner~'"'~data[hidCtrl].name~'" setup!');
        print(" ");
        } # hid controls loop
    dmxconf = {};
    return 1;
    }


##
# Function to find and perform the specified action (if any) for the specific 
# button and button event
#
var action = func(nbr, evnt) {
ot.reset();
ot.log("start");
    # A button that was not defined in the demultiplexer setup, when pressed, 
    # causes "Nasal runtime error: non-objects have no members" written to 
    # the log. To prevent this, assign any such button to the "Unused" hidCtrls 
    # group. 
    if (!contains(button, nbr)) {
        #print("!!!!!!!!!!!!!!! this button is not defined !!!!!!!!!!!!!!!");
        create_button(nbr, "Unused", "void");
        }

    var ev = button[nbr].sw ~ "_" ~ evnt;
    var item = data[button[nbr].controlGrp]; # 1st item level
    var i=0;

    while (true) {
        # Loop 0: act on group select
        # Loop 1: act on item slect
        # Loop 2: act on item
        if (contains(item, ev) and call(item[ev][0], item[ev][1], item)) {
            # Found matching event AND performed action
            if (i < 2 and item[ev][-1] == "show") { # show the item pointed to by the new focus
                    newItem = item.items[item.fcs];
                    var prop = contains(newItem, "prop") ? newItem.prop : nil;
                    popup(newItem.name, prop)
                }
            break; # Event matched and action was performed
            }
        i += 1; 
        if (i > 2) {break} # no event found - search finished
        item = item.items[item.fcs]; # down one item level
        }
ot.log("finished");
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
