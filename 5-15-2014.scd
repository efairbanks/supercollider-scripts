// ================================== //
// SuperCollider Live Coding Template //
// ================================== //
s.reboot;
( // buses
e=();
e.kick = Bus.audio(s,2);
e.hats = Bus.audio(s,2);
e.snare = Bus.audio(s,2);
e.bass = Bus.audio(s,2);
e.feedbackBass = Bus.audio(s,2);
e.sawStab = Bus.audio(s,2);
e.pulseLead = Bus.audio(s,2);
e.sweep = Bus.audio(s,2);
)
( // mixer
e.mixer.free;
e.mixer = {
	var kick, snare, hats, bass, feedbackBass, sawStab, pulseLead, sweep, out;
	kick = In.ar(e.kick,2);
	snare = In.ar(e.snare,2)+BPF.ar(FreeVerb.ar(In.ar(e.snare,2),1,0.99,0.9),1000,1,1/4);
	hats = In.ar(e.hats,2);
	bass = In.ar(e.bass,2);
  feedbackBass = In.ar(e.feedbackBass,2);
	sawStab = Compander.ar(FreeVerb.ar(In.ar(e.sawStab,2),1/4,0.8,0.8),bass,0.025,1,1/4,0.001,0.2);
	pulseLead = In.ar(e.pulseLead,2);
	sweep = In.ar(e.sweep,2);
  out = kick+snare+hats+(bass*10)+feedbackBass+sawStab+pulseLead+sweep;
	out = out + (LPF.ar(HPF.ar(FreeVerb.ar(out,1,0.3,0.95),400),11000)/5);
	out = Compander.ar(out,out,0.1,1,1/8,0.01,0.2);
	Out.ar(0,out);
}.play;
)
( // helpers and music environment
e.tick = 0;
e.levels = [2];
e.beatLevel = 4;
e.pitchClassIndex = 0;
e.pitchClasses = [];
e.inputPitchClasses = [];
e.clearBeat=false;
e.beatPitchClasses = []!32;
e.beatPitchClassesStorage = [[[]]]!64;
e.states=[\tonnetz,\divisions,\length,\level,\octave,\globalEdit,\sequencerEdit,\clearBeat];
e.sequencerEditStates=[\sequencerEdit,\instrument];
e.topButtonStates=0!8;
e.globalEditStates=[\globalEdit,\beatPitchClassesLength,\saveBeatPitchClasses,\loadBeatPitchClasses];
e.state=e.states[0];
e.sequencerEditState=e.sequencerEditStates[0];
e.globalEditState=e.globalEditStates[0];
e.instruments = [\feedbackBass,\sawStab,\pulseLead,\kick,\hats,\snare];
e.sequencers = (divisions:5,length:8,level:4,octave:4,instrument:\feedbackBass,\player:\chordPlayer)!3;
e.thisBeatSequencerSettings=()!e.sequencers.size;
e.perBeatSequencerSettings={()!e.sequencers.size}!32;
e.selectedSequencer=0;
e.sequencers.size.do({|inc|
  e.sequencers[inc].player=[\notePlayer,\chordPlayer].clipAt(inc);
  e.sequencers[inc].divisions=4;
  e.sequencers[inc].length=8;
  e.sequencers[inc].level=[5,4,5].clipAt(inc);
  e.sequencers[inc].octave=[2,5,6].wrapAt(inc);
  e.sequencers[inc].instrument=e.instruments[inc];
  e.sequencers[inc].muted=false;
});
~lvl2ticks = { |lvl|
	var product = 1;
	(lvl).do({ |inc| product = product * e.levels.clipAt(inc);});
	product;
};
~lvl2seconds = { |lvl|
  ~lvl2ticks.(lvl)*t.beatDur/~lvl2ticks.(e.beatLevel);
};
~ifIsBoundary = { |lvl,rhythm,func|
	var boundary = (e.tick/~lvl2ticks.(lvl)).asInteger;
	if(((e.tick%~lvl2ticks.(lvl))==0).and(rhythm.wrapAt(boundary)>0),{
		func.(e.tick,boundary);
	});
};
~getBeat = {(e.tick/~lvl2ticks.(e.beatLevel)).asInteger;};
~bjork={|nPegs=1,nHoles=1|
  var pegs,holes,lastPegIndex,work;pegs=[];holes=[];
  nHoles=nHoles-nPegs;
  pegs=[1]!nPegs;holes=[0]!nHoles;
  lastPegIndex=(-1);
  work={
    if(lastPegIndex!=(-1),{
      holes=pegs[lastPegIndex..(pegs.size-1)];
      pegs=pegs[0..(lastPegIndex-1)];
    });
    nPegs=pegs.size;nHoles=holes.size;
    nHoles.do({|inc|pegs[inc%nPegs]=pegs[inc%nPegs]++holes[inc];});
    lastPegIndex=nHoles%nPegs;
  };
  work.();while({(lastPegIndex!=0).and(lastPegIndex!=(nPegs-1))},work);
  pegs.flat;
};
)
( // music loop
e.players = ();
e.players.chordPlayer = {|sequencer|
  ~ifIsBoundary.(sequencer.level,~bjork.(sequencer.divisions,sequencer.length),{|tick,boundary|
    sequencer.voices.do({|voice| if(voice.isRunning,{voice.release;/*voice.free;*//* bkmk */});});
    e.pitchClasses.do({|pitchClass|
      while({pitchClass<(12*sequencer.octave)},{pitchClass=pitchClass+12});
      sequencer.voices=sequencer.voices++[Synth(sequencer.instrument,[\outBus,e[sequencer.instrument],\freq,pitchClass.midicps,\amp,0.025]).register];
    });
  });
};
e.players.notePlayer = {|sequencer|
  ~ifIsBoundary.(sequencer.level,~bjork.(sequencer.divisions,sequencer.length),{|tick,boundary|
    sequencer.voices.do({|voice| if(voice.isRunning,{voice.release;});});
    if(e.pitchClasses.size>0,{
      var pitchClass = e.pitchClasses; pitchClass = pitchClass.sort({|a,b| a>b;});
      pitchClass = pitchClass.wrapAt(e.pitchClassIndex);
      e.pitchClassIndex = e.pitchClassIndex+1;
      while({pitchClass<(12*sequencer.octave)},{pitchClass=pitchClass+12});
      sequencer.voices=sequencer.voices++[Synth(sequencer.instrument,[\outBus,e[sequencer.instrument],\freq,pitchClass.midicps,\amp,0.025]).register];
    });
  });
};
e.players.drumPlayer = {|sequencer|
  ~ifIsBoundary.(sequencer.level,~bjork.(sequencer.divisions,sequencer.length),{|tick,boundary|
    Synth(sequencer.instrument,[\outBus,e[sequencer.instrument],\amp,0.025]);
  });
};
~metro = {
  ~ifIsBoundary.(e.beatLevel,[1],{|tick,boundary|
    if(e.inputPitchClasses.size>0,{e.beatPitchClasses.wrapPut(~getBeat.(),e.inputPitchClasses++[]);});
  });
  /*
  ~ifIsBoundary.(e.beatLevel,[1],{|tick,boundary| // bkmk - save current sequencer settings to last beat
    var beatSequencerSettings = e.perBeatSequencerSettings.wrapAt(boundary);
    e.sequencers.size.do({|inc|
      e.sequencers[inc].keysValuesDo({|key,value|
        if(key!=\voices,{e.perBeatSequencerSettings.wrapAt(boundary-1)[inc][key]=value;});
      });
    });
    beatSequencerSettings.size.do({|inc| // bkmk - load sequencer settings for beat
      beatSequencerSettings[inc].keysValuesDo({|key,value|
        if(key!=\voices,{e.sequencers[inc][key]=value;});
      });
    });
  });*/
  e.sequencers.do({|sequencer|
    e.pitchClasses = [];
    if(e.beatPitchClasses.wrapAt(~getBeat.()).size>0,{
      e.pitchClasses=e.beatPitchClasses.wrapAt(~getBeat.());},{
        e.pitchClasses=e.inputPitchClasses;});
    // --- START TEST --- //
    //e.pitchClasses=Scale.minor.performDegreeToKey([0,2,4]+[0,3,5,4].wrapAt((e.tick/(2**6)).floor));
    // ---  END TEST  --- //
    if(sequencer.muted==false,{e.players[sequencer.player].(sequencer);});
  });
  // --- TEMPORARY DRUMS --- //
  ~ifIsBoundary.(3,~bjork.(5,16),{|tick, boundary|
    Synth(\kick,[\outBus,e.kick]);
	});
  ~ifIsBoundary.(5,[0,1],{|tick, boundary|
    Synth(\snare,[\outBus,e.snare,\amp,0.15]);
  });
  ~ifIsBoundary.(2,~bjork.(2,8),{|tick, boundary|
    Synth(\hats,[\outBus,e.hats,\amp,0.01*2/3]);
  });
  // ----------------------- //
	e.tick = e.tick + 1;1/~lvl2ticks.(e.beatLevel);
};
)
( // synthdefs
SynthDef(\kick, {|amp = 0.1, outBus = 0|
    var pitchEnv, ampEnv, tone, out;
    ampEnv = EnvGen.ar(Env([0,1,0],[0.005,0.15]), doneAction: 2);
    pitchEnv = EnvGen.ar(Env([1,0],[0.1]));
    pitchEnv = pitchEnv**20;
    tone = SinOsc.ar((pitchEnv*1000)+55, 0, ampEnv);
    out = Mix.ar(tone*amp);
    Out.ar(outBus, out!2);
}).store;
SynthDef(\snare, {|amp = 0.1, dur = 0.125, outBus = 0|
	var body, snare, stick, resoEnv, out;
	resoEnv = EnvGen.ar(Env([0.01,1,0.01],[0.005,dur]));
	snare = PinkNoise.ar();
	snare = BPF.ar(snare, [200,400,1000,5000], resoEnv)*4;
	snare = snare + (BPF.ar(PinkNoise.ar(),[7000,11000],0.8)/2);
	snare = snare*EnvGen.ar(Env([0,1,0],[0.005, dur]), doneAction:2)/2;
	snare = LPF.ar(HPF.ar(snare, 500),10000);
	stick = WhiteNoise.ar();
	stick = BPF.ar(stick, [1000,2000,3000], resoEnv/3);
	stick = stick*EnvGen.ar(Env([0,1,0],[0.001, 0.04]));
	body = HPF.ar(SinOsc.ar(EnvGen.ar(Env([1,0],[0.01]))*400+30),180);
	body = LPF.ar(body, 200)/2;
	out = HPF.ar(stick+snare+body,220)*amp;
	Out.ar(outBus, out!2);
}).store;
SynthDef(\hats, {|amp = 0.1, outBus = 0|
  var noise, env, out;
  env = EnvGen.ar(Env([0,1,0],[0.001,0.05]), doneAction:2);
  noise = BPF.ar(WhiteNoise.ar(), [5000,7000,11000], 1*env);
  out = Mix.ar(env * noise * amp);
  Out.ar(outBus, out!2);
}).store;
SynthDef(\bass,{|freq=110, gate=1, dur=0.3, amp=0.1, timbre = 0, outBus = 0|
  var tone, env, out;
  tone = LPF.ar(Pulse.ar([freq,freq*10],[0.25,0.05]), freq+(freq*7*timbre));
  env = EnvGen.ar(Env.adsr(0.005,0.15,0.5,0.005), gate, doneAction:2);
  out = Mix.ar(tone * env * amp);
  Out.ar(outBus, out!2);
}).store;
SynthDef(\feedbackBass,{|freq=110, gate=1, dur=0.3, amp=0.1, outBus=0|
    var out, env, feedback;
  feedback=LocalIn.ar(2);
  env=EnvGen.ar(Env.adsr(0.001,0.2,0.5,0.001),gate,doneAction:2);
  freq=freq+SinOsc.ar(9,0,1);
  out=Mix.ar(Saw.ar([freq,freq*1.0123456,freq*0.98765,freq*4,freq*3]+(feedback[0]*freq)))/4;
  out=out*((-22).dbamp);
  out=[out,out]+DelayC.ar(feedback,1,1/freq/1.01);
  LocalOut.ar(out*0.8);
  Out.ar(outBus, out);
}).store;
SynthDef(\sawStab,{|freq=440, gate=1, dur=0.3, amp=0.1, outBus=0|
	var out, env, vibrato;
  env = EnvGen.ar(Env.adsr(0.005,1,-4.5.dbamp,0.2),gate,doneAction:2);
	vibrato = SinOsc.ar(8)*freq/50;
	out = HPF.ar(LPF.ar(Saw.ar(Mix.ar(freq+vibrato)+[0,5,-5])*env,freq*9),freq*3);
	out = out*amp*2;
	Out.ar(outBus, out!2);
}).store;
SynthDef(\pulseLead,{|freq=440, gate=1, dur=0.4, amp=0.1, outBus=0|
	var out, env, pulseMod;
	pulseMod = SinOsc.ar(7,0,1/2,1/2);
  env = EnvGen.ar(Env.adsr(0.001,0.5,-15.dbamp,1),gate,doneAction:2);
	out = Pulse.ar(freq, pulseMod)*env;
	out = out * amp;
	Out.ar(outBus, out!2);
}).store;
SynthDef(\sweep,{|dur=1, startFreq=200, endFreq=8000, startAmp=0.001, endAmp=0.1, outBus=0|
	var out, ampEnv, freqEnv;
	ampEnv = EnvGen.ar(Env([startAmp,endAmp],[dur]),doneAction:2);
	freqEnv = EnvGen.ar(Env([startFreq,endFreq],[dur]),doneAction:2);
	out = BPF.ar(PinkNoise.ar(),freqEnv,0.3)*ampEnv;
	out = HPF.ar(out, 400);
	Out.ar(outBus, out!2);
}).store;
)
( // launchpad input handling
MIDIClient.init;
l = ();
l.midisource=MIDIClient.sources.detect{|a|a.name.contains("Launchpad")};
l.mididestination=MIDIClient.destinations.detect{|a|a.name.contains("Launchpad")};
l.midirecv=MIDIIn.connect(0,l.midisource.uid);
l.midiout=MIDIOut(0,l.mididestination.uid);
l.midirecv.noteOn={|src,chan,num,val| var x,y;
  x=num&0x0f; y=(num&0xf0)>>4;
  if((x<8).and(y<8),{
    e.state.switch(
      \tonnetz,{if(x>7,{e.sequencers[y].muted=(e.sequencers[y].muted==false);});
        e.inputPitchClasses=e.inputPitchClasses++[((x*3)+(y*4))%12];},
      \divisions,{e.sequencers[y].divisions=x+1;},
      \length,{e.sequencers[y].length=x+1;},
      \level,{e.sequencers[y].level=x;},
      \octave,{e.sequencers[y].octave=x;},
      \clearBeat,{e.clearBeat=true;if(x>7,{},{e.beatPitchClasses.wrapPut(x+(y*8),[]);});},
      \globalEdit,{
        if(x>7,{e.selectedSequencer=y;},{
          e.globalEditState.switch(
            \globalEdit,{e.globalEditState=e.globalEditStates.clipAt(x+1);});
        });
      },
      \sequencerEdit,{
        if(x>7,{e.selectedSequencer=y;},{
          e.globalEditState.switch(\instrument,{
            e.sequencers[e.selectedSequencer].instrument=e.instruments.clipAt(x+(y*8));
          });
        });
    });
  });
};
l.midirecv.noteOff={|src,chan,num,val| var x,y;
  x=num&0x0f; y=(num&0xf0)>>4;
  e.state.switch(
    \tonnetz,{if((x<8).and(y<8),{e.inputPitchClasses.take(((x*3)+(y*4))%12);});},
    \clearBeat,{e.clearBeat=false;});
};
l.midirecv.control={|src,chan,num,val|
  if(val>0,{
    var newState=0;
    num=num-104;
    e.topButtonStates[num]=[1,0][e.topButtonStates[num]];
    8.do({|inc| newState=newState+(e.topButtonStates[inc]*(2**inc))});
    e.state=e.states.clipAt(newState);
    e.globalEditState=e.globalEditStates[0];
    e.topButtonStates.postln;
  });
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
)
( // display loop
~displayHandler={
  l.greenTopBarBuffer=0!8; l.redTopBarBuffer=0!8;
  l.greenSideBarBuffer=0!8; l.redSideBarBuffer=0!8;
  l.greenDisplayBuffer=0!64; l.redDisplayBuffer=0!64;
  //8.do({|inc| if(e.topButtonStates[inc]==1,{e.greenTopBarBuffer[inc] = 3;});});
  e.sequencers.size.do({|inc| if(e.sequencers[inc].muted==true,{l.redSideBarBuffer[inc]=3;});});
  e.state.switch(\tonnetz,{
    64.do({|inc| var x,y; x=inc&3; y=inc>>3;
      if(e.inputPitchClasses.size>0,{if(e.inputPitchClasses.indexOf(((x*3)+(y*4))%12)!=nil,{l.greenDisplayBuffer[inc]=3;});});
    });
    64.do({|inc| var x,y; x=inc&3; y=inc>>3;
      if(e.pitchClasses.size>0,{if(e.pitchClasses.indexOf(((x*3)+(y*4))%12)!=nil,{l.redDisplayBuffer[inc]=3;});});
    });
  },\divisions,{
      e.sequencers.size.do({|sequencer| 8.do({|cell|
        if(cell<e.sequencers[sequencer].divisions,{l.greenDisplayBuffer[cell+(sequencer*8)]=3;});});});
  },\length,{
      e.sequencers.size.do({|sequencer| 8.do({|cell|
        if(cell<e.sequencers[sequencer].length,{l.greenDisplayBuffer[cell+(sequencer*8)]=3;});});});
  },\level,{
      e.sequencers.size.do({|sequencer| 8.do({|cell|
        if(cell<=e.sequencers[sequencer].level,{l.greenDisplayBuffer[cell+(sequencer*8)]=3;});});});
  },\octave,{
      e.sequencers.size.do({|sequencer| 8.do({|cell|
        if(cell<=e.sequencers[sequencer].octave,{l.greenDisplayBuffer[cell+(sequencer*8)]=3;});});});
  },\globalEdit,{
  },\sequencerEdit,{
      l.greenSideBarBuffer[e.selectedSequencer]=3;
      e.sequencerEditState.switch(\instrument,{
        l.greenDisplayBuffer[e.instruments.indexOf(e.sequencers[e.selectedSequencer].instrument)]=3;
      });
  },\clearBeat,{
      if(e.beatPitchClasses.size>64,{64},{e.beatPitchClasses.size}).do({|inc|
        if(e.beatPitchClasses[inc]!=nil,{
          if(e.beatPitchClasses[inc].size>0,{
            l.greenDisplayBuffer[inc]=3;
          });
        });
      });
  });
  l.draw.();
  1/5;
};
)
(
c=SystemClock.sched(0,{~displayHandler.();});
)
( // start the music!
t=TempoClock(140/60).schedAbs(0,{~metro.();});
)
(
Server.default.makeGui;
)