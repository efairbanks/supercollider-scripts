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
			
		events:		[],		// list of sequencer events
		bpm:			130,	// tempo
		instruments:	[],		// list of instruments
		accumulator:	[],		// accumulator for entering numbers
		cmdstring:		"",		// string for holding command line
		logstring:		"",		// string for hold the command log/errors
		commandlist:	[],		// list of previously executed commands
		
		instlevels:	(),
		
		divs:			4,		// current working measure divisions
		div:			0,		// current working measure division
		measure:		0,		// current working measure
		beat:			0,		// current working beat (actual working beat is beat: + [measure: * mlen:])
		durmul:		1,		// current working note duration multiplier (actual dur is durmul * divs, played this is mul'd by beatDur)
		mlen:			4,		// current working measure length (length of measure in beats)
		note:			0,		// current working MIDI note value.
		noteoffset:	48,		// current working MIDI note offset
		instrument:	nil,	// current working instrument
		stringarg:		nil		// variable to hold string args for changing instrument and/or synth key/value arguments
		
	),
	
	tempoclock:	nil,

	exit: {	// exit program
		
		|in|
	
		if(w==nil,{},{w.close;});
		
	},
	
	save: {
		
		|in|
		
		var file = File.new("testsong","w");
		
		e.state.cmdstring = "";
		
		file.write(e.state.asCompileString);
		
		file.close;
		
		nil;
		
	},
		
	idb: {
	
		|in|
		
		e.oldstates = e.oldstates.add(e.state.deepCopy);
	
		e.state.instlevels[in[0]] = in[1].dbamp;
		
	},
	
	e: {
	
		|in|
	
		e.oldstates = e.oldstates.add(e.state.deepCopy);
	
		in[0].do({
			
			|element|
	
			var event = ();
			
			event.beat = (element/e.state.divs*e.state.mlen)+(e.state.beat+(e.state.measure*e.state.mlen));
			
			event.instrument = e.state.instrument;
			
			event.freq = (e.state.note+e.state.noteoffset).midicps;
	
			e.state.events = e.state.events.add(event);
		
		});
		
	},
	
	series: {
	
		|in|
		
		Array.series(in[0], in[1], in[2]); //size start step
		
	},
	
	rand: {
	
		|in|
		
		Array.rand(in[0], in[1], in[2]); //size max min
		
	},
	
	flat: {
	
		|in|
		
		in.flatten(1);
		
	},
	
	reverse: {
	
		|in|
	
		in[0].reverse;
		
	},
	
	shuffle: {
	
		|in|
	
		in[0].perfectShuffle;
		
	},
	
	eumake: {
		
		|in|
	
		ED.create(in[0],in[1]);
		
	},
	
	eufold: {
		
		|in|
	
		ED.convert(in[0]);
		
	},
	
	euxpand: {
		
		|in|
	
		ED.expand(in[0]);
		
	},
	
	euxtra: {
		
		|in|
	
		ED.extrapolate(in[0],in[1],in[2]);
		
	},
	
	eucvt: {
		
		|in|
	
		in[0].findAll([1]);
		
	},
	
	dn: {
	
		|in|
		
		if(in[0].size == in[1].size,{
		
			in[0].do({
				
				|element, index|
			
				var noteval = Scale.major.wrapAt(in[1][index])+(12*((in[1][index]/7).asInteger)) + e.state.noteoffset;
			
				var event = ();
				
				event.beat = (in[0][index]/e.state.divs*e.state.mlen)+(e.state.beat+(e.state.measure*e.state.mlen));
				
				event.instrument = e.state.instrument;
				
				event.freq = noteval.midicps;
			
				e.state.events = e.state.events.add(event);
				
			});
			
		});
		
	},
	
	mul: {
	
		|in|
		
		in[0]*in[1];
		
	},
	
	div: {

		|in|
		
		in[0]/in[1];
		
	},
	
	p: {
	
		|in|
	
		var events = e.state.events.deepCopy;
		
		var proc;
		
		var amp;
		
		var floor;
		
		if(in[0]!=nil,{
		
			events = events.select({
			
				|element|
				
				element.beat>=in[0];
				
			});
		
		});
		
		if(in[1]!=nil,{
		
			events = events.select({
			
				|element|
				
				element.beat<in[1];
				
			});
		
		});
		
		events = events.sort({|a, b| a.beat < b.beat;});
		
		floor = events[0].beat;
		
		events.do({
		
			|item, index|
			
			events[index].beat = events[index].beat - floor;
			
		});
		
		events.postln;
		
		"".postln;
		
		proc = {
			
			|es, curbeat|
			
			if(es.size > 0,{
				
				var args = [];
				
				es[0].keys.do({
				
					|element|
					
					if((element != \beat) && (element != \instrument) && (element != \amp), {
					
						args = args ++ [element,es[0][element]];
					
					});
					
				});
				
				amp = if(es[0].amp==nil,{1.0},{es[0].amp});
				
				amp = amp*if(e.state.instlevels[es[0].instrument]==nil,{1.0},{e.state.instlevels[es[0].instrument]});
				
				args = args ++ [\amp,amp];
				
				Synth(es[0].instrument,args);
				
				if(es.size > 1,{
					
					e.tempoclock.sched(es[1].beat-curbeat,{
						
						proc.(es.copyRange(1,es.size), curbeat+(es[1].beat-es[0].beat));
						
						nil;
					
					});
				});
			});
			
		};
		
		proc.(events, 0);
		
		events;
		
	},

	d: {		// change number of measure divisions
	
		|in|
		
		e.oldstates = e.oldstates.add(e.state.deepCopy);
		
		e.state.divs = in[0];
		
		in[0];
		
	},
	
	cd: {		// change current measure div
	
		|in|
		
		e.oldstates = e.oldstates.add(e.state.deepCopy);
		
		e.state.div = in[0];
		
		nil;
		
	},
	
	dm: {
	
		|in|
		
		if(in.size > 0, {e.state.durmul = in[0];});
		
		nil;
		
	},
	
	mb: {		// change the length of a measure in beats
	
		|in|
		
		e.oldstates = e.oldstates.add(e.state.deepCopy);
		
		e.state.mlen = in[0];
		
		nil;
		
	},
	
	m: {
	
		|in|
	
		e.state.measure = in[0];
		
		nil;
		
	},
	
	bpm: {
	
		|in|
		
		if(in.size>0,{e.state.bpm = in[0];});
		
		e.tempoclock.tempo = e.state.bpm/60;
		
		nil;
		
	},
	
	i: {		// change default instrument
	
		|in|
		
		e.oldstates = e.oldstates.add(e.state.deepCopy);
		
		e.state.instrument = in[0];
		
		e.state.stringarg = nil;
		
		nil;
		
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
		
		e.oldstates = e.oldstates.add(e.state.deepCopy);
		
		e.state.stringarg = nil;
		
		nil;
		
	},
	
	n: {		// change default working note value
	
		|in|
		
		e.oldstates = e.oldstates.add(e.state.deepCopy);
	
		e.state.note = in[0];
		
		nil;
		
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
	
	undo: {
	
		if(e.oldstates!=[],{
		
			e.state = e.oldstates[e.oldstates.size-1];
			
			e.oldstates = e.oldstates.copyRange(0,e.oldstates.size-2);
			
			nil;
			
		});
		
	},
	
	processCommand: {	// process the command
		
		var return = nil;

		var lex = {
			
			|string|
		
			var getType = {
		
				|element|
				
				var type = \symbol;
				
				var haschars = "[a-zA-Z]+".matchRegexp(element++" ");
					
				var hasdigits = "[0-9]+".matchRegexp(element++" ");
				
				var isfloat = "[\.]+".matchRegexp(element++" ");
				
				if( hasdigits && isfloat.not, {type = \integer;});
				
				if( hasdigits && isfloat, {type = \float;});
				
				if( haschars, {type = \symbol});
				
				if( element == "\(", {type = \leftparen;});
				
				if( element == "\)", {type = \rightparen;});
				
				type;
			
			};
		
			var tokens = [];
		
			string.replace("\("," \( ").replace("\)"," \) ").split($ ).do({
			
				|element, index|
				
				if( (element != "") && (element != " ") && (element != nil) && (element != []), {
				
					tokens = tokens.add(element);
					
				});
				
			});
		
			tokens.collect({
			
				|element|
				
				var return = nil;
						
				getType.(element).switch(
				
					\leftparen,	{"\("},
					\rightparen,	{"\)"},
					\symbol,		{element.asSymbol},
					\integer,		{element.asInteger},
					\float,		{element.asFloat}
							
				);
				
			});
		
		};
		
		var parse = {
			
			|symbols|
			
			var processingexpression = false;
			
			var symboltree = [];
			
			var expression = [];
			
			var pcount = 0;
			
			symbols.do({
			
				|element, index|
				
				if( (element == "\(") && (processingexpression == false), {processingexpression = true; expression = [];});
				
				if( element == "\(", {pcount = pcount + 1;});
				
				if( element == "\)", {pcount = pcount - 1;});
				
				if(	processingexpression == true,
					{
						
						expression = expression.add(element);
						
						if( (element == "\)") && (pcount == 0),{
						
							processingexpression = false;
							
							symboltree = symboltree.add(parse.(expression.copyRange(1,expression.size-2)));
							
						});
						
					},
					{
					
						symboltree = symboltree.add(element);
						
					});
				
			});
			
			symboltree;
			
		};
		
		var eval = {
		
			|tree|
		
			tree.collect({
			
				|node|
				
				if(	node.isArray,
					{
						
						node = eval.(node);
						
						if(	node[0].isKindOf(Symbol),
							{
								
								if(	e[node[0]] != nil,
									{
									
										e[node[0]].(node.copyRange(1,node.size));
										
									},{nil;});
									
							},
							{
								
								node;
								
							});
						
					},
					{
						
						node;
						
					});
				
			});
		
		};
		
		//bkmk
		
		return = eval.([parse.(lex.(e.state.cmdstring))]);
		
		e.state.logstring = format("%",return);
	
	},
	
	init: {	// initialize the environment
			
		var file = File("testsong","r");
		
		if(file.isOpen,{
		
			e.state = 	String.readNew(file).interpret;
			
			file.close;
			
		},{
			
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
			
			var temp = "";
			
			// Draw Command Line //
			
			format("cmd: %",e.state.cmdstring).drawInRect(Rect(5,0,width,height/10), Font("Arial", 20), Color.green);
			
			format("log: %",e.state.logstring).drawInRect(Rect(5,height*9/10,width,height/10), Font("Arial", 20), Color.green);
			
			temp = temp ++ format("inst: %\n",e.state.instrument);
			temp = temp ++ format("divs: %\n",e.state.divs);
			temp = temp ++ format("div: %\n",e.state.div);
			temp = temp ++ format("measure: %\n",e.state.measure);
			temp = temp ++ format("mlen: %\n",e.state.mlen);
			
			temp.drawInRect(Rect(5,height*1/10,width,height*4/10), Font("Arial", 20), Color.green);
			
			// Draw current working measure and events //
			
			Pen.strokeColor = Color.green;
			
			Pen.fillColor = Color.black;
				
			Pen.width = 2;
			
			Pen.moveTo(0@(height/2));
				
			Pen.lineTo(width@(height/2));
			
			Pen.stroke;
			
			e.state.events.do({
			
				|event|
			
				if(	event.beat != nil,
					{
						
					var beatloc = (event.beat-e.state.beat-(e.state.measure*e.state.mlen))/e.state.mlen;
					
					if( (beatloc >= 0) && (beatloc <= 1), {
				
						Pen.addArc((width*beatloc)@(height/2),5,0,2*pi);
						
						Pen.fill;
						
						Pen.addArc((width*beatloc)@(height/2),5,0,2*pi);
						
						Pen.stroke;
					
					});
						
				});
				
			});
			
			/*
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
			
			});*/
			
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
				
			var validchars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789()._- ";
				
			if(validchars.contains(c.asString),{e.state.cmdstring = e.state.cmdstring++(c.asString)});
						
				k.switch(	
		
					123,{},	// left
					124,{},	// right
					125,{},	// down
					126,{},	// up
					
					53,{if(w==nil,{},{w.close;});},  // quit
					
					36,{ // Process command
					
						e.processCommand.value;
						
						e.state.cmdstring = "";
						
					},
					
					51,{
						
						if(e.state.cmdstring.size>0,{
						
							e.state.cmdstring.removeAt(e.state.cmdstring.size-1);
						
						});
							
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
	
	if(~mixer != nil, ~mixer.free);

	~mixer = Synth(\mixer);
	
},inf);

)

// bkmk

/*

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

	var out = 0;

	var lkick = In.ar(kick,2);

	var lsnare = In.ar(snare,2);

	var lhats = In.ar(hats,2);

	var lcrash = In.ar(crash,2);

	var lbass = Compander.ar(FreeVerb.ar(In.ar(bass,2),1/4,1/4,1/4),HPF.ar(lkick,200),-60.dbamp,1,1/21,2/1000,1/100);

	var lleads = HPF.ar(In.ar(leads,2),200);

	var lbgmel = In.ar(bgmel,2);

	var lpads = In.ar(pads,2);

	var lnoisefx = In.ar(noisefx,2);
	
	lbass = (In.ar(bass,2)*(-20.dbamp))+lbass;

	// --- //
	
	out = lkick+lsnare+lhats+lcrash+lbass+lleads+lbgmel+lpads+lnoisefx;
	
	out = FreeVerb.ar(out,-20.dbamp,2/4,1/4);
	
	out = Limiter.ar(out,0.5,(1/333)+(1/10)) + (Normalizer.ar(Limiter.ar(out,1/16,1/333),1,1/10)/32);
	
	out = Limiter.ar(out,1.0,1/1000);
	
	Out.ar(0,out);
	
}).store;

f = {
	
	|ratio = 2, elements = 10|

	var x = [1];
	
	elements.do({x = x ++ (x[x.size-1]*ratio)});
	
	x;
	
};

SynthDef(\bass, {

	|freq=440,dur=1,amp=0.5|
	
	var afreq = freq/8;
	
	var env = EnvGen.ar(Env([1,1/2,1/3,0],[1/200,(dur-(1/200))-(1/50),1/50]), doneAction: 2);
	
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

SynthDef(\basswub, {

	|freq = 440,dur = 0.3, amp = 0.5|
	
	var lfo = SinOsc.ar(1/dur,pi/2,0.5,0.5);
	
	var newfreq = freq/8;
	
	var env = EnvGen.ar(Env([0,1,1,0],[1/500,dur-(2/500),1/500]),doneAction:2);
	
	var tone = Saw.ar([newfreq+(newfreq/100),newfreq-(newfreq/100)])+Pulse.ar(freq*2/3,0.1,0.05);
	
	var out;
	
	lfo = lfo*lfo;
	
	out = RLPF.ar(tone,lfo*8000+30,0.3);
	
	out = Normalizer.ar(out,1.0,1/333)*amp;

	Out.ar(bass, out!2);
	
}).store;

SynthDef(	\kick, {
			
	|dur=0.25,amp=0.5,basefreq=120|
	
	var freqs = f.value(1.1,20)*basefreq;
	
	var amps = f.value(0.225,20)*0.5;
		
	var phases = NamedControl.kr(\phases,#[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]);
	
	var modfreqs = freqs * EnvGen.ar(Env([1,0],[dur]));
	
	var tone = SinOsc.ar(modfreqs,phases,amps)*EnvGen.ar(Env([0,1,0],[0.005,dur]),doneAction:2);
	
	tone = tone + LPF.ar((PinkNoise.ar()*EnvGen.ar(Env([1,0],[0.01])))*0.02,2250);
	
	tone = HPF.ar(tone,40)*amp;
	
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

SynthDef(\acidbass,{

	|freq=440,amp=0.5|
	
	var out = (Saw.ar(freq/2)+Pulse.ar(freq/2,0.3))/2;
	
	out = out * amp;
	
	out = RLPF.ar(out,EnvGen.ar(Env([0,1,0],[1/500,1/30]),doneAction:2)*12000,0.15);
	
	Out.ar(bass, out!2);
	
}).store;

SynthDef(\proglead,{
	
	|freq=440,amp=0.5,dur=0.4|
	
	var out = Saw.ar([freq-(freq/100),freq+(freq/100)])/2;
	
	var env = EnvGen.ar(Env([1,1/32,0],[dur,1]), doneAction: 2);
	
	out = LPF.ar(out,env*8000);
	
	out = out*amp;
	
	Out.ar(leads, out!2);
	
}).store;

SynthDef( \hats, {

	|amp=0.1,out=0,dur=0.1|
	
	var env1, output;
	
	env1 = EnvGen.ar( Env.new([0,1,0],[0.0005,dur]), doneAction:2 );
	
	output = WhiteNoise.ar()*env1*env1*env1*env1*amp;
	
	output = FreeVerb.ar( output, 1/3, 0.8, 0.05 );
	
	output = HPF.ar( output, 5000 );
	
	Out.ar(hats, output!2);
	
}).store;

}.();

)

*/