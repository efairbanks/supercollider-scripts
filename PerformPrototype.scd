(

// ------------------------------------ //
// --- INIT LAUNCHPAD INTERFACE --- //
// ------------------------------------ //

"/Users/ericfairbanks/Dropbox/SuperCollider/LaunchpadClass.scd".loadPath;

~lp.initialize();

AppClock.sched(0.0,{
	if(~displayHandler!=nil,{~displayHandler.();});
	~lp.draw();
	1/5;
});

// ------------------------ //
// --- INPUT HANDLER --- //
// ------------------------ //

~state = \select;
~selectedSequence = 0;
~sequences = ();

64.do({

	|inc|

	~sequences[inc] = 0!8;

});

~lp.noteOnHandler = {

	[~lp.x+(~lp.y*8)].postln;

	if(~state==\sequence,{
		if( (~lp.x<8).and(~lp.y<8),{
			~sequences[~selectedSequence].wrapPut(~lp.x,~lp.y);
			},{
				~state = \select;
		});
	});

	if(~state==\select,{
		if( (~lp.x<8).and(~lp.y<8),{
			~selectedSequence = ~lp.x+(~lp.y*8);
			~state = \sequence;
			},{

		});
	});

	true;

};

// ----------------- //
// --- DRAWING --- //
// ----------------- //

~displayHandler = {

	if(~state==\select,{
		64.do({|inc|
			~lp.setCell(inc%8,(inc/8).asInteger,3,3);
		});
	});

	if(~state==\sequence,{
		64.do({|inc|
			~lp.setCell(inc%8,(inc/8).asInteger,0,0);
		});
		~sequences[~selectedSequence].size.do({|inc|
			~lp.setCell(inc,~sequences[~selectedSequence][inc],3,0);
		});
	});

};

)

(

// ---------------------------- //
// --- MUSIC SCAFFOLDING --- //
// ---------------------------- //

~tick = 0;

~lvls = [2];

~lvl2ticks = { |lvl|

    var product = 1;

    (lvl).do({ |inc|

        product = product * ~lvls.clipAt(inc);

    });

    product;

};

~ifIsBoundary = { |lvl,rhythm,func|

	var boundary = (~tick/~lvl2ticks.(lvl)).asInteger;

	if( ((~tick%~lvl2ticks.(lvl))==0).and(rhythm.wrapAt(boundary)>0), {

		func.(~tick,boundary);

	});

};

~scale = Scale.minor;

~degree = 0;

~progression = [1,4,6,5,7,3,4,5]-1;

~harmonics = [5,1,3,1,7,1]-1;

~subDegree = 0;

)

~sequences[0]

(

// --------------------- //
// --- MUSIC FUNC --- //
// --------------------- //

~metro = {

	~ifIsBoundary.(5, [1], { |tick, boundary|

		~degree = ~sequences[0].wrapAt(boundary);

	});

	~ifIsBoundary.(3, [1], { |tick, boundary|

		~subDegree = ~sequences[1].wrapAt(boundary);

	});

	~ifIsBoundary.(3, [1,1,0,1,1,1,0,1], { |tick, boundary|
			Synth(\kick);
	});

	~ifIsBoundary.(2, [0,0,0,0,1,0,0,0], { |tick, boundary|
		Synth(\snare);
	});

	~ifIsBoundary.(2, [1,0,1], { |tick, boundary|
			Synth(\bass,[\amp,0.8,\freq,~scale.degreeToFreq(~degree,36.midicps,0)]);
	});

	~ifIsBoundary.(3, [1,0,0,0], { |tick, boundary|
			3.do({ |inc|
				Synth(\leads,[\freq,~scale.degreeToFreq((~degree+(inc*2))%7,36.midicps,0),
				\attack,0.001,
				\amp,0.016,
				\decay,2]);
			});
 });

	~ifIsBoundary.(2, [1], { |tick, boundary|
		Synth(\hats,[\amp,cos(boundary*2*pi/3)+1/2*0.03]);
	});

	/*
	~ifIsBoundary.(3, [1], { |tick, boundary|
			Synth(\leads,[\freq,~scale.degreeToFreq((~subDegree+~degree)%7,60.midicps,0),
			\attack,0.005,
			\amp,0.02,
			\decay,1/3]);
	});*/

	~tick = ~tick + 1;

	1/16;

};

)

(

// -------------- //
// --- PLAY --- //
// -------------- //

t=TempoClock(140/60).schedAbs(0,{

	~metro.();

});

)