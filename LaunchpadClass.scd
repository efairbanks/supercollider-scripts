

(

~lp = ();
~lp.redDisplayBuffer = ();
~lp.greenDisplayBuffer = ();
~lp.referenceBuffer = ();

~lp.x = nil;
~lp.y = nil;

64.do({
	|inc|
	~lp.redDisplayBuffer[inc]=0;
	~lp.greenDisplayBuffer[inc]=0;
	~lp.referenceBuffer[inc]=0;
});

~lp.noteOnHandler = nil;
~lp.noteOffHandler = nil;

~lp.initialize = {

	|self|

	MIDIClient.init;

	~lp.midisource=MIDIClient.sources.detect{|a|a.name.contains("Launchpad")};

	if(~lp.midisource.notNil,{

		var non, noff;

		~lp.mididestination=MIDIClient.destinations.detect{|a|a.name.contains("Launchpad")};
		~lp.midirecv=MIDIIn.connect(0,~lp.midisource.uid);
		~lp.midiout=MIDIOut(0,~lp.mididestination.uid);

		non={
			|src,chan,num,val|

		 ~lp.x=(num%16).asInteger;
			~lp.y=7-((num-~lp.x)/16).asInteger;

			if(~lp[\noteOnHandler]!=nil,{
				~lp[\noteOnHandler].();
			});

			nil;
		};

		noff={
			|src,chan,num,val|

			~lp.x=(num%16).asInteger;
			~lp.y=7-((num-~lp.x)/16).asInteger;

			if(~lp[\noteOffHandler]!=nil,{
				~lp[\noteOffHandler].();
			});

			nil;
		};

		~lp.midirecv.noteOn=non;
		~lp.midirecv.noteOff=noff;

	});

	nil;
};

~lp.setCell = { |self, x, y, red, green|
	var set = 0x0c;

	red = red & 0x03;
	green = green & 0x03;
	set = set | red;
	set = set | (green << 4);

	~lp.referenceBuffer[x+((7-y)*8)]=set;

	nil;
};

~lp.draw = { |self|

	~lp.midiout.noteOn(3,0,0);

	32.do({

		|inc|

		var message = [0x92];

		message = message.add(~lp.redDisplayBuffer[inc*2]|(~lp.greenDisplayBuffer[inc*2]<<4)|~lp.referenceBuffer[inc*2]);
		message = message.add(~lp.redDisplayBuffer[inc*2+1]|(~lp.greenDisplayBuffer[inc*2+1]<<4)|~lp.referenceBuffer[inc*2+1]);

		~lp.midiout.sysex(Int8Array.newFrom(message));

	});

	8.do({~lp.midiout.sysex(Int8Array[0x92,0x0c,0x0c]);});

	~lp.midiout.sysex(Int8Array[0xb0,0x00,0x01]);

	nil;
};

true;

)