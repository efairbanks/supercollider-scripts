(

SynthDef(\pulse, {

	|freq = 440, dur = 0.1, amp = 0.1, width = 0.1|

	var tone, env, out;

	tone = Pulse.ar(freq, width);

	env = EnvGen.ar(Env([0,1,0],[0.005,dur]), doneAction:2);

	out = tone * env * amp;

	Out.ar(0,out!2);

}).store;

Synth(\pulse);

)

(

~getDivision = {

	|beat, div|

	(beat/div).asInteger;

};

~scale = Scale.minor;

~mainProgression = [0,3,5,6,2,4,5,-1];
~subProgression = [4,0,2,0,6,0];

//~degree = 0;
//~subDegree = 0;

~metro = {

	|beat|

	if(beat%128==0,{

		~mainProgression = [[0,3,5,6,2,4,5,-1],[0,6,4,3,1,6,5,4],[3,4,0]].choose;

	});

	if(beat%16==0,{

		~degree = ~mainProgression.wrapAt(~getDivision.(beat,16));

		~subDegree = ~subProgression.wrapAt(~getDivision.(beat,16));

		3.do({

			|inc|

			var freq = ~scale.degreeToFreq((~degree+(inc*2))%7,48.midicps,1);

			Synth(\pulse,[\freq,freq,\dur,2,\amp,0.03,\width, 0.05]);

		});

	});

	if(beat%8==0,{

	});

	if(beat%4==0,{

		var freq;

		~subDegree = ~subProgression.wrapAt(~getDivision.(beat,4));

		freq = ~scale.degreeToFreq(~degree+~subDegree,24.midicps,1);

		Synth(\pulse,[\freq,freq,\dur,0.2,\amp,0.05,\width, 0.2]);

	});

	if(beat%2==0,{

		var freq;

		~subDegree = ~subProgression.wrapAt(~getDivision.(beat,2));

		freq = ~scale.degreeToFreq((~degree+~subDegree)%7,48.midicps,1);

		Synth(\pulse,[\freq,freq,\dur,0.3,\amp, 0.065,\width,0.4]);

	});

};

)

(

t = TempoClock((100/15)*2).schedAbs(0,{

	|beat|

	~metro.(beat);

	1;

});

)