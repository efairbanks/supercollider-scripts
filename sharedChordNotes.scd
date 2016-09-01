
(

var width, height, incc;

~allChords = [];

~generateAllChords = {

		12.do({
			
			// major chords
			
			|inc|
			
			var chord = [];
			
			chord = chord.add((0+inc)%12);
			chord = chord.add((4+inc)%12);
			chord = chord.add((7+inc)%12);
			
			~allChords = ~allChords.add(chord);
			
		});

		12.do({
			
			// minor chords
			
			|inc|
			
			var chord = [];
			
			chord = chord.add((0+inc)%12);
			chord = chord.add((3+inc)%12);
			chord = chord.add((7+inc)%12);
			
			~allChords = ~allChords.add(chord);
			
		});
		
		12.do({
			
			// diminished chords
			
			|inc|
			
			var chord = [];
			
			chord = chord.add((0+inc)%12);
			chord = chord.add((3+inc)%12);
			chord = chord.add((6+inc)%12);
			
			~allChords = ~allChords.add(chord);
			
		});
		
		~allChords;
	
};

~sharedNotes = {

	|chorda, chordb|
	
	var sharedNotes = 0;
	
	chorda.do({
	
		|note|
		
		if(chordb.indexOf(note)!=nil,{sharedNotes = sharedNotes + 1;});
		
	});
	
	sharedNotes;
	
};

~generateAllChords.();

width	= 700;
height	= 700;

incc = 0;

w = Window("window", Rect(100, 100, width, height)).front;

w.view.background_(Color.black(0.5));

~xdivs = 36;
~ydivs = 36;

w.drawFunc = {

	Pen.strokeColor = Color.green;
	Pen.fillColor = Color.black;
	Pen.width = 2;

	~xdivs.do({

		|x|

		~ydivs.do({

			|y|

			var currentChordMidi=[];

			Pen.addRect(Rect(width*y/(~ydivs), (height*x/(~xdivs)), width/~ydivs, height/~xdivs));

			if(~sharedNotes.(~allChords[x],~allChords[y])==0,{Pen.fillColor=Color.black;});
			if(~sharedNotes.(~allChords[x],~allChords[y])==1,{Pen.fillColor=Color.blue;});
			if(~sharedNotes.(~allChords[x],~allChords[y])==2,{Pen.fillColor=Color.red;});
			if(~sharedNotes.(~allChords[x],~allChords[y])==3,{Pen.fillColor=Color.green;});

			Pen.fill();

		});

	});

	1;

};

fork { while { w.isClosed.not } { defer { w.refresh }; (1/60).wait; } };

)
