

( // keyboard input handling
w = Window.new("Derp");


w.view.background_(Color.black);
w.drawHook = {};


AppClock.sched(0.0,{w.refresh;0.1;});
w.view.keyDownAction = {|v,c,m,u,k|
	//if([$1].indexOf(c)!=nil,{Synth(\snare)});
	c.switch($z,{Synth(\kick,[\amp,0.3]);},$x,{Synth(\snare,[\amp,0.3]);},$,,{Synth(\hats,[\amp,0.01]);});
};
w.front;
)

( // launchpad input handling
MIDIClient.init;
l = ();
l.midisource=MIDIClient.sources.detect{|a|a.name.contains("Launchpad")};
l.mididestination=MIDIClient.destinations.detect{|a|a.name.contains("Launchpad")};
l.midirecv=MIDIIn.connect(0,l.midisource.uid);
l.midiout=MIDIOut(0,l.mididestination.uid);
l.midirecv.noteOn={|src,chan,num,val|};
l.midirecv.noteOff={|src,chan,num,val|};
l.greenDisplayBuffer = [1]++(0!63); l.redDisplayBuffer = [1]++(0!63);
l.greenSideBarBuffer = 0!8; l.redSideBarBuffer = 1!8;
l.greenTopBarBuffer= 0!8; l.redTopBarBuffer = 1!8;
l.draw = { l.midiout.noteOn(3,0,0);
	32.do({|inc| var message = [0x92];
		message = message.add(l.redDisplayBuffer[inc*2]|(l.greenDisplayBuffer[inc*2]<<4));
		message = message.add(l.redDisplayBuffer[inc*2+1]|(l.greenDisplayBuffer[inc*2+1]<<4));
		l.midiout.sysex(Int8Array.newFrom(message));
	});
	4.do({|inc| var message = [0x92];
		message = message.add(l.redSideBarBuffer[inc*2]|(l.greenSideBarBuffer[inc*2]<<4));
		message = message.add(l.redSideBarBuffer[inc*2+1]|(l.greenSideBarBuffer[inc*2+1]<<4));
		l.midiout.sysex(Int8Array.newFrom(message));
  });
  4.do({|inc| var message = [0x92];
		message = message.add(l.redTopBarBuffer[inc*2]|(l.greenTopBarBuffer[inc*2]<<4));
		message = message.add(l.redTopBarBuffer[inc*2+1]|(l.greenTopBarBuffer[inc*2+1]<<4));
		l.midiout.sysex(Int8Array.newFrom(message));
  }); l.midiout.sysex(Int8Array[0xb0,0x00,0x01]); nil;
};
l.draw.();
)

( // padkontrol input handling
MIDIClient.init;
p = ();
p.sysexSend = MIDIOut.new(MIDIClient.destinations.indexOf(MIDIOut.findPort("padKONTROL", "CTRL")));
p.sysexRecv = MIDIIn.connect(0,MIDIClient.sources.indexOf(MIDIIn.findPort("padKONTROL", "PORT A")));
p.sysexSend.sysex(Int8Array.newFrom([0xF0, 0x42, 0x40, 0x6E, 0x08, 0x00, 0x00, 0x01, 0xF7,0xF0, 0x42, 0x40, 0x6E, 0x08, 0x3F, 0x2A, 0x00, 0x00, 0x05, 0x05, 0x05, 0x7F, 0x7E, 0x7F, 0x7F, 0x03, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0d, 0x0E, 0x0F, 0x10, 0xF7,0xF0,0x42,0x40,0x6E,0x08,0x3F,0x0A,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x29,0x29,0x29,0xF7]));
p.sysexRecv.sysex = {|src, sysex|};
p.buttonvals = [0x7f,0x7f,0x7f,0x7f,0x7f];
p.numvals = [0x33,0x32,0x31];
p.sysexMessage = [0xF0,0x42,0x40,0x6E,0x08,0x3F,0x0A,0x01]++p.buttonvals++[0x00]++p.numvals++[0xF7];
p.sysexSend.sysex(Int8Array.newFrom(p.sysexMessage));
)
