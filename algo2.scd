
(
	
	
	
	SynthDef(\leads, {arg freq = 440, dur = 1, amp = 1.0;
		
		var env = Line.ar(1.0, 0, dur*5/4, doneAction:2);
		
		var tone = SinOsc.ar(freq*1, 0, amp);
		
		var output = tone*env;
		
		output = FreeVerb.ar(output, 0.5, 0.95, 0.05);
		
		Out.ar(0, output ! 2);
		
	}).add;
	
	

	SynthDef(\kick, {arg amp = 1.0, freq = 120;
		
		var env, sin, output;
		
		env = Line.ar(1.0, 0, 0.25, doneAction:2);
		
		sin = SinOsc.ar(freq*env*env, 0, amp);
		
		output = sin * env * env;
		
		Out.ar(0, output ! 2);
		
	}).add;
	
	SynthDef(\snare, { arg amp = 0.5, dur = 0.1;
	
		var env, noise, output;
		
		//noise = PinkNoise.ar(amp);
		
		noise = Dust2.ar(4000, amp);
		
		env = Line.ar(1.0, 0, 0.15, doneAction:2);
		
		output = LPF.ar(RHPF.ar( noise * env, 1000, 0.4), 9000);
		
		Out.ar(0, output ! 2 );
	
	}).add;
	
	SynthDef(\hats, {arg amp = 0.5, dur = 0.1;

		var env = Line.ar(1.0, 0, 0.05, doneAction:2);
		
		var noise = SinOsc.ar( WhiteNoise.ar(1000) + 12000, 0, amp);
		
		var output = LPF.ar(env * noise, 18000);
		
		Out.ar(0, output ! 2 );

	}).add;
	
)

(

	Pbind(
		\instrument, \leads,
		\scale, [0,2,4,6,7,9,11],
		\degree, Pseq([0,3,4,7,5,2,3,-1,2,-3] +.t [0,2,4],inf),
		\dur, Pseq([1, 1/2,1/2,1,1],inf),
		\amp, 0.1
	).play;
	
	Pbind(
		\instrument, \kick,
		\dur, 0.5,
		\amp, 0.4
	).play;
	
	Pbind(
		\instrument, \snare,
		\dur, 0.5,
		\amp, Pseq([Pseq([0,0.2],inf)],inf)
	).play;
	
	Pbind(
		\instrument, \hats,
		\dur, Pseq([1/8,1/8,1/8,1/16,1/16],inf)
	).play;

)