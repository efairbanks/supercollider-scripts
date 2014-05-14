(

~redDisplayBuffer=();
~greenDisplayBuffer=();

~editArray = ();

8.do({

	|i|

	~editArray[i] = ();

	8.do({

		|j|

		~editArray[i][j] = 0;

	});

});

64.do({

	|inc|

	~redDisplayBuffer[inc]=0;
	~greenDisplayBuffer[inc]=0;

});

MIDIClient.init;

~midisource=MIDIClient.sources.detect{|a|a.name.contains("Launchpad")};

if(~midisource.notNil,{

	~mididestination=MIDIClient.destinations.detect{|a|a.name.contains("Launchpad")};
	~midirecv=MIDIIn.connect(0, ~midisource.uid);
	~midiout=MIDIOut(0, ~mididestination.uid);

	~non={|src,chan,num,val|
		var x=(num%16).asInteger;
		var y=((num-x)/16).asInteger;

		if(~editArray[x][y]>0,{~editArray[x][y]=0;},{~editArray[x][y]=1});
		~editArray[x][y].postln;

		y;

	};

	~midirecv.noteOn=~non;
	//~midirecv.noteOff=~non;

});

~redGreenToVelocity={

	|red, green|

	var set = 0x0c;

	red = red & 0x03;
	green = green & 0x03;

	set = set | red;
	set = set | (green << 4);

	set;

};

~xy2midi={

	|x,y|

	((x*3)+(y*4));

};

~referenceBuffer=();


64.do({

	|inc|

	~referenceBuffer[inc]=~redGreenToVelocity.(3,0);

});

// set all LEDs

~setAllLEDs={

	~midiout.noteOn(3,0,0);

	32.do({

		|inc|

		var message = [0x92];

		message = message.add(~redDisplayBuffer[inc*2]|(~greenDisplayBuffer[inc*2]<<4)|~referenceBuffer[inc*2]);
		message = message.add(~redDisplayBuffer[inc*2+1]|(~greenDisplayBuffer[inc*2+1]<<4)|~referenceBuffer[inc*2+1]);

		~midiout.sysex(Int8Array.newFrom(message));

	});

	8.do({

		~midiout.sysex(Int8Array[0x92,0x0c,0x0c]);

	});

	~midiout.sysex(Int8Array[0xb0,0x00,0x01]);

};

~setAllLEDs.();

~frameCount = 0;

)

(

~beat = 0;

t=TempoClock(140/15).schedAbs(0,{

	8.do({

		|i|

		8.do({

			|j|

			if(~editArray[i][j]>0,{

				~referenceBuffer[i+(j*8)]=~redGreenToVelocity.(3,3);

			},{

					~referenceBuffer[i+(j*8)]=~redGreenToVelocity.(0,0);

			});

		});

	});

	~setAllLEDs.();

	~beat=~beat+1;

	1;

});

)
