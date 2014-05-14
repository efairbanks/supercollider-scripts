(
e=();
e.scale=Scale.aeolian;
e.beat=0;
e.root=0;
e.offset=35;
e.target=50;
t=TempoClock(140/30).sched(0,{
  var note, degree, freq;
  if(e.beat%8==0,{e.root=[0,5,3,1,4,2,5,3].wrapAt((e.beat/8).asInteger);});
  e.target=[48,38,43,50,48,40,48,55].wrapAt((e.beat/2).asInteger);
  if(e.beat%4==0,{
    3.do({|inc|
    var note, degree, freq;
      degree=inc*2+e.root+e.offset;
      while({degree>(e.offset+4)},{degree=degree-7});
      note=e.scale.performDegreeToKey(degree);
      freq=note.midicps;
      Synth(\tone,[\freq,freq]);
    });
  });
  degree=e.root+e.offset+[4,0,2,0,6,0,3].wrapAt(e.beat)+7;
  while({e.target+4<degree},{degree=degree-7});
  while({e.target-4>degree},{degree=degree+7});
  note=e.scale.performDegreeToKey(degree);
  freq=note.midicps;
  Synth(\vibro,[\freq,freq]);
  e.beat=e.beat+1;
  1;
});
)
// --- //
(
SynthDef(\vibro,{|freq=440|
  var out;
  freq=SinOsc.ar(7,0,10,freq);
  out=EnvGen.ar(Env([0,1,0],[0.005,2.5]),doneAction:2);
  out=out**8;
  out=out*SinOsc.ar(freq+SinOsc.ar(freq*4,0,freq*5*(0.5-out)));
  out=out*0.1;
  Out.ar(0,out!2);
}).store;
SynthDef(\tone,{|freq=440|
  var out;
  out=EnvGen.ar(Env([0,1,0],[0.005,2.5]),doneAction:2);
  out=out**8;
  out=out*SinOsc.ar(freq+SinOsc.ar(freq*5,0,freq*5*(1-out)));
  out=out*0.1;
  Out.ar(0,out!2);
}).store;
SynthDef(\xylo,{|freq=440|
  var out;
  out=EnvGen.ar(Env([0,1,0],[0.005,2.5]),doneAction:2);
  out=out**5;
  out=out*SinOsc.ar(freq+SinOsc.ar(freq*5,0,freq*4*(1-out)));
  out=out*0.1;
  Out.ar(0,out!2);
}).store;
)