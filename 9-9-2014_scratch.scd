(
var pattern=1!e.bjorkHoles;
var finalPattern=0!e.bjorkHoles;
  (e.maxLevel+1).do({|inc|
    pattern=~bjorkSelect.(e.levelBjorkSelects[inc],pattern);
    finalPattern=finalPattern+pattern;
  });
finalPattern;
)
e.metro.tempo=190/15;
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
  e.levelBjorkSelects=(0:(8*7)!3++[8*7],1:((8*4)!7)++[3*4],2:[32],3:[4,5,4,7]*2,4:[4]);
  e.bjorkHoles=64;
  e.levelBeats=();
  e.maxLevel=4;
  e.scale=Scale.melodicMinor;
  e.metro=TempoClock(180/15).sched(0,{e.run.();e.beat=e.beat+1;1;});
  e.masterBus=Bus.audio(s,2);
  e.mixer={var in=In.ar(e.masterBus,2);Out.ar(0,Compander.ar(FreeVerb.ar(in,-20.dbamp),in,-30.dbamp,1,-10.dbamp,0.005,0.15));}.play;
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
(
e.run={
  var level=~getLevel.(e.beat%~level2beats.(e.maxLevel),e.maxLevel);
  var pattern=1!e.bjorkHoles;
  var finalPattern=0!e.bjorkHoles;
  var measureLength=(e.bjorkHoles/2);
  var measure=(e.beat/measureLength).floor;
  var degree;
  (e.maxLevel+1).do({|inc|
    pattern=~bjorkSelect.(e.levelBjorkSelects[inc].wrapAt(measure),pattern);
    finalPattern=finalPattern+pattern;
  });
  level=finalPattern.wrapAt(e.beat)-1;
  // --- //
  if(e.levelBeats[level]==nil,{e.levelBeats[level]=0;});
  e.levelBeats[level]=e.levelBeats[level]+1;
  if(e.breakLookup[level].size>0,{
    Synth(\break,[
      \bufnum,e.break.bufnum,
      \offset,e.breakLookup[level].wrapAt(e.levelBeats[level])/~level2beats.(e.maxLevel),
      \dur,(0.14/(1.7**e.maxLevel))*(2**level),
      \amp,(0.6/(1.35**e.maxLevel))*(1.4**level),\outBus,e.masterBus]);
    degree=[0,5,3,1].wrapAt(measure);
    degree=degree+(3*((measure/2).floor%4));
    while({degree>6},{degree=degree-7;});
    degree=degree+[[0],[4,2],[2,5]].wrapAt(level).wrapAt(e.levelBeats[level]);
    if([0,1,2,3].includes(level),{
      Synth(\acid,[
        \freq,e.scale.degreeToFreq(degree, 55/2,[2,3,0,0,0].wrapAt(level)),
        \dur,(0.04/(1.1**e.maxLevel))*(2**level),
        \amp,(0.06/(1**e.maxLevel))*(1.4**level),\outBus,e.masterBus]);
    });
    if([0].includes(level),{
      4.do({|inc|
        var padsDegree = degree+(inc*2);
        while({padsDegree<25},{padsDegree=padsDegree+7;});
        Synth(\fmpads,[
          \freq,e.scale.degreeToFreq(padsDegree,55/2,0),
          \dur,(0.8/(1.6**e.maxLevel))*(2**level),
          \amp,(0.016/(1.2**e.maxLevel))*(1.4**level),\outBus,e.masterBus]);
      });
    });
    if(e.beat%(measureLength*8)==0,{Synth(\birdfx,[\amp,0.008,\outBus,e.masterBus]);});
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
SynthDef(\acid,{|freq=55,dur=0.1,amp=0.5,outBus=0|
  var out, env;
  env = EnvGen.ar(Env([0,1,0],[0.005,dur],-5),doneAction:2);
  out = RLPF.ar(Pulse.ar(freq,0.5)+Saw.ar(freq)/2,100+(5000*env),0.05)*amp*env;
  Out.ar(outBus,out!2);
}).store;
SynthDef(\fmpads,{|freq=800,dur=1,amp=0.5,outBus=0|
  var out, env;
  freq = freq + SinOsc.ar(Rand(0.01,0.3),0,freq/100);
  env = EnvGen.ar(Env([0,1,1/4,0],[0.005,0.1,dur-0.105]),doneAction:2);
  out = SinOsc.ar(freq/2)*(freq/2)*((7/8)-env)*8;
  out = SinOsc.ar(out+freq)*env*amp;
  out = LPF.ar(out,freq*2);
  //out = HPF.ar(out,freq/1.75);
  Out.ar(outBus,out!2);
}).store;
SynthDef(\birdfx,{|freq=200,dur=10,amp=0.5,outBus=0|
  var out=0, env;
  env = EnvGen.ar(Env([0,1,0],[0.1,dur-0.1],-5),doneAction:2);
  10.do({
    out = out + [(Saw.ar(Rand(1.1,10.4))+1/2),(Saw.ar(Rand(1.1,10.4))+1/2)];
    out = SinOsc.ar(freq+(Rand(200,2000)*out))*amp*env;
  });
  Out.ar(outBus,out!2);
}).store;
)
