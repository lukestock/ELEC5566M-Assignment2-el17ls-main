/* Key pressed testbench
 * -------------------------
 * ELEC5566M: Assignment 2
 * By: Luke Stock 
 * SID: 201148579
 * Date: 20th March 2022
 *
 * Module Description:
 * -------------------
 * Auto-verifying testbench for key buttons pressed. 
 */
 
 
 // Create a timescale to indicate units of delay 
 // Here: units = 1 ns; precision = 100 ps. 
 `timescale 1 ns/100 ps
 
 
 // Declare test bench module 
 module KeyPressed_tb;
 
 
 // Test bench generated signals 
 reg clock; 
 reg [3:0] key;
 
 
 // DUT output signals
 wire [3:0] key_pressed_posedge; 
  
  
 // DUT 
 KeyPressed keypressed_dut (
	.clock               ( clock               ),
	.key                 ( key                 ),
	.key_pressed_posedge ( key_pressed_posedge )
  );
 
 
 // Initialise loop counter value and expected value
integer i;
wire [3:0] expected_value;  


 // Initialise clock to zero.
 initial begin 
 
	clock = 1'b0;
	
 end 
 
 // Toggle clock every 5 ns
always begin 

	#5;
	clock = ~clock;
	
end

// Loop through and assign all values (0000 to 1111) to the key to verify output 
always begin 

	for (i = 0; i < 16; i = i + 1) begin
		 key <= i;
		#10; //Wait 10 units.
	end 
	
	$stop;
	
end 


// Assign expected value output
assign expected_value = i;


always @ (posedge clock) begin 

	if ( expected_value != key_pressed_posedge ) begin // If DUT ouput doesn't match expected output 
		$display("Error when i=%b. Actual ouput = %b. Expected output = %b", key, 
					key_pressed_posedge, expected_value); // Prints error message
	end
	
end 

endmodule 
	