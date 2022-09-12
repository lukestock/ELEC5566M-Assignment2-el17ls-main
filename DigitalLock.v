/* Finite state machine digital lock
 * -------------------------
 * ELEC5566M: Assignment 2
 * By: Luke Stock 
 * SID: 201148579
 * Date: 9th March 2022
 *
 * Module Description:
 * -------------------
 * Top level module for a finite state machine 
 * digital lock sytem, designed for implementation 
 * on a DE1-SoC Development Board.
 */
module DigitalLock #(
	// Declare parameters
	parameter PASSWORD_LENGTH = 4 // Default to 4 Key presses

)(
	// Declare inputs
	input clock,        // Clock 
	input reset,        // Reset
	input [3:0] key,    // Key input to enter password
	output locked,      // Lock - locked when HIGH, unlocked when LOW
	output error        // Error - flags HIGH when password entered is incorrect

);

// Declare internal connections between sub-modules 
wire [3:0] posedge_key;

// Instantiate key pressed sub-module to read in when key is pressed
// and output the key on rising 
KeyPressed KeyOutput (
	.clock               ( clock             ),
	.key                 ( key               ),
	.key_pressed_posedge ( posedge_key       )
);

// Instantiate finite state machine sub-module to receive a key pressed
// signal, function the lock state and return a password

DigitalLock_FSM  #(

	.PASSWORD_LENGTH      ( PASSWORD_LENGTH   )
	
) digitallock_fsm (
	
	 
	.clock               ( clock            ),         
	.reset               ( reset            ),     
	.key                 ( posedge_key      ),     
	
	.lock                ( lock             ),     
	.error               ( error            ),     
	.set_password        ( set_password     ),     
	.input_password      ( input_password   ),     
	.check_password      ( check_password   ),     
	.password_correct    ( password_correct ),     
	.initial_password    ( initial_password )

);

endmodule 