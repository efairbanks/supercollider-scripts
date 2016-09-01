
(

	var width, height, incc;
	
	width	= 640;
	height	= 480;
	
	incc = 0;

      w = Window("window", Rect(100, 100, width, height)).front;
        
      w.view.background_(Color.black(0.5)); 
        
      w.drawHook = { 
                
            Pen.strokeColor = Color.green;
		Pen.fillColor = Color.black;
            Pen.width = 2;

		Pen.addRect(Rect(0,0,width,height));
		
		Pen.fill;
                
            Pen.addOval(Rect(width/2-(width/8),height/2-(width/8),width/4,width/4));
             
		Pen.stroke; 

		8.do({
			
			|inc|
			
			Pen.fillColor = Color.black;
			
			Pen.addOval(Rect(	(width/2)-5+(cos(2pi*inc/8-(pi/2))*width/8),
								(height/2)-5+(sin(2pi*inc/8-(pi/2))*width/8),
								10,
								10));
								
			Pen.fill;
			
			Pen.addOval(Rect(	(width/2)-5+(cos(2pi*inc/8-(pi/2))*width/8),
								(height/2)-5+(sin(2pi*inc/8-(pi/2))*width/8),
								10,
								10));
								
			Pen.strokeColor = Color.green;
							
			Pen.fillColor = Color.green;
			
			if(inc==incc,{Pen.fill;},{Pen.stroke;});
			
			});

            
                
      };

	fork { while { w.isClosed.not } { defer { w.refresh }; (1/60).wait; } };

	t = TempoClock(140/60).schedAbs(	1,
										{
										
											|beat|
											
											incc = (incc + 1) % 8;
											
											1;
											
										});
        
)
