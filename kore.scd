
(

SynthDef(

	\kick,
	
	{
	
		|out=0,freq=300,len=0.5|
			
		var tone, env;
		
		env = EnvGen.ar(Env([1,0],[len]),doneAction:2);
		
		tone = SinOsc.ar(env**15*freq)*env;
			
		Out.ar(0, tone ! 2);
		
	}

).store();

x = Synth.new(\kick);

)

(

MIDIClient.init;

~koreMIDIin	= MIDIIn.connect(0,MIDIClient.sources.indexOf(MIDIIn.findPort("Kore controller 2", "MIDI input port 0")));

z = Array.new(127);

~koreMIDIin.control = {
	
	|src, chan, num, val|
	
	val.postln;
	
	z[num]=val;
	
	[num,z[num]].postln;
	
};

)

