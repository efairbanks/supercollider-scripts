
(

a=1.0;

c=1.0;

MIDIClient.init;

~xboard = MIDIIn.connect(0,MIDIClient.sources.indexOf(MIDIIn.findPort("E-MU Xboard49", "E-MU Xboard49")));

~notes = ();

~xboard.noteOn = {
	
				|src, chan, num, vel|
				
				//~notes = Array.new().addAll(~notes).add(num);
				
				//~notes = ~notes.sort({|a,b|a<b;});
				
				~notes[num] = Synth(\lead1,[\freq,num.midicps,
												\amp,a,
												\cutoff,c]);
				
				//~notes.postln;
				
				//num.postln;
				
				};
				
~xboard.noteOff = {
	
				|src, chan, num, vel|
				
				//~notes = Array.new().addAll(~notes).removeAll([num]);
				
				//~notes.postln;
				
				//~notes[num].free
				
				};
/*
t = TempoClock(120/60).schedAbs(0,	{
	
											|in|
	
											if(	~notes.size>0,
												{
													Synth(\lead1).set(\freq, 2**(~notes[~inc%~notes.size]/12)*55,\amp,12.reciprocal);
												},
												{});
												
											~inc = ~inc + 1;
												
											0.5;
	
										});
*/				
-)


(

a = NetAddr("129.63.91.157", 8080);

o = OSCresponderNode(nil, "/sliders/1", {
	
	|t, r, msg|
	
	("time:" + t).postln; msg[1].postln;
	
}).add;


p = OSCresponderNode(nil, "/knob1", {
	
	|t, r, msg|
	
	a = msg[1];
	
}).add;

q = OSCresponderNode(nil, "/knob2", {
	
	|t, r, msg|
	
	c = msg[1];
	
}).add;

)

(

SynthDef(	\lead1,
			{
			
			|freq=440,amp=0.1,cutoff=1.0|
				
			var tone, env, out, lfo;
			
			env = EnvGen.ar(Env([1/8,1,1/8],[0.01,2]), doneAction:2);
			
			tone = Pulse.ar(freq*2,0.1)*amp;
			
			out = tone;
			
			out = RLPF.ar(out,freq*8*cutoff*env,0.1);
			
			out = HPF.ar(out, 40);
			
			out = out*(env-(1/8))/4;
			
			Out.ar(0,out!2);
				
			}).store;

)



