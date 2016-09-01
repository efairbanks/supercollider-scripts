
(

f = {
	
	|pulses, steps|
	
	var a = Array.new(steps);
	
	var b = Array.new(steps);
	
	var tempa = Array.new(steps);
	
	var tempb = Array.new(steps);
	
	var split;
	
	steps.do({
		
		|inc|
		
		if(	inc<pulses,
			{a = tempa.add(Array.new(steps).add(1));},
			{b = tempb.add(Array.new(steps).add(0));});
			
	});
	
	// --- //
	
	while(	{(b.size>1).and(a.size>0)},{
			
		split = 0;
		
		b.size.do({
		
			|inc|
			
			tempa = Array.new(steps).addAll(a);
			
			a[inc%a.size] = tempa[inc%a.size].add(b[inc]);
			
			split = (split+1)%a.size;
			
		});
		
		b = a.copyRange(split,a.size-1);
		
		tempa = a.copyRange(0,split-1);
		
		a = Array.new(steps).addAll(tempa);

	});
		
	a.addAll(b).flat;
	
};

g = {

	|array|
	
	var return = Array.new();
	
	array.size.do({
		
		|inc|
		
		if(	(array[inc] == 0).and(return.size>0),
			{return[return.size-1] = return[return.size-1] + 1;},
			{return = return ++ [0];}
		);
				
	});
	
	return+1;
	
};

h = {
	
	|lengths, pulses, slots|

	var a = Array.new();
	
	lengths.size.do({
		
		|inc|
		
		a = a ++ f.value( pulses.wrapAt(inc), slots ).copyRange(0,lengths.wrapAt(inc)-1);
		
	});

	a;

};

)

// --- Some sweet Euclidian beats --- //

(

~measure = 16;

z = f.value(5,~measure);

x = h.value(g.value(z)*2, [2,6,4],64);

y = h.value(g.value(x)*2, [10,13,11], 16);

w = h.value(g.value(y)*2, [3,1,2,4], 4);

Pbind(\instrument, \kick, \dur, Pseq(g.value(z)/2,inf)).play;

Pbind(	\instrument, \snare,
		\dur, 1/4,
		\amp, Pseq(x.rotate(4)/10,inf),
		\freq, 4000,
		\res, 0.2).play;

Pbind(	\instrument, \hats,
		\dur, Pseq(g.value(y)/8,inf),
		\amp, Pseq((2**g.value(y)/70),inf),
		\len, Pseq((2**g.value(y)/15),inf)).play;

Pbind(	\instrument, \pop,
		\dur, Pseq(g.value(w)/16,inf),
		\amp, Pseq((g.value(w)/8),inf),
		\len, Pseq((2**g.value(w)*10),inf),
		\freq, 10000).play;

)

~measure/2.round(1)

// --- //

(

Pbind(	\instrument, \hats,
		\out, [0,1],
		\dur, 0.2,
		\len, 0.4,
		\amp, Pseq(f.value(5,13)/10,inf)).play;
		
Pbind(	\instrument, \hats,
		\out, [0,1],
		\dur, Prand([0.2,0.4],inf),
		\amp, Pseq(f.value(9,13)/10,inf)).play;

Pbind(\instrument, \kick, \out, [0,1], \dur, 0.2, \amp, Pseq(f.value(2,13),inf)).play;

Pbind(\instrument, \snare, \out, [0,1], \dur, 0.2, \amp, Pseq(f.value(1,13).rotate(7)/2,inf)).play;

Pmono(	\reese,
		\out, [0,2],
		\dur, 0.2*13/Prand([2],inf),
		\amp, 0.13,
		\wobble,Prand([1/3,1,3,5,13],inf),
		\degree, Pseq([0,0,-1,-1,Prand([1,2],1),Prand([3,2],1),3,Prand([2,3],1)],inf),
		\scale,[0,3,5,7,10]).play;

z;

g.value(f.value(7,16));

)

// --- //

