
(


/* TODO:
 * 
 * * Make padKONTROL class (singleton)
 * * Handle inputs and build states/getters for pressed, held, released, etc…
 * * Migrate output functions to class
 * 
 * 
 * 
 */

~pks = nil; // Keepin' it fresh!

~padKONTROL = {
	
	// pks = PadKONTROL Singleton
	
	|message|
	
	if(~pks==nil,{
	
		MIDIClient.init;
	
		~pks = ();
		
		~pks.sysexSend = MIDIOut.new(MIDIClient.destinations.indexOf(MIDIOut.findPort("padKONTROL", "CTRL")));
		~pks.sysexRecv = MIDIIn.connect(0,MIDIClient.sources.indexOf(MIDIIn.findPort("padKONTROL", "PORT A")));
		
		~pks.init = {
				
			~pks.sysexSend.sysex(Int8Array[0xF0, 0x42, 0x40, 0x6E, 0x08, 0x00, 0x00, 0x01, 0xF7,0xF0, 0x42, 0x40, 0x6E, 0x08, 0x3F, 0x2A, 0x00, 0x00, 0x05, 0x05, 0x05, 0x7F, 0x7E, 0x7F, 0x7F, 0x03, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0d, 0x0E, 0x0F, 0x10, 0xF7,0xF0,0x42,0x40,0x6E,0x08,0x3F,0x0A,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x29,0x29,0x29,0xF7]);
		
		};
		
		~pks.init.();
	
		~pks.button2index = (

			0: 0,
			1: 1,
			2: 2,
			3: 3,
			4: 4,
			5: 5,
			6: 6,
			7: 7,
			8: 8,
			9: 9,
			10: 10,
			11: 11,
			12: 12,
			13: 13,
			14: 14,
			15: 15,
			scene: 16,
			message: 17,
			setting: 18,
			note: 19,
			midich: 20,
			swtype: 21,
			relval: 22,
			velocity: 23,
			port: 24,
			fixedvelocity: 25,
			progchange: 26,
			x: 27,
			y: 28,
			knob1: 29,
			knob2: 30,
			pedal: 31,
			roll: 32,
			flam: 33,
			hold: 34
		
		);
		
		~pks.states2sysex = {

			|states, numberarray|
			
			var hexarray, numvalues;
			
			numvalues = (states.size/7).asInteger;
			
			hexarray = 0!numvalues;
			
			numvalues.do({ |valueiter|
				
				7.do({ |bititer|
				
					hexarray[valueiter] = states[valueiter*7+bititer]*(1<<bititer) + hexarray[valueiter];
				
				});
				
			});
			
			hexarray++[0x00]++(numberarray.reverse);
			
		};
		
		~pks.sendSysex = {
	
			|hexvals|
			
			~pks.sysexSend.sysex(Int8Array.newFrom([0xF0,0x42,0x40,0x6E,0x08,0x3F,0x0A,0x01]++hexvals++[0xF7]));
			
		};
		
		~pks.lightStates	= (1!16)++(0!19);
		~pks.numberStates	= [0x32,0x32,0x32];
		
		~pks.setLights = {
		
			~pks.sendSysex.(~pks.states2sysex.(~pks.lightStates, ~pks.numberStates));
			
		};
		
		~pks.setLights.();
		
		// --- end class --- //
		
	});
	
	// --- //
	
	~pks[message];
	
};

)

~padKONTROL.(\init);

~padKONTROL.(\sendSysex).(~padKONTROL.(\states2sysex).(1!35, [0x32,0x32,0x32]));

