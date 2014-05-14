

(

var width, height, incc;

var ovalDiam = 40;
var divs = 7;

width	= 600;
height	= 600;

incc = 0;

w = Window("window", Rect(100, 100, width, height)).front;

w.view.background_(Color.black(0.5));

~currentChord = [0,2,4,6];

~getPitchClass = {

	|pitch, pitchesPerOctave|

	while({pitch>=pitchesPerOctave},{pitch = pitch - pitchesPerOctave});
	while({pitch<0},{pitch = pitch + pitchesPerOctave});

	pitch;

};

~newChord = {

	var chords = [];

	7.do({
		|inc|

		var chord = ~currentChord+inc;
		var sharedNotes = 0;

		chord.size.do({
			|index|

			chord[index] = ~getPitchClass.(chord[index],7);

			if(~currentChord.indexOf(chord[index])!=nil, {sharedNotes=sharedNotes+1});

		});

		chords = chords.add((chord: chord, sharedNotes: sharedNotes));

	});

	chords;

};

~xdivs = 18;
~ydivs = 18;

~drawCircle = {

	Pen.strokeColor = Color.new(1,0.5,0,1);
	Pen.fillColor = Color.black;
	Pen.width = 5;

	Pen.fill;

	Pen.addOval(Rect(width/2-(width/4),height/2-(width/4),width/2,width/2));

	Pen.stroke;

	divs.do({

		|inc|

		Pen.fillColor = Color.black;

		Pen.addOval(Rect(	(width/2)-(ovalDiam/2)+(cos(2pi*inc/divs-(pi/2))*width/4),
			(height/2)-(ovalDiam/2)+(sin(2pi*inc/divs-(pi/2))*width/4),
			ovalDiam,
			ovalDiam));

		Pen.fill;

		Pen.addOval(Rect(	(width/2)-(ovalDiam/2)+(cos(2pi*inc/divs-(pi/2))*width/4),
			(height/2)-(ovalDiam/2)+(sin(2pi*inc/divs-(pi/2))*width/4),
			ovalDiam,
			ovalDiam));

		Pen.strokeColor = Color.new(1,0.5,0,1);

		Pen.fillColor = Color.new(1,1,0.75,1);

		Pen.stroke;

		Pen.addOval(Rect(	(width/2)-(ovalDiam/2)+(cos(2pi*inc/divs-(pi/2))*width/4),
			(height/2)-(ovalDiam/2)+(sin(2pi*inc/divs-(pi/2))*width/4),
			ovalDiam,
			ovalDiam));

		~currentChord.do({

			|pitch|

			if(inc==~getPitchClass.(pitch,7),{Pen.fill;});

		});



	});

	1;

};

w.drawFunc = {

	Pen.strokeColor = Color.green;
	Pen.fillColor = Color.black;
	Pen.width = 2;

	Pen.rotate(-pi*3/4, width*0.5, height*0.5);

	~xdivs.do({

		|x|

		~ydivs.do({

			|y|

			var currentChordMidi = [];

			Pen.addRect(Rect(width*x/(~xdivs-1), (height*y/(~ydivs-1)), width/~xdivs, height/~ydivs));

			Pen.fillColor = Color.green;

			~currentChord.size.do({
				|inc|
				currentChordMidi = currentChordMidi.add([0,2,4,5,7,9,11][~currentChord[inc]]);
			});

			if(((x*3)+(y*4))%12==0, {Pen.strokeColor = Color.white;});

			if((currentChordMidi+48).indexOf((x*3)+(y*4))!=nil, {Pen.fill;}, {Pen.stroke;});

			Pen.strokeColor = Color.green;

		});

	});

	Pen.rotate(pi*3/4, width*0.5, height*0.5);

	~drawCircle.();

	1;

};


fork { while { w.isClosed.not } { defer { w.refresh }; (1/60).wait; } };



t = TempoClock(140/60).schedAbs(	1,
	{

		|beat|

		if(incc%6==0,{

			var potentialChord = ~newChord.();

			var chosenChords = [];

			potentialChord.do({

				|chordItem|

				if([2,3].indexOf(chordItem.sharedNotes)!=nil,{

					chosenChords = chosenChords.add(chordItem.chord);

				});

			});

			~currentChord = chosenChords.choose;

			(degree: ~currentChord, dur: 6).play;

		});

		//if((incc%(6*8))==0, {~currentChord = [0,2,4,6];"Tonic".postln;nil;});

		incc = (incc + 1);

		(degree: (~currentChord[(incc%7)%~currentChord.size]+7),
			amp: ((4-(incc%4))+1)/70,
		dur: 4).play;

		0.75;

});

)
