(
s.options.hardwareBufferSize=1024*8;
~beats2secs={|beats,bpm| beats*60/bpm};
e=nil;
if(e==nil,{
  e=();
  e.beat=0;
  e.break=Buffer.read(s, Platform.resourceDir+/+"sounds/action.wav");
  //e.break=Buffer.read(s, Platform.resourceDir+/+"sounds/its_a_new_day.wav");
  //e.break=Buffer.read(s, Platform.resourceDir+/+"sounds/new_orleans.wav");
  //e.break=Buffer.read(s, Platform.resourceDir+/+"sounds/funky_drummer.wav");
  //e.break=Buffer.read(s, Platform.resourceDir+/+"sounds/fools_gold.wav");
  e.breakLookup=(0:[8,14],1:[14,6],2:[6,8,14],3:[4,12],4:[0]);
  e.levelBjorkSelects=(0:[16],1:[32],2:[16],3:[8],4:[4]);
  e.busesToRecord=[\bassBus,\chordBus,\drumsBus,\slideBus,\padsBus,\transitionBus,\masterBus];
  e.bjorkHoles=24;
  e.recordLength=e.bjorkHoles*8;
  e.levelBeats=();
  e.maxLevel=4;
  e.scale=Scale.major;
  e.bpm=160;
  e.metro=TempoClock(e.bpm/15).sched(0,{e.run.();e.beat=e.beat+1;1;});
  e.ringRecBufs=();
  e.writeBufs=();
  e.busesToRecord.do({|bus|
    e.ringRecBufs[bus]=Buffer.alloc(
      s,
      s.sampleRate*~beats2secs.(e.recordLength/4,e.bpm),
      2
    );
    e.writeBufs[bus]=Buffer.alloc(
      s,
      s.sampleRate*~beats2secs.(e.recordLength/4,e.bpm),
      2
    );
  });
  e.bassBus=Bus.audio(s,2);
  e.chordBus=Bus.audio(s,2);
  e.drumsBus=Bus.audio(s,2);
  e.masterBus=Bus.audio(s,2);
  e.slideBus=Bus.audio(s,2);
  e.padsBus=Bus.audio(s,2);
  e.transitionBus=Bus.audio(s,2);
  (
  e.mixer.free;
    e.mixer={|t_phase|
      var master=In.ar(e.masterBus,2);
      var bassBus=In.ar(e.bassBus,2);
      var drumsBus=In.ar(e.drumsBus,2);
      var chordBus=In.ar(e.chordBus,2);
      var slideBus=In.ar(e.slideBus,2);
      var padsBus=In.ar(e.padsBus,2);
      var transitionBus=In.ar(e.transitionBus,2);
      bassBus=Compander.ar(bassBus,bassBus,-48.dbamp,1,1/30,0.001,0.03)*17.dbamp;
      bassBus=HPF.ar((bassBus*30).tanh,5000)/7+bassBus;
      bassBus=bassBus*(-3.5.dbamp);
      chordBus=Compander.ar(chordBus,chordBus,-48.dbamp,1,1/20,0.001,0.5)*13.dbamp;
      drumsBus=Compander.ar(drumsBus,drumsBus,-44.dbamp,1,0.8,0.001,0.15)*5.dbamp;
      drumsBus=drumsBus+HPF.ar(drumsBus,8000).tanh;
      // --- //
      BufWr.ar(
        bassBus,
        e.ringRecBufs[\bassBus].bufnum,
        Phasor.ar(t_phase,BufRateScale.kr(e.ringRecBufs[\bassBus].bufnum),0,BufFrames.kr(e.ringRecBufs[\bassBus].bufnum))
      );
      BufWr.ar(
        drumsBus,
        e.ringRecBufs[\drumsBus].bufnum,
        Phasor.ar(t_phase,BufRateScale.kr(e.ringRecBufs[\drumsBus].bufnum),0,BufFrames.kr(e.ringRecBufs[\drumsBus].bufnum))
      );
      BufWr.ar(
        chordBus,
        e.ringRecBufs[\chordBus].bufnum,
        Phasor.ar(t_phase,BufRateScale.kr(e.ringRecBufs[\chordBus].bufnum),0,BufFrames.kr(e.ringRecBufs[\chordBus].bufnum))
      );
      BufWr.ar(
        slideBus,
        e.ringRecBufs[\slideBus].bufnum,
        Phasor.ar(t_phase,BufRateScale.kr(e.ringRecBufs[\slideBus].bufnum),0,BufFrames.kr(e.ringRecBufs[\slideBus].bufnum))
      );
      BufWr.ar(
        padsBus,
        e.ringRecBufs[\padsBus].bufnum,
        Phasor.ar(t_phase,BufRateScale.kr(e.ringRecBufs[\padsBus].bufnum),0,BufFrames.kr(e.ringRecBufs[\padsBus].bufnum))
      );
      BufWr.ar(
        transitionBus,
        e.ringRecBufs[\transitionBus].bufnum,
        Phasor.ar(t_phase,BufRateScale.kr(e.ringRecBufs[\transitionBus].bufnum),0,BufFrames.kr(e.ringRecBufs[\transitionBus].bufnum))
      );
      // --- //
      master=master+bassBus+drumsBus+chordBus+slideBus+padsBus+transitionBus;
      master=Compander.ar(FreeVerb.ar(master,-20.dbamp),master,-30.dbamp,1,-10.dbamp,0.005,0.15);
      master=master*20.dbamp;
      // --- //
      BufWr.ar(
        master,
        e.ringRecBufs[\masterBus].bufnum,
        Phasor.ar(t_phase,BufRateScale.kr(e.ringRecBufs[\masterBus].bufnum),0,BufFrames.kr(e.ringRecBufs[\masterBus].bufnum))
      );
      // --- //
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
(
e.run={
  var level=~getLevel.(e.beat%~level2beats.(e.maxLevel),e.maxLevel);
  var pattern=1!e.bjorkHoles;
  var finalPattern=0!e.bjorkHoles;
  var measureLength=(e.bjorkHoles/2);
  var measure=(e.beat/measureLength).floor;
  var degree;
  // --- record --- //
  if((e.beat%e.recordLength==0).and(e.beat!=0),{
    e.busesToRecord.do({|bus|
      e.ringRecBufs[bus].copyData(e.writeBufs[bus]);
      e.mixer.set(\t_phase,1);
      e.writeBufs[bus].write(thisProcess.platform.recordingsDir++"/"++bus.asString++"_"++measure++".aiff");
    });
  });
  // --- //
  e.levelBjorkSelects=(
    0:[16],
    1:([16]!5++[[[10],[12]].wrapAt(measure/3)]).wrapAt(measure/16),
    2:[[8],[9,7]].wrapAt(measure/16),
    3:4!1++[[6,5].wrapAt(measure%5),[5,7].wrapAt(measure/12)].wrapAt(measure/4),
    4:[2]);
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
      \dur,(0.15/(1.65**e.maxLevel))*(2**level),
      \amp,(0.6/(1.35**e.maxLevel))*(1.4**level),\outBus,e.drumsBus]);
    //degree=[[0,5,3,1],[0,2,4,6],[1,2,3,0].perfectShuffle].wrapAt(measure/16).wrapAt(measure);
    //degree=(((measure%8)*[4,3,5].wrapAt(measure/16))%7)+[0,4,0,6].wrapAt(measure/8);
    degree=[
      (((measure%8)*[[5],[4]].wrapAt(measure/16).wrapAt(measure))%7),
      ((measure/2).floor%5)*4,
      (((measure%8)*[[5],[4]].wrapAt(measure/16).wrapAt(measure))%7),
      ([0,4,3,5].wrapAt(measure/2))
    ].wrapAt(measure/32)+[0,1,0,-1].wrapAt(measure/24);
    while({degree>6},{degree=degree-7;});
    if([[4,3,2,1,0],[4,3]].wrapAt(measure/8).includes(level),{
      Synth(\acid,[
        \freq,e.scale.degreeToFreq(degree, 55/2,[1,1,2].wrapAt(level)),
        \dur,(0.035/(1.1**e.maxLevel))*(2**level),
        \amp,(0.03/(1**e.maxLevel))*(1.4**level),\outBus,e.bassBus]);
    });
    if([[4,3],[0,1,2,3]].wrapAt(measure/16).includes(level),{
      2.do({|inc|
        var chipPadsDegree = degree+(inc*4);
        while({chipPadsDegree<25},{chipPadsDegree=chipPadsDegree+7});
        Synth(\chippads,[
          \freq,e.scale.degreeToFreq(chipPadsDegree,55/2,0),
          \dur,(0.05/(2**e.maxLevel))*(2**level),
          \amp,(0.022/(1.2**e.maxLevel))*(1.4**level),\outBus,e.chordBus]);
      });
    });
    if([[3,0],[3,4,0]].wrapAt(measure/16).includes(level),{
      1.do({|inc|
        var chipPadsDegree = degree+(inc*4);
        while({chipPadsDegree<25},{chipPadsDegree=chipPadsDegree+7});
        Synth(\slide,[
          \freq,e.scale.degreeToFreq(chipPadsDegree,55/2,0),
          \dur,(0.25/(2**e.maxLevel))*(2**level),
          \amp,(0.006/(1.2**e.maxLevel))*(1.4**level),\outBus,e.slideBus]);
      });
    });
    if([[],[],[4,3]].wrapAt(measure/16).includes(level),{
      3.do({|inc|
        var fmPadsDegree = degree+(inc*2);
        while({fmPadsDegree<40},{fmPadsDegree=fmPadsDegree+7});
        Synth(\fmpads,[
          \freq,e.scale.degreeToFreq(fmPadsDegree,55/2,0),
          \dur,(0.3/(1.1**e.maxLevel))*(2**level),
          \amp,(0.002/(1.2**e.maxLevel))*(1.4**level),\outBus,e.padsBus]);
      });
    });
    if(e.beat%(measureLength*16)==0,{Synth(\birdfx,[\amp,0.01,\outBus,e.transitionBus]);});
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
  out = RLPF.ar(Pulse.ar(freq,0.5)+Saw.ar(freq)/2,100+(5000*env),0.4);
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
)
