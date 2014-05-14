// ================================== //
// SuperCollider Live Coding Template //
// ================================== //

s.reboot;

(
~kick = Bus.audio(s,2);
~hats = Bus.audio(s,2);
~snare = Bus.audio(s,2);
~bass = Bus.audio(s,2);
~sawStab = Bus.audio(s,2);
~pulseLead = Bus.audio(s,2);
~sweep = Bus.audio(s,2);
)

(
~mixer.free;
~mixer = {
	var kick, snare, hats, bass, sawStab, pulseLead, sweep, out;
	kick = In.ar(~kick,2);
	snare = In.ar(~snare,2)+BPF.ar(FreeVerb.ar(In.ar(~snare,2),1,0.99,0.9),1000,1,1/4);
	hats = In.ar(~hats,2);
	bass = In.ar(~bass,2);
	sawStab = Compander.ar(FreeVerb.ar(In.ar(~sawStab,2),1/4,0.8,0.8),bass,0.025,1,1/4,0.001,0.2);
	pulseLead = In.ar(~pulseLead,2);
	sweep = In.ar(~sweep,2);
	out = kick+snare+hats+bass+sawStab+pulseLead+sweep;
	out = out + (LPF.ar(HPF.ar(FreeVerb.ar(out,1,0.3,0.95),400),11000)/5);
	out = Compander.ar(out,out,0.1,1,1/8,0.01,0.2);
	Out.ar(0,out);
}.play;
)

(
~tick = 0;
~lvls = [2];
~ticksPerBeat = 16;

~lvl2ticks = { |lvl|
	var product = 1;
	(lvl).do({ |inc| product = product * ~lvls.clipAt(inc);});
	product;
};

~lvl2seconds = { |lvl|
	~lvl2ticks.(lvl)*t.beatDur/~ticksPerBeat;
};

~ifIsBoundary = { |lvl,rhythm,func|
	var boundary = (~tick/~lvl2ticks.(lvl)).asInteger;
	if(((~tick%~lvl2ticks.(lvl))==0).and(rhythm.wrapAt(boundary)>0),{
		func.(~tick,boundary);
	});
};

)

(
~bassProgression = [4,5,0,0,4,5,0,0,3,2,0,6,4,5,3,0];
~bassRhythmProgression = [1,0,0,0,0,0,0,1]!2 ++ [[1,0,1,0,1]];
~pulseLeadProgression = [4,0,2,0,6,0];
~muteProgression = [[1,1,0,1,0,0,0,0,0]];
~muteProgression = ~muteProgression++[[1,1,1,1,1,0,0,0,0]];
~muteProgression = ~muteProgression++[[1,1,1,1,1,1,0,0,1]];
~muteProgression = ~muteProgression++[[1,1,1,1,1,1,1,1,0]];
~muteProgression = ~muteProgression++[[0,1,0,1,0,0,1,1,0]];
~muteProgression = ~muteProgression++[[1,1,0,1,1,0,1,0,1]];
~muteProgression = ~muteProgression++[[1,1,1,1,1,1,1,1,0]];
~scale = Scale.minor;

~metro = {
	~ifIsBoundary.(10,[1],{
		|tick, boundary|
		~mute = ~muteProgression.wrapAt(boundary);
	});
	~ifIsBoundary.(6,[1],{
		|tick, boundary|
		~bassDegree = ~bassProgression.wrapAt(boundary);
	});
	~ifIsBoundary.(2,[1],{
		|tick, boundary|
		~pulseLeadDegree = ~bassDegree + ~pulseLeadProgression.wrapAt(boundary);
	});

	~ifIsBoundary.(3,[1,0,1,1,0,1,1,0]*~mute[0],{Synth(\kick,[\outBus,~kick,\amp,0.065]);});
	~ifIsBoundary.(5,[0,1]*~mute[1],{Synth(\snare,[\outBus,~snare,\amp,0.065]);});
	~ifIsBoundary.(3.rand+1,[1,0]*~mute[2],{
		|ticks, boundary|
		Synth(\hats,[\amp,0.0065*(cos(2*pi*boundary/3)+2/3),\outBus,~hats]);
	});

	~ifIsBoundary.(10,[1],{
		|tick, boundary|
		~bassRhythm = ~bassRhythmProgression.wrapAt(boundary);
	});

	~ifIsBoundary.(3,~bassRhythm*~mute[3],{
		var freq = ~scale.degreeToFreq(~bassDegree,55,0);
		Synth(\bass,[\outBus,~bass,\amp,0.5,\freq,freq]);
		Synth(\bass,[\outBus,~bass,\amp,0.1,\freq,freq*3]);
	});

	~ifIsBoundary.(4,[0,1,0,1]*~mute[4],{
		3.do({|inc|
			Synth(\sawStab,[\freq,~scale.degreeToFreq(~bassDegree+(inc*2)%7,55,2),\amp,0.0135,\outBus,~sawStab]);
		});
	});

	~ifIsBoundary.(3,[1,0,1,0,0,1,0,1,0,0,1,0]*~mute[5],{
		2.do({|inc|
			var freq = ~scale.degreeToFreq(~pulseLeadDegree+(inc*4)%7,220,1);
			Synth(\pulseLead,[\amp,0.011,\freq,freq,\outBus,~pulseLead]);
		});
	});

	~ifIsBoundary.([2,3].choose,[1]*~mute[6],{
		var freq = ~scale.degreeToFreq(~pulseLeadDegree,220,2);
		Synth(\pulseLead,[\amp,0.009,\freq,freq,\outBus,~pulseLead,\dur,[1/10,1/20].choose]);
	});

	~ifIsBoundary.(10,[1]*~mute[7],{
		|tick, boundary|
		Synth(\sweep, [\startAmp,1/24,\endAmp,0,\startFreq,12300,\endFreq,500,\dur,~lvl2seconds.(9)]);
		Synth(\sweep, [\startAmp,1/20,\endAmp,0,\startFreq,9300,\endFreq,500,\dur,~lvl2seconds.(9)]);
		Synth(\sweep, [\startAmp,1/16,\endAmp,0,\startFreq,4600,\endFreq,500,\dur,~lvl2seconds.(9)]);
		Synth(\sweep, [\startAmp,1/12,\endAmp,0,\startFreq,2100,\endFreq,500,\dur,~lvl2seconds.(9)]);
	});

	~ifIsBoundary.(7,((0!7)++[1])*~mute[8],{
		|tick, boundary|
		Synth(\sweep, [\endAmp,1/12,\startAmp,0,\endFreq,4000,\startFreq,100,\dur,~lvl2seconds.(7)-0.025,\outBus,~sweep]);
	});

	~tick = ~tick + 1;1/~ticksPerBeat;
};
)

