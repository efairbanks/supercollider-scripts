




(

	x = [0,2,4];

	y = x;

	i = 0;

	j = 0;

	t = TempoClock(120/60).schedAbs(0,
		{

			var note = Scale.ionian.wrapAt(y[j%x.size]);

			var bassnote = Scale.ionian.wrapAt(y[0]);

			if(i%8==0,{y=x+7.rand;},{});

			if(i%2==0,{Synth(\kick).set(\amp,0.25);},{});

			if(i%4==2,{Synth(\snare).set(\amp,0.25);},{});

			if(i%2==1,{Synth(\hats).set(\amp,0.1,\len,2/3);},{});

			Synth(\leads).set(\freq,2**(note/12)*440,\amp,0.05);

			Synth(\leads).set(\freq,2**(bassnote/12)*110,\amp,0.1);

			i = 1 + i;

			j = 3.rand + j;

			0.5;

		});

)