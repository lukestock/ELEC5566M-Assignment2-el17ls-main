/* Digital lock - finite state machine 
 * -------------------------
 * ELEC5566M: Assignment 2
 * By: Luke Stock 
 * SID: 201148579
 * Date: 21st March 2022
 *
 * Module Description:
 * -------------------
 * Finite state machine module for the
 * digital lock sytem, designed for implementation 
 * on a DE1-SoC Development Board.
 */
 
module DigitalLock_FSM #(

	// Declare parameters
	parameter PASSWORD_LENGTH = 4 // Default to 4 Key presses

)(

	input clock,
	input reset, 
	input [3:0] key, 
	
	output reg lock,
	output reg error, 
	output reg set_password,
	output reg input_password,
	output reg check_password,
	output reg password_correct,
	output reg [(4*PASSWORD_LENGTH-1):0] initial_password

);

// Define state-machine definition registers
reg [2:0] state;

// Define password reset value (ZERO)
localparam reset_password = {((4*PASSWORD_LENGTH)-1){1'b0}};

// Define register to hold saved password
reg [(4*PASSWORD_LENGTH-1):0] saved_password;

// Initialise variables
integer key_pressed_counter = 0;
integer input_password_counter = 0;

// Local Parameters used to define state names
localparam LOCKED_STATE = 3'b001;
localparam UNLOCKED_STATE = 3'b010;
localparam SET_PASSWORD_STATE = 3'b011;
localparam INPUT_PASSWORD_STATE = 3'b100;
localparam CHECK_PASSWORD_MATCH_STATE = 3'b101;
localparam CORRECT_PASSWORD_STATE = 3'b110;

// Define the outputs for each state, which are only dependent on the state
always @(state) begin 
	
	// Initialise state outputs
	set_password = 1'b0;
	input_password = 1'b0;
	
	case (state)
	
		LOCKED_STATE: begin  // Lock flagged HIGH
		lock = 1'b1;
		password_correct = 1'b0;
		end
		
		UNLOCKED_STATE: begin  // Lock flagged LOW
		lock = 1'b0;
		password_correct = 1'b0;
		end
		
		SET_PASSWORD_STATE: begin  // Set password flagged HIGH
		set_password = 1'b1;
		end
		
		INPUT_PASSWORD_STATE: begin  // Input password flagged HIGH
		input_password = 1'b1;
		end
		
		CHECK_PASSWORD_MATCH_STATE: begin  // Check password flagged HIGH
		check_password = 1'b1;
		end
		
		CORRECT_PASSWORD_STATE: begin  // Correct password flagged HIGH
		password_correct = 1'b1;
		check_password = 1'b0;
		end
				
	endcase	
end

// State Machine Transitions and Output Generations
always @ (posedge clock or posedge reset) begin

	if (reset) begin 
		
		error = 1'b0;
		state <= UNLOCKED_STATE;
		initial_password <= reset_password; 
		saved_password <= reset_password;
		key_pressed_counter <= 0;
		input_password_counter <= 0;
		
	end else begin	
		case (state)
			
			// Wait in unlocked state until a key is pressed.
			// If in second password is not a match with save_password, 
			// once key has been pressed, reset error flag LOW.
			UNLOCKED_STATE: begin
			
				if (|key) begin 
				
					state <= SET_PASSWORD_STATE;
				
					error <= 1'b0;
					
				end else begin 
				
					state <= UNLOCKED_STATE;
				
				end
					
			end
				
			// Wait in locked state until a key is pressed
			// If password entered is not a match with save_password, 
			// once key has been pressed, reset error flag LOW.
			LOCKED_STATE: begin
				
				if (|key) begin 
				
					state <= SET_PASSWORD_STATE;
					
					error <= 1'b0;
					
				end else begin 
				
					state <= LOCKED_STATE;
				
				end
			end

			
			SET_PASSWORD_STATE: begin
				
				// If previously in UNLOCKED_STATE 
				if (lock == 1'b0) begin
				
					// Whilst number of keys pressed is less than max password length 
					// add the key value to the LSB of initial password. This sets 
					// the password created from key button inputs.
					if (key_pressed_counter < PASSWORD_LENGTH) begin
						
						// If a key is pressed pass value into initial password
						if (|key) begin
							
							initial_password[(4*PASSWORD_LENGTH) - 1 - (4*key_pressed_counter) -: 4] <= key;
							key_pressed_counter <= key_pressed_counter + 1;
						
						// If no key is pressed, remain in SET_PASSWORD_STATE until key is pressed
						end else begin 
						
							state <= SET_PASSWORD_STATE;
							
						end
					
					// Set the password to user key input when amount of key values
					// pressed is equal to the password length
					end else if (key_pressed_counter >= PASSWORD_LENGTH) begin
							
						// If password password has been set: store initial password, reset
						// reset initial password to read in a second time and compare it 
						// to check it if has been entered correctly to enter locked state.
						if (input_password_counter == 0) begin 
								
							state <= UNLOCKED_STATE;
										
							saved_password <= initial_password;
							initial_password <= reset_password;
							input_password_counter <= input_password_counter + 1;				
							key_pressed_counter <= 0;
							
						// If password has been entered for a second time check if it 
						// matches set passowrd to enter locked state.
						end else begin 
							
							input_password_counter = 0;
							
							state <= CHECK_PASSWORD_MATCH_STATE;
															
						end
					end 
					
					
				// If previously in LOCKED_STATE
				end else if (lock == 1'b1)  begin 
				
					// Whilst number of keys pressed is less than max password length 
					// add the key value to the LSB of initial password. This sets 
					// the password created from key button inputs.
					if (key_pressed_counter < PASSWORD_LENGTH) begin
					
						if (|key) begin
							
							initial_password[(4*PASSWORD_LENGTH) - 1 - (4*key_pressed_counter) -: 4] <= key;
							key_pressed_counter <= key_pressed_counter + 1;
						
						end 
					
					// Check the password to user key input when amount of key values
					// pressed is equal to the password length
					end else begin
							
							state <= INPUT_PASSWORD_STATE;
							
							key_pressed_counter <= 0;
							
						end 
					
					// Else stay in locked state
					end 
					
				end
			
			INPUT_PASSWORD_STATE: begin
				
				if (initial_password == saved_password) begin 
					
					state <= CORRECT_PASSWORD_STATE;
									
				end else if (initial_password != saved_password) begin 
								
					state <= LOCKED_STATE;
					
					error <= 1'b1;
					initial_password <= reset_password;
				
				end
				
			end 
			
			CHECK_PASSWORD_MATCH_STATE: begin
			
				if (lock == 1'b0) begin 
				
					if (initial_password == saved_password) begin 
						
						state <= CORRECT_PASSWORD_STATE;
										
					end else if (initial_password != saved_password) begin 
									
						state <= UNLOCKED_STATE;
						
						error <= 1'b1;
						initial_password <= reset_password;
					
					end
					
				end
				
				if (lock == 1'b1) begin 
				
					if (initial_password == saved_password) begin 
						
						state <= CORRECT_PASSWORD_STATE;
										
					end else if (initial_password != saved_password) begin 
									
						state <= LOCKED_STATE;
						
						error <= 1'b1;
						initial_password <= reset_password;
					
					end
					
				end
				
			end 
			
			CORRECT_PASSWORD_STATE: begin
			
				if (lock == 1'b0) begin 
				
					// If repeated password matches initial password transition to LOCKED state
					// and reset input password counter to 0.
					state <= LOCKED_STATE; 
					
					input_password_counter <= 0;
					initial_password <= reset_password;
					key_pressed_counter <= 0;
				
				end else if (lock == 1'b1) begin 
				
					// If repeated password matches initial password transition to UNLOCKED state
					// and reset input password counter to 0.
					state <= UNLOCKED_STATE; 
					
					input_password_counter <= 0;
					initial_password <= reset_password;
					saved_password <= reset_password;
					key_pressed_counter <= 0;
											
				end
				
			end 
			
		endcase
	
	end 
	
end 

						
endmodule 