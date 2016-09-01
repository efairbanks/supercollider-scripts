(

SynthDef(\test,{

	|freq=150,c1fs=1,c2fs=1,c1as=1,c2as=1,c1fe=1,c2fe=1,c1ae=1,c2ae=1,dur=0.3,ds1=22000,ds2=22000|

	var out;
	
	var c1f = EnvGen.ar(Env([c1fs,c1fe],[dur]));
	var c2f = EnvGen.ar(Env([c2fs,c2fe],[dur]));
	var c1a = EnvGen.ar(Env([c1as,c1ae],[dur]));
	var c2a = EnvGen.ar(Env([c2as,c2ae],[dur]));
	
	var c1 = Latch.ar(SinOsc.ar(freq*c1f,0,freq*c1a,freq), Impulse.ar(ds1));
	var c2 = Latch.ar(SinOsc.ar(c1*c2f,0,freq*c2a,freq), Impulse.ar(ds2));
	
	out = SinOsc.ar(c2);
	
	out = Limiter.ar(out,1/3,0.01);

	Out.ar(0,out!2);
	
}).store;

)

x = nil;

(

n = 0;

o = 1;

w = Window.new("Derp");

w.view.keyDownAction = {
		
		|v,c,m,u,k|
	
		switch(	
		
					k,
					123,\left,
					124,\right,
					125,\down,
					126,\up,
					27,\minus,
					24,\plus,
					k
						
				).postln;
				
				if(k==6,{z = [	\c1fs,[1/2,5/3,9/4].choose,
									\c2fs,[21/8,3/7,30/7],
									\c1as,20.rand/9,
									\c2as,3.rand/4,
									\c1fe,30.rand/8,
									\c2fe,50.rand/7,
									\c1ae,16.rand/8,
									\c2ae,40.rand/10,
									\ds1,16000/(10.rand+1),
									\ds2,16000/(10.rand+1),
									\dur,[1/5,1/3,1/10].choose];});
				
				if(k==49,{
					
					if(x!=nil,{x.free;x=nil;});
					
					x = Synth(\test,[\freq,(n+48+(o*12)).midicps].addAll(z));
					
					});
					
					switch(	k,
								18,{n=0;},
								19,{n=2;},
								20,{n=3;},
								21,{n=5;},
								23,{n=7;},
								22,{n=8;},
								26,{n=10;},
								28,{n=12;},
								25,{n=14;});
	
	};

w.front;

)

(

Synth(\test,[	\freq,[110,220,440,880].choose,
				\c1fs,[1/2,5/3,9/4].choose,
				\c2fs,[21/8,3/7,30/7],
				\c1as,20.rand/9,
				\c2as,3.rand/4,
				\c1fe,30.rand/8,
				\c2fe,50.rand/7,
				\c1ae,16.rand/8,
				\c2ae,40.rand/10,
				\ds1,16000/(10.rand+1),
				\ds2,16000/(10.rand+1),
				\dur,[1/5,1/3,1/10].choose]);
				
)

(

Synth(\test,[	\freq,220,
				\c1fs,1/2,
				\c2fs,21/8,
				\c1as,1/8,
				\c2as,3/4,
				\c1fe,30/8,
				\c2fe,50/7,
				\c1ae,16/8,
				\c2ae,40/10,
				\ds1,700*17,
				\ds2,700*10,
				\dur,1/5]);
				
)
				