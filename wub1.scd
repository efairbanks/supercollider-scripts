
(

SynthDef( \hats, {

	|amp=0.1,out=0,len=0.1|
	
	var env1, output;
	
	env1 = EnvGen.ar( Env.new([0,1,0],[0.0005,len]), doneAction:2 );
	
	output = WhiteNoise.ar()*env1*env1*env1*env1*amp;
	
	output = FreeVerb.ar( output, 1/3, 0.8, 0.05 );
	
	output = HPF.ar( output, 5000 );
	
	Out.ar(out, output);
	
}).add;

SynthDef( \snare, {

	|amp=0.1,out=0|
	
	var env1, output;
	
	env1 = EnvGen.ar( Env.new([0,1,0],[0.001,1/3]), doneAction:2 );
	
	output = WhiteNoise.ar()*env1*env1*env1*env1*amp;
	
	output = LPF.ar( output, 7000 );
	
	output = FreeVerb.ar( output, 1/3, 0.8, 0.05 );
	
	Out.ar(out, output);
	
}).add;

SynthDef( \kick, {
	
	|amp=0.1,out=0|
	
	var output, env1, env2;
	
	env1 = EnvGen.ar( Env.new([0,1,0],[0.005,0.07]), doneAction:2 );
	
	env2 = EnvGen.ar( Env.new([0,1,0],[0.0001,0.005]) );
	
	output = SinOsc.ar(200*env1) + SinOsc.ar(100*env1,env1);
	
	output = output + (WhiteNoise.ar()*0.075*env2);
	
	output = LPF.ar( output, env1*4000 );
	
	output = output * amp * env1;
	
	Out.ar(out, output);
	
}).add;

(instrument: 'kick').play;

SynthDef( \wobble, {
	
	|freq=440,amp=0.1,out=0,rate=3,dur=1|
	
	var output;
	
	var env1 = EnvGen.ar( Env.new([0,1,1,0],[0,dur,0]), doneAction:2 );
	
	output = Pulse.ar(freq/4,0.5);
	
	output = output + SinOsc.ar(freq/4);
	
	output = output + Saw.ar(freq/4);
	
	output = output + (Saw.ar(freq*3/8)*0.5);
	
	output = output + SinOsc.ar(freq/8);
		
	output = output * amp * env1;
	
	output = FreeVerb.ar( output, 1/3, 0.95, 0.05 );
	
	output = RLPF.ar( output, SinOsc.ar(rate,0,8000,8100) );
	
	output = FreeVerb.ar( output, 1/6, 0.99, 0.5 ) * env1 * env1;
	
	Out.ar(out, output);
	
}).add;

SynthDef( \masterbus, {
	
	|in = 32|
	
	var output = In.ar(in, 1);
	
	output = HPF.ar( output, 20 );
	
	output = Limiter.ar(output, 0.5, 0.05)*2;
	
	Out.ar(0, output!2);
	
}).add;

SynthDef( \sawpad, {
	
	|freq=440,amp=0.1,out=0,dur=1|
	
	var output, env;

	env = EnvGen.ar(Env.new([1,0.5],[dur],\sine),doneAction:2);
	
	output = Pulse.ar( freq, env/2+0.25 );
	
	output = FreeVerb.ar( output, 1/3, 0.95, 0.05 );
	
	output = output * env * amp;
	
	output = RHPF.ar( output, freq*4*env, 0.4 );
	
	Out.ar( out, output );
	
}).add;

)

(

t = TempoClock(1);

~masterbus = Bus.audio();

b = Synth.new( \masterbus, [\in, ~masterbus] );

//(degree: 0, instrument: \wobble, out: ~masterbus ).play;

~bseq1 = Pseq([0,3+Prand([4,-1,0],Prand([1,5],1)),5,Prand([2,4,6,14,18],1)],4);

~bseq2 = Pseq([0,1,2,3,0,-1,-2,-3],2);

~bseq3 = Pseq([Pbrown(-3,6,2,4),Pbrown(-2,1,1,4),Pbrown(-4,2,2,4),Pbrown(-2,10,3,4),],1);

Pbind(	\instrument, \wobble,
		\scale, [0,2,3,5,7,8,11],
		\out, ~masterbus,
		\degree, Prand([~bseq1,~bseq2,~bseq3],inf),
		\rate, Prand([1,3,4,5,6,7,10],inf),
		\dur, 1,
		\amp, 0.15
).play(t);

/*
Pbind(	\instrument, \sawpad,
		\scale, [0,2,3,5,7,8,10],
		\out, ~masterbus,
		\degree, Pseq([7,5,Prand([2,3,4],1),0] +.t [0,-3],inf),
		\dur, 2,
		\amp, 0.02
).play(t);
*/

Pbind(	\instrument, \kick,
		\out, ~masterbus,
		\dur, 1/3,
		\amp, Pseq([1,0,0,1,0,0.5,1,0,0,1,0.4,0.2],inf)
).play(t);

Pbind(	\instrument, \snare,
		\out, ~masterbus,
		\amp, Pseq([0,0,0.6,0,0,0,0.6,Prand([0,0,0,0.2],1)],inf),
		\dur, 0.5
).play(t);

Pbind(	\instrument, \hats,
		\out, ~masterbus,
		\amp, Prand([0.1,0.2,0.25]/3,inf),
		\len, Pseq([0.125,0.125,0.125,0.25],inf),
		\dur, Pseq([0.25,Pseq([0.25/3],3)],inf)
).play(t);


)