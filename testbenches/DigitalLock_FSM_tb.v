/* Digital lock finite state machine testbench
 * -------------------------
 * ELEC5566M: Assignment 2
 * By: Luke Stock 
 * SID: 201148579
 * Date: 24th March 2022
 *
 * Module Description:
 * -------------------
 * Auto-verifying testbench for finite state machine. 
 */
 
 
 // Create a timescale to indicate units of delay 
 // Here: units = 1 ns; precision = 100 ps. 
 `timescale 1 ns/100 ps
 
 
 // Declare test bench module 
 module DigitalLock_FSM_tb;
 
 // Test bench parameter
 parameter PASSWORD_LENGTH = 4;
 
 // Test bench generated signals 
 reg clock; 
 reg reset;
 reg [3:0] key;
 
 // DUT output signals
 wire lock;
 wire error;
 wire set_password;
 wire input_password;
 wire check_password;
 wire password_correct;
 wire [(4*PASSWORD_LENGTH-1):0] initial_password; 
  
  
  // DUT 
  DigitalLock_FSM DigitalLock_FSM_dut (
 
	.clock               ( clock               ),
	.reset               ( reset               ),
	.key                 ( key                 ),
	.lock 					( lock                ),
	.error               ( error               ),
	.set_password        ( set_password        ),
	.input_password      ( input_password      ),
	.check_password 	   ( check_password      ),
	.password_correct    ( password_correct    ),
	.initial_password    ( initial_password    )

	);
 
 
 localparam NUM_CYCLES = 50;      //Simulate this many clock cycles. Max. 1 billion
 localparam CLOCK_FREQ = 5000000; //Clock frequency (in Hz)
 localparam RST_CYCLES = 2;       //Number of cycles of reset at beginning.

 
 
 // Initialise loop counter value and expected value
 integer i;
 integer j;
 integer random_key;
 
 reg [(4*PASSWORD_LENGTH)-1:0] RandomPasscode;
 
 // Initialise clock to zero.
 initial begin 
 
	clock = 1'b0;
	
 end 
 
 // Toggle clock every 5 ns
 always begin 
 
	#2;
	clock = ~clock;
	
 end

 initial begin 
	
	// Initialise in reset 
	reset_task();
	
	
	if (!error && !lock && !set_password && !input_password) begin 
		
		// Test unlocked state
		$display("Testing UNLOCKED_STATE");
		
		// Test for all buttons pushes
		for (i = 0; i < PASSWORD_LENGTH; i = i + 1) begin
								
			key <= i;
			
			@(posedge clock);
			
			if (key == 4'b0000 && set_password) begin 
			
				$display("ERROR! When no key is pressed state transitions to SET_PASSWORD state. Outputs: error = %b; lock = %b; set_password = %b; initial_password = %b.",
							error, lock, set_password, input_password);
				
				$stop;
				
			end
		
			if (key && !set_password) begin 
					
				$display("ERROR! When a key is pressed state does NOT transition to SET_PASSWORD state. Outputs: error = %b; lock = %b; set_password = %b; initial_password = %b; key = %b.",
							error, lock, set_password, input_password, key);
							
				
			end
			
				
			#10; //Wait 10 units.
		
		end 
	
	end 
	
	
	else if (!error && !lock && set_password) begin 
		
		// Test set password state
		$display("Testing SET_PASSWORD_STATE");
		
		// Generate a random password
		random_password();
				
				
	end
	
	
	$stop;
	
end 

 
 task reset_task();
	begin
		
		// Initialise reset then clear reset 
		reset = 1'b1;
		repeat(RST_CYCLES) @(negedge clock);
		reset = 1'b0;
		
	end  
 endtask
 
 
 task random_password();
 	begin
		
		for (j = 0; j < 4 * PASSWORD_LENGTH; j = j + 4) begin
		
		random_key = $urandom_range(3,0);                                                                      // Generate a random key press
		RandomPasscode[((4 * PASSWORD_LENGTH) - 1) - j -:4] = {{PASSWORD_LENGTH-1{1'b0}}, 1'b1} << random_key; // Store the random key press in the random passcode register by shifitng into MSB 
		
		end	
		
			
	end  
 
 endtask
 
 
 endmodule 