(

MIDIClient.init;

~pkMIDIout	= MIDIOut.new(MIDIClient.destinations.indexOf(MIDIOut.findPort("padKONTROL", "CTRL")));

~pkMIDIin	= MIDIIn.connect(0,MIDIClient.sources.indexOf(MIDIIn.findPort("padKONTROL", "PORT A")));

~pkInit = {
	
|midiport|
	
midiport.sysex(Int8Array[0xF0, 0x42, 0x40, 0x6E, 0x08, 0x00, 0x00, 0x01, 0xF7,0xF0, 0x42, 0x40, 0x6E, 0x08, 0x3F, 0x2A, 0x00, 0x00, 0x05, 0x05, 0x05, 0x7F, 0x7E, 0x7F, 0x7F, 0x03, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0d, 0x0E, 0x0F, 0x10, 0xF7,0xF0,0x42,0x40,0x6E,0x08,0x3F,0x0A,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x29,0x29,0x29,0xF7]);

};

~pkTest = {

|midiport|	
	
midiport.sysex(Int8Array[0xF0,0x42,0x40,0x6E,0x08,0x22,0x04,0x00,0x59,0x45,0x53,0xF7]);
	
};

~pkSetLight = {

|midiport, light, state|
	
midiport.sysex(Int8Array[0xF0,0x42,0x40,0x6E,0x08,0x01,light,0x20*state,0xF7]);
	
};

~pkSetAllLights = {

	|midiport|
	
	midiport.sysex(Int8Array[0xF0,0x42,0x40,0x6E,0x08,0x3F,0x0A,0x01,0x7F,0x7F,0x7F,0x7F,0x7F,0x00,0x38,0x38,0x38,0xF7]);
	
	
	
};

~pkLightStates2HexArray = {

	|states, lights|
	
	var hexarray, numvalues;
	
	numvalues = (states.size/7).asInteger;
	
	hexarray = 0!numvalues;
	
	numvalues.do({ |valueiter|
		
		7.do({ |bititer|
		
			hexarray[valueiter] = states[valueiter*7+bititer]*(1<<bititer) + hexarray[valueiter];
		
		});
		
	});
	
	hexarray++[0x00]++(lights.reverse);
	
};

~pkSetLightStates = {
	
	|hexvals|
	
	~pkMIDIout.sysex(Int8Array.newFrom([0xF0,0x42,0x40,0x6E,0x08,0x3F,0x0A,0x01]++hexvals++[0xF7]));
	
};

~randomizeLightStates = {
	
	~pkLightStates.size.do({
	
		|inc|
		
		~pkLightStates[inc] = 2.rand;
		
	});
	
	~pkSetLightStates.(~pkLightStates2HexArray.(~pkLightStates, [38,38,38]));
	
};

~buttonName2Index = (

	0: 0,
	1: 1,
	2: 2,
	3: 3,
	4: 4,
	5: 5,
	6: 6,
	7: 7,
	8: 8,
	9: 9,
	10: 10,
	11: 11,
	12: 12,
	13: 13,
	14: 14,
	15: 15,
	scene: 16,
	message: 17,
	setting: 18,
	note: 19,
	midich: 20,
	swtype: 21,
	relval: 22,
	velocity: 23,
	port: 24,
	fixedvelocity: 25,
	progchange: 26,
	x: 27,
	y: 28,
	knob1: 29,
	knob2: 30,
	pedal: 31,
	roll: 32,
	flam: 33,
	hold: 34

);

// --- //

~pkInit.(~pkMIDIout);

~pkLightStates = ((0!35)[19]=1);

~pkSetLightStates.(~pkLightStates2HexArray.(((0!35)[~buttonName2Index[\setting]]=1), [0x31,0x32,0x33]));

~randomizeLightStates.();

~pkLightStates[0]=1;

~pkMIDIout.sysex(Int8Array[0xF0,0x42,0x40,0x6E,0x08,0x3F,0x0A,0x01,0x7F,0x7F,0x7F,0x7F,0x7F,0x00,0x38,0x38,0x38,0xF7]);

~pkMIDIin.sysex = {
	
	|src, sysex|
	
	sysex[5].switch(
	
		0x45,{	[\pad,(sysex[6]%64),(sysex[6]/64).round,sysex[7]/127].postln;
					if((sysex[6]/64).round==1,{Synth(\sweeper,[\freq,125*(15-(sysex[6]%64)),\amp,sysex[7]/127])});
				},
			
		0x49,{	[\knob,sysex[6],sysex[7]].postln;
				~pkSetNum.value(~pkMIDIout,sysex[7]);
				},
		
		0x43,{	[\rotary,sysex[7]].postln;
				/*
				if(sysex[7]==1,{~tempo=~tempo+1},{~tempo=~tempo-1});
				~pkSetNum.value(~pkMIDIout,~tempo);
				if(~tempo<0,{~tempo=0},{});
				t.tempo = ~tempo/30;
				*/
				},
		
		0x48,{
				[\button,sysex[6],sysex[7]].postln;
			},
		
		0x4b,{
				[\x,sysex[6],\y,sysex[7]].postln;
			}
	
	);

};

//-------//
//-------//
//-------//

/*
{
	var z, p, n, sweeper;
	
	p = 500;
	
	z = `[Array.fill(p, { 80 + 10000.0.linrand} ), Array.fill(p, { 1.0.rand2 }), Array.fill(p, { 0.2 + 0.5.rand } ) ];
	
	sweeper = BPF.ar(PinkNoise.ar(), EnvGen.ar(Env([2500,10,10],[0.0125,1]), doneAction: 2), 0.05);
	
	(Klank.ar(z,sweeper)*EnvGen.ar(Env([1,1,0],[0.0125,1]), doneAction: 2))!2;
	
}.play;
*/

SynthDef(\sweeper,{
	
	|freq=440, amp=1.0|
	
	var z, p, n, sweeper;
	
	var expAmp = amp*amp;
	
	p = 50;
	
	z = `[Array.fill(p, { 80 + 10000.0.linrand} ), Array.fill(p, { 1.0.rand2 }), Array.fill(p, { 0.2 + 0.5.rand } ) ];
	
	sweeper = LPF.ar(BPF.ar(PinkNoise.ar(), EnvGen.ar(Env([freq+(expAmp*1000),10,10],[amp/200,1]), doneAction: 2), 0.05), expAmp*10000);
	
	Out.ar(0, (Klank.ar(z,sweeper)*EnvGen.ar(Env([amp,amp/7,0],[0.0125,1]), doneAction: 2))!2);
	
}).store;

)