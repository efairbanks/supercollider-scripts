(
e=();
e.patternLength=32;
e.tick=0;

~beats2secs={|beats,bpm| beats*60/bpm};
~arrayAsBits={|array|
  var ret=0;
  array=array.reverse;
  array.size.do({|inc|ret=(2**inc)*array[inc]+ret;});
  ret;
};
~bjorkSelect={|select,pattern|
  var selectIndex=0, selectPattern=~bjork.(select,pattern.sum), outPattern=pattern++[];
  outPattern.size.do({|inc|
    if(outPattern[inc]==1,{
      outPattern[inc]=outPattern[inc]*selectPattern[selectIndex];
      selectIndex=selectIndex+1;
    });
  });
  outPattern;
};
~level2beats={|level|
  2**level;
};
~getLevel={|index, maxLevel|
  while({(maxLevel>0).and((index%~level2beats.(maxLevel))!=0)},{
    maxLevel=maxLevel-1;
  });
  maxLevel;
};
~chordGen={|base=0,tones=3,intervals=#[4,3]|
  var chord=[];
  if(tones<1,{tones=1});
  (tones-1).do({|inc|
    chord=chord++[intervals.wrapAt(inc)];
  });
  chord=[0]++chord;
  chord=chord.integrate+base;
  chord;
};
~playMono={|alias,synth,params|
  if(e.voices[alias]!=nil,{if(e.voices[alias].isRunning,{e.voices[alias].release;});});
  e.voices[alias]=Synth(synth,params).register;
  nil;
};
)
(
if(e==nil,{e=();});
e.grid=0!(256*8*8);
e.topRow=0!8;

// ------ //
// ------ //
// ------ //
// ------ //

// display loop
~displayHandler={
  var gridOffset;
  l.greenTopBarBuffer=3!8; l.redTopBarBuffer=0!8;
  l.greenSideBarBuffer=0!8; l.redSideBarBuffer=3!8;
  l.greenDisplayBuffer=2!64; l.redDisplayBuffer=3!64;
  e.topRow.size.do({|inc|l.greenTopBarBuffer[inc]=e.topRow[inc]*3;});
  gridOffset=~arrayAsBits.(e.topRow)*64;
  64.do({|inc|
    l.greenDisplayBuffer[inc]=e.grid[inc+gridOffset]*2;
    l.redDisplayBuffer[inc]=e.grid[inc+gridOffset]*3;
  });
  l.draw.();
  1/5;
};

// launchpad input handling
MIDIClient.init;
l = ();
l.midisource=MIDIClient.sources.detect{|a|a.name.contains("Launchpad")};
l.mididestination=MIDIClient.destinations.detect{|a|a.name.contains("Launchpad")};
l.midirecv=MIDIIn.connect(0,l.midisource.uid);
l.midiout=MIDIOut(0,l.mididestination.uid);
l.midirecv.noteOn={|src,chan,num,val| var x,y;
  x=num&0x0f; y=(num&0xf0)>>4;
  [x,y,\on].postln;
  if((x<8).and(y<8),{
    var gridOffset=~arrayAsBits.(e.topRow)*64;
    e.grid[y*8+x+gridOffset]=if(e.grid[y*8+x+gridOffset]==0,{1},{0});
  });
};
l.midirecv.noteOff={|src,chan,num,val| var x,y;
  x=num&0x0f; y=(num&0xf0)>>4;
  [x,y,\off].postln;
};
l.midirecv.control={|src,chan,num,val|
  num=num-104;
  [num,(0:\off,127:\on)[val]].postln;
  if(val>0,{e.topRow[num]=if(e.topRow[num]==0,{1},{0});});
};
l.greenDisplayBuffer = 0!64; l.redDisplayBuffer = 0!64;
l.greenSideBarBuffer = 0!8; l.redSideBarBuffer = 0!8;
l.greenTopBarBuffer= 0!8; l.redTopBarBuffer = 0!8;
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
// start display loop
c=SystemClock.sched(0,{~displayHandler.();});
)