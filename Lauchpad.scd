(
var non,nof,co,midisource,mididestination;
MIDIClient.init;

midisource=MIDIClient.sources.detect{|a|a.name.contains("Launchpad")};
if(midisource.notNil,{

	mididestination=MIDIClient.destinations.detect{|a|a.name.contains("Launchpad")};
	~midirecv=MIDIIn.connect(0, midisource.uid);
	~midiout=MIDIOut(0, mididestination.uid);

	~non={|src,chan,num,val|
		var x=num%16;
		var y=(num-x)/16;
		[\on,src,chan,num,val].postln;
		//r{
		//}.play;
		y;
	};

	~midirecv.noteOn=~non;

	~nof={|src,chan,num,val|
		var x=num%16;
		var y=(num-x)/16;
		[\off,src,chan,num,val].postln;
		//r{

		//}.play;
	};

	~midirecv.noteOff=~nof;

	~co={|src,chan,num,val|
		var x=num-104;
		[\co,src,chan,num,val].postln;
		//r{

		//}.play;
	};

	~midirecv.control=~co;

	},{
		"Launchpad Not available".postln;
		^nil;
 });

~setLED={

	|x, y, red, green|

	var set = 0x0c;

	red = red & 0x03;
	green = green & 0x03;
	x = x & 0x07;
	y = y & 0x07;

	set = set | red;
	set = set | (green << 4);

	~midiout.noteOn(0, x + (y << 4), set);

};

~setLEDs={

	|red, green|

	var set = 0x0c;

	red = red & 0x03;
	green = green & 0x03;

	set = set | red;
	set = set | (green << 4);

	~midiout.noteOn(0, set, set);

};

~redGreen2velociy={

	|red, green|

	var set = 0x0c;

	red = red & 0x03;
	green = green & 0x03;

	set = set | red;
	set = set | (green << 4);

	set;

};

)

(

// set all LEDs

~midiout.noteOn(3,0,0);

40.do({

	~midiout.sysex(Int8Array[0x92,0x3f,0x3f]);

});

~midiout.sysex(0xb0,0x00,0x01);

)

(
8.do({|x|
	8.do({|y|
		~setLED.(x,y,x%4,y%4);
	});
});
)



~midiout.noteOn(0, 0x35, 0x0d);