(
t=TempoClock(140/60).schedAbs(0,{~metro.();});
)

(
SynthDef(\kick, {

    |amp = 0.1, outBus = 0|

    var pitchEnv, ampEnv, tone, out;

    ampEnv = EnvGen.ar(Env([0,1,0],[0.005,0.15]), doneAction: 2);

    pitchEnv = EnvGen.ar(Env([1,0],[0.1]));

    pitchEnv = pitchEnv**20;

    tone = SinOsc.ar((pitchEnv*1000)+55, 0, ampEnv);

    out = Mix.ar(tone*amp);

    Out.ar(outBus, out!2);

}).store;

SynthDef(\snare, {
	|amp = 0.1, dur = 0.125, outBus = 0|

	var body, snare, stick, resoEnv, out;

	resoEnv = EnvGen.ar(Env([0.01,1,0.01],[0.005,dur]));

	snare = PinkNoise.ar();
	snare = BPF.ar(snare, [200,400,1000,5000], resoEnv)*4;
	snare = snare + (BPF.ar(PinkNoise.ar(),[7000,11000],0.8)/2);
	snare = snare*EnvGen.ar(Env([0,1,0],[0.005, dur]), doneAction:2)/2;
	snare = LPF.ar(HPF.ar(snare, 500),10000);

	stick = WhiteNoise.ar();
	stick = BPF.ar(stick, [1000,2000,3000], resoEnv/3);
	stick = stick*EnvGen.ar(Env([0,1,0],[0.001, 0.04]));

	body = HPF.ar(SinOsc.ar(EnvGen.ar(Env([1,0],[0.01]))*400+30),180);
	body = LPF.ar(body, 200)/2;

	out = HPF.ar(stick+snare+body,220)*amp;

	Out.ar(outBus, out!2);

}).store;

SynthDef(\hats, {

    |amp = 0.1, outBus = 0|

    var noise, env, out;

    env = EnvGen.ar(Env([0,1,0],[0.001,0.05]), doneAction:2);

    noise = BPF.ar(WhiteNoise.ar(), [5000,7000,11000], 1*env);

    out = Mix.ar(env * noise * amp);

    Out.ar(outBus, out!2);

}).store;

SynthDef(\bass,{

    |freq=110, dur=0.3, amp=0.1, timbre = 0, outBus = 0|

    var tone, env, out;

    tone = LPF.ar(Pulse.ar([freq,freq*10],[0.25,0.05]), freq+(freq*7*timbre));

    env = EnvGen.ar(Env([0,1,1/3,0],[0.01, dur/10, dur*9/10]), doneAction:2);

    out = Mix.ar(tone * env * amp);

    Out.ar(outBus, out!2);

}).store;

SynthDef(\sawStab,{

	|freq=440, dur=0.3, amp=0.1, outBus=0|

	var out, env, vibrato;

	env = EnvGen.ar(Env([0,1,1,0],[0.005,dur,0.02]),doneAction:2);

	vibrato = SinOsc.ar(8)*freq/50;

	out = HPF.ar(LPF.ar(Saw.ar(Mix.ar(freq+vibrato)+[0,5,-5])*env,freq*9),freq*3);

	out = out*amp;

	Out.ar(outBus, out!2);

}).store;

SynthDef(\pulseLead,{

	|freq=440, dur=0.4, amp=0.1, outBus=0|

	var out, env, pulseMod;

	pulseMod = SinOsc.ar(7,0,1/2,1/2);

	env = EnvGen.ar(Env([0,1,0],[0.001,dur,0.01]),doneAction:2);

	out = Pulse.ar(freq, pulseMod)*env;

	out = out * amp;

	Out.ar(outBus, out!2);

}).store;

SynthDef(\sweep,{

	|dur=1, startFreq=200, endFreq=8000, startAmp=0.001, endAmp=0.1, outBus=0|

	var out, ampEnv, freqEnv;

	ampEnv = EnvGen.ar(Env([startAmp,endAmp],[dur]),doneAction:2);
	freqEnv = EnvGen.ar(Env([startFreq,endFreq],[dur]),doneAction:2);

	out = BPF.ar(PinkNoise.ar(),freqEnv,0.3)*ampEnv;

	out = HPF.ar(out, 400);

	Out.ar(outBus, out!2);

}).store;

)