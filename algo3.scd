
(
	SynthDef(\leads, {arg freq = 440, dur = 1, amp = 1.0;
		
		var env = Line.ar(1.0, 0, dur*5/4, doneAction:2);
		
		var tone = SinOsc.ar(freq*2, 0, amp);
		
		var output = tone*env;
		
		output = FreeVerb.ar(output, 0.5, 0.95, 0.05);
		
		Out.ar(0, output ! 2);
		
	}).add;
	
)

(

	Pbind(
	
		\instrument, \leads,
		
		\degree, Pseq([0,1,2,3] +.t [8,2,4],inf)
	
	).play;
	
	Pbind(
	
		\instrument, \leads,
		
		\degree, Pseq([-16,-17,-18,-19],inf)
	
	).play;

)