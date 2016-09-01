
(

~kb = nil; // Keepin' it fresh!

~xBoard = {
	
	// pks = Keyboard Singleton
	
	|message|
	
	if(~kb==nil,{
	
		MIDIClient.init;
	
		~kb = (
		
			midiRecv: MIDIIn.connect(0,MIDIClient.sources.indexOf(MIDIIn.findPort("E-MU Xboard49", "E-MU Xboard49"))),
		
			keyStates: (),
		
			start: {
			
				|self|
				
				self.midiRecv.noteOn = {
	
					|src, chan, num, vel|
				
					self.keyStates[num] = vel;
				
				};
								
				self.midiRecv.noteOff = {
					
					|src, chan, num, vel|
				
					self.keyStates[num] = nil;
								
				};
		
			}
			
		);
		
	});
	
	~kb;
	
};

)



