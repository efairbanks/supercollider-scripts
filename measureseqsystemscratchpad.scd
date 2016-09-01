(

e = (	

	state: (
			
		measures:		[],		// stores measures
		bpm:			132,	// tempo
		instruments:	[],		// list of instruments
		stack:			[],		// stack for magic-ing keypresses into commands
		accumulator:	[],		// accumulator for entering numbers
		commandlist:	[],		// list of previously executed commands
		
		divs:			8,		// current working measure divisions
		measure:		0,		// current working measure
		duration:		1,		// current working note duration (actual note dur: dur*(1/divs)*measurelengthorwhatever)
		mbeats:		4,		// current working measure length (length of measure in beats)
		note:			0,		// current working MIDI note value.
		noteoffset:	48,		// current working MIDI note offset
		instrument:	nil,	// current working instrument
		stringarg:		nil		// variable to hold string args for changing instrument and/or synth key/value arguments
		
	),
	
	tempoclock:	nil,

	exit: {	// exit program
		
		|in|
	
		if(w==nil,{},{w.close;});
		
		e = nil;
		
	},
	
	save: {
		
		|in|
		
		var file = File.new("testsong","w");
		
		file.write(e.state.asCompileString);
		
		file.close;
		
		nil;
		
	},

	pm: {		// play measure
	
		e.state.measures[e.state.measure].events.do({
		
			|event|
			
			e.tempoclock.sched(	e.state.mbeats*event.numerator/event.denominator,
									{
								
										Synth(event.instrument,[\freq,event.note.midicps]);
									
									});
			
		});
		
	},

	d: {		// change number of measure divisions
	
		|in|
		
		e.state.divs = in[0];
		
	},
	
	nd: {		// change default note duration
	
		|in|
		
		e.state.duration = in[0];
		
	},
	
	mb: {		// change the length of a measure in beats
	
		|in|
		
		e.state.mbeats = in[0];
		
	},
	
	i: {		// change default instrument
	
		|in|
		
		e.state.instrument = e.state.stringarg.asSymbol;
		
		e.state.stringarg = nil;
		
	},
	
	csa: {
		
		e.state.stringarg = nil;
		
	},
	
	m: {		// change current working measure
	
		|in|
		
		e.state.measure = in[0];
		
	},
	
	n: {		// change default working note value
	
		|in|
	
		e.state.note = in[0];
		
	},
	
	e: {		// enter a new event or list of events via measure division number
	
		|in|
		
		in.do({
			
			|event|
	
			var n = ();
			
			n.numerator = event;
			
			n.denominator = e.state.divs;
			
			n.dur = e.dur;
			
			n.note = e.state.note+e.state.noteoffset;
			
			n.instrument = e.state.instrument;
			
			while({e.state.measures[e.state.measure] == nil},{
			
				e.state.measures = e.state.measures.add((mlength: e.mlength, events: []));
				
			});
			
			e.state.measures[e.state.measure].events = e.state.measures[e.state.measure].events ++ [n];
		
		});
		
	},
		
	sm: {		// show current measure
	
		e.state.measures[e.state.measure].postln;
		
	},
	
	spush: {	// push

		var ret = 0;

		e.state.accumulator.size.do({
	
			|index|
		
			ret = ret + (e.state.accumulator[index]*(10**((e.state.accumulator.size-1)-index)));
		
		});
		
		e.state.stack = e.state.stack ++ ret;
	
		e.state.accumulator = [];
	
		ret;
	
	},

	spop: {	// pop
		
		var ret = e.state.stack[0];
		
		if(	e.state.stack.size>1,
			{e.state.stack = e.state.stack[0..(e.state.stack.size-2)];},
			{e.state.stack = [];});
		
		ret;
		
	},
	
	kick: {	// play kick
		
		Synth(\kick);
		
	},
	
	snare: {	// play snare
		
		Synth(\snare);
		
	},
	
	hats: {	// play hats
		
		Synth(\hats);
		
	},
	
	print: {	// print arguments
	
		|args|
		
		args.postln;
		
	},
	
	processStack: {	// process the command stack
		
		var cmdstring, lastelement, cmdargs;
		
		cmdstring		= nil;
		cmdargs		= [];
		lastelement	= nil;
		
		e.state.commandlist = [e.state.stack] ++ e.state.commandlist;
		
		while(	{e.state.stack != []},
		
				{
				
					if(	e.state.stack[0].isNumber,
						{
						
							if(	lastelement.isNumber,
								{
									
									// last element was a number, processing a number
									
									cmdargs = cmdargs.add(e.state.stack[0]);
									
								},
								{
									
									// last element was a character, processing a number
									
									cmdargs = cmdargs.add(e.state.stack[0]);
									
								});
						
						},
						{
						
							if(	lastelement.isNumber,
								{
									
									// last element was a number, processing a character
									
									if(	e[cmdstring.asSymbol].isFunction,
										{e[cmdstring.asSymbol].value(cmdargs);},
										{format("No known method %.",cmdstring).postln;});
										
									cmdstring = nil;
									
									cmdargs = [];
									
									cmdstring = cmdstring ++ e.state.stack[0];
									
								},
								{
									
									// last element was a character, processing a character
									
									cmdstring = cmdstring ++ e.state.stack[0];
									
								});
						
						});
						
					lastelement = e.state.stack[0];
					
					if(e.state.stack != [],{e.state.stack = e.state.stack[1..e.state.stack.size];});
				
				}
			
		);

		if(	e[cmdstring.asSymbol].isFunction,
			{e[cmdstring.asSymbol].value(cmdargs);},
			{format("No known method %.",cmdstring).postln;});
		
	},
	
	init: {	// initialize the environment
			
		var file = File("testsong","r");
		
		if(file.isOpen,{
		
			e.state = 	String.readNew(file).interpret;
			
			file.close;
			
		});
				
		// - //
		
		e.tempoclock = TempoClock(e.state.bpm/60);
		
		// - //
	
		w = Window.new("Derp", Rect(100,100,640,480), border:true);
		
		w.front;
		
		w.view.background_(Color.black);
		        
		w.drawHook = {
			
			/*
			Pen.strokeColor = Color.green;
		
			Pen.width = 5;
			
			Pen.moveTo(0@0);
			
			Pen.lineTo(100@100);
			
			Pen.stroke;
			*/
			
			var width = w.bounds.width;
			
			var height = w.bounds.height;
			
			format("cmd: %",e.state.stack).drawInRect(Rect(5,0,width,height/10), Font("Arial", 20), Color.green);
			
			format("accumulator: %",e.state.accumulator).drawInRect(Rect(5,height-25,width/2,25), Font("Arial", 20), Color.green);
			
			format("%",e.state.stringarg).drawInRect(Rect(5+width/2,height-25,width,25), Font("Arial", 20), Color.green);
			
		};
		
		
		w.view.keyDownAction = {
				
				|v,c,m,u,k|
				
				if((u > 96) && (u < 122),{e.state.stack = e.state.stack++[c]});
				
				if((u > 64) && (u < 91),{e.state.stringarg = e.state.stringarg++(c.toLower)});
						
				k.switch(	
		
					123,{},	// left
					124,{},	// right
					125,{},	// down
					126,{},	// up
					
					18,{e.state.accumulator = e.state.accumulator ++ 1;},  // 1 - 9 & 0
					19,{e.state.accumulator = e.state.accumulator ++ 2;},
					20,{e.state.accumulator = e.state.accumulator ++ 3;},
					21,{e.state.accumulator = e.state.accumulator ++ 4;},
					23,{e.state.accumulator = e.state.accumulator ++ 5;},
					22,{e.state.accumulator = e.state.accumulator ++ 6;},
					26,{e.state.accumulator = e.state.accumulator ++ 7;},
					28,{e.state.accumulator = e.state.accumulator ++ 8;},
					25,{e.state.accumulator = e.state.accumulator ++ 9;},
					29,{e.state.accumulator = e.state.accumulator ++ 0;},  // --- //
					
					49,{e.spush.value;}, // " " spush
					50,{e.spop.value;}, //  "`" spop
					
					51,{e.state.accumulator = [];},     // clear acc
					
					53,{if(w==nil,{},{w.close;});},  // quit
					
					36,{ // Process stack
					
						e.processStack.value;
						
					}
					
					,{k.postln;c.postln;u.postln;}
						
				);
						
		};
	
		AppClock.sched(0.0,{w.refresh;1/30;});
	
	}
	
);

s.boot;

s.waitForBoot({

	e.init.();
	
},5);

)

