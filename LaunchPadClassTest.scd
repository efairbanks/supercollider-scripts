(

"/Users/ericfairbanks/Dropbox/SuperCollider/LaunchpadClass.scd".loadPath;

~seq = {

	var newSeq = ();

	newSeq.seq = 0!8;

	newSeq.display = {

		8.do({

			|i|

			8.do({|j| ~lp.setCell(i,j,0,0)});

			~lp.setCell(i,newSeq.seq[i],3,3);

		});

	};

	newSeq.inputHandler = {

		if((~lp.x!=nil).and(~lp.y!=nil),{
			newSeq.seq[~lp.x]=~lp.y;
		});

	};

};

~lp.initialize();

~newseq = ~seq.();

~lp.noteOnHandler = ~newseq[\inputHandler];

~displayHandler = ~newseq[\display];

AppClock.sched(0.0,{
	if(~displayHandler!=nil,{~displayHandler.();});
	~lp.draw();
	1/5;
});

~beat=0;

f = {

	var freq = Scale.minor.degreeToFreq(~newseq.seq.wrapAt(~beat),24.midicps,1);

	Synth(\leads,[\amp,0.01,\freq,freq]);

	~beat = ~beat+1;

};

t=TempoClock(140/60).schedAbs(0,{

	f.();

	1;

});

)
