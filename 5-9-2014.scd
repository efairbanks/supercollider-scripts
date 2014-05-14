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
e.sawStab = Bus.audio(s,2);
e.pulseLead = Bus.audio(s,2);
e.sweep = Bus.audio(s,2);
)
( // mixer
e.mixer.free;
e.mixer = {
	var kick, snare, hats, bass, sawStab, pulseLead, sweep, out;
	kick = In.ar(e.kick,2);
	snare = In.ar(e.snare,2)+BPF.ar(FreeVerb.ar(In.ar(e.snare,2),1,0.99,0.9),1000,1,1/4);
	hats = In.ar(e.hats,2);
	bass = In.ar(e.bass,2);
	sawStab = Compander.ar(FreeVerb.ar(In.ar(e.sawStab,2),1/4,0.8,0.8),bass,0.025,1,1/4,0.001,0.2);
	pulseLead = In.ar(e.pulseLead,2);
	sweep = In.ar(e.sweep,2);
  out = kick+snare+hats+(bass*3)+sawStab+pulseLead+sweep;
	out = out + (LPF.ar(HPF.ar(FreeVerb.ar(out,1,0.3,0.95),400),11000)/5);
	out = Compander.ar(out,out,0.1,1,1/8,0.01,0.2);
	Out.ar(0,out);
}.play;
)
( // helpers and music environment
e.tick = 0;
e.levels = [2];
e.beatLevel = 4;
e.state=\tonnetz;
e.states=[\tonnetz,\divisions,\length,\level,\octave,\f,\g,\h];
e.pitchClasses = [];
e.inputPitchClasses = [];
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
e.scale = Scale.aeolian;
e.instruments = [\bass,\sawStab,\pulseLead];
e.players = (divisions:5,length:8,level:4,octave:4,instrument:\bass)!3;
e.players.size.do({|inc|
  e.players[inc].divisions=4;
  e.players[inc].length=8;
  e.players[inc].level=3+inc;
  e.players[inc].octave=4+inc;
  e.players[inc].instrument=e.instruments[inc];
});
e.beatPitchClasses = []!16;
~metro = {
  /*
  ~ifIsBoundary.(6,[1],{|tick, boundary|
    var prog = [0,1,2,3,4,5,6,7]*4;
    e.tempPitchClasses=[];
    3.do({|inc|
      e.tempPitchClasses=e.tempPitchClasses++(e.scale.performDegreeToKey(prog.reverse.wrapAt(boundary)+(inc*2))%12);
    });
  });
  ~ifIsBoundary.(3,[1],{|tick, boundary|
    e.pitchClasses=[];
    if(~bjork.(16,16).wrapAt(boundary)==1,{e.pitchClasses=e.tempPitchClasses;});
  });
  */
  // --- //
  ~ifIsBoundary.(e.beatLevel,[1],{|tick,boundary|
    if(e.inputPitchClasses.size>0,{e.beatPitchClasses.wrapPut(~getBeat.(),e.inputPitchClasses++[]);});
    (~getBeat.()%e.beatPitchClasses.size).postln;
    e.beatPitchClasses.wrapAt(~getBeat.()).postln;
  });
  // --- //
  e.players.do({|player|
    e.pitchClasses = [];
    if(e.beatPitchClasses.wrapAt(~getBeat.()).size>0,{
      e.pitchClasses=e.beatPitchClasses.wrapAt(~getBeat.());},{
        e.pitchClasses=e.inputPitchClasses;});
    ~ifIsBoundary.(player.level,~bjork.(player.divisions,player.length),{|tick,boundary|
      e.pitchClasses.do({|pitchClass|
        while({pitchClass<(12*player.octave)},{pitchClass=pitchClass+12});
        Synth(player.instrument,[\outBus,e[player.instrument],\freq,pitchClass.midicps,\amp,0.025]);
      });
    });
  });
  // --- //
  ~ifIsBoundary.(4,~bjork.(3,8),{|tick, boundary|
    Synth(\kick,[\outBus,e.kick]);
	});
  ~ifIsBoundary.(5,[0,1],{|tick, boundary|
    Synth(\snare,[\outBus,e.snare,\amp,0.15]);
  });
  ~ifIsBoundary.(2,~bjork.(9,16),{|tick, boundary|
    Synth(\hats,[\outBus,e.hats,\amp,0.01*2/3]);
  });
  /*
  ~ifIsBoundary.(4,~bjork.(3,5),{|tick, boundary|
    e.pitchClasses.do({|pitchClass|
      while({pitchClass<55},{pitchClass=pitchClass+12});
      Synth(\sawStab,[\outBus,e.sawStab,\freq,pitchClass.midicps]);
    });
  });
  ~ifIsBoundary.(3,~bjork.(3,5),{|tick, boundary|
    if(e.pitchClasses.size>0,{
      var pitchClass = e.pitchClasses.at(0);
      while({pitchClass<30},{pitchClass=pitchClass+12;});
      Synth(\bass,[\outBus,e.bass,\freq,pitchClass.midicps,\amp,2/3]);
    });
  });
  ~ifIsBoundary.(3,~bjork.(5,9)*0,{|tick, boundary|
    if(e.pitchClasses.size>0,{
      var pitchClass = e.pitchClasses.wrapAt(boundary);
      while({pitchClass<65},{pitchClass=pitchClass+12;});
      Synth(\pulseLead,[\outBus,e.pulseLead,\freq,pitchClass.midicps,\amp,1/40]);
      Synth(\pulseLead,[\outBus,e.pulseLead,\freq,pitchClass.midicps*3,\amp,1/100]);
    });
  });
  */
	e.tick = e.tick + 1;1/~lvl2ticks.(e.beatLevel);
};
)
( // start the music!
t=TempoClock(140/60).schedAbs(0,{~metro.();});
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
SynthDef(\bass,{|freq=110, dur=0.3, amp=0.1, timbre = 0, outBus = 0|
    var tone, env, out;
    tone = LPF.ar(Pulse.ar([freq,freq*10],[0.25,0.05]), freq+(freq*7*timbre));
    env = EnvGen.ar(Env([0,1,1/3,0],[0.01, dur/10, dur*9/10]), doneAction:2);
    out = Mix.ar(tone * env * amp);
    Out.ar(outBus, out!2);
}).store;
SynthDef(\sawStab,{|freq=440, dur=0.3, amp=0.1, outBus=0|
	var out, env, vibrato;
	env = EnvGen.ar(Env([0,1,1,0],[0.005,dur,0.02]),doneAction:2);
	vibrato = SinOsc.ar(8)*freq/50;
	out = HPF.ar(LPF.ar(Saw.ar(Mix.ar(freq+vibrato)+[0,5,-5])*env,freq*9),freq*3);
	out = out*amp;
	Out.ar(outBus, out!2);
}).store;
SynthDef(\pulseLead,{|freq=440, dur=0.4, amp=0.1, outBus=0|
	var out, env, pulseMod;
	pulseMod = SinOsc.ar(7,0,1/2,1/2);
	env = EnvGen.ar(Env([0,1,0],[0.001,dur,0.01]),doneAction:2);
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
  if(x>7,{e.state=e.states[y];});
  if((x<8).and(y<8),{
    e.state.switch(
      \tonnetz,{e.inputPitchClasses=e.inputPitchClasses++[((x*3)+(y*4))%12];},
      \divisions,{e.players[y].divisions=x+1;},
      \length,{e.players[y].length=x+1;},
      \level,{e.players[y].level=x;},
      \octave,{e.players[y].octave=x;});
  });
};
l.midirecv.noteOff={|src,chan,num,val| var x,y;
  x=num&0x0f; y=(num&0xf0)>>4;
  e.state.switch(
    \tonnetz,{if((x<8).and(y<8),{e.inputPitchClasses.take(((x*3)+(y*4))%12);});});
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
( // input loop
c=SystemClock.sched(0,{
  l.greenSideBarBuffer=0!8; l.redSideBarBuffer=0!8;
  l.greenSideBarBuffer[e.states.indexOf(e.state)]=3;
  l.greenDisplayBuffer=0!64;
  l.redDisplayBuffer=0!64;
  e.state.switch(\tonnetz,{
    64.do({|inc| var x,y; x=inc&3; y=inc>>3;
      if(e.inputPitchClasses.size>0,{if(e.inputPitchClasses.indexOf(((x*3)+(y*4))%12)!=nil,{l.greenDisplayBuffer[inc]=3;});});
    });
    64.do({|inc| var x,y; x=inc&3; y=inc>>3;
      if(e.pitchClasses.size>0,{if(e.pitchClasses.indexOf(((x*3)+(y*4))%12)!=nil,{l.redDisplayBuffer[inc]=3;});});
    });
  },\divisions,{
      e.players.size.do({|player| 8.do({|cell|
        if(cell<e.players[player].divisions,{l.greenDisplayBuffer[cell+(player*8)]=3;});});});
  },\length,{
      e.players.size.do({|player| 8.do({|cell|
        if(cell<e.players[player].length,{l.greenDisplayBuffer[cell+(player*8)]=3;});});});
  },\level,{
      e.players.size.do({|player| 8.do({|cell|
        if(cell<=e.players[player].level,{l.greenDisplayBuffer[cell+(player*8)]=3;});});});
  },\octave,{
      e.players.size.do({|player| 8.do({|cell|
        if(cell<=e.players[player].octave,{l.greenDisplayBuffer[cell+(player*8)]=3;});});});
  });
  l.draw.();
  1/5;
});
)