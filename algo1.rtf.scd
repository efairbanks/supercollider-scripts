


(

SynthDef(\kick, {arg amp = 0.5, freq = 180;

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

	Out.ar(0, output ! 2 ); }).add;

SynthDef(\hats, {arg amp = 0.5, dur = 0.1;

	var env = Line.ar(1.0, 0, 0.05, doneAction:2);

	var noise = SinOsc.ar( WhiteNoise.ar(1000) + 12000, 0, amp);

	var output = LPF.ar(env * noise, 10000);

	Out.ar(0, output ! 2 );

}).add;

SynthDef(\bass, {arg freq = 110, dur = 1, amp = 1.0;

	var env = Line.ar(1.0, 0, dur, doneAction:2);

	var tone = SinOsc.ar(SinOsc.ar(freq/2,0,freq/4)+freq/4, 0, amp*2/3) + LPF.ar(Pulse.ar(freq/4, env*0.125, amp*3/10), freq*8);

	var output = LPF.ar(HPF.ar(env * tone * env, 120), freq*2);

	Out.ar(0, output ! 2);

}).add;

SynthDef(\leads, {arg freq = 440, dur = 1, amp = 1.0;

	var env = Line.ar(1.0, 0, dur*5/4, doneAction:2);

	var tone = SinOsc.ar(freq*4, 0, amp);

	var output = tone*env;

	Out.ar(0, output ! 2);

}).add;

)

(

var t = TempoClock(140/60);

var minmaj = 1;



var sf = BBCutBuffer("sounds/break",8);

var cut;



t.play;

Routine.run({

	s.sync;

	cut = BBCut2(CutBuf2(sf, 0.0)).play(t);

});



Pbind(\instrument, \kick, \freq, 160, \dur, 1).play(t);

Pbind(\instrument, \hats, \dur, Pseq([0.5,0.25,0.25],inf), \amp, Pseq([0,0.025,0.0125],inf)).play(t);

Pbind(\instrument, \snare, \dur, 1, \amp, Pseq([0,0.065], inf)).play(t);

Pbind(\instrument, \bass,
	 \scale, [0,2,3,5,7,8,10],
	 \root, [0],
	 \dur, Pseq([0.5,0.5,0.5,0.5],inf),
	 \degree, Pseq([Pseq([7,0,7,0],1), Pbrown(0,6,2,4),Pseq([5,0,5,\rest],1), Pbrown(0,6,1,4)], inf) ).play(t);

Pbind(\instrument, \leads,
	 \scale, [0,2,3,5,7,8,10],
	 \dur, Pseq([Pseq([1,1,1,0.5,0.5],3),Pseq([0.5,0.25,0.25,0.125,0.125,0.25,0.25,0.25,0.5,0.5,1],1)], inf),
	 \degree, Pseq([Pseq([Pseq([0,1,-3], 3), Pbrown(-3,1,2,3), Pbrown(-3,1,1,3)], 2), Pseq([0,1,2,3,4],2)], inf),
	 \amp,0.0075).play(t);

)
