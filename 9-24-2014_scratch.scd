(
~beats2secs={|beats,bpm| beats*60/bpm};
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
~play={|alias,synth,params,freqs|
  if(e.voices[alias]!=nil,{
    e.voices[alias].size.do({|inc|
      if(e.voices[alias][inc].isRunning,{
        e.voices[alias][inc].release;
      });
    });
    e.voices[alias]=nil;
  });
  e.voices[alias]=Synth(synth,params).register;
  nil;
};

////////////////////////////////////
////////////////////////////////////
////////////////////////////////////

e=nil;
if(e==nil,{
  e=();
  e.voices=();
  e.beat=0;
  e.bjorkHoles=32;
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
  /*
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
  )*/
});
)