(

z = Pbind(	\instrument, \leads,
				\amp, Pseq(f.value(rand(23,31),32)),
				\degree, Pseq((f.value(rand(13,31),32)+f.value(rand(11,19),32)+(f.value(rand(3,11),32)*2) * (f.value(rand(21,31),32)*2-1)).integrate +.t [0,2,4] - 4),
				\dur, 0.5,
				\scale, [0,2,3,5,7,8,10]);

t = TempoClock(140/60);

t.schedAbs(0,{
	
	Pbind(	\instrument, \leads,
			\amp, Pseq(f.value(rand(23,31),32)),
			\degree, Pseq((f.value(rand(13,31),32)+f.value(rand(11,19),32)+(f.value(rand(3,11),32)*2) * (f.value(rand(21,31),32)*2-1)).integrate +.t [0,2,4] - 4),
			\dur, 0.5,
			\scale, [0,2,3,5,7,8,11]).play;
	
	32;
	
});

101.do({

	|ind|
	
	ind.do({
		
		|inc|
		
		f.value(inc,ind).postln;
		
	});
	
});

)

// --- //

(

t = TempoClock(140/60);

~pop1_1 = Prand([Pseq(f.value(1,8)),Pseq(f.value(2,8))],inf);

~pop2_1 = Prand([Pseq(f.value(3,8)),Pseq(f.value(2,8))],inf);

~pop3_1 = Prand([Pseq(f.value(3,12)),Pseq(f.value(3,8)),Pseq(f.value(4,16))],inf);

Pbind(	\instrument, \pop,
		\amp, ~pop1_1*6/7,
		\dur, 1/4,
		\len, 15,
		\out, [0,1],
		\res, 1,
		\freq, 300).play(t);
		
Pbind(	\instrument, \pop,
		\amp, ~pop2_1*3/5,
		\dur, 1/8,
		\len, 10,
		\out, [1],
		\res, 0.25,
		\freq, 5000).play(t);
	
Pbind(	\instrument, \pop,
		\amp, ~pop3_1/2,
		\dur, 1/16,
		\len, 10,
		\out, [0],
		\res, 0.25,
		\freq, 2500).play(t);
	
)

(

t = TempoClock( 140/60 );

a = 10;
b = 11;
c = 12;
d = 13;
e = 14;
f = 15;

// --- High Hats --- //

~hh1 = Pbind(	\instrument, \hats,
					\dur, Pseq( [2,[2,1,1,2,2],1].convertRhythm ),
					\amp, Pseq( [4,1,1,3,4]/4 )
				);
				
~hh2 = Pbind(	\instrument, \hats,
					\dur, Pseq( [2,[1,1,1,1],1].convertRhythm ),
					\amp, Pseq( [2,2,3,4]/4 )
				);
				
~hh3 = Pbind(	\instrument, \hats,
					\dur, Pseq( [2,[2,2],1].convertRhythm ),
					\amp, Pseq( [3,3]/4 )
				);
				
~hh4 = Pbind(	\instrument, \hats,
					\dur, Pseq( [2,[1,1,1,1,1,1,1,1],1].convertRhythm ),
					\amp, Pseq( [4,3,2,1,3,4,2,1]/4 )
				);
				
~hh5 = Pbind(	\instrument, \hats,
					\dur, Pseq( [2,[3,3,2],1].convertRhythm ),
					\amp, Pseq( [2,3,4]/4 )
				);
				
// --- Kick Drum --- //

~kk1 = Pbind(	\instrument, \kick,
					\dur, Pseq( [2,[1],1].convertRhythm ),
					\amp, Pseq( [3]/4 )
				);
				
~kk2 = Pbind(	\instrument, \kick,
					\dur, Pseq( [2,[3,3,2],1].convertRhythm ),
					\amp, Pseq( [4,3,3]/16 )
				);

// --- Snare Drum --- //

~sn1 = Pbind(	\instrument, \snare,
					\dur, Pseq( [4,[1,1],1].convertRhythm ),
					\amp, Pseq( [0,2]/5 )
				);

// --- Bass --- //

~bs1 = Pmono(	\reese,
					\dur, Pseq( [16,[1,1,1,1],1].convertRhythm ),
					\degree, Pseq([0,3,-3,-1]),
					\wobble, 140*7/8/60*Prand([0,1,2,3,5,7,11],inf),
					\amp, 1/15
				);

// --- //
				
//z = Pseq([~hh1,~hh2,~hh3,~hh4,~hh5]);

z = Prand([~hh1,~hh2,~hh3,~hh4,~hh5],inf);

z = Pbindf(z, \out, [0,1], \len, Prand([1,2,3]/30+0.1,inf), \amp, 1/10);

z.play(t);

y = Prand([~kk1,~kk2],inf);

y = Pbindf(y, \out, [0,1], \amp, 0.075);

y.play(t);

x = Prand([~sn1],inf);

x = Pbindf(x, \out, [0,1]);

x.play(t);

w = Prand([~bs1],inf);

w = Pbindf(w, \out, [0,1]);

w.play(t);

)

