

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

SynthDef( \masterbus, {
	
	|in = 32|
	
	var output = In.ar(in, 1);
	
	output = HPF.ar( output, 20 );
	
	output = Limiter.ar(output, 0.125, 0.05)*8;
	
	Out.ar(0, output!2);
	
}).add;


)

(

r = 'rest';

~hatseq = Prand([Pseq([1,0,1,1],1),Pseq([1,0,1,0],1),Pseq([1,1,1,0],1),Pseq([1,1,1,1],1)],inf).asStream;

~basseq = Pseq([0,r,r,4,1,r,r,r,2,r,r,r,3,r,5,4],inf).asStream;

~basseq = Pseq([0,r,r,1,r,r,3,r,2,r,r,-1,r,r,1,r],inf).asStream;

b = Bus.audio();

Synth.new( 'masterbus', ['in', b] );

t = TempoClock( 130/60 );

t.schedAbs( t.beats.ceil, { |beat, sec|
	
	var deg;
	
	if(beat%1 == 0){
	
		deg = ~basseq.next();
	
		(instrument: 'wobble', out: b, dur: t.beatDur*2, degree: deg, rate: 15.rand).play;	
		(instrument: 'sawpad', out: b, dur: t.beatDur*2, degree: deg + (2+(2-4.rand*2)), amp: 0.085).play;
		
	};
	
	if(beat%1 == 0){
		
		(instrument: 'kick', out: b).play;
	
	};
	
	if(beat+1%2 == 0){
	
		(instrument: 'snare', out: b).play;
		
	};
	
	if( ~hatseq.next() != 0 ){
		
		(instrument: 'hats', out: b).play;
		
	};
	
	0.25
	
});

)