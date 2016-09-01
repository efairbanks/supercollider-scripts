
(

SynthDef(\simplesin,{

	|freq=440, amp=0.02|

	var out = SinOsc.ar(freq)*amp*EnvGen.ar(Env([0,1,0],[1,4]),doneAction:2);

	Out.ar(0,out!2);
	
}).store;

SynthDef(\simplenoise,{

	|freq=440, amp=0.8|

	var out, tone, env;
	
	env = EnvGen.ar(Env([0,1,0],[1,4]),doneAction:2);
	
	tone = BPF.ar(PinkNoise.ar(), freq, 0.05*env);

	out = tone*amp*env;

	Out.ar(0,out!2);
	
}).store;

SynthDef(\beepdecay,{

	|freq=440, amp=0.2|
	
	var env, out, tone;
	
	env = EnvGen.ar(Env([0.0001,1,0.0001],[8,8],'exponential'),doneAction:2)*LPF.ar(Saw.ar(Rand(3, 8)),4);
	
	tone = Pulse.ar(freq*2+SinOsc.ar(0.2+Rand(0, 0.6),0,freq/(Rand(10, 40))),0.2*env);
	
	out = LPF.ar(HPF.ar(tone*env*amp,2000),4000);
	
	Out.ar(0,out!2);
	
	
}).store;

SynthDef(\noisedecay,{
	
	|freq=3000, amp=0.2|
	
	var noise, env, env2, out;
	
	env = EnvGen.ar(Env([1,0.0001],[8],'exponential'),doneAction:2);
	
	env2 = env*(1-env);
	
	noise = BPF.ar(PinkNoise.ar(),freq+(env*freq/2)-(freq/2),0.025+(env*0.2));
	
	noise = noise + BPF.ar(PinkNoise.ar(),400+SinOsc.ar(20,0,200),0.02+(0.1*env2));
	
	out = noise*env;
	
	Out.ar(0,out!2);
	
}).store;

)

(

Synth(\simplesin);

Synth(\simplenoise, [\freq, 1000]);

Synth(\beepdecay, [\freq,1000]);

Synth(\noisedecay);

)

(

~freq = 440;

~intervals = [3/2,4/3,2,1/2,2/3,1/3,1/2,1];

t = TempoClock(160/60).sched(0,{
	
	var newfreq;
	
	Synth(\simplesin,[\freq,~freq]);	
	
	newfreq = ~freq * ~intervals.choose;
	
	if((newfreq>200).and(newfreq<12000),{
	
		~freq = newfreq;
		
	});
	
	Synth(\simplenoise,[\freq,newfreq]);
	
	1;
	
});

u = TempoClock(120/60).sched(0,{

	var newfreq = ~freq;
	
	while({newfreq<200},{newfreq=newfreq*2});
	
	while({newfreq>1000},{newfreq=newfreq/2});
	
	Synth(\beepdecay, [\freq,newfreq]);
	
	4+10.rand;
	
});

)

Synth(\bassdrum);