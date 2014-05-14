


(

~measureIndex = 0;
~measureLength = 24;

// --- //

~bassdrumChoices = [ED.create(4,~measureLength)];
~bassdrumSeq = ~bassdrumChoices.choose;

~bassdrum = {

	|index|

	if([true,false,false].choose,{

		~bassdrumSeq = ~bassdrumChoices.choose;

	});

	~bassdrumSeq.wrapAt(index);

};

// --- //

~snaredrumChoices = (ED.expand(ED.convert([0,1,0,1])*(~measureLength/4)))!16;
~snaredrumChoices = ~snaredrumChoices ++ [ED.expand(ED.convert([0,0,1,0,0,0,1,1])*(~measureLength/8))];

~snaredrumSeq = ~snaredrumChoices.choose;

~snaredrum = {

	|index|

	if([true,false,false,false,false,false].choose,{

		~snaredrumSeq = ~snaredrumChoices.choose;

	});

	~snaredrumSeq.wrapAt(index);

};

// --- //

~highhatChoices = [ED.expand(ED.convert([0,1])*3),ED.expand(ED.convert([1,0,1]))];
~highhatSeq = ~highhatChoices.choose;

~highhat = {

	|index|

	if([true,false,false,false,false,false].choose,{

		~highhatSeq = ~highhatChoices.choose;

	});

	~highhatSeq.wrapAt(index);

};

// --- //

~basslineChoices = [ED.expand(ED.convert([0,1])*3)];
~basslineSeq = ~basslineChoices.choose;

~bassline = {

	|index|

	if(([true,false].choose).and(index%3==0),{

		~basslineSeq = ~basslineChoices.choose;

	});

	~basslineSeq.wrapAt(index);

};

// --- //

~backgroundpadsChoices = [[1]++(0!(~measureLength-1))];
~backgroundpadsSeq = ~backgroundpadsChoices.choose;

~backgroundpads = {

	|index|

	if([true,false,false,false,false,false].choose,{

		~backgroundpadsSeq = ~backgroundpadsChoices.choose;

	});

	~backgroundpadsSeq.wrapAt(index);

};

// --- //

~chordIndex = 0;

~chordChooser = {

	var minChordOffsetPairs, majChordOffsetPairs, minChord, majChord;

	~chordIndex = ~chordIndex + ((2.rand)*(3.rand+1));

	minChordOffsetPairs = [[[0,3,7-12],[0,3-12,7-12]].choose,[0,2,5,7].foldAt(~chordIndex)];
	majChordOffsetPairs = [[[0,4,7-12],[0,4-12,7-12]].choose,[3,8,10,11].foldAt(~chordIndex)];

	minChord = minChordOffsetPairs[0] + minChordOffsetPairs[1];
	majChord = majChordOffsetPairs[0] + majChordOffsetPairs[1];

	[minChord, majChord].choose;

};

// --- //

t = TempoClock(130*(1.5)/15).sched(0,{

	var bassdrumAmp, snaredrumAmp, highhatAmp;

	if(~measureIndex==0,{

		~chord = ~chordChooser.();

	});

	bassdrumAmp	= cos(~measureIndex*2*pi/~measureLength*2)*0.5;
	snaredrumAmp	= cos(~measureIndex*2*pi/~measureLength*4)*0.5;
	highhatAmp		= cos(~measureIndex*2*pi/~measureLength*16)*0.5;

	if(~bassdrum.(~measureIndex)==1,{Synth(\bassdrum,[\amp,bassdrumAmp]);});
	if(~snaredrum.(~measureIndex)==1,{Synth(\snaredrum,[\amp,snaredrumAmp]);});
	if(~highhat.(~measureIndex)==1,{Synth(\highhat,[\amp,highhatAmp]);});

	if(~backgroundpads.(~measureIndex)==1,{

		~chord.do({

			|note|

			Synth(\backgroundpads,[\freq,(note+60).midicps,\amp,1/5]);

		});

	});

	if(~bassline.(~measureIndex)==1,{

		Synth(\bassline,[\freq,((((~chord.sort[0]!3)++[~chord.choose]).choose).wrap(-9,2)+48).midicps,\amp,1]);

	});

	~measureIndex = ~measureIndex + 1;

	if(~measureIndex >= ~measureLength, {

		~measureIndex = 0;

	});

	1;

});

)

(

SynthDef(\bassdrum,{

	|amp = 0.5|

	var output = SinOsc.ar(EnvGen.ar(Env([400,160,0],[5,70]/1000),doneAction:2));

	output = output + (BPF.ar(WhiteNoise.ar(),[400,4000],0.6)*EnvGen.ar(Env([0,4,1,0]/2,[5,20,100])));

	output = output*amp*2/3;

	output = HPF.ar(output,20);

	Out.ar(0,output/2!2);

}).store;

SynthDef(\snaredrum,{

	|amp = 0.5|

	var noise = WhiteNoise.ar()*EnvGen.ar(Env([0,20,5,2,2/3,0]/40,[5,30,70,30,750]/1000),doneAction:2);

	var output = BPF.ar(noise, [200,1000,2000,5000], 0.5, [10,20,15,5]/7)*amp;

	Out.ar(0,output!2);

}).store;

SynthDef(\highhat,{

	|amp = 0.5|

	var noise = WhiteNoise.ar()*EnvGen.ar(Env([0,20,5,2]/40,[5,40,70]/1000),doneAction:2);

	var output = BPF.ar(noise, [1000,2000,5000,7000,11000], 0.4, [3,5,15,10,15]/60)*amp;

	Out.ar(0,output!2);

}).store;

SynthDef(\backgroundpads,{

	|freq=440,amp=0.5|

	var env, output;

	env = EnvGen.ar(Env([0,2,1,0].normalize,[250,500,3000]/1000),doneAction:2)*0.5;

	output = LPF.ar(Pulse.ar(freq)*env,freq*3);

	output = output + (HPF.ar(Saw.ar(freq),3500)*EnvGen.ar(Env([0,1,0],[100,2000]/1000))/2);

	output = HPF.ar(output, 300)*amp;

	Out.ar(0,output!2);

}).store;

SynthDef(\bassline,{

	|freq=440,amp=0.5|

	var output, ifreq;

	ifreq = freq+Rand(0,freq/100);

	output = Saw.ar(ifreq/2)*EnvGen.ar(Env([0,2,1,0].normalize,[10,100,250]/1000),doneAction:2)*amp*0.5;

	output = output + (HPF.ar(Pulse.ar(ifreq, EnvGen.ar(Env([1/100,2/3],[1]))), 3000)*amp*EnvGen.ar(Env([0,1,0],[100,200]/2500)));

	output = LPF.ar(output, 1000);

	Out.ar(0,output!2);

}).store;

)

//t.stop;

//s.boot