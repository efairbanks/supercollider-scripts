

(

SynthDef(\bass303,{
	
		|freq=110,attack=0.01,decay=0.1,pulsexsaw=0.75,res=0.25,amp=0.5|
		
		var env = EnvGen.ar(Env([0,1,0],[attack,decay]),doneAction:2);
		
		var tone = (Pulse.ar(freq)*pulsexsaw) + (Saw.ar(freq)*(1-pulsexsaw));
		
		var out = RLPF.ar(tone,freq*8*env+40,res) + (SinOsc.ar(freq/2)/2);
		
		out = out * env;
		
		out = HPF.ar(out,40);
		
		Out.ar([0,1],out*amp);
		
	}).store;
	
Synth(\bass303,[\pulsexsaw,0.75]);

(instrument:\bass303,degree:-14).play;

(

Pbind(	\instrument,\bass303,
		\degree,Pseq(([1,4,5,2,0,2,3,2] +.t [0,2,4,2]).flat + [0,0,0,0,0] - 15,1),
		\dur,0.075,
		\decay,0.0125,
		\res,Pseq([9,5,3]/30,10)).play;
		
)

)