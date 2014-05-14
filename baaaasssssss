
(

~reverbBus = Bus.audio(s, 2);

{

	Out.ar(0,FreeVerb.ar(In.ar(~reverbBus, 2), 1/3, 0.9, 0.7));

}.play;

SynthDef(\reese,{

	|freq=55|

	var out, mod, env = EnvGen.ar(Env([0,1,0],[0.001,0.3]),doneAction:2);

	freq = freq+SinOsc.ar(5,0,5);

	out = Saw.ar([freq,freq-1.0.rand,freq+1.0.rand,freq-2.0.rand,freq+2.0.rand]);

	out = HPF.ar(LPF.ar(out, freq*2),30) + HPF.ar(out, freq*16);

	out = out * 0.5 * env;

	Out.ar(~reverbBus, out!2);

}).store;

3.do({

	|inc|

	Synth(\reese,[\freq,Scale.minor.degreeToFreq(inc*2+2,48.midicps,1)]);

});

)