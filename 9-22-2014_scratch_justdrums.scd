(
~beats2secs={|beats,bpm| beats*60/bpm};
e=nil;
if(e==nil,{
  e=();
  e.voices=();
  e.beat=0;
  e.break=Buffer.read(s, Platform.resourceDir+/+"sounds/action.wav");
  e.breakLookup=(0:[8,14],1:[14,6],2:[6,8,14],3:[4,12],4:[0]);
  e.levelBjorkSelects=(0:[16],1:[32],2:[16],3:[8],4:[4]);
  e.bjorkHoles=32;
  e.recordLength=e.bjorkHoles*8;
  e.levelBeats=();
  e.maxLevel=4;
  e.bpm=160;
  e.metro=TempoClock(e.bpm/15).sched(0,{e.run.();e.beat=e.beat+1;1;});
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
e.run={
  var level=~getLevel.(e.beat%~level2beats.(e.maxLevel),e.maxLevel);
  var pattern=1!e.bjorkHoles;
  var finalPattern=0!e.bjorkHoles;
  var measureLength=(e.bjorkHoles/2);
  var measure=(e.beat/measureLength).floor;
  // --- //
  e.levelBjorkSelects=(
    0:[32],
    1:[16],
    2:[16],
    3:[8],
    4:[4]);
  (e.maxLevel+1).do({|inc|
    pattern=~bjorkSelect.(e.levelBjorkSelects[inc].wrapAt(measure/2),pattern);
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
      \dur,(0.2/(1.65**e.maxLevel))*(2**level),
      \amp,(0.1/(1.35**e.maxLevel))*(1.3**level),\outBus,e.drumsBus]);
  });
};
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
)


