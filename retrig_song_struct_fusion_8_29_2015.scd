(
e=nil;
if(e==nil,{
  e=();
  e.beat=0;
  //e.break=Buffer.read(s, Platform.resourceDir+/+"sounds/action.wav");
  //e.break=Buffer.read(s, Platform.resourceDir+/+"sounds/its_a_new_day.wav");
  //e.break=Buffer.read(s, Platform.resourceDir+/+"sounds/new_orleans.wav");
  //e.break=Buffer.read(s, Platform.resourceDir+/+"sounds/funky_drummer.wav");
  e.break=Buffer.read(s, Platform.resourceDir+/+"sounds/helicopter.wav");
  //e.ringBuf=Buffer.alloc(s,s.sampleRate * 5,2);
  e.breakLookup=(0:[2,14,8,12],1:[2,14,8],2:[8,12,2,14,2],3:[10,4],4:[6,0]);
  e.breakBeat=0;
  e.levelBjorkSelects=(0:[64],1:[32],2:[16],3:[8],4:[4]);
  e.bjorkHoles=96;
  e.levelBeats=();
  e.maxLevel=4;
  e.scale=Scale.melodicMinor;
  e.metro=TempoClock(140/15).sched(0,{e.run.();e.beat=e.beat+1;1;});
  e.bassBus=Bus.audio(s,2);
  e.chordBus=Bus.audio(s,2);
  e.drumsBus=Bus.audio(s,2);
  e.masterBus=Bus.audio(s,2);
  (
    e.mixer={|t_retrig=0,retrigmix=0,retrigspeed=1,retrigdur=0.1|
      var master=In.ar(e.masterBus,2);
      var bassBus=In.ar(e.bassBus,2);
      var drumsBus=In.ar(e.drumsBus,2);
      var chordBus=In.ar(e.chordBus,2);

      var glitch=0;

      var ringBuf = LocalBuf.new(SampleRate.ir()*0.5, 2);

      var phasor = 0;
      var retrigPhasor = 0;
      var bufReadIndex = 0;
      var stutterWindow = 0;
      //var stutterWindowPhasor = 0;
      var out = 0;

      var bufFramesLatch = 0;
      var retrigMixerLatch = 0;

      bassBus=Compander.ar(bassBus,bassBus,-48.dbamp,1,1/30,0.001,0.03)*15.5.dbamp;
      chordBus=Compander.ar(chordBus,chordBus,-48.dbamp,1,1/20,0.001,0.5)*17.dbamp;

      // --- //

      glitch = drumsBus + chordBus;

      phasor = Phasor.ar(0, BufRateScale.kr(ringBuf),0,BufFrames.kr(ringBuf));
      bufFramesLatch = Latch.ar(phasor,t_retrig);
      BufWr.ar(DC.ar(0)!2,ringBuf, phasor + (BufFrames.kr(ringBuf)/2));
      BufWr.ar(glitch, ringBuf, phasor);
      retrigPhasor = Phasor.ar(t_retrig, BufRateScale.kr(ringBuf)*retrigspeed,0,SampleRate.ir()*(retrigdur*retrigspeed));
      stutterWindow = (SinOsc.ar(0,pi*(retrigPhasor/(SampleRate.ir()*(retrigdur*retrigspeed))))*20).tanh;
      retrigPhasor = retrigPhasor + bufFramesLatch;
      bufReadIndex = Select.ar(retrigmix > 0.5, [phasor, retrigPhasor]);
      glitch = BufRd.ar(2, ringBuf, bufReadIndex,interpolation:3)*Select.ar(retrigmix > 0.5, [DC.ar(1), stutterWindow]);

      drumsBus = glitch;

      // --- //

      master=master+bassBus+drumsBus;//+chordBus;

      master=Compander.ar(FreeVerb.ar(master,-27.dbamp),master,-25.dbamp,1,-10.dbamp,0.005,0.15);
      master=master*(5.dbamp);

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
  e.measureLength=(e.bjorkHoles/4);
  e.measure=(e.beat/e.measureLength).floor;
  e.levelBjorkSelects=[(
    0:[64],
    1:[48],
    2:[33],
    3:[15],
    4:[8]
  ),(
    0:[64],
    1:[48],
    2:[32],
    3:[16],
    4:[8]
  )].wrapAt(e.measure/8);
  e.scale=[
    Scale.minor
  ].wrapAt(e.measure/12);
  e.metro.tempo=[
    180/15
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
  //e.degree=[[0,2,3,5],[0,3,4,6]].wrapAt(e.measure/16).wrapAt(e.measure);
  //e.degree=e.degree+(4*((e.measure/2).floor%4));
  e.degree=4*(e.measure/2).floor;
  while({e.degree>6},{e.degree=e.degree-7;});
  //e.degree=e.degree+[[0],[3,5],[4,1]].wrapAt(e.level).wrapAt(e.levelBeats[e.level]);
};
~break={
  if([4,3].includes(e.level),{e.breakBeat=0;});
  /*
  Synth(\break,[
    \bufnum,e.break.bufnum,
    \offset,e.breakLookup[e.level].wrapAt(e.levelBeats[e.level])/~level2beats.(e.maxLevel),
    \dur,(0.1/(1.7**e.maxLevel))*(2**e.level),
    \rate,1/((e.breakBeat/10)+0.825),
    \amp,(0.5/(1.35**e.maxLevel))*(2.5**e.level),
    \grainMix,[1,0,0.5,1,0,0.5].wrapAt(e.beat),
    \grainSize,[1/30,1/60,1/30,1/100,1/60,1/30,1/1000].wrapAt(e.beat),
    \grainPitch,[1,-1,1.5,2,1].wrapAt(e.beat),
    \outBus,e.drumsBus
  ]);*/
  Synth(\break,[
    \bufnum,e.break.bufnum,
    \offset,e.breakLookup[e.level].wrapAt(e.levelBeats[e.level])/~level2beats.(e.maxLevel),
    \dur,(0.15/(1.7**e.maxLevel))*(2**e.level),
    \rate,1.1,
    \amp,(2/(3**e.maxLevel))*(2.5**e.level),
    \grainMix,0,
    \grainSize,1/30,
    \grainPitch,1,
    \outBus,e.drumsBus
  ]);
  if([4].includes(e.level),{Synth(\kick,[
    \amp,0.3,
    \dur,0.15,
    \outBus,e.drumsBus
  ]);});
  e.breakBeat=e.breakBeat+1
};
~glitch={|section|
  if(section==1,{
    if([1,0].includes(e.level),{
      e.mixer.set(
        \t_retrig,1,
        \retrigmix,[1,0,0,1,0,0,1,0,0,0].wrapAt(e.beat),
        \retrigspeed,[1,-1,1,1,-2,1.5,1,-1,-1.5].wrapAt(e.beat),
        \retrigdur,e.metro.beatDur*[2,1,3,1/2,2,1,3,1,1/4,3,2].wrapAt(e.beat)
      );
    });
    if([4,3,2].includes(e.level),{
      e.mixer.set(\t_retrig,0,\retrigmix,0,\retrigspeed,1);
    });
  },{
      e.mixer.set(\t_retrig,0,\retrigmix,0,\retrigspeed,1);
  });
};
~acidBassline={
  if([4,2,1].includes(e.level),{
    var degree=e.degree;
    while({degree<5},{degree=degree+7;});
    if(~lastAcid!=nil,{~lastAcid.free;});//release(0.001);});
    ~lastAcid=Synth(\acid,[
      \freq,e.scale.degreeToFreq(degree, 55/2,0),
      \dur,(0.05/(1.1**e.maxLevel))*(2**e.level),
      \amp,(0.02/(1**e.maxLevel))*(1.4**e.level),
      \outBus,e.bassBus]);
  });
};
~modBass={
  if([4,3,2,1].includes(e.level),{
    var degree=e.degree+[0,2,3,4].wrapAt(e.level);
    while({degree<3},{degree=degree+7;});
    if(~lastModBass==nil,{~lastModBass=Synth(\modBass);});//release(0.001);});
    ~lastModBass.set(
      \freq,e.scale.degreeToFreq(degree, 55/2,0)*[1,5,3].wrapAt(e.level),
      \mod,(1/(1**e.maxLevel))*(1.4**e.level),
      \amp,(0.02/(1**e.maxLevel))*(1.4**e.level),
      \outBus,e.bassBus);
  });
};
~string={
  if([2,3,5,6].includes(e.level),{
    3.do({|inc|
      var degree=e.degree+(2*inc);
      while({degree<21},{degree=degree+7;});
      Synth(\string,[
        \freq,e.scale.degreeToFreq(degree, 55/2,[2,3,0,0,0].wrapAt(e.level)),
        \dur,0.001,//(0.04/(1.1**e.maxLevel))*(2**e.level),
        \amp,0.01,//(0.06/(1**e.maxLevel))*(1.4**e.level),
        \delay,0.015*inc,
        \outBus,e.chordBus]);
    });
    3.do({|inc|
      var degree=e.degree+(2*inc);
      while({degree<29},{degree=degree+7;});
      Synth(\string,[
        \freq,e.scale.degreeToFreq(degree, 55/2,[2,3,0,0,0].wrapAt(e.level)),
        \dur,0.001,//(0.04/(1.1**e.maxLevel))*(2**e.level),
        \amp,0.02,//(0.06/(1**e.maxLevel))*(1.4**e.level),
        \delay,0.011*inc,
        \outBus,e.chordBus]);
    });
  });
};
~theremin={
  if([2,3,4,5].includes(e.level),{
    var degree=e.degree;
    while({degree<30},{degree=degree+7;});
    if(~lastTheremin!=nil,{~lastTheremin.free;});
    ~lastTheremin=Synth(\theremin,[
      \freq,e.scale.degreeToFreq(degree, 55/2,0),
      \dur,(0.05/(1.1**e.maxLevel))*(2**e.level),
      \amp,(0.002/(1**e.maxLevel))*(1.4**e.level),
      \outBus,e.bassBus]);
    if(~lastTheremin2!=nil,{~lastTheremin2.free;});
    ~lastTheremin2=Synth(\theremin,[
      \freq,e.scale.degreeToFreq(degree+2, 55/2,0),
      \dur,(0.05/(1.1**e.maxLevel))*(2**e.level),
      \amp,(0.001/(1**e.maxLevel))*(1.4**e.level),
      \outBus,e.bassBus]);
  });
};
~fmPads={
  if([1].includes(e.level),{
    3.do({|inc|
      var padsDegree = e.degree+(inc*2);
      while({padsDegree<30},{padsDegree=padsDegree+7;});
      Synth(\fmpads,[
        \freq,e.scale.degreeToFreq(padsDegree,55/2,0),
        \dur,(0.8/(1.6**e.maxLevel))*(2**e.level),
        \amp,(0.016/(1.2**e.maxLevel))*(1.4**e.level),
        \outBus,e.chordBus]);
    });
  });
};
~chipPads={
  if([1,2].includes(e.level),{
    2.do({|inc|
      var chipPadsDegree = e.degree+(inc*4);
      while({chipPadsDegree<35},{chipPadsDegree=chipPadsDegree+7});
      Synth(\chippads,[
        \freq,e.scale.degreeToFreq(chipPadsDegree,55/2,0),
        \dur,(0.05/(1.6**e.maxLevel))*(2**e.level),
        \amp,(0.003/(1.2**e.maxLevel))*(1.4**e.level),
        \outBus,e.bassBus]);
    });
  });
};
~slideSynth={
  if([2,3].includes(e.level),{
    1.do({|inc|
      var slideDegree = e.degree+(inc*3);
      while({slideDegree<35},{slideDegree=slideDegree+7});
      Synth(\slide,[
        \freq,e.scale.degreeToFreq(slideDegree,55/2,0),
        \dur,(0.2/(1.6**e.maxLevel))*(2**e.level),
        \amp,(0.03/(1.8**e.maxLevel))*(1.4**e.level),
        \outBus,e.chordBus]);
    });
  });
};
(
e.run={
  ~buildStructures.();
  if(e.breakLookup[e.level].size>0,{
    ~glitch.(1);
    ~break.();
    ~modBass.();
    /*
    ~glitch.([1,0,1,1,0,1].wrapAt(e.measure/8));
    if([0,1,1,1].wrapAt(e.measure/8)>0,{~break.();},{});
    if([0,1,1,1].wrapAt(e.measure/8)>0,{~acidBassline.();});
    if([1,1,0,1,0].wrapAt(e.measure/8)>0,{~string.();});
    if([0,0,0,0,1,1,1,1].wrapAt(e.measure/8)>0,{~theremin.();},{~lastTheremin.free;~lastTheremin2.free;});
    if([0,0,1,1,1].wrapAt(e.measure/8)>0,{~fmPads.();});
    if([0,1,0,1,0,1,1].wrapAt(e.measure/8)>0,{~chipPads.();});
    if([0,0,0,0,1,1,1,1,0,0].wrapAt(e.measure/8)>0,{~slideSynth.();});
    */
  });
};
)
)
(
f = {
	|ratio = 2, elements = 10|
	var x = [1];
	elements.do({x = x ++ (x[x.size-1]*ratio)});
	x;
};
SynthDef(	\kick, {
	|dur=0.25,amp=0.5,basefreq=120,outBus=0|
	var freqs = f.value(1.1,20)*basefreq;
	var amps = f.value(0.225,20)*0.5;
	var phases = NamedControl.kr(\phases,#[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]);
	var modfreqs = freqs * EnvGen.ar(Env([1,0],[dur]));
	var tone = SinOsc.ar(modfreqs,phases,amps)*EnvGen.ar(Env([0,1,0],[0.005,dur]),doneAction:2);
	tone = tone + LPF.ar((PinkNoise.ar()*EnvGen.ar(Env([1,0],[0.01])))*0.02,2250);
	tone = HPF.ar(tone,40)*amp;
	Out.ar(outBus, tone!2);
}).store;
SynthDef(\break,{|offset=0.5,bufnum,dur=0.075,amp=0.5,outBus=0,rate=1,grainMix=0.2,grainSize=0.03,grainPitch=1.5|
  var phasor, out, env, grainOut;
  env=EnvGen.ar(Env([0,1,0],[0.001,dur]),doneAction:2);
  phasor = Phasor.ar(1, BufRateScale.kr(bufnum)*rate,0,BufFrames.kr(bufnum))+(offset*BufFrames.kr(bufnum));
  out = BufRd.ar(2, bufnum, phasor)*env*amp;
  phasor = phasor/BufFrames.kr(bufnum);
  grainOut = GrainBuf.ar(1,Saw.ar((1/grainSize)*2)*1,grainSize*1,bufnum,grainPitch,phasor);
  out = (out*(1-grainMix)) + (grainOut*grainMix);
  Out.ar(outBus,out);
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
SynthDef(\modBass,{|freq=50,mod=2,amp=0.1,outBus=0|
  var modulator;
  var out;
  var slowMod = Lag.kr(mod,0.01);
  var slowFreq = Lag.kr(freq, 0.005);
  modulator = SinOsc.ar([slowFreq*2-1,slowFreq*2+1])*slowMod;
  modulator = modulator.tanh*slowMod;
  out = (SinOsc.ar(slowFreq+(slowMod*100),modulator)*1.1).tanh*amp;
  Out.ar(outBus,out);
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
SynthDef(\slide,{|freq=440,dur=0.2,amp=0.5,outBus=0,width=1|
  var outl, outr, env;
  freq = EnvGen.ar(Env([1000,freq,freq],[0.07,dur-0.07]));
  env = EnvGen.ar(Env([0,1,1,0],[0.01,dur-0.02,0.01]),doneAction:2);
  outl=Pulse.ar(freq+width,0.25+(env/2))*env*amp;
  outr=Pulse.ar(freq-width,0.25+(env/2))*env*amp;
  Out.ar(outBus,[outl,outr]);
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
SynthDef(\string, {|freq=440,amp=0.1,outBus=0,delay=0,dur=0.1|
  var out, env;
  //freq = Rand(-1.0,1.0)*(freq/400)+freq;
  env = EnvGen.ar(Env([0,1,2/3,0],[0.005,0.15,dur]),doneAction:2);
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
SynthDef(\theremin,{|freq=330,dur=0.1,amp=0.5,outBus=0,gate=1,width=1|
  var outl, outr, env, lfo;
  env = EnvGen.ar(Env.adsr(0.01,dur,0.25,0.1),doneAction:2);
  lfo = SinOsc.ar(7);
  outl = (SinOsc.ar(freq+width+(lfo*freq/25),0)*2).tanh*env*amp;
  outr = (SinOsc.ar(freq-width+(lfo*freq/25),0)*2).tanh*env*amp;
  Out.ar(outBus, [outl, outr]);
}).store;
)
