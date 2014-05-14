


(

SynthDef(\bassOne,{

	|freq=110, amp=0.2, dur=1|

	var env, tone, out;

	tone = RLPF.ar(Saw.ar([freq/2,freq,freq*2]),freq*3/2,0.2)*(-40).dbamp;

	tone = tone + (HPF.ar(Pulse.ar(freq/2,0.05),freq*8)*(-60).dbamp);

	env = EnvGen.ar(Env([0,1,0.5,0],[0.001,dur,0.001]), doneAction:2);

	out = tone*env;

	Out.ar(0,out!2);

}).store;

Synth(\bassOne);

SynthDef(\percGen,{

	|freq=100, amp=0.2, amp2=0.2, spread=1, dampen=1, a=0, d=1, r=0|

	var env, tone, out;

	tone = SinOsc.ar(freq+(RLPF.ar(PinkNoise.ar(),freq*dampen,0.05)*freq*spread));

	env = EnvGen.ar(Env([0,amp,amp2,0],[a,d,r]), doneAction:2);

	out = tone*env;

	Out.ar(0,out!2);

}).store;

)

(

Synth(\percGen,[\freq,55,\spread,0.4,\dampen,0.1,\a,0.002,\d,0.02,\r,0.3,\amp,0.8,\amp2,0.4]);
Synth(\percGen,[\freq,1500,\spread,12,\dampen,4,\a,0.002,\d,0.03,\r,0.075,\amp,0.05,\amp2,0.0125]);

Synth(\percGen,[\freq,10000,\spread,0.2,\dampen,0.4,\a,0.05,\d,0.005,\r,0.005,\amp,0.05,\amp2,0.0125]);
Synth(\percGen,[\freq,10000,\spread,0.2,\dampen,0.4,\a,0.002,\d,0.03,\r,0.075,\amp,0.07,\amp2,0.0125]);

Synth(\percGen,[\freq,100,\spread,0.8,\dampen,3,\a,0.001,\d,0.03,\r,0.1,\amp,0.1,\amp2,0.025]);
Synth(\percGen,[\freq,90,\spread,0.8,\dampen,3,\a,0.001,\d,0.03,\r,0.1,\amp,0.1,\amp2,0.025]);

)

// -- //

(

	var kick = [\freq,55,\spread,0.4,\dampen,0.1,\a,0.002,\d,0.02,\r,0.3,\amp,(-2).dbamp,\amp2,0.4];
	var snare = [\freq,1500,\spread,12,\dampen,4,\a,0.002,\d,0.03,\r,0.075,\amp,(-33).dbamp,\amp2,0.0125];
	var tamb1 = [\freq,10000,\spread,0.2,\dampen,0.4,\a,0.05,\d,0.005,\r,0.005,\amp,(-32).dbamp,\amp2,0.0005];
	var tamb2 = [\freq,10000,\spread,0.2,\dampen,0.4,\a,0.002,\d,0.03,\r,0.075,\amp,(-32).dbamp,\amp2,0.0005];

	t = TempoClock(160/60).sched(0,{

		|beat|

		((beat*6)%48).postln;

		if([0,4,30,34,12,36].indexOf((beat*6).asInteger%48)!=nil,{

			var note = [6.rand+6.rand-6,12.rand-6,4.rand+4.rand+4.rand-6].wchoose([0.2,0.3,0.5]);

			Synth(\bassOne,[\freq,Scale.dorian.degreeToFreq(note,110,3),\dur,0.15]);
			Synth(\bassOne,[\freq,Scale.dorian.degreeToFreq(note+(2.rand*2-1*2),110,2),\dur,0.16]);
			Synth(\bassOne,[\freq,Scale.dorian.degreeToFreq(note+(3.rand-1*2),110,0),\dur,0.1]);

		});

		if([0,4,30,34].indexOf((beat*6).asInteger%48)!=nil,{

			Synth(\percGen, kick);

		});

		if([12,36].indexOf((beat*6).asInteger%48)!=nil,{

			Synth(\percGen,snare);

		});

		if(([20]).indexOf((beat*12).asInteger%48)!=nil,{

			Synth(\percGen,tamb1);

		});

		if(([12]).indexOf((beat*12).asInteger%24)!=nil,{

			Synth(\percGen,tamb2);

		});

		1/6;

	});

)