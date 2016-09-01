(
~arrayAsBits={|array| var ret=0;
  array=array.reverse;
  array.size.do({|inc|ret=(2**inc)*array[inc]+ret;});
  ret;
};
~displayHandler={ var gridOffset;
  l.greenTopBarBuffer=0!8; l.redTopBarBuffer=0!8;
  l.greenSideBarBuffer=0!8; l.redSideBarBuffer=0!8;
  l.greenDisplayBuffer=0!64; l.redDisplayBuffer=0!64;
  l.topRow.size.do({|inc|l.greenTopBarBuffer[inc]=l.topRow[inc]*3;});
  gridOffset=~arrayAsBits.(l.topRow)*64;
  64.do({|inc|
    l.greenDisplayBuffer[inc]=l.grid[inc+gridOffset]*2;
    l.redDisplayBuffer[inc]=l.grid[inc+gridOffset]*3;
  });
  l.draw.();
  1/5;
};
l = ();
l.grid=0!(256*8*8);
l.topRow=0!8;
MIDIClient.init;
l.midisource=MIDIClient.sources.detect{|a|a.name.contains("Launchpad")}.uid;
l.midikbdsource=MIDIClient.sources.detect{|a|a.name.contains("E-MU Xboard49")}.uid;
l.mididestination=MIDIClient.destinations.detect{|a|a.name.contains("Launchpad")}.uid;
l.midirecv=MIDIIn.connect(0,l.midisource);
l.midikbdrecv=MIDIIn.connect(0,l.midikbdsource);
l.midiout=MIDIOut(0,l.mididestination);
l.midirecv.noteOn={|src,chan,num,val| var x,y;
  if(src==l.midisource,{
    x=num&0x0f; y=(num&0xf0)>>4;
    [x,y,\on].postln;
    if((x<8).and(y<8),{
      var gridOffset=~arrayAsBits.(l.topRow)*64;
      l.grid[y*8+x+gridOffset]=if(l.grid[y*8+x+gridOffset]==0,{1},{0});
    });
  },{e.notes=e.notes.add(num%12);});
};
l.midirecv.noteOff={|src,chan,num,val| var x,y;
  if(src==l.midisource,{
    x=num&0x0f; y=(num&0xf0)>>4;
    [x,y,\off].postln;
  },{e.notes.remove(num%12);});
};
l.midirecv.control={|src,chan,num,val|
  num=num-104;
  [num,(0:\off,127:\on)[val]].postln;
  if(val>0,{l.topRow[num]=if(l.topRow[num]==0,{1},{0});});
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
c=SystemClock.sched(0,{~displayHandler.();});
)
(
~beats2secs={|beats,bpm| beats*60/bpm};
e=nil;
if(e==nil,{
  e=();
  e.voices=();
  e.notes=[];
  e.beat=0;
  e.break=Buffer.read(s, Platform.resourceDir+/+"sounds/action.wav");
  e.breakLookup=(0:[8,14],1:[14,6],2:[6,8,14],3:[4,12],4:[0]);
  e.levelBjorkSelects=(0:[32],1:[16],2:[12],3:[4],4:[2]);
  e.bjorkHoles=32;
  e.recordLength=e.bjorkHoles*8;
  e.levelBeats=();
  e.maxLevel=4;
  e.bpm=160;
  e.metro=TempoClock(e.bpm/15).sched(0,{e.run.();e.beat=e.beat+1;1;});
});
e.metro.tempo=50/15;
~bjork={|nPegs=1,nHoles=1|
  var pegs,holes,lastPegIndex,work;pegs=[];holes=[];
  if(nPegs>0,{
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
  },{0!nHoles});
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
~playMulti={|alias,synth,paramset|
  if(e.voices[alias]!=nil,{
    e.voices[alias].do({|voice|
      if(voice.isRunning,{
        voice.release;
      });
    });
  });
  e.voices[alias]=[];
  paramset.do({|params|
    e.voices[alias]=e.voices[alias].add(Synth(synth,params).register);
  });
};
~getPattern={
  var ret, pattern;
  ret=0!e.bjorkHoles;
  pattern=1!e.bjorkHoles;
  (e.maxLevel+1).do({|inc|
    pattern=~bjorkSelect.(e.levelBjorkSelects[inc].wrapAt(0),pattern);
    ret=ret+pattern;
  });
  ret;
};
~processTick={
  var level;
  if(l!=nil,{
    5.do({|inc| e.levelBjorkSelects[inc]=[~arrayAsBits.(l.grid.copyRange(inc*8,(inc+1)*8-1))];});
  });
  level=~getPattern.().wrapAt(e.beat)-1;
  if(e.levelBeats[level]==nil,{e.levelBeats[level]=0;});
  e.levelBeats[level]=e.levelBeats[level]+1;
};
~dummyChords={
  var progA=[[0,3,6,9]-1,[0,3,7]].wrapAt(e.beat/32)+[7,0].wrapAt(e.beat/64)+[11,0].wrapAt(e.beat/128);
  var min3=[0,3,7];
  var maj3=[0,4,7];
  e.notes=[[0,3,6]-1+7,[0,4,7,10]+7,[-1,3,6],[0,3,7]].wrapAt(e.beat/(7*11/2));
  e.notes=progA;
  e.notes=[0,3,7]+((e.beat/32).floor*5);
  e.notes=e.notes%12;
  //e.notes=[maj3,min3,min3,maj3].wrapAt(e.beat/32)+[0,11,4,9].wrapAt(e.beat/32);
  if(x!=nil,{
    x.keyStates.keys.do({|key|
      //e.notes=e.notes.add(key%12);
    });
  });
};
~changeDivisions={
  var level, paramset;
  level=~getPattern.().wrapAt(e.beat)-1;
  paramset=[];
  if(e.beat%16==0,{
    e.levelBjorkSelects=(
      0:[64],
      1:[32],
      2:[19],
      3:[[8],[9],[10],[11],[13]].wrapAt(e.beat/64),
      4:[[4],[5],[6],[7]].wrapAt(e.beat/32));
      //3:[[4]].wrapAt(e.beat/64),
      //4:[[2]].wrapAt(e.beat/32));
  });
};
(
e.run={
  ~dummyChords.();
  ~processTick.();
  ~changeDivisions.();
  ~sampledDrums.();
  ~bass.();
  ~stab.();
  ~pads.();
  ~arp.();
  ~noise.();
  ~swish.();
};
~sampledDrums={
  var level=~getPattern.().wrapAt(e.beat)-1;
  if(e.breakLookup[level].size>0,{
    if(level>(-1),{
      Synth(\break,[
        \bufnum,e.break.bufnum,
        \offset,e.breakLookup[level].wrapAt(e.levelBeats[level])/~level2beats.(e.maxLevel),
        \dur,(0.12/(1.65**e.maxLevel))*(2**level),
        \amp,(1.3/(1.35**e.maxLevel))*(1.3**level),\outBus,e.drumsBus]);
    });
  });
};
~stab={
  var level, paramset;
  level=~getPattern.().wrapAt(e.beat)-1;
  paramset=[];
  if([3].includes(level),{
    e.notes.do({|note|
      while({note<70},{note=note+12});
      paramset=paramset.add([\freq,note.midicps,\amp,-10.dbamp]);
    });
    //~playMulti.(\stab,\chippads,paramset);
   });
  if([1].includes(level),{
    ~playMulti.(\stab,\chippads,[]);
  });
};
~bass={
  var level, paramset;
  level=~getPattern.().wrapAt(e.beat)-1;
  paramset=[];
  if([4,3].includes(level),{
    if((e.notes!=nil).and(e.notes.size>0),{
      var note=e.notes[0];
      while({note<27},{note=note+12});
      note=note+[0,12].wrapAt(e.beat/2);
      //~playMulti.(\bass,\roughneckbass,[[\freq,note.midicps]]);
    },{~playMulti.(\bass,\roughneckbass,[]);});
  });
  if([1].includes(level),{
    ~playMulti.(\bass,\roughneckbass,[]);
  });
  nil;
};
~pads={
  var level, paramset;
  level=~getPattern.().wrapAt(e.beat)-1;
  paramset=[];
  if([4,3,2].includes(level),{
    e.notes.do({|note|
      while({note<40},{note=note+12});
      note=note+[0,24].wrapAt(level);
      paramset=paramset.add([\freq,note.midicps,\amp,-7.dbamp,\dur,3]);
    });
    //~playMulti.(\superSaw,\superSaw,paramset);
   });
  if([0].includes(level),{
    ~playMulti.(\superSaw,\superSaw,[]);
  });
};
~arp={
  var level, paramset;
  level=~getPattern.().wrapAt(e.beat)-1;
  paramset=[];
  if([4,2,1].includes(level),{
    if((e.notes!=nil).and(e.notes.size>0),{
      var note=e.notes[0];
      while({note<(48-24)},{note=note+12});
      //note=note+[0,-17,-12].wrapAt(level);
      //~playMulti.(\arp,\acid,[[\freq,note.midicps,\amp,-16.dbamp,\dur,(1/(2**e.maxLevel))*(2**level)]]);
    });
  });
  if([1].includes(level),{
    ~playMulti.(\arp,\acid,[]);
  });
  nil;
};
~noise={
  var level, paramset;
  level=~getPattern.().wrapAt(e.beat)-1;
  paramset=[];
  if([3,2,4].includes(level),{
    ~playMulti.(\arp,\noiseHit,[[\freq,500*[15,2,11,4].wrapAt(level),\amp,-5.dbamp,\dur,(1.1/(2**e.maxLevel))*(1.55**level)]]);
  });
};
~swish={
  var level, paramset;
  level=~getPattern.().wrapAt(e.beat)-1;
  paramset=[];
  if([3,2,4,1].includes(level),{
    ~playMulti.(\arp,\swish,[[\freq,1200*[11,11,0.1,6,14].wrapAt(level),\amp,1.dbamp,\dur,(1.1/(2**e.maxLevel))*(1.85**level)]]);
  });
};
)
)
(
SynthDef(\break,{|offset=0.5,bufnum,dur=0.075,amp=0.5,outBus=0|
  var phasor, out, env, rate;
  rate = 1;
  env=EnvGen.ar(Env([0,1,0],[0.001,dur]),doneAction:2);
	phasor = Phasor.ar(1, BufRateScale.kr(bufnum)*rate,0,BufFrames.kr(bufnum))+(offset*BufFrames.kr(bufnum));
	out = BufRd.ar(1, bufnum, phasor)*env*amp;
  Out.ar(outBus,out!2);
}).store;
SynthDef(\acid,{|freq=55,dur=0.1,amp=0.5,outBus=0,gate=1|
  var out, env;
  //env = EnvGen.ar(Env([0,1,0],[0.005,dur],-5),doneAction:2);
  env = EnvGen.ar(Env.adsr(0.001,dur,0.0,0.0), gate, doneAction:2);
  out = RLPF.ar(Pulse.ar(freq,0.5)+Saw.ar(freq)/2,100+(5000*env),0.12);
  out = (out*3).tanh*amp*env;
  Out.ar(outBus,out!2);
}).store;
SynthDef(\fmpads,{|freq=800,dur=1,amp=0.5,outBus=0|
  var out, env;
  freq = freq + SinOsc.ar(Rand(0.01,0.3),0,freq/100);
  env = EnvGen.ar(Env([0,1,1/4,0],[0.005,0.1,dur-0.105]),doneAction:2);
  out = SinOsc.ar(freq/2)*(freq/2)*((7/8)-env)*8;
  out = SinOsc.ar(out+freq)*env*amp;
  out = LPF.ar(out,freq*2);
  Out.ar(outBus,out!2);
}).store;
SynthDef(\birdfx,{|freq=200,dur=10,amp=0.5,outBus=0|
  var out=0, env;
  env = EnvGen.ar(Env([0,1,0],[0.1,dur-0.1],-5),doneAction:2);
  10.do({
    out = out + [(Saw.ar(Rand(1.1,10.4))+1/2),(Saw.ar(Rand(1.1,10.4))+1/2)];
    out = Pulse.ar(freq+(Rand(200,2000)*out),0.25+(env/2))*amp*env;
  });
  Out.ar(outBus,out!2);
}).store;
SynthDef(\chippads,{|freq=800,dur=1,amp=0.5,outBus=0|
  var out, env;
  freq = freq*(1+Schmidt.ar(Pulse.ar(Rand(7,13)),0,0));
  env = EnvGen.ar(Env([0,1,1/4,0],[0.005,0.1,dur-0.105]),doneAction:2);
  out = Pulse.ar(freq)*env*amp;
  out = HPF.ar(out,freq*2);
  out = LPF.ar(out,freq*2);
  Out.ar(outBus,out!2);
}).store;
SynthDef(\slide,{|freq=440,dur=0.2,amp=0.5,outBus=0|
  var out, env;
  freq = EnvGen.ar(Env([1000,freq,freq],[0.07,dur-0.07]));
  env = EnvGen.ar(Env([0,1,1,0],[0.01,dur-0.02,0.01]),doneAction:2);
  out=Pulse.ar(freq,0.25+(env/2))*env*amp;
  Out.ar(outBus,out!2);
}).store;
SynthDef(\sinbass,{|freq=55,amp=0.5,outBus=0,gate=1|
  var env = EnvGen.ar(Env.adsr(0.01,0.4,0.8,0.05), gate, doneAction:2);
  Out.ar(outBus,LPF.ar(Pulse.ar(freq,0.5,amp)*env,freq)!2);
}).store;
SynthDef(\roughneckbass,{|freq=55,amp=0.5,outBus=0,gate=1|
  var env, out;
  env = EnvGen.ar(Env.adsr(0.001,0.07,2/3,0.075), gate, doneAction:2);
  out=(SinOsc.ar(freq+((SinOsc.ar([freq*2+SinOsc.ar(0.2,Rand(0,3.14*2)),freq*3+SinOsc.ar(0.3,Rand(0,3.14*2)),freq*7+SinOsc.ar(0.5,Rand(0,3.14*2))])*3).tanh*300))*1000).tanh;
  out=LPF.ar(out,env*16000+50);
  out=out*amp/21.5;
  Out.ar(outBus,out!2);
}).store;
SynthDef(\string, {|freq=440,amp=0.1,outBus=0,delay=0|
	var out, env;
	//freq = Rand(-1.0,1.0)*(freq/400)+freq;
	env = EnvGen.ar(Env([0,1,2/3,0],[0.005,0.15,1]),doneAction:2);
	out = PinkNoise.ar()*env;
	out = Pluck.ar(out, 1, freq.reciprocal, freq.reciprocal, 200,0.4);
	out = out*env*amp*10;
	out = DelayN.ar(out, 0.05, delay);
	Out.ar(outBus, out!2);
}).store;
SynthDef(\superSaw,{|freq=55,amp=0.1,outBus=0,gate=1|
  var env, out;
  env=EnvGen.ar(Env.adsr(0.01,0.4,0.8,0.05), gate, doneAction:2);
  out=Saw.ar([freq+({Rand(-1*freq/100,freq/100)}!30)]*[1,2,4])/(30*6);
  out=out*amp;
  out=out!2;
  Out.ar(outBus,out);
}).store;
SynthDef(\noiseHit,{|freq=1000,amp=0.1,dur=0.15,outBus=0,gate=1|
  var out, env;
  env=EnvGen.ar(Env([0,1,0],[0.005,dur]),doneAction:2);
  env=env**3;
  out=Ringz.ar(BPF.ar(PinkNoise.ar(0.1),freq*env+30,0.15), {exprand(300, 20000)}.dup(500)).mean;
  out=out*env*amp;
  Out.ar(outBus,out!2);
}).store;
SynthDef(\swish,{|freq=5000,amp=0.1,dur=0.5,outBus=0,gate=1|
  var out, env;
  env=EnvGen.ar(Env([0,1,0],[0.005,dur]),doneAction:2);
  env=env**3;
  out=Ringz.ar(BPF.ar(PinkNoise.ar(0.1),freq+SinOsc.ar(20,3.14,freq*env)+30,0.01), {exprand(300, 20000)}.dup(500)).mean;
  out=out*env*amp*10;
  Out.ar(outBus,out!2);
}).store;
)
)