// --- //

( instrument: 'snare', amp: 1.0 ).play;

( instrument: 'kick', amp: 1.0 ).play;

( instrument: 'hats' ).play;

( instrument: 'reese' ).play;

( instrument: 'pop', out: [0,1], dur: 6).play;

// --- //

(

SynthDef( 'pop',
{
	
	|freq = 2000, amp = 0.6, out = 0, len = 200, res = 1|
	
	var output;
	
	output = PinkNoise.ar()*amp;
	
	output = output*EnvGen.ar( Env([1,0],[len/1000]), doneAction:2 );
	
	output = BPF.ar( output, freq, res );
	
	Out.ar( out, output );
	
}).add;

SynthDef( 'reese',
{

	|freq = 440, amp = 0.2, dur = 1, out = 0, res = 0.3, xover = 0.5, wobble = 0|

	var sub, mid, hi, sum, env, lfomid, lfohi, lfo;
	
	
	lfomid = SinOsc.kr( 1.0.rand, pi/2, 9000, 10000 );
		
	lfohi = SinOsc.kr( 0.5.rand, pi/2, 5000, 10000 );
	
	
	lfo = SinOsc.kr( wobble, pi/2, 9000, 9500 );
	
	
	sub = (SinOsc.ar( [freq*3/16 + 0.25.rand,freq/8 + 0.25.rand,freq*3/8 + 0.25.rand,freq/4 + 0.25.rand,freq*3/4 + 0.25.rand,freq/2 + 0.25.rand] )*0.5) + (PinkNoise.ar()*0.2);
	
	sub = LPF.ar( sub, 220 );
	
	sub = HPF.ar( sub, 30 );
	
	sub = sub/8;
	
	
	mid = RLPF.ar( Saw.ar( [freq/8 + 1.0.rand, freq/4 + 2.0.rand] )*0.15, freq*12*xover, 0.4);
	
	mid = mid + BPF.ar( WhiteNoise.ar(), [freq+10.0.rand,freq*3+10.0.rand,freq*5+10.0.rand], 0.05 )*0.5;
	
	mid = BRF.ar( mid, lfomid, res );
	
	
	hi = RHPF.ar( Pulse.ar( [freq/4 + 0.5.rand, freq/2 + 0.25.rand], 0.5 )*0.2, freq*12*xover, 0.4);
	
	hi = BRF.ar( hi, lfohi, res );
	
	
	mid = HPF.ar( mid, 220 );
	
	
	sum = LPF.ar( sub + mid + hi, lfo );
	
	sum = sum * amp;
	
	Out.ar( 0, sum ! 2 );
		
}).add;

SynthDef( \hats, {

	|amp=0.1,out=0,len=0.1|
	
	var env1, output;
	
	env1 = EnvGen.ar( Env.new([0,1,0],[0.0005,len]), doneAction:2 );
	
	output = WhiteNoise.ar()*env1*env1*env1*env1;
	
	output = LPF.ar( output, 17000 + Rand( -1000, 1000 ) );
	
	output = FreeVerb.ar( output, 1/3, 0.8 + Rand(-0.1,0.1), 0.05 );
	
	output = HPF.ar( output, 5000 + Rand(-500, 500) );
	
	Out.ar(out, output*amp);
	
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

)
