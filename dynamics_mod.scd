

(

t = TempoClock(2);

d = 0;

t.sched(0,{
	
	|beat|
	
	var degree = d;
	
	var amp = sin((beat%4)*2*pi/4+(pi/2))+1/4+0.5/10;
	
	(degree: degree +.t [7,2,4], amp: amp).play;
	
	1;
	
	});

)