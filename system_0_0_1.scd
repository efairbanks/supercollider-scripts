(

/*

To Do:

	- Display whole song
	- Display current measure
	- Display current working note value
	- Display current working divisions
	- Display current working tempo
	- Display beats/measure in some meaningful way
	- Add facilities for asking for instrument levels
	- Make stringargs "negative" strings
	- Allow negative numbers
	- Figure out how to deal with note durations (mlen*secsperbeats/divs*multiplier)

*/

e = (

	oldstates: [],

	state: (
			
		measures:		[],		// stores measures
		bpm:			132,	// tempo
		instruments:	[],		// list of instruments
		stack:			[],		// stack for magic-ing keypresses into commands
		accumulator:	[],		// accumulator for entering numbers
		commandlist:	[],		// list of previously executed commands
		
		instlevels:	(),
		
		divs:			8,		// current working measure divisions
		div:			0,		// current working measure division
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
		
	 |measures|
	
	 if(measures != [],
	 {
		
	  if(measures.size > 1,
	  {
		
	   e.tempoclock.sched(e.state.measures[measures[0]].mbeats,
	   {
		
		 e[\pm].(measures.copyRange(1,measures.size-1));
		 
		 nil;
		
		});
		  
	  });
		
	  e.state.measures[measures[0]].events.do({
	
	   |event|
	
	   e.tempoclock.sched(	e.state.measures[measures[0]].mbeats*event.numerator/event.denominator,
	   {
	
	    var amp, freq, args;
	
	    amp = 0.5;
	
	    if(	e.state.instlevels[event.instrument] != nil,
	    		{amp = amp*e.state.instlevels[event.instrument].dbamp});
	
	    args = [	\freq,	event.note.midicps,
	   	 			\amp,	0.5*amp];
	
	    Synth(event.instrument,args);
	
	   });
		  
	  });
		 
	 },
	 {
		  
	  e.state.measures[e.state.measure].events.do({
	
	   |event|
	
	   e.tempoclock.sched(	e.state.measures[e.state.measure].mbeats*event.numerator/event.denominator,
	   {
	
	    var amp, freq, args;
	
	    amp = 0.5;
	
	    if(	e.state.instlevels[event.instrument] != nil,
	    		{amp = amp*e.state.instlevels[event.instrument].dbamp});
	
	    args = [	\freq,	event.note.midicps,
	   				\amp,	0.5*amp];
	
	    Synth(event.instrument,args);
	
	   });
	
	  });
	  
	 });
		
	},
	
	idb: {
	
		|in|
	
		e.state.instlevels[e.state.instrument] = in[0].neg;
		
	},

	d: {		// change number of measure divisions
	
		|in|
		
		e.state.divs = in[0];
		
	},
	
	cd: {		// change current measure div
	
		|in|
		
		e.state.div = in[0];
		
	},
	
	nd: {		// change default note duration
	
		|in|
		
		e.state.duration = in[0]/1000;
		
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
	
	majtri: {
	
		|events|
	
		events.do({
			
			|event|
		
			[0,4,7].do({
				
				|note|
		
				var n = ();
				
				n.numerator = event;
				
				n.denominator = e.state.divs;
				
				n.dur = e.dur;
				
				n.note = note+e.state.note+e.state.noteoffset;
				
				n.instrument = e.state.instrument;
				
				while({e.state.measures[e.state.measure] == nil},{
				
					e.state.measures = e.state.measures.add((events: [], mbeats: e.state.mbeats));
					
				});
				
				e.state.measures[e.state.measure].events = e.state.measures[e.state.measure].events ++ [n];
			
			});
			
		});
		
	},
	
	mintri: {
	
		|events|
	
		events.do({
			
			|event|
		
			[0,3,7].do({
				
				|note|
		
				var n = ();
				
				n.numerator = event;
				
				n.denominator = e.state.divs;
				
				n.dur = e.dur;
				
				n.note = note+e.state.note+e.state.noteoffset;
				
				n.instrument = e.state.instrument;
				
				while({e.state.measures[e.state.measure] == nil},{
				
					e.state.measures = e.state.measures.add((events: [], mbeats: e.state.mbeats));
					
				});
				
				e.state.measures[e.state.measure].events = e.state.measures[e.state.measure].events ++ [n];
			
			});
			
		});
		
	},
	
	ti: {
	
		var amp, freq, args;
	
		amp = 0.5;
	
		if(	e.state.instlevels[e.state.instrument] != nil,
			{amp = amp*e.state.instlevels[e.state.instrument].dbamp});
	
		args = [	\freq,	(e.state.note+e.state.noteoffset).midicps,
					\amp,	0.5*amp	];
	
		Synth(e.state.instrument,args);
		
		nil;
		
	},
	
	csa: {
		
		e.state.stringarg = nil;
		
	},
	
	m: {		// change current working measure
	
		|in|
		
		e.state.measure = in[0];
		
	},
	
	cpm: {
	
		|in|
		
		if(in.size==1,{
		
			e.state.measures.clipPut(e.state.measure,e.state.measures.clipAt(in[0]).copy);
			
		});
		
		if(n.size==2,{
		
			e.state.measures.clipPut(in[1],e.state.measures.clipAt(in[0]).copy);
			
		});
		
	},
	
	nm: {
	
		e.state.measures.size.postln;
		
	},
	
	am: {
		
		e.state.measures = e.state.measures.insert(e.state.measure.asInteger,(events: [], mbeats: e.state.mbeats));
		
	},
	
	amf: {
		
		e.state.measures = e.state.measures.insert(e.state.measure.asInteger+1,(events: [], mbeats: e.state.mbeats));
		
	},
	
	rm: {
		
		|in|
		
		if(e.state.measures.size>1,
		{
		 
		 in.do({
			 
		  |measure|
		 
		  if(e.state.measure >= e.state.measures.size, {e.state.measure = e.measures.size-1;},{e.state.measure = e.state.measure - 1;});
		  
		  if(e.state.measure<0,{e.state.measure=0;});
		  
		  e.state.measures.removeAt(e.state.measure);
		
		 });
		
		});
		
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
			
				e.state.measures = e.state.measures.add((events: [], mbeats: e.state.mbeats));
				
			});
			
			e.state.measures[e.state.measure].events = e.state.measures[e.state.measure].events ++ [n];
		
		});
		
	},
	
	c: {		// enter a new note or list of notes
	
		|in|
		
		in.do({
			
			|note|
	
			var n = ();
			
			n.numerator = e.state.div;
			
			n.denominator = e.state.divs;
			
			n.dur = e.dur;
			
			n.note = note+e.state.noteoffset;
			
			n.instrument = e.state.instrument;
			
			while({e.state.measures[e.state.measure] == nil},{
			
				e.state.measures = e.state.measures.add((events: [], mbeats: e.state.mbeats));
				
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
	
	undo: {
	
		if(e.oldstates!=[],{
		
			e.state = e.oldstates[e.oldstates.size-1];
			
			e.oldstates = e.oldstates.copyRange(0,e.oldstates.size-2);
			
		});
		
	},
	
	processStack: {	// process the command stack
		
		var cmdstring, lastelement, cmdargs;
		
		// --- //
		
		if((e.state.measures == []).or(e.state.measures == nil),{
			
			e.state.measures = (events: [], mbeats: e.state.mbeats);
		
		});
		
		// --- //
		
		e.oldstates = e.oldstates.add(e.state);
		
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
			
		},{
		
			e.state.measures = [(events: [], mbeats: e.state.mbeats)];
			
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
			
			// Draw Command Line //
			
			format("cmd: %",e.state.stack).drawInRect(Rect(5,0,width,height/10), Font("Arial", 20), Color.green);
			
			// Draw elements in accumulator //
			
			format("accumulator: %",e.state.accumulator).drawInRect(Rect(5,height-25,width/2,25), Font("Arial", 20), Color.green);
			
			// Draw string in stringarg section //
			
			format("%",e.state.stringarg).drawInRect(Rect(5+width/2,height-25,width,25), Font("Arial", 20), Color.green);
			
			// Draw current working measure and events //
			
			if(e.state.measures.at(e.state.measure) != nil, {
				
				Pen.strokeColor = Color.green;
			
				Pen.fillColor = Color.black;
				
				Pen.width = 2;
				
				Pen.moveTo(0@(height/2));
				
				Pen.lineTo(width@(height/2));
				
				Pen.stroke;
			
				e.state.measures[e.state.measure].events.do({
				
					|event|
					
					Pen.addArc((width*event.numerator/event.denominator)@(height/2),5,0,2*pi);
					
					Pen.fill;
					
					Pen.addArc((width*event.numerator/event.denominator)@(height/2),5,0,2*pi);
					
					Pen.stroke;
					
					nil;
					
				});
			
			});
			
			// Draw current measure division size //
			
			Pen.strokeColor = Color.green;
		
			Pen.fillColor = Color.black;
			
			Pen.width = 2;
			
			Pen.moveTo(0@(height*9/16));
			
			Pen.lineTo(width@(height*9/16));
			
			Pen.stroke;
			
			e.state.divs.do({
			
				|inc|
				
				Pen.moveTo((width*inc/e.state.divs)@(height*35/64));
				
				Pen.lineTo((width*inc/e.state.divs)@(height*9/16));
				
				Pen.stroke;
				
			});
			
			Pen.fillColor = Color.green;
			
			7.do({
				
				|inc|
				
				var ncheck = [0,2,4,5,7,9,11];
				
				Pen.strokeRect(Rect((inc*(width/2)/7)+(width/4),height*5/8,(width/2)/7,height/8));
				
				if(	(e.state.note+e.state.noteoffset)%12 == ncheck[inc],
					{Pen.fillRect(Rect((inc*(width/2)/7)+(width/4),height*5/8,(width/2)/7,height/8));});
				
			});
			
			6.do({
			
				|inc|
				
				var ncheck = [1,3,nil,6,8,10];
				
				if(inc != 2, {
					
					Pen.fillColor = Color.black;
				
					Pen.fillRect(Rect((inc*(width/2)/7)+((width/2)/14)+((width/2)/28)+(width/4),height*5/8,(width/2)/14,height/16));
					
					Pen.strokeRect(Rect((inc*(width/2)/7)+((width/2)/14)+((width/2)/28)+(width/4),height*5/8,(width/2)/14,height/16));
				
					Pen.fillColor = Color.green;
				
					if(	(e.state.note+e.state.noteoffset)%12 == ncheck[inc],
						{Pen.fillRect(Rect((inc*(width/2)/7)+((width/2)/14)+((width/2)/28)+(width/4),height*5/8,(width/2)/14,height/16));});
				
				});
				
			});
			
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
					
					//,{k.postln;c.postln;u.postln;}
						
				);
						
		};
	
		AppClock.sched(0.0,{w.refresh;1/30;});
	
	}
	
);

s.boot;

s.waitForBoot({

	e.init.();
	
},inf);

)

// bkmk

(

{

var kick, snare, hats, crash, bass, leads, bgmel, pads, noisefx;

kick		= 16;
snare		= 18;
hats		= 20;
crash		= 22;
bass		= 24;
leads		= 26;
bgmel		= 28;
pads		= 30;
noisefx	= 32;

SynthDef(\mixer, {

	var lkick = In.ar(kick,2);

	var lsnare = In.ar(snare,2);

	var lhats = In.ar(hats,2);

	var lcrash = In.ar(crash,2);

	var lbass = Compander.ar(FreeVerb.ar(In.ar(bass,2),1/4,1/4,1/4),HPF.ar(lkick,100),-60.dbamp,1,1/30,2/1000,7/100);

	var lleads = HPF.ar(In.ar(leads,2),200);

	var lbgmel = In.ar(bgmel,2);

	var lpads = In.ar(pads,2);

	var lnoisefx = In.ar(noisefx,2);

	// --- //
	
	var out = lkick+lsnare+lhats+lcrash+lbass+lleads+lbgmel+lpads+lnoisefx;
	
	out = FreeVerb.ar(out,-20.dbamp,2/4,1/4);
	
	out = Limiter.ar(out,0.5,(1/333)+(1/10)) + (Normalizer.ar(Limiter.ar(out,1/16,1/333),1,1/10)/32);
	
	Out.ar(0,out);
	
}).store;

~mixer = Synth(\mixer);

f = {
	
	|ratio = 2, elements = 10|

	var x = [1];
	
	elements.do({x = x ++ (x[x.size-1]*ratio)});
	
	x;
	
};

SynthDef(\bass, {

	|freq=440,dur=0.3,amp=0.5|
	
	var afreq = freq/8;
	
	var env = EnvGen.ar(Env([1,1/2,1/3,0],[1/200,dur,1/50]), doneAction: 2);
	
	var penv = EnvGen.ar(Env([1,2,2],[dur/2,dur/2]));
	
	var out = Fold.ar(RLPF.ar(Saw.ar([afreq+(afreq/100),afreq-(afreq/100)])*env,env*16000,0.4),-1/6,1/6)*3/2;
	
	out = RLPF.ar(out,5000,0.3);
	
	afreq = freq*2*penv;
	
	out = out + ((Saw.ar([afreq+(afreq/100),afreq-(afreq/100)])*env)/4);
	
	out = out.tanh;
	
	out = out + BPF.ar(Fold.ar(out,-1/8,1/8),SinOsc.ar(7,0,5000,5500),0.1)*8;
	
	out = Normalizer.ar(out,1,1/300)*amp;
	
	Out.ar(bass, out!2);
	
}).store;

SynthDef(	\kick, {
			
	|dur=0.25,amp=0.5,basefreq=120|
	
	var freqs = f.value(1.1,20)*basefreq;
	
	var amps = f.value(0.225,20)*amp*0.5;
		
	var phases = NamedControl.kr(\phases,#[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]);
	
	var modfreqs = freqs * EnvGen.ar(Env([1,0],[dur]));
	
	var tone = SinOsc.ar(modfreqs,phases,amps)*EnvGen.ar(Env([0,1,0],[0.005,dur]),doneAction:2);
	
	tone = tone + LPF.ar((PinkNoise.ar()*EnvGen.ar(Env([1,0],[0.004])))*0.02,2250);
	
	tone = HPF.ar(tone,40);
	
	Out.ar(kick, tone!2);
				
}).store;

SynthDef(\snare, {
	
	|amp = 0.5, dur = 0.1|
	
	var env, noise, output;
	
	noise = Dust2.ar(4000);
	
	env = Line.ar(1.0, 0, 0.15, doneAction:2);
	
	output = LPF.ar(RHPF.ar( noise * env, 1000, 0.4), 9000)*amp;
	
	Out.ar(snare, output ! 2 );
	
}).store;

SynthDef(\proglead,{
	
	|freq=440,amp=0.5|
	
	var out = Saw.ar([freq-(freq/100),freq+(freq/100)])/2;
	
	var env = EnvGen.ar(Env([1,1/32,0],[0.15,1]), doneAction: 2);
	
	out = LPF.ar(out,env*8000);
	
	out = out*amp;
	
	Out.ar(leads, out!2);
	
}).store;

SynthDef( \hats, {

	|amp=0.1,out=0,len=0.1|
	
	var env1, output;
	
	env1 = EnvGen.ar( Env.new([0,1,0],[0.0005,len]), doneAction:2 );
	
	output = WhiteNoise.ar()*env1*env1*env1*env1*amp;
	
	output = FreeVerb.ar( output, 1/3, 0.8, 0.05 );
	
	output = HPF.ar( output, 5000 );
	
	Out.ar(hats, output!2);
	
}).store;

}.();

)