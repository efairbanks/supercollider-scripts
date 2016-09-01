
/*

Two modes, a global editing mode and a track editing mode.

Each track has its own rendering routine and command set.

The global mode has its own rendering routine and command set.

There is a global queue that numbers can be pushed to so as to be used as arguments to commands.

Commands are mapped to specific keys, and when that key is pressed it pulls the appropriate number of arguments off the stack and the command is executed.

*/

(

if(w==nil,{},{w.close;});

// --- //	

~stack		= [];

~acc		= [];

~figures	= [];

~pcursor	= 0;

~fcursor	= 0;

// --- //

~getNote = {
	
	|midival|
	
	midival = midival.asInteger;
	
	(midival%12).switch(
	
		0,\C,
		1,\Cx,
		2,\D,
		3,\Dx,
		4,\E,
		5,\F,
		6,\Fx,
		7,\G,
		8,\Gx,
		9,\A,
		10,\Ax,
		11,\B
	
	);
	
	};

~getOctave = {
	
	|midival|
	
	midival = midival.asInteger;
	
	(midival/12-1).asInteger;
	
	};
	
~getOctave.value(12);

~push = {
	
	var ret = 0;
	
	~acc.size.do({
		
		|index|
		
		ret = ret + (~acc[index]*(10**((~acc.size-1)-index)));
		
		});
		
	~stack = ~stack ++ ret;
	
	~acc = [];
	
	ret;
	
	};
	
~pop = {
	
	var ret = ~stack[0];
	
	~stack = ~stack[1..~stack.size];
	
	ret;
	
	};
	
~rhythm2beats = {
	
	|pulses, steps|
	
	var a = Array.new(steps);
	
	var b = Array.new(steps);
	
	var tempa = Array.new(steps);
	
	var tempb = Array.new(steps);
	
	var split;
	
	steps.do({
		
		|inc|
		
		if(	inc<pulses,
			{a = tempa.add(Array.new(steps).add(1));},
			{b = tempb.add(Array.new(steps).add(0));});
			
	});
	
	while(	{(b.size>1).and(a.size>0)},{
			
		split = 0;
		
		b.size.do({
		
			|inc|
			
			tempa = Array.new(steps).addAll(a);
			
			a[inc%a.size] = tempa[inc%a.size].add(b[inc]);
			
			split = (split+1)%a.size;
			
		});
		
		b = a.copyRange(split,a.size-1);
		
		tempa = a.copyRange(0,split-1);
		
		a = Array.new(steps).addAll(tempa);

	});
		
	a.addAll(b).flat;
	
	};
	
~figures2beats = {
	
	var ret = [];
	
	~figures.size.do({
		
		|iter|
		
		ret = ret ++ ~rhythm2beats.value(~figures[iter][\rhythm][0],~figures[iter][\rhythm][1]);
		
		});
		
		ret;
	
	};
	
~figures2chords = {
	
	var beats = [];
	
	var chords = [];
	
	var rhythm = [];
	
	var ret = [];
	
	~figures.size.do({
		
		|iter|
		
		rhythm = ~rhythm2beats.value(~figures[iter][\rhythm][0],~figures[iter][\rhythm][1]);
		
		ret = ret ++ rhythm;
		
		rhythm.size.do({
			
			chords = chords.add(~figures[iter][\chord]);
			
			});
		
		});
		
		chords;
	
	};
	
// --- Set up artificial beat step callback --- //

// --- instruments --- //

~kick = {
	
	|rhythm,chord|
	
	var delay = ED.convert(rhythm)[0];
	
	var bstart = ED.convert(rhythm);
	
	var blen = ED.convert(rhythm);
	
	blen = blen[1..blen.size-1];
	
	bstart = [0]++bstart[1..bstart.size-2];
	
	bstart = bstart.integrate + delay;
	
	~clock.sched(0,{Synth(\kick)});
	
	bstart.size.do({
		
		|inc|
		
		//~clock.sched(bstart[inc],{Synth(\kick)});
		
		});
	
	};
	
~snare = {
	
	|rhythm,chord|
	
	var delay = ED.convert(rhythm)[0];
	
	var bstart = ED.convert(rhythm);
	
	var blen = ED.convert(rhythm);
	
	blen = blen[1..blen.size-1];
	
	bstart = [0]++bstart[1..bstart.size-2];
	
	bstart = bstart.integrate + delay;
	
	~clock.sched((rhythm.size/2).asInteger,{Synth(\snare)});
	
	bstart.size.do({
		
		|inc|
		
		//~clock.sched(bstart[inc],{Synth(\snare)});
		
		});
	
	};
	
~hats = {
	
	|rhythm,chord|
	
	var delay, bstart, blen;
	
	rhythm = ED.extrapolate(ED.convert(rhythm)*4,2**Array.rand(8,0,3),16);
	
	delay = ED.convert(rhythm)[0];
	
	bstart = ED.convert(rhythm);
	
	blen = ED.convert(rhythm);
	
	blen = blen[1..blen.size-1];
	
	bstart = [0]++bstart[1..bstart.size-2];
	
	bstart = bstart.integrate + delay;
	
	bstart.size.do({
		
		|inc|
		
		~clock.sched(bstart[inc]/4,{Synth(\hats,[\amp,cos(inc/bstart.size*2*pi*8)+2/80,\len,sin((inc/bstart.size)*(2*pi+(pi/8))*32)+2/15])});
		
		});
	
	};
	
~bass = {
	
	|rhythm,chord|
	
	var delay, bstart, blen, note;
	
	delay = ED.convert(rhythm)[0];
	
	bstart = ED.convert(rhythm);
	
	blen = ED.convert(rhythm);
	
	blen = blen[1..blen.size-1];
	
	bstart = [0]++bstart[1..bstart.size-2];
	
	bstart = bstart.integrate + delay;
	
	bstart.size.do({
		
		|inc|
		
		if(chord!=nil,{note = (chord.choose)%7});
		
		~clock.sched(bstart[inc],{Synth(\bass303,[\freq,Scale.major.degreeToFreq(note%7,36.midicps,(note/7).asInteger),\amp,0.1])});
		
		});
	
	};

~pads = {
	
	|rhythm,chord|
	
	var delay, bstart, blen;
	
	delay = ED.convert(rhythm)[0];
	
	bstart = ED.convert(rhythm);
	
	blen = ED.convert(rhythm);
	
	blen = blen[1..blen.size-1];
	
	bstart = [0]++bstart[1..bstart.size-2];
	
	bstart = bstart.integrate + delay;
	
	chord.do({
		
		|degree|
		
		//~clock.sched(0,{Synth(\leads,[\freq,Scale.major.degreeToFreq(degree,60.midicps,0)])});
		
		Synth(\leads,[\freq,Scale.major.degreeToFreq(degree%7,60.midicps,0)]);
		
		});
	
	};

// --- end instruments --- //  //bkmk

~clock.stop;

~figures2chords.value();

~clock = TempoClock.new(120/60*4).sched(	0,
											{
												
												var chord, rhythm, beats, pulses;
												
												if(~fcursor>=~figures.size,{~fcursor=0;~pcursor=0;});
												
												if(~figures!=nil,{
												
												  if(~figures[~fcursor]!=nil,{
												
												    if(~figures[~fcursor][\chord]!=nil,{chord=~figures[~fcursor][\chord];});
												
												    beats = ~figures[~fcursor][\rhythm][1];
												
												    pulses = ~figures[~fcursor][\rhythm][0];
												
												    rhythm = ED.create(pulses,beats);
												  
												    ~kick.value(rhythm,chord);
												    
												    ~snare.value(rhythm,chord);
												    
												    ~hats.value(rhythm,chord);
												    
												    ~bass.value(rhythm,chord);
												    
												    ~pads.value(rhythm,chord);
												 
												  });
												
												});
												
												~fcursor = ~fcursor + 1;
												
												if(beats==nil,{beats=1;});
												
												beats;
												
												/*
												var max = 0;
												
												var chord = [];
												
												if(~figures2chords.value()[~pcursor]!=nil,{chord = ~figures2chords.value()[~pcursor]});
												
												~figures.size.do({
																								|iter|
												
												max = max + ~figures[iter][\rhythm][1];
																								});
																								if(~figures2beats.value()[~pcursor]==1,
																								{(\instrument:\leads,\degree:chord).play});
																								if(~pcursor+1<max,{~pcursor=~pcursor+1;},{~pcursor=0});
																								//chord.postln;
																								1;
												*/
												
											});

// --- end --- //

w = Window.new("Derp", Rect(0,0,1000,778), border:false).fullScreen;

w.view.background_(Color.black);
        
w.drawHook = {
	
	var stackstring = ""; // make string for printing arg stack
	
	var rhythmarray = [];	// holds the rhythm based on all figures
	
	var pos = 0;	// offset for figure group drawing
	
	var padding = 5; // global padding variable
	
	// --- Draw arg stack --- //
	
	stackstring = stackstring ++ "[ ";
	
	~stack.size.do({
		
			|iterator|
		
			stackstring = stackstring ++ ~stack[iterator].asString;
			
			if( iterator < (~stack.size-1), {stackstring = stackstring ++ ", ";});
		
		});
	
	stackstring = stackstring ++ " ]";

	stackstring.drawInRect(Rect(0,5,w.bounds.width,w.bounds.height/10), Font("Arial", 30), Color.green);
	
	// --- end --- //
	
	// --- Draw figure rhythms --- //
	
	Pen.width = 2;
	
	~figures.size.do({
		
		|iter|
		
		rhythmarray = rhythmarray ++ ~rhythm2beats.value(~figures[iter][\rhythm][0],~figures[iter][\rhythm][1]);
		
		});
		
	rhythmarray.size.do({
		
		|iter|
		
		Pen.strokeRect(Rect(	(w.bounds.width)/(rhythmarray.size)*iter+padding,
							(w.bounds.height)*2/4+padding,
							(w.bounds.width)/(rhythmarray.size)-(padding*2),
							(w.bounds.height)/4*(3/4)-(padding*2)));
		
		Pen.addRect(Rect(		(w.bounds.width)/(rhythmarray.size)*iter+padding,
							(w.bounds.height)*2/4+padding,
							(w.bounds.width)/(rhythmarray.size)-(padding*2),
							(w.bounds.height)/4*(3/4)-(padding*2)));
								
		if(rhythmarray[iter]==0,{Pen.stroke;},{Pen.fill;});
		
		});
	
	// --- end --- //
	
	// --- Draw figure bounds --- //
	
	~figures.size.do({
		
		|iter|
		
		var beatwidth = (w.bounds.width)/(rhythmarray.size);
		
		var rhythmsize = ~figures[iter][\rhythm][1];
		
		var notes = "";
		
		~figures[iter][\chord].size.do({
			
			|itr|
			
			notes = notes ++ ~getNote.value(~figures[iter][\chord][itr]);
			
			notes = notes ++ ~getOctave.value(~figures[iter][\chord][itr]);
			
			notes = notes ++ " ";
			
			});
			
		notes = format("%/% - ", ~figures[iter][\rhythm][0], ~figures[iter][\rhythm][1]) ++ notes;
		
		Pen.strokeRect(Rect(	pos + padding,
							(w.bounds.height)*2/4 + ((w.bounds.height)*3/16) + padding,
							rhythmsize*beatwidth - (padding*2),
							(w.bounds.height)/4*(1/5) - (padding*2)));
							
		(notes).drawInRect(	Rect(	pos + (padding*2),
									(w.bounds.height)*2/4 + ((w.bounds.height)*3/16) + (padding*2),
									rhythmsize*beatwidth - (padding*4),
									(w.bounds.height)/4*(1/5) - (padding*4)),
									
							Font("Arial", (w.bounds.height)/4*(1/5) - (padding*4)),
							
							Color.green);
							
		pos = pos + (rhythmsize*beatwidth);
		
		});
	
	// --- end --- //
	
	// --- Draw play cursor --- //
	
	Pen.fillRect(Rect(	(~pcursor*(w.bounds.width)/(rhythmarray.size)) + padding,
						(w.bounds.height)*1/4 + ((w.bounds.height)*3/16) + padding,
						((w.bounds.width)/(rhythmarray.size)) - (padding*2),
						(w.bounds.height)/4*(1/4) - (padding*2)));
	
	// --- end --- //
	
};

AppClock.sched(0.0,{w.refresh;1/30;});

w.view.keyDownAction = {
		
		|v,c,m,u,k|
				
		k.switch(	

					123,{},	// left
					124,{},	// right
					125,{},	// down
					126,{},	// up
					
					18,{~acc = ~acc ++ 1;},  // 1 - 9 & 0
					19,{~acc = ~acc ++ 2;},
					20,{~acc = ~acc ++ 3;},
					21,{~acc = ~acc ++ 4;},
					23,{~acc = ~acc ++ 5;},
					22,{~acc = ~acc ++ 6;},
					26,{~acc = ~acc ++ 7;},
					28,{~acc = ~acc ++ 8;},
					25,{~acc = ~acc ++ 9;},
					29,{~acc = ~acc ++ 0;},  // --- //
					
					33,{if(~figures.size>1,	{~figures = ~figures[1..(~figures.size)];~pcursor = ~pcursor - ~figures[0][\rhythm][1];},
												{~figures = [];});},    // [
					
					30,{~figures = ~figures[0..(~figures.size-2)];}, // ]
					
					24,{~push.value;},	// + push
					27,{~pop.value;},		// - pop
					
					51,{~acc = [];},     // clear acc
					
					53,{if(w==nil,{},{w.close;});},  // quit
					
					3,{	if(	 ~stack.size > 1,
							{
								var dict = Dictionary.new[\rhythm] = Array.new ++ ~pop.value() ++ ~pop.value();
								
								~figures = ~figures.add(dict);
								
							});}, // push figure
						
					8,{	if(	 ~stack.size > 2,
							{
								
								var index = ~pop.value();
								
								if(index>=~figures.size,{index=~figures.size-1;});
								
								while({~stack.size>0},{~figures[index][\chord] = ~figures[index][\chord] ++ [~pop.value()];});
								
							});},
					
					{k.postln;}
						
				);
	
};

w.front;

)