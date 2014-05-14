(

var buttonIndex;

"/Users/ericfairbanks/Dropbox/SuperCollider/padKONTROLclassInterfaceFinal.scd".loadPath;

~padKONTROL.().start();

~padKONTROL.().lightState(0, 0);

~padKONTROL.().setLights();

)

(

~beatIndex = 0;

~divs = 16;

free(z);

b = Buffer.read(s, Platform.resourceDir +/+ "sounds/break.wav");

b.bufnum;

SynthDef(\breakplayer,{ arg rate=1, mix = 0.3, offset = 0.5, t_trig;
 var phasor, out;

	phasor = Phasor.ar(t_trig, BufRateScale.kr(b.bufnum) * rate, 0, BufFrames.kr(b.bufnum))+(offset*BufFrames.kr(b.bufnum));

	out = BufRd.ar(2, b.bufnum, phasor);

	Out.ar(0,out!2);
}).store;

z = Synth(\breakplayer);

t.stop;

t = TempoClock(170/60).sched(0,{

	|beat|

	~divs.do({

		|inc|

		if((~padKONTROL.().buttonState(inc)==\pressed),
			{~beatIndex = inc; "SDFSD".postln;});

	});

	z.set(\offset, (~beatIndex)/~divs, \t_trig, 1);

	16.do({

		|inc|

		var state = 0;

		if(inc==(~beatIndex),{ state = 1; });

		~padKONTROL.().lightState(inc, state);

	});

	~padKONTROL.().setLights();

	~padKONTROL.().decayButtonStates();

	~beatIndex = (~beatIndex+1)%~divs;

	0.5;

});

)

(

s = Server.local;
s.sendMsg("/b_alloc", 0, 44100 * 2);

y = { arg rate=1, mix = 0.3;
 var in, out;

	in = SinOsc.ar(LFNoise1.kr(2, 300, 400), 0, 0.1)*Pulse.ar(6.4,0.99);

	out = BufRd.ar(1, 0, Phasor.ar(0, (BufRateScale.kr(0) * rate), 0, BufFrames.kr(0)));

	BufWr.ar(in+(out*mix), 0, Phasor.ar(0, (BufRateScale.kr(0) * rate), 0, BufFrames.kr(0)));

	Out.ar(0,out!2);
}.play;

)



