
// figure, measure, player, instrument, sequencer

/*

pass figure parameter list, including length in beats, start beat and process function referencing self

*/

There is a global melodic note/interval
There is a global beat struture
Players will use "riffs" and note-generators/counterpoint/set-algebra-on-arpeggios and arrange these to accomodate the beat global note/interval and beat structure

// --- //

Global note structure will have twiddle factors such as rising/falling on pitch bend as well as dissonance/consonance

Global rhythm structure can be set by specifying a list of divisors that define the time signature

Global rhythm structure has twiddle factors for varying depth levels including variety, A-B/A-A-A-B/A-B-A-C modes and manipulations thereof, note density, syncopation, note splitting/merging probabilities, etc… 

// --- //

Environment -> Conductor -> Players -> Phrases -> Measures -> Figures -> Notes => {time, duration, degree}

// --- //

players are figure factories

figures output a series of notes

notes are [beat,duration,{params}] tuples

measure[]
	figure[]
		note[]
		
		

(

~createFigure = { |length_in_beats, start_beat, player_parameters|

	(
	
		lengthInBeats: length_in_beats,
		
		startBeat: start_beat,
		
		playerParameters: player_parameters,
		
		played: false,
		
		playCheck: { |self, current_beat, shortest_beat_division|
			
			var currentlyPlaying = if(current_beat+(shortest_beat_division/2)>=self.startBeat, true, false);
			
			if(currentlyPlaying&&self.played.not, {
			
				self.played = true;
				
				true;
				
			}, {false;});
			
		},
		
		doneCheck: { |self, current_beat, shortest_beat_division|
			
			if(current_beat+(shortest_beat_division/2) >= (self.startBeat+self.lengthInBeats), true, false);
	
		}
	
	);
	
};

~createMeasure = {

	(
	
		figures: [],
		
		currentFigure: nil,
		
		addFigure: { |self, length_in_beats, start_beat, player_parameters|
			
			self.figures = self.figures.add(~createFigure.(length_in_beats, start_beat, player_parameters));
			
		},
		
		process: { |self, currentbeat, shortest_beat_division|
			
			if(self.figures.size>0,{
				
				// check if current figure needs to be destroyed
				
				if(self.currentFigure!=nil,{
					
					if(self.currentFigure.doneCheck(currentbeat, shortest_beat_division),{
					
						self.currentFigure = nil;
						
					});
					
				});
				
				// check if there is a figure needs to be played
				
				if(self.figures[0].playCheck(currentbeat, shortest_beat_division),{
				
					self.currentFigure = self.figures.removeAt(0);
					
					// play figure
					
				});
									
			},
			{
				
				nil;
					
			});
			
		}
	
	);

};

~createPlayer = { |instrument_list|

	(
	
		instruments: instrument_list,
		
		figures: [],
		
		process: {}
	
	);
	
};

)

a = ~createMeasure.();

a.addFigure(2, 0, ());

a.figures.size;

a.process(0, 1/32);

a = ~createFigure.(2, 0, (instrument: 0));

a.playCheck(0, 1/32);

(

t = TempoClock(110/60);

q = ~createMeasure.();

q.addFigure(2,0,());
q.addFigure(2,2,());
q.addFigure(2,4,());
q.addFigure(2,6,());

t.sched(0,{

	q.process(t.beats,1);

	postln(q.figures.size);

	postln(t.beats);
	
	postln("");

	1;
	
});

)