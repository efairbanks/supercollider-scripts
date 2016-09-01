
(

SynthDef(\detunedlead,{
	
	|freq = 440|
	
	var tone = Pulse.ar(freq+SinOsc.ar(Rand(0.0,1/3),0,freq/80),SinOsc.ar(Rand(0.1,0.5),0,0.25,0.5));
	
	tone = RLPF.ar(tone,freq*Rand(2.0,6.0),0.2);
	
	tone = tone * EnvGen.ar(Env([1,3/4,0],[1/2,1]*4),doneAction:2);
	
	Out.ar(0,tone*0.1);
	
	}).store;
	

(instrument:\detunedlead,degree:[0,-5,-3] +.t 0).play;
	
)