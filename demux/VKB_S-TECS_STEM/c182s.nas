##
# Numbering convention for buttons
#---------------------------------
# Use the button number of the xml binding  e.g. in the throttle file:
# <button n="15"> 
# <script>bdn(15);</script>
# To avoid number collisions add 100 to the numbers of the next xml file, i.e.
# in the joystick file:
# <button n="15"> 
# <script>bdn(115);</script>
# . . and for a 3rd hid 
# <button n="15"> 
# <script>bdn(215);</script>

##
# Naming convention for button id:s
#----------------------------------
# A double letter e.g. 'cc' indicates double use of this button id. It is involved 
# both in events for shifting of focus as well as events for acting on properties. 
# For example, cc_down and cc_up are already reserved for the focus shifting 
# mechanism but cc_short and cc_long are free to use for actions on properties.
#
# A single letter id e.g. 'e' have all four events ('e_down', e_up', 'e_short'
# and 'e_long') available for acting on properties.
#
print("Loading c182s S-TECS_STEM dmux");

var hidCtrls = ["EN1", "EN2", "SW12"];

var EN1buttons = {
    26: "aa", # encoder ccw
    27: "bb", # encoder cw
    30: "cc", # encoder PB
    };

var EN2buttons = {
    28: "aa", # encoder ccw
    29: "bb", # encoder cw
    31: "cc", # encoder PB
    };

var SW12buttons = {
    15: "a",  # sw1 toggle up
    17: "b",  # sw1 toggle down
    16: "c",  # sw1 PB
    18: "d",  # sw2 toggle up
    20: "e",  # sw2 toggle down
    19: "f",  # sw2 PB
    };

var EN1items = ["FltInstr"];

var EN2items = ["PanelSwitches_L_side"];

var SW12items = ["EngCtrls"];

var FltInstr = [ 

    {name	: "ALTimeter: %.2f inHg", 
    prop	   : "/instrumentation/altimeter/setting-inhg", 
    aa_short: ["adjust", [-0.02, 27.5, 31]],
    bb_short: ["adjust", [0.02, 27.5, 31]],
    cc_long : ["popup"],
    }, 
    
    {name	: "ALTimeter: %.1f hPa", 
    prop	   : "/instrumentation/altimeter/setting-hpa", 
    aa_short: ["adjust", [-0.5, 931, 1050]],
    bb_short: ["adjust", [0.5, 931, 1050]],
    cc_long : ["popup"],
    }, 
    
    {name	: "Instr light", 
    prop	   : "/controls/lighting/instrument-lights-norm", 
    aa_short: ["adjust", ["Dec instr light", -0.05, 0, 1.0]],
    bb_short: ["adjust", ["Inc instr light", 0.05, 0, 1.0]],
    cc_long : ["popup"],
    }, 
    
    {name	: "Radio light", 
    prop	   : "/controls/lighting/radio-lights-norm", 
    aa_short: ["adjust", ["Dec radio light", -0.05, 0, 1.0]],
    bb_short: ["adjust", ["Inc radio light", 0.05, 0, 1.0]],
    cc_long : ["popup"],
    }, 
    
    {name	: "Pedestal light", 
    prop	   : "/controls/lighting/pedestal-lights-norm", 
    aa_short: ["adjust", ["Dec pedestal light", -0.05, 0, 1.0]],
    bb_short: ["adjust", ["Inc pedestal light", 0.05, 0, 1.0]],
    cc_long : ["popup"],
    }, 
    
    {name	: "Glareshield light", 
    prop	   : "/controls/lighting/glareshield-lights-norm", 
    aa_short: ["adjust", ["Dec glareshield light", -0.05, 0, 1.0]],
    bb_short: ["adjust", ["Inc glareshield light", 0.05, 0, 1.0]],
    cc_long : ["popup"],
    }, 
    
    ];

var PanelSwitches_L_side = [

    {name	: "Fuel pump %s;off|on", 
    prop	   : "/controls/engines/engine/fuel-pump", 
    cc_short: ["toggle", []],
    cc_long : ["popup"],
    }, 
    
    {name	: "Beacon %s;off|on", 
    prop	   : "/controls/lighting/beacon", 
    cc_short: ["toggle", []],
    cc_long : ["popup"],
    }, 
    
    {name	: "Landing light %s;off|on", 
    prop	   : "/controls/lighting/landing-lights", 
    cc_short: ["toggle", []],
    cc_long : ["popup"],
    }, 
    
    {name	: "Taxi light %s;off|on", 
    prop	   : "/controls/lighting/taxi-light", 
    cc_short: ["toggle", []],
    cc_long : ["popup"],
    }, 
    
    {name	: "Nav lights %s;off|on", 
    prop	   : "/controls/lighting/nav-lights", 
    cc_short: ["toggle", []],
    cc_long : ["popup"],
    },
    
    {name	: "Strobe %s;off|on", 
    prop	   : "/controls/lighting/strobe", 
    cc_short: ["toggle", []],
    cc_long : ["popup"],
    }, 
    
    {name	: "Pitot ht %s;off|on", 
    prop	   : "/controls/anti-ice/pitot-heat", 
    cc_short: ["toggle", []],
    cc_long : ["popup"],
    }, 
    
    ];

var EngCtrls = [

    {name	: "Magnetos, starter and fuel", 
    a_long	: ["adjust", ["Magnetos %s;OFF|R|L|BOTH", "/controls/switches/magnetos", -1, 0, 3]],
    b_long	: ["adjust", ["Magnetos %s;OFF|R|L|BOTH", "/controls/switches/magnetos", 1, 0, 3]],
    
    b_down  : ["script", ["", func {if (getprop("/controls/switches/magnetos")==3) {
		             setprop("/controls/switches/starter", 1);
		             gui.popupTip("Starter", 0.5); 
		             # Display popup only when the starter is activated
		             }
		        }]],
      b_up  : ["script", ["", func {if (getprop("/controls/switches/magnetos")==3) {
		             setprop("/controls/switches/starter", 0);
		             }
		        }]],
    c_long  : ["popup", ["Magnetos %s;OFF|R|L|BOTH", "/controls/switches/magnetos"]],

    d_long	: ["adjust", ["Tanks %s;OFF|RIGHT|BOTH|LEFT", "/controls/switches/fuel_tank_selector", -1, 0, 3, 1]],
    e_long	: ["adjust", ["Tanks %s;OFF|RIGHT|BOTH|LEFT", "/controls/switches/fuel_tank_selector", 1, 0, 3, 1]],
    # Could not figure out how to involve the animation of the fuel tank selector
    f_long  : ["popup", ["Tanks %s;OFF|RIGHT|BOTH|LEFT", "/controls/switches/fuel_tank_selector"]],
    },
    
    ];

