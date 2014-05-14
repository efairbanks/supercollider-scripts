GeneralHID.buildDeviceList;
// Get the list of devices:
d = GeneralHID.deviceList;
// Check which devices have been found:
GeneralHID.postDevices;
// Pick the 6th device and open it and create an instance of it:
a = GeneralHID.open( d[0] );
// Start eventloop:
GeneralHID.startEventLoop(1000);
// Get the capabilities of the device in a readable format:
a.caps;
// there are different types of slots:
// button (type 1), has only on/off (1/0) states
// relative (type 2), counts up or down (scrollwheel for example)
// absolute (type 3), continuous value between 0 and 1
// some other may show up on Linux ( Syn (type 0) and Miscellaneous (type 4), but these are generally not very useful).
// See if data is coming in:
a.debug_( true );
a.debug_( false );
(

)

// [3][49] left stick vertical
// [3][48] left stick horizontal
// [1][9] left stick button
// [3][51] right stick horizontal
// [3][52] right stick vertical
// [1][10] right stick button
// [3][50] left bumper
// [3][53] right bumper
// [1][11] d-pad up
// [1][12] d-pad down
// [1][13] d-pad left
// [1][14] d-pad right
// [1][8] back
// [1][7] start
// [1][5] black
// [1][6] white
// [1][1] A
// [1][2] B
// [1][3] X
// [1][4] Y

// --- //

(

//x.free;

//x = {|freq=440| SinOsc.ar(freq);}.play;

a.slots[3][52].action_({|v|

	~contour = 15*v.value;
	
});

)

// --- //

// You can also create a generic gui to see what is coming in:
a.makeGui;

// The current value of a slot can be checked:
a.slots[1].at( 272 ).value;
a.slots[2].at( 1 ).value;
a.slots[3][1].value
//If the slot is an LED, you can set the value:
a.slots[11][0].value = 1;
a.slots[11][0].value = 0;

// Actions can be mapped to each slot individually.
a.slots[1].at( 272 ).action_( { "hello".postln; } );
a.slots[1].at( 273 ).action_( { "hi".postln; } );
a.slots[3].at( 1 ).action_( { "hi".postln; } );
// with an input to the function
a.slots[3].at( 1 ).action_( { |v| "hi, my value is ".post; v.value.postln; } );
a.slots[1].at( 272 ).action_( { |v| "hi, my value is ".post; v.value.postln; } );

// To stop the action, assign it to an empty function.
a.slots[1].at( 272 ).action_( {} );
a.slots[1].at( 273 ).action_( {} );
a.slots[3].at( 1 ).action_( {} );

// you can access slots, by giving them a key:
a.add( \lx, [3,0] );
a[\lx].debug_( true );
// the last item in the output array, now shows the key
a[\lx].debug_( false );
// save the spec for future use:
a.spec.save( "Impact_help" );
// find a spec defined previously for this device:
c = a.findSpec;
// set it:
a.setSpec( c[0] );
// more info on this in the [GeneralHIDSpec] helpfile
// If the server is running you can create a control bus for the HID data to go to, so that a synth can immediately read the data:
s = Server.local.boot;
// To create the bus:
a.slots[1].at( 272 ).createBus( s ); a.slots[2].at( 8 ).createBus( s );

SynthDef( \hidbus_help, { |out=0,amp=0|
    Out.ar( out, SinOsc.ar( 300, 0, 0.01*amp.abs ) );
}).add;
)
x = Synth.new( \hidbus_help );
x.map( \amp, a.slots[2].at( 8 ).bus );
x.free;

( // a nicer version:
SynthDef( \hidbus_help, { |out=0,amp=0,amp2=0|
    Out.ar( out, SinOsc.ar( 300, 0, 0.01*amp.abs.lag( 0.1 ) * amp2.lag(0.01,0.99) ) );
}).add;
)
x = Synth.new( \hidbus_help );
x.map( \amp, a.slots[2].at( 8 ).bus );
x.map( \amp2, a.slots[1].at( 272 ).bus );
x.free;

( // an even nicer version:
SynthDef( \hidbus_help, { |out=0,freqadd=0,amp=0|
    Out.ar( out, SinOsc.ar( 300 + (freqadd.lag(0.2,1)*40), 0, 0.2*amp.lag(0.01,0.99) ) );
}).add;
)
x = Synth.new( \hidbus_help );
x.map( \freqadd, a.slots[2].at( 8 ).bus );
x.map( \amp, a.slots[1].at( 272 ).bus );
x.free;

// To free the bus:
a.slots[1].at( 272 ).freeBus;
a.slots[2].at( 8 ).freeBus;
// Close the device after use:
a.close;
GeneralHID.stopEventLoop