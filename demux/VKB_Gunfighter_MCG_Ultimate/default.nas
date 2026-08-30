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

# Note:
# This configuration file has actions also for Flightgear Addon FGCamera
#
print("Loading default VKB_Gunfighter_MCG_Ultimate dmux");

var hidCtrls = ["LHAT"];

var LHATbuttons = {
    208: "a",
    };

var LHATitems = ["View"];

var View = [ 
    {name	: "Pilots view", 
    # Reset FGCamera view or select Flightgear view 0
    a_short: ["script", ["", func {
              if (getprop("/addons/by-id/a.marius.FGCamera/addon-devel/fgcamera-enabled")) {
                  fgcommand("fgcamera-reset-view")}
              else {
		          setprop("/sim/current-view/view-number", 0)}
		      }]],
    # Switch (from FGCamera) to Flightgear view 0 and reset view
    a_long: ["script", ["Flightgear view reset", func {
            setprop("/sim/current-view/view-number", 0);
            setprop("/sim/panel/visibility", false); # Does not work (Disable 2D panel)
            view.resetView();		# only resets tilt/pan/zoom:
            # must reset x/y/z view point separately
            vn = getprop("/sim/current-view/view-number");
            conf = sprintf("/sim/view[%d]/config", vn);
            foreach (parm ; ["x-offset-m", "y-offset-m", "z-offset-m"]) {
                setprop("/sim/current-view/", parm, getprop(conf, parm));
                }
			  }]],
    }, 
    ];
