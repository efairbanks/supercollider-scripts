
(

MIDIClient.init;

~pkMIDIout	= MIDIOut.new(MIDIClient.destinations.indexOf(MIDIOut.findPort("padKONTROL", "CTRL")));

~pkMIDIin	= MIDIIn.connect(0,MIDIClient.sources.indexOf(MIDIIn.findPort("padKONTROL", "PORT A")));

// --- //

~pkInit = {
	
|midiport|
	
midiport.sysex(Int8Array[0xF0, 0x42, 0x40, 0x6E, 0x08, 0x00, 0x00, 0x01, 0xF7,0xF0, 0x42, 0x40, 0x6E, 0x08, 0x3F, 0x2A, 0x00, 0x00, 0x05, 0x05, 0x05, 0x7F, 0x7E, 0x7F, 0x7F, 0x03, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0d, 0x0E, 0x0F, 0x10, 0xF7,0xF0,0x42,0x40,0x6E,0x08,0x3F,0x0A,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x29,0x29,0x29,0xF7]);

};

// --- //

~pkTest = {

|midiport|	
	
midiport.sysex(Int8Array[0xF0,0x42,0x40,0x6E,0x08,0x22,0x04,0x00,0x59,0x45,0x53,0xF7]);
	
};

// --- //

~pkSetLight = {

|midiport, light, state|
	
midiport.sysex(Int8Array[0xF0,0x42,0x40,0x6E,0x08,0x01,light,0x20*state,0xF7]);
	
};

// --- //

~pkSetNum = {

|midiport, num|
	
midiport.sysex(Int8Array[	0xF0,0x42,0x40,0x6E,0x08,0x22,0x04,0x00,
								0x30+(num/100%10),
								0x30+(num/10%10),
								0x30+(num%10),
								0xF7]);
	
};

// --- //

{
	
~step = 0;

~loop = Buffer.read(s,"break.wav");

SynthDef(	\looper,
			{
				
				|bufnum, tempo=120, t_restart=0, offset=0, pitch=1, granulize=0|
				
				// --- //
				
				var gloop, loop, phase, bufdur, loopdur, output;
				
				bufdur = BufDur.kr(bufnum);
				
				loopdur = (30/tempo)*8;
				
				// --- //
				
				phase = Phasor.ar(t_restart,(loopdur*SampleRate.ir).reciprocal,0,1,offset);
				
				// --- //
				
				gloop = Warp1.ar(1,bufnum,phase,pitch,interp:4,overlaps:2);
				
				// --- //
				
				loop = BufRd.ar(1,bufnum,phase*BufFrames.kr(bufnum),loop:1,interpolation:4);
				
				// --- //
				
				output = (1-granulize)*loop;
				
				output = output + (gloop*granulize);
				
				Out.ar(0, output ! 2);
				
			}).store();
			
s.sync;
			
~tempo = 140;

t = TempoClock.new(~tempo/30);
			
~looper = Synth.new(\looper,[\bufnum,~loop.bufnum,\tempo,~tempo]);

t.schedAbs(	0,
				{
					
					~looper.set(\t_restart,1,\offset,~step/8,\tempo,~tempo, \granulize, 0);
					
					~pkSetNum.value(~pkMIDIout,~step);
					
					16.do({
						
						|inc|
						
						~pkSetLight.value(~pkMIDIout,inc,0);
						
					});
					
					~pkSetLight.value(~pkMIDIout,~step,1);
					
					~step = (~step + 1) % 8;
					
					1;
					
				});

}.fork;


// --- //

~pkMIDIin.sysex = {
	
	|src, sysex|
	
	sysex[5].switch(
	
		0x45,{	[\pad,(sysex[6]%64),(sysex[6]/64).round].postln;
				if(	(sysex[6]/64).round == 1,
					{~step = (sysex[6]%64)},
					{});
				},
			
		0x49,{	[\knob,sysex[6],sysex[7]].postln;
				~pkSetNum.value(~pkMIDIout,sysex[7]);
				},
		
		0x43,{	[\rotary,sysex[7]].postln;
				if(sysex[7]==1,{~tempo=~tempo+1},{~tempo=~tempo-1});
				~pkSetNum.value(~pkMIDIout,~tempo);
				if(~tempo<0,{~tempo=0},{});
				t.tempo = ~tempo/30;
				},
		
		0x48,{
				[\button,sysex[6],sysex[7]].postln;
			},
		
		0x4b,{
				[\x,sysex[6],\y,sysex[7]].postln;
			}
	
	);

};

// --- //

)

