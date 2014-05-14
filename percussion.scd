// =====================================================================
// SuperCollider Workspace
// =====================================================================

(

SynthDef(\kick, {

	|amp = 0.1|

	var pitchEnv, ampEnv, tone, out;

	ampEnv = EnvGen.ar(Env([0,1,0],[0.005,0.15]), doneAction: 2);

	pitchEnv = EnvGen.ar(Env([1,0],[0.1]));

	pitchEnv = pitchEnv**20;

	tone = SinOsc.ar((pitchEnv*1000)+55, 0, ampEnv);

	out = tone*amp;

	Out.ar(0, out!2);

}).store;

SynthDef(\snare, {

	|amp = 0.1|

	var noise, env, out;

	env = EnvGen.ar(Env([0,1,0],[0.001,0.15]), doneAction:2);

	noise = BPF.ar(WhiteNoise.ar(), [200,1000,5000], 1*env);

	out = env * noise * amp;

	Out.ar(0, out!2);

}).store;

SynthDef(\hats, {

	|amp = 0.1|

	var noise, env, out;

	env = EnvGen.ar(Env([0,1,0],[0.001,0.05]), doneAction:2);

	noise = BPF.ar(WhiteNoise.ar(), [5000,7000,11000], 1*env);

	out = env * noise * amp;

	Out.ar(0, out!2);

}).store;

SynthDef(\bass,{

	|freq=110, dur=0.3, amp=0.1, timbre = 0|

	var tone, env, out;

	tone = LPF.ar(Pulse.ar([freq,freq*10],[0.25,0.05]), freq+(freq*7*timbre));

	env = EnvGen.ar(Env([0,1,1/3,0],[0.01, dur/10, dur*9/10]), doneAction:2);

	out = tone * env * amp;

	Out.ar(0, out!2);
	
}).store;

SynthDef(\crash,{

	|amp = 0.05|

	var tone, env, filterEnv, out;

	env = EnvGen.ar(Env([0,1,0.5,0],[0.01,0.15,24]), doneAction: 2);

	filterEnv = EnvGen.ar(Env([1,0],[16]), doneAction: 2);

	tone = WhiteNoise.ar();

	tone = RHPF.ar(tone, 8000*filterEnv+1000, 0.4*env);

	tone = LPF.ar(tone, 10000);

	out = tone*env*env*amp;

	Out.ar(0, out!2);

}).store;

)

(

~bassArp = 0;

~bassProg = 0;

~bassDegree = 0;

~processBeat = {

	|beat|

	Synth(\hats, [\amp, 0.015]);

	if(beat%10==0,{

		~bassProg = [0,4,2,1].wrapAt((beat/4).asInteger);

	});

	~bassArp = [0,4,0,2,0,6].wrapAt(beat.asInteger);

	~bassDegree = (~bassArp+~bassProg)%7;

	if([1,0,1,1,0,1,1].wrapAt(beat)==1,{

		var dur, timbre, freq = Scale.minor.degreeToFreq(~bassDegree, 30.midicps, 1);

		dur = (beat%32)/64+0.075;

		timbre = (beat%48)/48;

		if(([1,0,1,1,0,1,1].wrapAt(beat+1)==1).and(timbre<(3/4)),{dur = 0.2});

		Synth(\bass,[\amp,0.27,\freq,freq,\timbre,timbre,\dur,dur]);

	});

	if(beat%2==0,{

	});

	if(beat%4==0,{

		Synth(\kick,[\amp, 0.175]);

		if([0,1].wrapAt((beat/4).asInteger)==1, {
			
			Synth(\snare);

		});

	});

	if(beat%8==0,{



	});

	if((beat%48==0).and(beat%64==0),{

		Synth(\crash);

	});

};

)

(

~beat = 0;

t = TempoClock(110/15).sched(0,{

	~beat = ~beat + 1;

	~processBeat.(~beat);

	1;

});

)

t.stop;