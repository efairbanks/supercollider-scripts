
(

~mkvdict = Dictionary();

~mkvtrain = {

	|inarray, depth|
	
	var ringbuf = Array.new(0);
	
	var ringbufindex = 0;
	
	var inarrayindex = 0;
	
	while({ringbuf.size<depth},{
	
		ringbuf = ringbuf.add(inarray[inarrayindex]);
		
		inarrayindex = inarrayindex + 1;
		
	});
	
	while({inarrayindex<inarray.size},{
		
		var keystring = "";
		
		depth.do({
			
			|index|
		
			keystring = keystring ++ ringbuf.wrapAt(ringbufindex-depth+index);
			
		});
		
		if(~mkvdict[keystring]==nil,{
			
			~mkvdict[keystring] = [inarray[inarrayindex]];
			
		},{
			
			~mkvdict[keystring].add(inarray[inarrayindex]);
			
		});
		
		ringbuf.wrapPut(ringbufindex,inarray[inarrayindex]);
		
		ringbufindex = ringbufindex + 1;
		
		inarrayindex = inarrayindex + 1;
		
	});
	
	~mkvdict;
	
};

~mkvgen = {

	|seedarray, depth, items|
	
	var ringbuffer = seedarray;
	
	var returnarray = [];
	
	var generateditem;
	
	var possibilityarray;
	
	items.do({
	
		|itemindex|
	
		var keystring = "";
	
		depth.do({
		
			|depthindex|
			
			keystring = keystring ++ ringbuffer.wrapAt(depthindex+itemindex);
			
		});
		
		possibilityarray = ~mkvdict[keystring];
		
		if(possibilityarray==nil,{
		
			possibilityarray = ~mkvdict.choose;
			
		});
		
		generateditem = possibilityarray.choose;
		
		returnarray = returnarray.add(generateditem);
		
		ringbuffer.wrapPut(itemindex, generateditem);
		
	});
	
	returnarray;
	
};

~mkvinput = [0,1,2,3,4,3,2,1,0,1,2,1,0,-1,0,-1,-2,-4,-2,-1,0,1,0,1,3,2,1,0,1,-1,0,3];

~mkvtrain.(~mkvinput.differentiate, 3);

~play = ~mkvgen.([0,1,2], 3, 32).integrate;



Pbind(\degree, Pseq(~play,1),\dur,1/4).play;

)
