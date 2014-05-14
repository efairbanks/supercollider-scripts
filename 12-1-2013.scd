
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

~harmonics = [5,1,3,1]-1;

~subDegree = 0;

)

(

// --------------------- //
// --- MUSIC FUNC --- //
// --------------------- //

~metro = {

	~ifIsBoundary.(5, [1], { |tick, boundary|

		~degree = ~progression.wrapAt(boundary);

	});

	~ifIsBoundary.(3, [1], { |tick, boundary|

		~subDegree = ~harmonics.wrapAt(boundary);

	});

	~ifIsBoundary.(2, [1,0,0,0], { |tick, boundary|
			//Synth(\kick);
	});

	~ifIsBoundary.(3, [0,0,1,0], { |tick, boundary|
		//Synth(\snare);
	});

	~ifIsBoundary.(2, [1,0,1], { |tick, boundary|
			//Synth(\bass,[\amp,0.8,\freq,~scale.degreeToFreq(~degree,36.midicps,0)]);
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
		//Synth(\hats,[\amp,cos(boundary*2*pi/3)+1/2*0.03]);
	});

	~ifIsBoundary.(3, [1], { |tick, boundary|
			Synth(\leads,[\freq,~scale.degreeToFreq((~subDegree+~degree)%7,48.midicps,0),
			\attack,0.005,
			\amp,0.02,
			\decay,1/3]);
	});

	~tick = ~tick + 1;

	1/16;

};

)

// -------------- //
// --- PLAY --- //
// -------------- //

(

//fourth

t=TempoClock(140/60).schedAbs(0,{

	~metro.();

});

)