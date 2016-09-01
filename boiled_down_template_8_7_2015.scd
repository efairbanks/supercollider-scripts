(
e=nil;
if(e==nil,{
  e=();
  e.beat=0;
  e.breaks=[
    (
      break:Buffer.read(s, Platform.resourceDir+/+"sounds/fools_gold.wav"),
      breakLookup:(
        0:[9,8,5],
        1:[2,5,9,8,11],
        2:[8,5,3],
        3:[10,6],
        4:[0])
    ),
    (
      break:Buffer.read(s, Platform.resourceDir+/+"sounds/funky_drummer.wav"),
      breakLookup:(
        0:[8],
        1:[1,3,5,7],
        2:[8,14],
        3:[4,12],
        4:[0])
    ),
    (
      break:Buffer.read(s, Platform.resourceDir+/+"sounds/action.wav"),
      breakLookup:(
        0:[8],
        1:[2,6,14],
        2:[8],
        3:[4,12],
        4:[0,10])
    )
  ];
  e.levelBjorkSelects=(
    0:[64],
    1:[32],
    2:[20],
    3:[8],
    4:[4]);
  e.bjorkHoles=64;
  e.levelBeats=();
  e.maxLevel=4;
  e.scale=Scale.melodicMinor;
  e.metro=TempoClock(140/15).sched(0,{e.run.();e.beat=e.beat+1;e.beat.postln;1;});
  e.masterBus=Bus.audio(s,2);
  (
    e.mixer.free;
    e.mixer={
      var master=In.ar(e.masterBus,2);
      var reverb=0;
      master=Compander.ar(FreeVerb.ar(master,-27.dbamp),master,-25.dbamp,1,-10.dbamp,0.005,0.15);
      reverb=FreeVerb.ar(master,1,0.99,0.8);
      reverb=Compander.ar(reverb,master,-45.dbamp,1,-15.dbamp,0.001,0.15)*(-15.dbamp);
      master=master+reverb;
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
  e.levelBjorkSelects=
  (
    0:[64],
    1:[32],
    2:[16],
    3:[8],
    4:[4]
  );
  e.scale=[
    Scale.minor
  ].wrapAt(e.measure/12);
  e.metro.tempo=[
    145/15
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
  e.degree=4*(e.measure/2).floor;
  while({e.degree>6},{e.degree=e.degree-7;});
};
~break={
  if(e.breaks.wrapAt(0).breakLookup[e.level].size>0,{
    Synth(\break,[
      \bufnum,e.breaks.wrapAt(e.beat/4).break.bufnum,
      \offset,e.breaks.wrapAt(e.beat/4).breakLookup[e.level].wrapAt(e.levelBeats[e.level])/~level2beats.(e.maxLevel),
      \dur,(0.18/(1.7**e.maxLevel))*(2**e.level),
      \amp,(0.5/(1.35**e.maxLevel))*(1.4**e.level),\outBus,e.masterBus]);
  });
};
~acidBassline={|style|
  if([4].includes(e.level),{
    var degree=e.degree;
    while({degree<5},{degree=degree+7;});
    if(~lastAcid!=nil,{~lastAcid.free;});
    ~lastAcid=Synth(\acid,[
      \freq,e.scale.degreeToFreq(degree, 55/2,0)*[0,1,2,3,1,5,6,7].wrapAt(e.level),
      \dur,(0.2/(1.1**e.maxLevel))*(1.4**e.level),
      \amp,(0.015/(1**e.maxLevel))*(1.4**e.level),
      \outBus,e.bassBus]);
  });
};
(
e.run={
  ~buildStructures.();
  ~break.();
  //~acidBassline.()
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
)
