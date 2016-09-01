
(

i = 15;

~beat = 0;

t = TempoClock(160/60).sched(0,

	{
		
		(instrument:\leads,freq: 440*(i/10)/2).play;
		
		if(~beat%2==0,{(instrument:\leads,freq:440*(i/10)/16).play;1.postln;});
		
		if(~beat%3==0,{(instrument:\leads,freq:440*(i/10)/8).play;1.postln;});
		
		i = i + [0,4,4,-4,-4,2,2,2,2,-2,-2,-2,-2,-1,1].choose;
		
		if(~beat%8==0,{i=15});
		
		if(~beat%16==0,{i=12});
		
		if(3.rand==0,{
			
			t.sched(0.76,{(instrument:\leads,freq: 440*(i+([-2,2].choose)/10)/2).play;
			
		})});
		
		if(i<10,{i=11});
		if(i>20,{i=19});
		
		~beat = ~beat + 1;
		
		1.5;
		
	});
	
)