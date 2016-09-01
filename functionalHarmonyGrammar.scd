(
f=();
f.tonic=(
  degrees:[0],
  from:[\dominant,\subdominant,\mediant],
  to:[\dominant,\subdominant,\mediant]);
f.dominant=(
  degrees:[4],
  from:[\tonic,\subdominant,\mediant],
  to:[\tonic,\leading,\subdominant]);
f.subdominant=(
  degrees:[1,3],
  from:[\tonic,\dominant,\mediant],
  to:[\leading,\tonic,\mediant]);
f.mediant=(
  degrees:[2,5],
  from:[\tonic,\subdominant],
  to:[\tonic,\dominant,\subdominant,\leading]);
f.leading=(
  degrees:[6],
  from:[\tonic,\dominant,\subdominant,\mediant],
  to:[\tonic]);
~intermediateFunction={|from,to|
  var functions=[];
  f.keys.do({|function|
    if((f[function].from.includes(from)).and(
      f[function].to.includes(to)).and(
        f[from].to.includes(function)).and(
        f[to].from.includes(function)),{
        functions=functions++[function];
    });
  });
  functions;
};
//~intermediateFunction.(\dominant,\tonic);
~expandProgression={|progression|
  var newProgression=[];
  (progression.size-1).do({|progressionIndex|
    var from,to,between;
    from=progression[progressionIndex];
    to=progression[progressionIndex+1];
    between=~intermediateFunction.(from,to).choose;
    newProgression=newProgression++[from];
    if(between!=nil,{newProgression=newProgression++[between];});
  });
  newProgression=newProgression++[progression[progression.size-1]];
  newProgression;
};
~recursivelyExpandProgression={|progression,times|
  times.do({progression=~expandProgression.(progression);});
  progression;
};
~prog=~recursivelyExpandProgression.([\dominant,\mediant,\tonic],8);
t=TempoClock(110/10).sched(0,{
  var degree,notes=[];
  if(e==nil,{e=();});
  e.beat=if(e.beat==nil,{0},{e.beat+1});
  degree=f[~prog.wrapAt(e.beat/4)].degrees.choose;
  1.do({|inc|
    var freq=Scale.minor.degreeToFreq(degree+[4,0,2,0].wrapAt(e.beat),55,0);
    while({freq<300},{freq=freq*2});
    Synth(\test,[\freq,freq]);
  });
  3.do({|inc|
    var freq=Scale.minor.degreeToFreq(degree+(inc*2),55,0);
    while({freq<180},{freq=freq*2});
    if(e.beat%8==0,{Synth(\test,[\freq,freq]);});
  });
  1;
});
)
(
SynthDef(\test,{|freq=440|
  var env,out;
  env=EnvGen.ar(Env([0,1,-18.dbamp,0],[0.001,0.01,1]),doneAction:2);
  out=env*SinOsc.ar(freq,0.2)*0.1;
  out=(out*100).tanh/40;
  out=out+(HPF.ar(RLPF.ar(out,freq*4*env+30,0.1),200)/4);
  Out.ar(0,out!2);
}).store;
Synth(\test);
)


