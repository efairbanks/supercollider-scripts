{SinOsc.ar(45,(MouseX.kr(0,1)*Saw.ar(45*32,5)),1000).tanh!2}.play;
"https://www.youtube.com/watch?v=hR6Ghj0FVdI&app=desktop".postln;

{SinOsc.ar(1,0,1,1)>1}.scope;