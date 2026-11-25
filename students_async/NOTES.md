# NOTES

## Level 1: event order
Predicted: A, C, (first frame), B, 6 students
Actual:    A, C, (first frame), B, 6 students
Unhandled exception line:
Unhandled Exception: Instance of 'NoConnectionException'
sleep(): first frame delayed 2 s, because the loop was blocked, not waiting.

## Level 2
First line of the error without mounted guards:
setState() called after dispose(): <paste your exact line>

## Level 4
Version B WITH cancel(): console stopped at tick 7 after Back.
Version B WITHOUT cancel(): setState() called after dispose(), and tick 6..0
kept printing with nobody on screen (leak).
Version A: console stopped at tick 7, StreamBuilder cancelled for me.

## Level 5
Un-awaited save: the second tap popped the screen as if it worked, and the
console showed "Unhandled Exception: Bad state: server rejected 6".
The user saw a success.