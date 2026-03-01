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

var banner = '*** cdmux: ';
print(banner~'loading cdmux');

var duration = 2.5; # popup duration
var longpress = 0.4; # button down duration required for "long" press

##
# String delimiters. Changing any of these delimiters will require a revision 
# of the popup/sprintf format strings in each of the configuration files.
# DO NOT USE: var del = "/"; # delimiter
# '/' must not be used in a popup message string! It is already in reserved 
# use as the identifying characteristic of a property path string.
#
var mk1 = ';'; # format str/ rep str and 
# enum/replace marker, e.g.:										';OFF|RIGHT|BOTH|LEFT'
var mk2 = '%'; # Dont change or use! 
# Format marker '%' is hardcoded inline
var mk3 = '$'; # Dont change or use! 
# Argument reordering marker '$' is hard coded inline
var mk4 = '|'; # enum str/srch-repl str marker, e.g.:		'|altitude-hold:engaged'
var mk5 = ':'; # replace str marker, e.g.:					':engaged'
#var mk = '`'; # alternative marker
#var mk = '\'; # alternative marker
#var mk = '@'; # alternative marker

var del = ";"; # substring (not label) delimiter
var del2 = ":"; # label delimiter
var del3 = "$"; # Dont change or use! Argument reordering marker '$' is hard coded inline

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
        print(banner~'File: ', nasfile, ' does not exist');
        return 0;
        }
    }	


##
# Demultiplexer actions
#
var propexists = func(props) {
#	print('propexists');
#	debug.dump(props);
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
print("showPopup parameters:");
debug.dump([str, fmt, props]);    

    if (!size(str) > 0 ) {print("#### size str =0"); return}
    # Zero size string given: don't popup

    if (props==nil) {
    # No property given, just popup
        gui.popupTip(str, duration);
        print("#### size props=nil"); 
        return;
        }

    # Message string and property path(s) are provided
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
        
    if (size(msg) > 1) { 
    # Format code and property value(s) present. popup and return
        gui.popupTip(call(sprintf, spfvec), duration);
        return
        }

    if (string.match(msg[0], "* ")) {
    # No format code but an ending space: Add format and property value, popup and return
        if (fmt==nil) {fmt = "%u"}
        gui.popupTip(sprintf(spfvec[0]~fmt, getprop(props[0])), duration);
        return;
        }

    else {
    # No format code, no ending space: popup message and return
        gui.popupTip(spfvec[0], duration);
        return;
        }
    }


var popup = func(str, props=nil) {
# Wrapper for showPopup
    if (props==nil or propexists(props)) {showPopup(str, nil, props)}
    return 1; # Task is completed regardless wether a property was toggled or not
    }

var toggle = func(popup, props) {
# Toggle a property
    if (propexists(props)) {
        setprop(props[0], math.mod(getprop(props[0]) + 1, 2));
        showPopup(popup, "%u", props)
        }
    return 1; # Task is completed regardless wether a property was toggled or not
    }

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
                    if (par == "shift") {me.skip = !shift}
                    else if (par) {me.skip = 1}
                    else {me.skip = 0}
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
         print(banner~'Object created: ', me.class_name);
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
        print(banner~'Loaded ' ~ file);
        }
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
# Check objects before loading
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
# Function to load the demultiplexer setup
#
var load_dmx_config = func (hid) {

    ##
    # Select a configuration file
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
        data[hidCtrl].aa_down = [data[hidCtrl].set_skip, ["shift"]];
        data[hidCtrl].bb_down = [data[hidCtrl].set_skip, ["shift"]];
        data[hidCtrl].items = [];
    
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
            simControlGroup.cc_down = [simControlGroup.set_skip, [1]];
            simControlGroup.cc_up = [simControlGroup.set_skip, [0]];

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
                    if (act[0]      == "toggle") {
                        act[0] = toggle}
                    else if (act[0] == "adjust") {
                        act[0] = adjust}
                    else if (act[0] == "script") {
                        act[0] = script}
                    else if (act[0] == "popup") {
                        act[0] = popup}
                    else if (act[0] == "swap") {
                        act[0] = swap}
                    else { # Ignore unknown action labels
                        print(banner~'unknown action "', act[0], 
                        '" in "', simControlGroup.items[k]["name"], 
                        '" in ', simControlGroup.name, ' group');
                        continue}
    
                    # (shallow) copy event/action to items
                    simControlGroup.items[k][key] = [act[0], act[1][:]];
                    # (deeper) manual copy if vector of property paths
                    if (isvec(act[1][1])) {simControlGroup.items[k][key][1][1] = act[1][1][:]}
                    
                    # process event key finished
                    } # keys loop
                } # items loop
            } # groups loop
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
#                    showPopup(newItem.name, nil, prop)
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
