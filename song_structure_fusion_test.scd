(
e=nil;
if(e==nil,{
  e=();
  e.beat=0;
  //e.break=Buffer.read(s, Platform.resourceDir+/+"sounds/action.wav");
  //e.break=Buffer.read(s, Platform.resourceDir+/+"sounds/its_a_new_day.wav");
  //e.break=Buffer.read(s, Platform.resourceDir+/+"sounds/new_orleans.wav");
  //e.break=Buffer.read(s, Platform.resourceDir+/+"sounds/funky_drummer.wav");
  e.break=Buffer.read(s, Platform.resourceDir+/+"sounds/fools_gold.wav");
  e.breakLookup=(0:[9,8,5],1:[2,5,9,8,11],2:[8,5,3],3:[10,6],4:[0]);
  e.levelBjorkSelects=(0:[64],1:[32],2:[20],3:[8],4:[4]);
  e.bjorkHoles=64;
  e.levelBeats=();
  e.maxLevel=4;
  e.scale=Scale.melodicMinor;
  e.metro=TempoClock(140/15).sched(0,{e.run.();e.beat=e.beat+1;1;});
  e.bassBus=Bus.audio(s,2);
  e.chordBus=Bus.audio(s,2);
  e.drumsBus=Bus.audio(s,2);
  e.masterBus=Bus.audio(s,2);
  (
    e.mixer.free;
    e.mixer={
      var master=In.ar(e.masterBus,2);
      var bassBus=In.ar(e.bassBus,2);
      var drumsBus=In.ar(e.drumsBus,2);
      var chordBus=In.ar(e.chordBus,2);
      bassBus=Compander.ar(bassBus,bassBus,-48.dbamp,1,1/30,0.001,0.03)*15.5.dbamp;
      chordBus=Compander.ar(chordBus,chordBus,-48.dbamp,1,1/20,0.001,0.5)*17.dbamp;
      master=master+bassBus+drumsBus+chordBus;
      master=Compander.ar(FreeVerb.ar(master,-27.dbamp),master,-25.dbamp,1,-10.dbamp,0.005,0.15);
      master=master*20.dbamp;
      Out.ar(0,master);
    }.play;
  )
});
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
~buildStructures={
  var pattern=1!e.bjorkHoles;
  var finalPattern=0!e.bjorkHoles;
  e.level=~getLevel.(e.beat%~level2beats.(e.maxLevel),e.maxLevel);
  e.measureLength=(e.bjorkHoles/2);
  e.measure=(e.beat/e.measureLength).floor;
  e.levelBjorkSelects=(
    0:[64],
    1:[32],
    2:[16],
    3:[8],
    4:[4]
  );
  e.scale=[
    Scale.melodicMinor,
    Scale.minor,
    Scale.harmonicMinor
  ].wrapAt(e.measure/12);
  e.metro.tempo=[
    140/15,
    160/15,
    180/15,
    160/15
  ].wrapAt(e.measure/16);
  (e.maxLevel+1).do({|inc|
    pattern=~bjorkSelect.(e.levelBjorkSelects[inc].wrapAt(e.measure),pattern);
    finalPattern=finalPattern+pattern;
  });
  e.level=finalPattern.wrapAt(e.beat)-1;
  // --- //
  if(e.levelBeats[e.level]==nil,{e.levelBeats[e.level]=0;});
  e.levelBeats[e.level]=e.levelBeats[e.level]+1;
  // --- //
  e.degree=[[0,5,3,1],[0,2,4,6]].wrapAt(e.measure/16).wrapAt(e.measure);
  e.degree=e.degree+(3*((e.measure/2).floor%4));
  while({e.degree>6},{e.degree=e.degree-7;});
  e.degree=e.degree+[[0],[4,2],[2,5]].wrapAt(e.level).wrapAt(e.levelBeats[e.level]);
};
~acidBassline={
  Synth(\break,[
    \bufnum,e.break.bufnum,
    \offset,e.breakLookup[e.level].wrapAt(e.levelBeats[e.level])/~level2beats.(e.maxLevel),
    \dur,(0.14/(1.7**e.maxLevel))*(2**e.level),
    \amp,(0.6/(1.35**e.maxLevel))*(1.4**e.level),\outBus,e.drumsBus]);
  if([[0,1,2,3],[1,2,4],[2,3,4]].wrapAt(e.measure/8).includes(e.level),{
    if(~lastAcid!=nil,{~lastAcid.release(0.001);});
    ~lastAcid=Synth(\acid,[
      \freq,e.scale.degreeToFreq(e.degree, 55/2,[2,3,0,0,0].wrapAt(e.level)),
      \dur,(0.04/(1.1**e.maxLevel))*(2**e.level),
      \amp,(0.06/(1**e.maxLevel))*(1.4**e.level),\outBus,e.bassBus]);
  });
};
~fmPads={
  if([[0],[4],[3]].wrapAt(e.measure/16).includes(e.level),{
    4.do({|inc|
      var padsDegree = e.degree+(inc*2);
      while({padsDegree<25},{padsDegree=padsDegree+7;});
      Synth(\fmpads,[
        \freq,e.scale.degreeToFreq(padsDegree,55/2,0),
        \dur,(0.8/(1.6**e.maxLevel))*(2**e.level),
        \amp,(0.016/(1.2**e.maxLevel))*(1.4**e.level),\outBus,e.chordBus]);
    });
  });
};
~chipPads={
  if([[],[4],[],[3],[]].wrapAt(e.measure/16).includes(e.level),{
    2.do({|inc|
      var chipPadsDegree = e.degree+(inc*4);
      while({chipPadsDegree<35},{chipPadsDegree=chipPadsDegree+7});
      Synth(\chippads,[
        \freq,e.scale.degreeToFreq(chipPadsDegree,55/2,0),
        \dur,(0.8/(1.6**e.maxLevel))*(2**e.level),
        \amp,(0.012/(1.2**e.maxLevel))*(1.4**e.level),\outBus,e.chordBus]);
    });
  });
};
~slideSynth={
  if([[],[],[2]].wrapAt(e.measure/16).includes(e.level),{
    1.do({|inc|
      var slideDegree = e.degree+(inc*3);
      while({slideDegree<35},{slideDegree=slideDegree+7});
      Synth(\slide,[
        \freq,e.scale.degreeToFreq(slideDegree,55/2,0),
        \dur,(0.2/(1.6**e.maxLevel))*(2**e.level),
        \amp,(0.034/(1.8**e.maxLevel))*(1.4**e.level),\outBus,e.masterBus]);
    });
  });
};
~birdFX={
  if(e.beat%(e.measureLength*8)==0,{Synth(\birdfx,[\amp,0.009,\outBus,e.masterBus]);});
};
(
e.run={
  ~buildStructures.();
  if(e.breakLookup[e.level].size>0,{
    ~acidBassline.();
    ~fmPads.();
    ~chipPads.();
    ~slideSynth.();
    ~birdFX.();
  });
};
)
)
(
SynthDef(\break,{|offset=0.5,bufnum,dur=0.075,amp=0.5,outBus=0,rate=1|
  var phasor, out, env;
  env=EnvGen.ar(Env([0,1,0],[0.001,dur]),doneAction:2);
  phasor = Phasor.ar(1, BufRateScale.kr(bufnum)*rate,0,BufFrames.kr(bufnum))+(offset*BufFrames.kr(bufnum));
  out = BufRd.ar(1, bufnum, phasor)*env*amp;
  Out.ar(outBus,out!2);
}).store;
SynthDef(\acid,{|freq=55,dur=0.1,amp=0.5,outBus=0,width=0.5,gate=1|
  var outl, outr, env;
  //env = EnvGen.ar(Env([0,1,0],[0.005,dur],-5),doneAction:2);
  env = EnvGen.ar(Env.adsr(0.001,dur,0.0,0.0), gate, doneAction:2);
  outl = RLPF.ar(Pulse.ar(freq+(1*width),0.5)+Saw.ar(freq-(1*width))/2,100+(5000*env),0.12);
  outl = (outl*3).tanh*amp*env;
  outr = RLPF.ar(Pulse.ar(freq-(1*width),0.5)+Saw.ar(freq+(1*width))/2,100+(5000*env),0.12);
  outr = (outr*3).tanh*amp*env;
  Out.ar(outBus,[outl,outr]);
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
SynthDef(\sitar,{|freq=100,amp=0.1,dur=15,outBus=0,gate=1|
  var out, env;
  env=EnvGen.ar(Env([0,1,0],[0.1,dur]),doneAction:2);
  env=env**3;
  out=Ringz.ar(BPF.ar(PinkNoise.ar(),18000*(1-env)+30,0.5),
    Array.series(20,4,1)*(freq/2)+{exprand(freq/20, freq/25)}.dup(20),
    30/Array.series(30,1,1))*(1/Array.series(30,8,1));
  out=out/50;
  out=out*env*amp;
  Out.ar(outBus,out!2);
}).store;
SynthDef(\next,{|freq=55,dur=0.1,amp=0.5,outBus=0,gate=1|
  var out, env;
  env = EnvGen.ar(Env.adsr(0.001,dur,0.1,0.1), gate, doneAction:2);
  out = Pulse.ar([Rand(-1,-0.5),Rand(0.5,1)]*(freq/50)+freq);
  out = (out*3).tanh*amp*env;
  Out.ar(outBus,out!2);
}).store;
)
