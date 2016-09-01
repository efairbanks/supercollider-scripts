
(

~expand = {
	
	|array,slots|
	
	var n = Array.new(array.size);
	
	array.size.do({
	
		|inc|
	
		n = n ++ (Array.new().add(Array.new().add(array[inc])));
		
	});
	
	n;
	
	while(
	
		{slots>0},
	
		{
			if(	slots>=array.size,
			
				{
			
					array.size.do({
				
						|inc|
						
						a[inc] = a[inc] ++ Array.new().add(0);
						
						slots = slots - 1;
					
					});
				
				},
				
				{
				
					slots.do({
					
						|inc|
						
						// do something
						
					});
				
				});
				
		});
	
};

~expand.value([1,0,0,0],8);

)