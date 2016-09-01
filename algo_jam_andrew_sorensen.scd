

(

d = Dictionary.new();

n = 0;

d[0] = [2,4,3];
d[1] = [3,2];
d[2] = [1,3,4,6];
d[3] = [4,5];
d[4] = [5,6,1];
d[5] = [1,3,4];
d[6] = [4,5];

t = TempoClock.new(4/5);

t.sched(0,{
	
	|beat|
	
	var oldn = n;
	
	var degree = d[n].choose;
	
	var chord = (beat.asInteger%3).switch(
	
		0,{[0,2,4]},
		1,{[2,4,7]},
		2,{[4,7,9]-7}) - 7;
	
	degree.postln;
	
	if( beat.asInteger%8 == 0, {n=0;degree=0;});
	
	(degree: degree - 14).play;
	
	(degree: degree +.t chord).play;
	
	t.sched(0.5,{(degree: degree + (2.rand*2+2)).play;});
	
	if(rrand(0.0,1.0)>(3/5),{t.sched(0.75,{(degree: degree + (2.rand*2),amp:0.04).play;});});
	
	n = degree;
	
	d[oldn] = d[oldn] ++ degree;
	
	1;
	
	});

)