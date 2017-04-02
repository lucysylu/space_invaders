module space_invaders(
		CLOCK_50,						
      KEY,
		LEDR,
		PS2_DAT,
		PS2_CLK,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);
	
	input CLOCK_50, PS2_DAT, PS2_CLK;
	input [3:0] KEY;
	output reg [4:0]   LEDR;
	output			VGA_CLK;   				//	VGA Clock	
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire writeEn;
	wire [2:0] colour;
	
	wire [8:0] x;
	wire [7:0] y;
	
	wire [8:0] player_x, bullet_x, alien_x;
	wire [7:0] player_y, bullet_y, alien_y;
	wire player_draw, player_erase, bullet_draw, bullet_erase, alien_draw, alien_erase;
	wire [2:0] player_colour, bullet_colour, alien_colour;
	wire player_fin, alien_fin, bullet_fin;
	wire lda, ldb, ldp;
	
	//change to reg with kb input
	wire left, right, reset;
	wire kb_reset = 1'b0;
	wire fire;
	
//	wire collisions, valid; 
//	wire [7:0] user_input;
//	wire makeBreak; 
//	
//	keyboard_press_driver keyboard(
//		.CLOCK_50(CLOCK_50),
//		.valid(valid),
//		.makeBreak(makeBreak),
//		.outCode(user_input),
//		.PS2_DAT(PS2_DAT),
//		.PS2_CLK(PS2_CLK),
//		.reset(kb_reset));
//
//	
//	always @(posedge CLOCK_50)
//	begin
//		reset <= 1'b1;
//		fire <= 1'b0; left <= 1'b0; right = 1'b0;
//		if (user_input == 8'h29 && makeBreak == 1'b1) begin
//			fire <= 1'b1;
//			LEDR[0] <= 1'b1;
//		end
//		else if (user_input == 8'h29 && makeBreak == 1'b0) begin
//			fire <= 1'b0;
//			LEDR[0] <= 1'b0;
//		end
//			
//		else if (user_input == 8'h6B && makeBreak == 1'b1) begin
//			left <= 1'b1;
//			LEDR[1] <= 1'b1;
//		end
//		else if (user_input == 8'h6B && makeBreak == 1'b0) begin
//			left <= 1'b0;
//			LEDR[1] <= 1'b0;
//		end
//		
//		else if (user_input == 8'h74 && makeBreak == 1'b1) begin
//			right <= 1'b1;
//			LEDR[2] <= 1'b1;
//		end
//		else if (user_input == 8'h74 && makeBreak == 1'b0) begin
//			right <= 1'b0;
//			LEDR[2] <= 1'b0;
//		end
//		else if (user_input == 8'h2D && makeBreak == 1'b1) begin
//			reset <= 1'b0;
//			LEDR[3] <= 1'b1;
//		end
//		else if (user_input == 8'h2D && makeBreak == 1'b0) begin
//			reset <= 1'b1;
//			LEDR[3] <= 1'b0;
//		end
//		else LEDR[4:0] = 5'd0;
//	end
	
	assign left = ~KEY[1];
	assign right = ~KEY[0];
	assign reset = KEY[3];
	assign fire = ~KEY[2];
	
	reg [25:0] clock_counter = 25'd0;
	
	always @(posedge CLOCK_50)
	begin
		if(!reset)
			clock_counter <= 25'd0;
		//counts to 1/60th of a second before resetting
		else if(clock_counter == 25'd833333)
			clock_counter <= 25'd0;
		else
			clock_counter <= clock_counter + 1;
	end
	
	assign bullet_draw = (clock_counter == 25'd833333) ? 1 : 0;
	assign bullet_erase = (clock_counter == 25'd833270) ? 1 : 0;
	assign alien_draw = (clock_counter == 25'd833220) ? 1 : 0;
	assign alien_erase = (clock_counter == 25'd833175) ? 1 : 0;
	assign player_draw = (clock_counter == 25'd833100) ? 1 : 0;
	assign player_erase = (clock_counter == 25'd833000) ? 1 : 0;

	
	
	datapath d_main (
			.clk(CLOCK_50),
			.reset(reset),
			.lda(lda),
			.ldb(ldb),
			.ldp(ldp),
			.alienX(alien_x),
			.alienY(alien_y), 
			.alienColour(alien_colour),
			.shipX(player_x),
			.shipY(player_y), 
			.bulletX(bullet_x), 
			.bulletY(bullet_y), 
			.shipColour(player_colour),
			.bulletColour(bullet_colour), 
			.x(x), 
			.y(y), 
			.colour(colour), 
			.writeEn(writeEn));
			
	controller c_main(
			.clk(CLOCK_50),
			.reset(reset), 
			.fire(fire),
			.p_sig(player_erase), 
			.a_sig(alien_erase), 
			.b_sig(bullet_erase), 
			.p_fin(player_fin), 
			.b_fin(bullet_fin), 
			.a_fin(alien_fin),
			.lda(lda), 
			.ldb(ldb), 
			.ldp(ldp));
		
//	vga_adapter VGA(
//			.resetn(reset),
//			.clock(CLOCK_50),
//			.colour(colour),
//			.x(x),
//			.y(y),
//			.plot(writeEn),
//			/* Signals for the DAC to drive the monitor. */
//			.VGA_R(VGA_R),
//			.VGA_G(VGA_G),
//			.VGA_B(VGA_B),
//			.VGA_HS(VGA_HS),
//			.VGA_VS(VGA_VS),
//			.VGA_BLANK(VGA_BLANK_N),
//			.VGA_SYNC(VGA_SYNC_N),
//			.VGA_CLK(VGA_CLK));
//		defparam VGA.RESOLUTION = "320x240";
//		defparam VGA.MONOCHROME = "FALSE";
//		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
//		defparam VGA.BACKGROUND_IMAGE = "black.mif";

	player p1(
			.clk(CLOCK_50), 
			.reset(reset), 
			.draw_signal(player_draw), 
			.erase_signal(player_erase), 
			.left(left), 
			.right(right), 
			.finish(player_fin),
			.x_out(player_x),
			.y_out(player_y),
			.colour(player_colour));
		
	alien a0(
		.clk(CLOCK_50), 
		.reset(reset), 
		.bullet_x(bullet_x),
		.bullet_y(bullet_y),
		.draw_signal(alien_draw), 
		.erase_signal(alien_erase), 
		.finish(alien_fin), 
		.collision(collision),
		.x(alien_x), 
		.y(alien_y), 
		.colour(alien_colour));
		
	reg [8:0] bx;
	reg [7:0] by;
	
	always @(posedge lda)
	begin
		bx <= player_x;
		by <= player_y;
	end
			
	bullet b(
		.clk(CLOCK_50), 
		.reset(reset), 
		.fire(fire),
		.pos_x(bx), 
		.pos_y(by), 
		.clk_draw(bullet_draw), 
		.clk_erase(bullet_erase), 
		.collision(collision), 
		.x(bullet_x), 
		.y(bullet_y), 
		.colour(bullet_colour),
		.finish(bullet_fin));

endmodule

module datapath(clk, reset, lda, ldb, ldp, alienX, alienY, alienColour,
					shipX, shipY, bulletX, bulletY, shipColour, bulletColour, x, y, colour, writeEn);

	input clk, reset, lda, ldb, ldp;
	input [2:0] bulletColour, shipColour, alienColour;
	input [8:0] shipX, bulletX, alienX;
	input [7:0] shipY, bulletY, alienY;
	
	output reg [8:0] x;
	output reg [7:0] y;
	output reg [2:0] colour;
	output reg writeEn = 1'b1;
	
	always @(posedge clk)
	begin
		if (ldp) begin
			x <= shipX;
			y <= shipY;
			colour <= shipColour;
		end
		else if (ldb) begin
			x <= bulletX;
			y <= bulletY;
			colour <= bulletColour;
		end
		else if (lda) begin
			x <= alienX;
			y <= alienY;
			colour <= alienColour;
		end
		
	end 
	
endmodule

module controller(clk, reset, fire, p_sig, a_sig, b_sig, p_fin, b_fin, a_fin, lda, ldb, ldp);
	input clk, reset, fire; 
	input p_sig, a_sig, b_sig, p_fin, b_fin, a_fin;
	
	output reg lda, ldb, ldp;
	
	//FSM state registers
	reg [2:0] current_state, next_state;
	
	localparam LOAD_PLAYER = 3'd0,
					LP_WAIT = 3'd1,
					LOAD_ALIENS = 3'd2,
					LA_WAIT = 3'd3,
					CHECK_BULLET = 3'd4,
					LOAD_BULLET = 3'd5,
					LB_WAIT = 3'd6;

					
		//State table	
		// Draw and erase player, aliens, bullet sequentially
		always @(*)
		begin: state_table
			case(current_state)
				LOAD_PLAYER: next_state = p_sig ? LP_WAIT : LOAD_PLAYER;
				LP_WAIT: next_state = p_fin ?	LOAD_ALIENS : LP_WAIT;
				LOAD_ALIENS: next_state = a_sig ? LA_WAIT : LOAD_ALIENS;
				LA_WAIT: next_state = a_fin ? LOAD_BULLET : LA_WAIT;
				CHECK_BULLET: next_state = fire ? LOAD_BULLET : LOAD_PLAYER;
				LOAD_BULLET: next_state = b_sig ? LB_WAIT : LOAD_BULLET;
				LB_WAIT: next_state = b_fin ? LOAD_PLAYER : LB_WAIT;
				default: next_state = LOAD_PLAYER;
			endcase
		end
					
		always @(*)
		begin
			lda = 1'b0;
			ldb = 1'b0;
			ldp = 1'b0;

			case(current_state)
				LP_WAIT: begin
					ldp = 1'b1;
				end

				LA_WAIT: begin
					lda = 1'b1;
				end

				LB_WAIT: begin
					ldb = 1'b1;
				end
				
			endcase
		end
		
		always@(posedge clk)
		begin: state_FFS
		if(!reset)
			current_state <= LOAD_PLAYER;
		else
			current_state <= next_state;
		end
endmodule