(

f = {
	
	|ratio = 2, elements = 10|

	var x = [1];
	
	elements.do({x = x ++ (x[x.size-1]*ratio)});
	
	x;
	
};

SynthDef(	\kick, {
			
	|dur=0.38,amp=0.5,freq=120|
	
	var freqs = f.value(1.1,20)*freq;
	
	var amps = f.value(0.225,20)*amp*0.5;
		
	var phases = NamedControl.kr(\phases,#[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]);
	
	var modfreqs = freqs * EnvGen.ar(Env([1,0],[dur]));
	
	var tone = SinOsc.ar(modfreqs,phases,amps)*EnvGen.ar(Env([0,1,0],[0.005,dur]),doneAction:2);
	
	tone = tone + LPF.ar((PinkNoise.ar()*EnvGen.ar(Env([1,0],[0.004])))*0.02,2250);
	
	Out.ar(0,tone!2);
				
}).store;

SynthDef(\snare, { arg amp = 0.5, dur = 0.1;
	
	var env, noise, output;
	
	//noise = PinkNoise.ar(amp);
	
	noise = Dust2.ar(4000, amp);
	
	env = Line.ar(1.0, 0, 0.15, doneAction:2);
	
	output = LPF.ar(RHPF.ar( noise * env, 1000, 0.4), 9000);
	
	Out.ar(0, output ! 2 );
	
}).store;


)