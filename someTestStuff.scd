(
SynthDef(\lead,{|freq=440|
  var out;
  out=EnvGen.ar(Env([0,1,0],[0.1,1]),doneAction:2)*Pulse.ar(freq);
  Out.ar(0,out!2);
}).store;
e=();
e.beat=0;
e.degree=0;
e.metro=TempoClock(120/30).schedAbs(0,{
  3.do({|inc|
    var chordDegrees=[[0,2,4],[0,3,4]];
    var chordSelection=[0,0,0,0,0,0,1,0];
    Synth(\lead,[\freq,Scale.major.degreeToFreq(e.degree+chordDegrees[chordSelection.wrapAt(e.beat)][inc],220,0)]);
  });
  if(e.beat>=8,{e.beat=0;e.degree=(e.degree+3)%7;});
  e.beat=e.beat+1;
  1;
});
)