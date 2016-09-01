
/*

Two modes, a global editing mode and a track editing mode.

Each track has its own rendering routine and command set.

The global mode has its own rendering routine and command set.

There is a global stack that numbers can be pushed to so as to be used as arguments to commands.

Commands are mapped to specific keys, and when that key is pressed it pulls the appropriate number of arguments off the stack and the command is executed.

*/

(

w.close;

~x = 100;
~y = 100;
~inc = 10;

w = Window.new("Derp");

w.view.background_(Color.black); 
        
w.drawHook = {
	
	Pen.strokeColor = Color.green; 
	Pen.width = 2; 
	Pen.moveTo((~x-5)@~y); 
	Pen.lineTo((~x+5)@~y); 
	Pen.stroke;
	Pen.moveTo(~x@(~y-5)); 
	Pen.lineTo(~x@(~y+5)); 
	Pen.stroke;

};

AppClock.sched(0.0,{w.refresh;0.1;});

w.view.keyDownAction = {
		
		|v,c,m,u,k|
	
		k.switch(	
		
					123,\left,
					124,\right,
					125,\down,
					126,\up,
					27,\minus,
					24,\plus,
					k
						
				).postln;
				
		k.switch(	

					123,{~x = ~x - ~inc;},
					124,{~x = ~x + ~inc;},
					125,{~y = ~y + ~inc;},
					126,{~y = ~y - ~inc;},
					27,{~inc = ~inc - 1;},
					24,{~inc = ~inc + 1;},
					{}
						
				);
	
};

w.front;

)