/* Key pressed
 * -------------------------
 * ELEC5566M: Assignment 2
 * By: Luke Stock 
 * SID: 201148579
 * Date: 11th March 2022
 *
 * Module Description:
 * -------------------
 * Module for key buttons pressed. 
 * Ensures key button is not held high after 
 * being released. 
 */
module KeyPressed (
	// Declare inputs
	input clock,                 // Clock 
	input [3:0] key,             // Key input to enter password
	output [3:0] key_pressed_posedge  // Key output on posedge

);

reg signal_delay;                

always @( posedge clock ) begin // At the rising edge of the clock
	
	signal_delay <= key;         // Delay the signal by 1 clock cycle  
    
end

// The output (key_pressed) gets passed the key value when 
// a button is pressed and remains HIGH for 1 clock cyle. 
// After 1 clock cycle the output is cleared and returns 
// LOW when the delay signal transitions

assign key_pressed_edge = key & ~(signal_delay);

endmodule 