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
	
	wire [8:0] player_x, bullet_x, alien_x, alien_x_2, alien_x_3;
	wire [7:0] player_y, bullet_y, alien_y, alien_y_2, alien_y_3;
	wire player_draw, player_erase, bullet_draw, bullet_erase, alien_draw_1, alien_erase_1, alien_draw_2, alien_erase_2, alien_draw_3, alien_erase_3;
	wire [2:0] player_colour, bullet_colour, alien_colour, alien_colour_2, alien_colour_3;
	wire player_fin, alien_fin_1, alien_fin_2, alien_fin_3, bullet_fin;
	wire lda, lda_2, lda_3, ldb, ldp;
	
	//change to reg with kb input
	wire left, right, reset;
	wire kb_reset = 1'b0;
	wire fire;
	
<<<<<<< HEAD
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
=======
	wire collision, collision_2, collision_3, valid; 
	wire [7:0] user_input;
	wire makeBreak; 
	
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
//	//keyboard inputs
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
	assign alien_draw_3 = (clock_counter == 25'd833220) ? 1 : 0;
	assign alien_erase_3 = (clock_counter == 25'd833175) ? 1 : 0;
	assign alien_draw_2 = (clock_counter == 25'd833100) ? 1 : 0;
	assign alien_erase_2 = (clock_counter == 25'd833000) ? 1 : 0;
	assign alien_draw_1 = (clock_counter == 25'd832900) ? 1 : 0;
	assign alien_erase_1 = (clock_counter == 25'd832800) ? 1 : 0;
	assign player_draw = (clock_counter == 25'd832700) ? 1 : 0;
	assign player_erase = (clock_counter == 25'd832600) ? 1 : 0;

	
	
	datapath d_main (
			.clk(CLOCK_50),
			.reset(reset),
			.lda(lda),
			.lda_2(lda_2),
			.lda_3(lda_3),
			.ldb(ldb),
			.ldp(ldp),
			.alienX(alien_x),
			.alienY(alien_y),
			.alienX_2(alien_x_2),
			.alienY_2(alien_y_2), 
			.alienX_3(alien_x_3),
			.alienY_3(alien_y_3), 	
			.alienColour(alien_colour),
			.alienColour_2(alien_colour_2),
			.alienColour_3(alien_colour_3),
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
			.a_sig_1(alien_erase_1),
			.a_sig_2(alien_erase_2),
			.a_sig_3(alien_erase_3),	
			.b_sig(bullet_erase), 
			.p_fin(player_fin), 
			.b_fin(bullet_fin),
			.a_fin_1(alien_fin_1),
			.a_fin_2(alien_fin_2),
			.a_fin_3(alien_fin_3),
			.lda(lda), 
			.lda_2(lda_2), 
			.lda_3(lda_3), 
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
		.draw_signal(alien_draw_3), 
		.erase_signal(alien_erase_3), 
		.finish(alien_fin_3), 
		.collision(collision),
		.x(alien_x), 
		.y(alien_y), 
		.colour(alien_colour));
	
	alien_2 a2(
		.clk(CLOCK_50), 
		.reset(reset), 
		.bullet_x(bullet_x),
		.bullet_y(bullet_y),
		.draw_signal(alien_draw_2), 
		.erase_signal(alien_erase_2), 
		.finish(alien_fin_2), 
		.collision(collision_2),
		.x(alien_x_2), 
		.y(alien_y_2), 
		.colour(alien_colour_2));
		
	alien_3 a3(
		.clk(CLOCK_50), 
		.reset(reset), 
		.bullet_x(bullet_x),
		.bullet_y(bullet_y),
		.draw_signal(alien_draw_1), 
		.erase_signal(alien_erase_1), 
		.finish(alien_fin_1), 
		.collision(collision_3),
		.x(alien_x_3), 
		.y(alien_y_3), 
		.colour(alien_colour_3));
		
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
		.collision_2(collision_2), 
		.collision_3(collision_3), 
		.x(bullet_x), 
		.y(bullet_y), 
		.colour(bullet_colour),
		.finish(bullet_fin));

endmodule

module datapath(clk, reset, lda, lda_2, lda_3, ldb, ldp, alienX, alienY, alienX_2, alienY_2, alienX_3, alienY_3, alienColour, alienColour_2, alienColour_3,
					shipX, shipY, bulletX, bulletY, shipColour, bulletColour, x, y, colour, writeEn);

	input clk, reset, lda, lda_2, lda_3, ldb, ldp;
	input [2:0] bulletColour, shipColour, alienColour, alienColour_2, alienColour_3;
	input [8:0] shipX, bulletX, alienX, alienX_2, alienX_3;
	input [7:0] shipY, bulletY, alienY, alienY_2, alienY_3;
	
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
		else if (lda_2) begin
			x <= alienX_2;
			y <= alienY_2;
			colour <= alienColour_2;
		end
		else if (lda_3) begin
			x <= alienX_3;
			y <= alienY_3;
			colour <= alienColour_3;
		endh
		
	end 
	
endmodule

module controller(clk, reset, fire, p_sig, a_sig_1, a_sig_2, a_sig_3, b_sig, p_fin, b_fin, a_fin_1, a_fin_2, a_fin_3, lda, lda_2, lda_3, ldb, ldp);
	input clk, reset, fire; 
	input p_sig, a_sig_1, a_sig_2, a_sig_3, b_sig, p_fin, b_fin, a_fin_1, a_fin_2, a_fin_3;
	
	output reg lda, lda_2, lda_3, ldb, ldp;
	
	//FSM state registers
	reg [3:0] current_state, next_state;
	
	localparam LOAD_PLAYER = 4'd0,
					LP_WAIT = 4'd1,
					LOAD_ALIENS_1 = 4'd2,
					LA_WAIT_1 = 4'd3,
					LOAD_ALIENS_2 = 4'd4,
					LA_WAIT_2 = 4'd5,
					LOAD_ALIENS_3 = 4'd6,
					LA_WAIT_3 = 4'd7,
					CHECK_BULLET = 4'd8,
					LOAD_BULLET = 4'd9,
					LB_WAIT = 4'd10;

					
		//State table	
		// Draw and erase player, aliens, bullet sequentially
		always @(*)
		begin: state_table
			case(current_state)
				LOAD_PLAYER: next_state = p_sig ? LP_WAIT : LOAD_PLAYER;
				LP_WAIT: next_state = p_fin ?	LOAD_ALIENS_1 : LP_WAIT;
				LOAD_ALIENS_1: next_state = a_sig_1 ? LA_WAIT_1 : LOAD_ALIENS_1;
				LA_WAIT_1: next_state = a_fin_1 ? LOAD_ALIENS_2 : LA_WAIT_1;
				LOAD_ALIENS_2: next_state = a_sig_2 ? LA_WAIT_2 : LOAD_ALIENS_2;
				LA_WAIT_2: next_state = a_fin_2 ? LOAD_ALIENS_3 : LA_WAIT_2;
				LOAD_ALIENS_3: next_state = a_sig_3 ? LA_WAIT_3 : LOAD_ALIENS_3;
				LA_WAIT_3: next_state = a_fin_3 ? LOAD_BULLET : LA_WAIT_3;
				CHECK_BULLET: next_state = fire ? LOAD_BULLET : LOAD_PLAYER;
				LOAD_BULLET: next_state = b_sig ? LB_WAIT : LOAD_BULLET;
				LB_WAIT: next_state = b_fin ? LOAD_PLAYER : LB_WAIT;
				default: next_state = LOAD_PLAYER;
			endcase
		end
					
		always @(*)
		begin
			lda = 1'b0;
			lda_2 = 1'b0;
			lda_3 = 1'b0;
			ldb = 1'b0;
			ldp = 1'b0;

			case(current_state)
				LP_WAIT: begin
					ldp = 1'b1;
				end

				LA_WAIT_1: begin
					lda = 1'b1;
				end

				LA_WAIT_2: begin
					lda_2 = 1'b1;
				end
				
				LA_WAIT_3: begin
					lda_3 = 1'b1;
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



