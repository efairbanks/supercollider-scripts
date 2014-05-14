// ================================== //
// SuperCollider Live Coding Template //
// ================================== //

s.reboot;

(
~kick = Bus.audio(s,2);
~hats = Bus.audio(s,2);
~snare = Bus.audio(s,2);
~bass = Bus.audio(s,2);
~mixer = {
	var kick, snare, hats, bass, out;
	kick = In.ar(~kick,2);
	snare = In.ar(~snare,2);
	hats = In.ar(~hats,2);
	bass = In.ar(~bass,2);
	out = snare+hats+bass;
	out = out + (LPF.ar(HPF.ar(FreeVerb.ar(out,1,0.3,0.95),400),11000)/5);
	out = Compander.ar(out, kick, 0.025, 1, 1/3, 0.001, 0.05)+HPF.ar(kick,100);
	Out.ar(0,out);
}.play;
)

(
~tick = 0;
~lvls = [2];

~lvl2ticks = { |lvl|
    var product = 1;
    (lvl).do({ |inc| product = product * ~lvls.clipAt(inc);});
    product;
};

~ifIsBoundary = { |lvl,rhythm,func|
    var boundary = (~tick/~lvl2ticks.(lvl)).asInteger;
    if(((~tick%~lvl2ticks.(lvl))==0).and(rhythm.wrapAt(boundary)>0),{
        func.(~tick,boundary);
    });
};
)

(
~prog = [5,2,6,1,3,7,4,1]-1;
~degree = ~prog.wrapAt(-1);
~nextDegree = ~prog.wrapAt(0);
~scale = Scale.minor;
~contour = 5;
)

(
~metro = {
	//~ifIsBoundary.(3,[1,0,1,1,0,1,1,0],{Synth(\kick,[\outBus,~kick]);});
	~ifIsBoundary.(7,[1],{|tick,boundary|
		~degree = ~nextDegree;
		~nextDegree = ~prog.wrapAt(boundary);
	});

	~ifIsBoundary.(4,[1],{|tick,boundary|
		Synth(\kick,[\amp,0.25,\outBus,~kick]);
	});

	~ifIsBoundary.(4,[0,1],{|tick,boundary|
		Synth(\snare,[\amp,0.75,\outBus,~snare]);
	});

	~ifIsBoundary.(3,[0,1],{|tick,boundary|
		Synth(\hats,[\amp,0.025,\outBus,~hats]);
	});

	
	~ifIsBoundary.(2,[1,0,1,0,1],{|tick,boundary|
		var tones, freq, delay, degree;
		tones = [1,5,10,15]-1;
		tones.size.do({|inc|
			degree = ~degree+tones[inc];
			while({degree<25},{degree = degree + 7});
			freq = ~scale.performDegreeToKey(degree+21).midicps;
			delay = inc/(tones.size-1);
			delay = delay*0.01+0.01.rand;
			Synth(\string,[\freq,freq,\delay,delay,\amp,0.175,\outBus,~bass]);
		});
	});
	
	~ifIsBoundary.(2,[1],{|tick,boundary|
		var degree, freq, thisChord, nextChord;
		thisChord = ~degree+[0,2,4];
		nextChord = ~degree+[0,2,4];
		if(boundary%2==1,{thisChord=nextChord;});
		degree = (~degree+(thisChord)).wrapAt(boundary);
		while({degree>~contour},{degree = degree - 7});
		while({degree<~contour},{degree = degree + 7});
		freq = ~scale.performDegreeToKey(degree+21).midicps;
		Synth(\string,[\freq,freq,\amp,(degree/130),\outBus,~bass]);
	});
	
	~tick = ~tick + 1;1/16;
};
)

(
t=TempoClock(140/60).schedAbs(0,{~metro.();});
)

(

SynthDef(\string, {
	|freq=440,amp=0.1,outBus=0,delay=0|
	var out, env;
	//freq = Rand(-1.0,1.0)*(freq/400)+freq;
	env = EnvGen.ar(Env([0,1,2/3,0],[0.005,0.15,1]),doneAction:2);
	out = PinkNoise.ar()*env;
	out = Pluck.ar(out, 1, freq.reciprocal, freq.reciprocal, 200,0.4);
	out = out*env*amp*10;
	out = DelayN.ar(out, 0.05, delay);
	Out.ar(outBus, out!2);
}).store;

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

    |freq=110, dur=0.3, amp=0.1, timbre = 0, outbus = 0|

    var tone, env, out;

    tone = LPF.ar(Pulse.ar([freq,freq*10],[0.25,0.05]), freq+(freq*7*timbre));

    env = EnvGen.ar(Env([0,1,1/3,0],[0.01, dur/10, dur*9/10]), doneAction:2);

    out = Mix.ar(tone * env * amp);

    Out.ar(outbus, out!2);

}).store;

)