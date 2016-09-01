(
SynthDef(\fm,{|modfreq=100,carrierfreq=200,modmodfreq=300|
  var out=0;
  var env=EnvGen.ar(Env([0,1,0],[0.001,2]))**7;
  out=SinOsc.ar(carrierfreq+SinOsc.ar(modmodfreq,0,200),SinOsc.ar(modfreq,0,3))*env;
  Out.ar(0,out!2);
}).store;

)

(
e=(beat:0);
t=TempoClock.sched(0,{
  var degree=[0,3,5,4,2,6,3,1].wrapAt(e.beat/8)+[4,0,2,0,-3,0,2,0].wrapAt(e.beat);
  var freq1=Scale.minor.degreeToFreq(degree,55,5);
  var freq2=Scale.minor.degreeToFreq(degree+3,55,4);
  var freq3=Scale.minor.degreeToFreq(degree+4,55,3);
  Synth(\fm,[\carrierfreq,freq1,\modfreq,freq2,\modmodfreq,freq3]);
  e.beat=e.beat+1;
  0.10;
});
)