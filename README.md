# talkBox
https://gfycat.com/ReliablePossibleAmbushbug

A library for doing simple speech boxes a la games like Undertale.  
It does a lot of font related calculations for you, so you never have overspill outside a region, regardless of size or type of font.
As well, line breaks are made before a word is typed, rather than as the text is being added.

Simply add talkBox.lua to your project and import "talkBox"


Then call talkBox.set(font, blurbList, textSpeed, sound), which sets and loads up the talkBox

--font - The font to print in.  I reccomend setting the line height to be a bit tighter than the default (e.g. myFont:setLineHeight(.8)).

--blurbList - A list of strings to print.  You'll need to hit continue to move on to the next string in the list, and any string that is 
              too long and goes outside the box will also be split up.

--textSpeed - How many ticks before another character is added to the talkBox

--sound(optional) - The sound to be played every time a characted is added

After that call talkBox.update(continue, skip)

--continue - A boolean, if true and the box is finished/filled up, will move onto the next blurb/remainder of the string.

--skip - A boolean, if true it will fill up the talkBox but not go past until continue is true.

Finally in the draw section call talkBox.draw(x, y, width, height)

--x,y - the top left corner of the box

--width - the width of the box

--height - the height of the box

note: update and draw should be used in conjunction, or if anything, draw should be used first, as the width and height used in draw
      are important for calculations in update.  As well, varying the width and height during animation is not reccomended.
      



Two more functions let you grab some useful information of the talkBox for syncing up animations

talkBox.isBusy() returns whether or not the box is still busy adding characters.

talkBox.blurbNumber() returns which blurb the talkBox is currently holding.
