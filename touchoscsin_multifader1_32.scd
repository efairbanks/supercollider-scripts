
(

a = "10.0.2.15";

p = 9000;

n = NetAddr(a,p);

32.do({

	|inc|

	n.sendMsg("/1/multifader1/" ++ (inc+1), sin(inc/32*pi*2)+1/2);

});

/*

r = OSCresponderNode(nil, "/1/multifader1/1", {
	
	|t, r, msg|
	
	("/1/multifader1/1: " + t).postln; msg[1].postln;
	
}).add;

*/

(

~enc = 0;

OSCresponderNode(nil,"/1/encoder1",{

	|t, r, msg|
	
	if(msg[1] == 1,{
		
		~enc = ~enc + 0.1;
		
		},{
		
		~enc = ~enc - 0.1;
			
	});
	
	~enc.postln;
	
}).add;

)

// Setup for simple sequencer -- v --

(

~tc.stop;

// --- //

a = "10.0.2.15";

p = 9000;

n = NetAddr(a,p);

// --- //

b = Buffer.read(s, Platform.resourceDir ++ "/sounds/break.wav");

~syn = SynthDef(\break, {
	
	|out = 0, bufnum = 0, spos = 0, trig = 0|

	Out.ar(out,

		PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), loop: 0, startPos: spos*BufFrames.kr(bufnum)) * EnvGen.ar(Env([1,0],[1/4]), doneAction:2);

	)

}).store;

// --- //

~seqpos = 0;

~tc = TempoClock(160/60).sched(0,{

	8.do({
	
		|xinc|
		
		n.sendMsg("/1/multipush1/1/" ++ (xinc+1), if(xinc == ~seqpos, {1}, {0}));

	});
	
	Synth(\break, [\out, 0, \bufnum, b, \spos, ~seqpos/8]);
	
	~seqpos = (~seqpos + 1) % 8;
	
	1/2;
	
});

OSCresponderNode(nil,"/1/rotary3",{
	
	|time, responder, msg|
	
	~tc.tempo = (msg[1]*300/60);

}).add;

8.do({

	|iter|
	
	OSCresponderNode(nil,"/1/multipush1/1/" ++ (iter+1), {
	
		|time, responder, msg|
		
		~seqpos = iter;
	
	}).add;

});

)
