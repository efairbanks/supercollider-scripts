
(

w = Window.new("Derp");

w.view.keyDownAction = {
		
		|v,c,m,u,k|
	
		switch(	
		
					k,
					123,\left,
					124,\right,
					125,\down,
					126,\up,
					27,\minus,
					24,\plus,
					k
						
				).postln;
	
	};

w.front;

)