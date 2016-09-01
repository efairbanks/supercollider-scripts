
(

w = Window.new("Derp", Window.screenBounds, border:true);

w.front;

w.view.background = Color.black;

// --- //

~run = true;

~phase = 0;
        
// --- //

~measures = /*measure list*/[/*measure one*/[/*measure one is seven beats long*/7,[[0,0,[0,2]],[0,3,[1,2]],[1,2,[0,3]]]]];

// --- //

w.drawFunc = {

	var screenXPadding, screenYPadding, screenWidth, screenHeight, linesPerMeasure, measureSizeY, measureSpacing, measureWidth, measureHeight, measuresSize;
	
	screenWidth = w.bounds.width;
	screenHeight = w.bounds.height;
	
	screenXPadding = (1/24)*screenWidth;
	screenYPadding = (1/24)*screenHeight;
	
	measureSpacing = (1/24)*screenHeight;
	
	measureWidth = screenWidth-(screenXPadding*2);
	measureHeight = (((screenHeight-(screenYPadding*2))/~measures.size)-measureSpacing)+(measureSpacing/~measures.size);
	
	linesPerMeasure = 9;
	
	measuresSize = ~measures.size;
	
	// --- //
	
	Pen.use {
	
		Pen.strokeColor = Color.new255(255,255,255,127);
		
		Pen.width = 3;
		
		// --- //
		
		measuresSize.do({
		
			|measureIterator|

			var measureYOffset, measureXOffset;			
			
			measureXOffset = screenXPadding;
			measureYOffset = screenYPadding+((measureHeight+measureSpacing)*measureIterator);
			
			linesPerMeasure.do({
				
				|lineIterator|
				
				var pointX1, pointX2, pointY, lineHeight;
			
				lineHeight = (measureHeight/linesPerMeasure);
			
				pointX1 = measureXOffset;
				pointX2 = measureXOffset+measureWidth;
				
				pointY = measureYOffset+(lineHeight*lineIterator);
				
				Pen.beginPath;
				
				Pen.moveTo(Point(pointX1,pointY));
				
				Pen.lineTo(Point(pointX2,pointY));
				
				Pen.stroke;
							
			});
	
		});

	};
	
};

{ while { ~run } { w.refresh; 0.05.wait; ~phase = ~phase + 0.01pi;} }.fork(AppClock);

)
