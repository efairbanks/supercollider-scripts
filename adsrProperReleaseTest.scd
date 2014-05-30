s.boot;
(
e=();
e.scale=Scale.major;
t.stop;
t=TempoClock(100/30).schedAbs(0,{
  var freq;
  if(e.beat==nil,{e.beat=0;});
  e.voices.do({|voice| if(voice.isRunning,{voice.release;});});
  freq = e.scale.performDegreeToKey([0,3,5,6,2,5,1,4].wrapAt((e.beat/4).floor)).midicps;
  while({freq<50},{freq=freq*2;});
  e.voices = e.voices ++ [Synth(\PulseLead,[\freq,freq,\amp,0.35]).register];
  3.do({|inc|
    var freq;
    freq = e.scale.performDegreeToKey(inc*2+[0,3,5,6,2,5,1,4].wrapAt((e.beat/4).floor)+2).midicps;
    while({freq<300},{freq=freq*2;});
    e.voices = e.voices ++ [Synth(\PulseLead,[\freq,freq]).register];
  });
  e.beat=e.beat+1;2;
});
)
(
SynthDef(\PulseLead,{|freq=440,gate=1,amp=0.1|
  var env, out;
  env = Env.adsr(0.005,0.5,0.5,0.2);
  env = EnvGen.ar(env, gate, doneAction:2);
  out = Pulse.ar([freq+2.0.rand,freq-2.0.rand],[0.6,-0.4])/8;
  out = out*env*amp;
  Out.ar(0, out!2);
}).store;
)
