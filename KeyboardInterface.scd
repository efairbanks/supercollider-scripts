
/*

Two modes, a global editing mode and a track editing mode.

Each track has its own rendering routine and command set.

The global mode has its own rendering routine and command set.

There is a global stack that numbers can be pushed to so as to be used as arguments to commands.

Commands are mapped to specific keys, and when that key is pressed it pulls the appropriate number of arguments off the stack and the command is executed.

*/

(

/* ------ */

~sequenceCursor = 0;

t = TempoClock(130/60).sched(0,{

	if(~keysLeftStatus[~sequenceCursor]>0,{Synth(\bassdrum);});

	if(~keysRightStatus[~sequenceCursor]>0,{Synth(\snaredrum);});
	
	~sequenceCursor = (~sequenceCursor + 1)%16;
	
	1/4;

});

/* ------ */

~keysLeftMap = [$1,$2,$3,$4,$q,$w,$e,$r,$a,$s,$d,$f,$z,$x,$c,$v];
~keysLeftStatus = 0!~keysLeftMap.size;

~keysRightMap = [$7,$8,$9,$0,$u,$i,$o,$p,$j,$k,$l,$;,$m,$,,$.,$/];
~keysRightStatus = 0!~keysRightMap.size;

//w.close;

~x = 100;
~y = 100;

w = Window.new("Derp");

w.view.background_(Color.black); 
        
w.drawHook = {
	
	/*
	Pen.strokeColor = Color.green; 
	Pen.width = 2; 
	Pen.moveTo((~x-5)@~y); 
	Pen.lineTo((~x+5)@~y); 
	Pen.stroke;
	Pen.moveTo(~x@(~y-5)); 
	Pen.lineTo(~x@(~y+5)); 
	Pen.stroke;
	*/
	
	var squareSize = 50;
	
	Pen.width = 2;
	
	Pen.strokeColor = Color.green;
	
	Pen.fillColor = Color.green;
	
	16.do({
	
		|inc|
		
		var x, y, xoff, square;
		
		x = (inc%4)*squareSize;
		
		y = (inc/4).asInteger*squareSize;
		
		xoff = y/2;
		
		square = Rect(10+x+xoff,10+y,squareSize,squareSize);
		
		Pen.strokeRect(square);
		
		if(~keysLeftStatus[inc]>0,{
			
			Pen.fillRect(square.insetBy(3,3))
			
		});
		
	});
	
	16.do({
	
		|inc|
		
		var x, y, xoff, square;
		
		x = (inc%4)*squareSize+(squareSize*5);
		
		y = (inc/4).asInteger*squareSize;
		
		xoff = y/2;
		
		square = Rect(10+x+xoff,10+y,squareSize,squareSize);
		
		Pen.strokeRect(square);
		
		if(~keysRightStatus[inc]>0,{
			
			Pen.fillRect(square.insetBy(3,3))
			
		});
		
	});

};

AppClock.sched(0.0,{w.refresh;0.1;});

w.view.keyDownAction = {
		
		|v,c,m,u,k|
		
		var x, y, keysLeftIndex, keysRightIndex;
		
		keysLeftIndex = ~keysLeftMap.indexOf( c );
		keysRightIndex = ~keysRightMap.indexOf( c );
		
		if(keysLeftIndex!=nil,{
		
			~keysLeftStatus[keysLeftIndex].switch(
			
				0,{
					
					~keysLeftStatus[keysLeftIndex] = 1;
					
				},
				1,{
					
					~keysLeftStatus[keysLeftIndex] = 0;
					
				}
			
			);
		
		});
		
		if(keysRightIndex!=nil,{
		
			~keysRightStatus[keysRightIndex].switch(
			
				0,{
					
					~keysRightStatus[keysRightIndex] = 1;
					
				},
				1,{
					
					~keysRightStatus[keysRightIndex] = 0;
					
				}
			
			);
		
		});
		
		//~keysLeftStatus.postln;
		
		/*
		k.switch(	

			123,{~x = ~x - ~inc;},
			124,{~x = ~x + ~inc;},
			125,{~y = ~y + ~inc;},
			126,{~y = ~y - ~inc;},
			27,{~inc = ~inc - 1;},
			24,{~inc = ~inc + 1;},
			{}
				
		);
		*/
	
};

w.front;

)