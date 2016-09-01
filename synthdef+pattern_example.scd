
(

TempoClock.default.tempo = 90/60;

var derp;

derp = SynthDef(\synth1,

	{ arg outbus = 0, freq = 440, dur = 0.5, amp = 0.3;
	
		var out, envelope;
	
		envelope = Line.ar(1.0, 0.0, dur, doneAction: 2);
	
		out = Pulse.ar(freq * envelope, envelope, 1.0);
	
		Out.ar( outbus, out ! 2 );
	
	});
	
derp.add();
	
p = Pbind(
	\instrument, \synth1,
	\scale, [0, 3, 4, 7, 9, 10, 11],
	\root, 0,
	\degree, Pseq([0,0,12,24,24,0]),
	\dur, Pseq([0.5,0.5,0.25,0.125,0.125,0.5], 4)
	);
	
p.play;

)