


/* TODO:
 *
 * * Store knob/xypad values and continuous knob increments
 * * Store relative values for knob/xypad values and update them during decayButtonStates()
 * * Add button value for xypad press
 *
 */

// --- Dat class --- //

(

~pks = nil; // Keepin' it fresh!

~padKONTROL = {

	// pks = PadKONTROL Singleton

	|message|

	if(~pks==nil,{

		MIDIClient.init;

		~pks = (

			sysexSend: MIDIOut.new(MIDIClient.destinations.indexOf(MIDIOut.findPort("padKONTROL", "CTRL"))),
			sysexRecv: MIDIIn.connect(0,MIDIClient.sources.indexOf(MIDIIn.findPort("padKONTROL", "PORT A"))),

			start: {

				|self|

				var startString = [0xF0, 0x42, 0x40, 0x6E, 0x08, 0x00, 0x00, 0x01, 0xF7,0xF0, 0x42, 0x40, 0x6E, 0x08, 0x3F, 0x2A, 0x00, 0x00, 0x05, 0x05, 0x05, 0x7F, 0x7E, 0x7F, 0x7F, 0x03, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0d, 0x0E, 0x0F, 0x10, 0xF7,0xF0,0x42,0x40,0x6E,0x08,0x3F,0x0A,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x29,0x29,0x29,0xF7];

				self.sysexSend.sysex(Int8Array.newFrom(startString));

				self.sysexRecv.sysex = {




					|src, sysex|

					self.sysexRecvHandler(src, sysex);

				};



			},

			sysexRecvHandler: {

				|self, src, sysex|




				sysex[5].switch(

					0x45,{	[\pad,(sysex[6]%64),(sysex[6]/64).round].postln;

						self.buttonStates[sysex[6]%64] = if((sysex[6]/64).round==0,{\released},{\pressed});

					},

					0x49,{	[\knob,sysex[6],sysex[7]].postln;},

					0x43,{	[\rotary,sysex[7]].postln;},

					0x48,{
						[\button,sysex[6],sysex[7]/127].postln;
						self.label2index.findKeyForValue(sysex[6]+16).postln;

						self.buttonStates[sysex[6]+16] = if((sysex[7]/127).round==0,{\released},{\pressed});

					},

					0x4b,{[\x,sysex[6],\y,sysex[7]].postln;}

				);



			},

			label2index: (




				0: 0,
				1: 1,
				2: 2,
				3: 3,
				4: 4,
				5: 5,
				6: 6,
				7: 7,
				8: 8,
				9: 9,
				10: 10,
				11: 11,
				12: 12,
				13: 13,
				14: 14,
				15: 15,
				scene: 16,
				message: 17,
				setting: 18,
				note: 19,
				midich: 20,
				swtype: 21,
				relval: 22,
				velocity: 23,
				port: 24,
				fixedvelocity: 25,
				progchange: 26,
				x: 27,
				y: 28,
				knob1: 29,
				knob2: 30,
				pedal: 31,
				roll: 32,
				flam: 33,
				hold: 34

			),

			lightState: {

				|self, name, state|

				self.lightStates[self.label2index[name]] = state;

			},

			decayButtonStates: { // call after one input "frame" (after checking button states)

				|self|

				self.buttonStates.do({

					|value, i|

					if(value == \released,{
						self.buttonStates[i] = nil;
					});

					if(value == \pressed,{
						self.buttonStates[i] = \held;
					});

				});

			},

			buttonState: {

				|self, nameOrPadIndex|

				var state = self.buttonStates[self.label2index[nameOrPadIndex]];

				state;

			},

			states2sysex: {

				|self, states, numberarray|

				var hexarray, numvalues;

				numvalues = (states.size/7).asInteger;

				hexarray = 0!numvalues;

				numvalues.do({ |valueiter|

					7.do({ |bititer|

						hexarray[valueiter] = states[valueiter*7+bititer]*(1<<bititer) + hexarray[valueiter];

					});

				});

				hexarray++[0x00]++(numberarray.reverse);

			},

			sendSysex: {

				|self, hexvals|

				var sendString = [0xF0,0x42,0x40,0x6E,0x08,0x3F,0x0A,0x01]++hexvals++[0xF7];

				self.sysexSend.sysex(Int8Array.newFrom(sendString));

			},

			lightStates: (1!16)++(0!19),
			numberStates: [0x32,0x32,0x32],
			buttonStates: (nil!35),

			setLights: {

				|self|

				self.sendSysex(self.states2sysex(self.lightStates, self.numberStates));

			}

		);

		// --- end class --- //



	});

	// --- //

	~pks;

};

"padKONTROLclassInterface loaded!".postln;

)
/*
// --- Lets use it! --- //

(

// --- All systems engage --- //

~padKONTROL.().start();

// --- One, two, three! --- //

~padKONTROL.().numberStates = [0x31,0x32,0x33];

// --- Checkerboard it! --- //

16.do({

	|inc|

	if(inc%2==1,{

		~padKONTROL.().lightState(inc, if((inc/4).asInteger%2==0,{0},{1}));

	},{

		~padKONTROL.().lightState(inc, if((inc/4).asInteger%2==1,{0},{1}));

	});

});

// --- Set it & forget it! --- //

~padKONTROL.().lightState(\setting, 1);

// --- Send it over! --- //

~padKONTROL.().setLights();

)

// --- Draw some pads! --- //

(

w = Window.new("Derp", Rect(100,100,640,480), border:true);

w.front;

w.view.background_(Color.black);

w.drawFunc = {



	var xoff, yoff, width, height, height2;

	width = w.bounds.width;
	height = w.bounds.height*9/10;
	height2 = w.bounds.height/10;

	Pen.strokeColor = Color.white;

	// --- Draw non-pad buttons --- //

	19.do({

		|i|

		var iter = i+16;

		if(~padKONTROL.().buttonStates[iter]==nil,{Pen.fillColor = Color.black;});
		if(~padKONTROL.().buttonStates[iter]==\held,{Pen.fillColor = Color.green;});
		if(~padKONTROL.().buttonStates[iter]==\released,{Pen.fillColor = Color.red;});
		if(~padKONTROL.().buttonStates[iter]==\pressed,{Pen.fillColor = Color.blue;});

		Pen.fillRect(Rect(i*width/19,0,width/19,height2));
		Pen.strokeRect(Rect(i*width/19,0,width/19,height2));

	});

	// --- Draw pads --- //

	16.do({

		|iter|

		var x, y;

		x = iter%4;

		y = (iter/4).asInteger;

		if(~padKONTROL.().buttonState(iter)==nil,{Pen.fillColor = Color.black;});
		if(~padKONTROL.().buttonState(iter)==\held,{Pen.fillColor = Color.green;});
		if(~padKONTROL.().buttonState(iter)==\released,{Pen.fillColor = Color.red;});
		if(~padKONTROL.().buttonState(iter)==\pressed,{Pen.fillColor = Color.blue;});

		Pen.fillRect(Rect(x*width/4,y*height/4+height2,width/4,height/4));
		Pen.strokeRect(Rect(x*width/4,y*height/4+height2,width/4,height/4));

	});

	// --- Set PadKONTROL light states to reflect button status --- //

	~padKONTROL.().buttonStates.do({

		|val, i|

		if(val!=nil,{~padKONTROL.().lightStates[i]=1;},{~padKONTROL.().lightStates[i]=0;});

	});

	// --- Send light states and tick buttons so that pressed/held/released values are relevant --- //

	~padKONTROL.().setLights();

	~padKONTROL.().decayButtonStates();

};

AppClock.sched(0.0,{w.refresh;1/5;});



)
*/