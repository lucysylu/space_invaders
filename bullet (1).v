module bullet(clk, reset, pos_x, pos_y, draw_signal, erase_signal, collision, x, y, colour);
	
	input clk, reset, collision, draw_signal, erase_signal;
	input [8:0] pos_x;
	input [7:0] pos_y;

	reg wire [8:0] pos_x;
	reg wire [7:0] pos_y;
	
	output wire [2:0] colour;
	output wire [8:0] x;
	output wire [7:0] y;

	
	datapath_bullet(
		.clk(clk),
		.reset(reset),
		.ld_b(ldb), 
		.x_in(pos_x),
		.y_in(pos_y),
		.colour(colour), 
		.draw(draw_signal), 
		.erase(erase_signal), 
		.x_out(x), 
		.y_out(y));
		
	controller_bullet(
		.
		
	
endmodule

module datapath_bullet(clk, reset,ld_b, x_in, y_in, colour, draw, erase, x_out, y_out);
	
	//enable signals
	input clk, reset, ld_b, draw, erase;
	
	input reg [8:0] x_in;
	input reg [7:0] y_in;
	
	output reg [8:0] x_out;
	output reg [7:0] y_out;
	
	//colour wires
	output reg [2:0] colour;
	reg [2:0] offset = 3'd6;	
	reg [2:0] bulletpos;

	//Drawing the ships
	always @(posedge clk)
	begin
			finish = 1'b0;
			if (!reset) begin
				//TODO: add x-offset so bullet is coming from middle & top of player
				x_in <= x_in + 3'd5;
				y_in <= y_in + 1'd1;
				pos = 3'b00;
			end
			if (ld_b) begin
				x_in <= x_in;
				if ((y_in + offset) > 244)
					y_in <= y_in;
				else y_in <= y_in + offset;
				bulletpos = 3'b000;
			end
			if (draw)
				colour <= 3'b101;
			if(erase)
				colour <= 3'b000;
			if (draw || erase)
			begin
				x_out = x_in + bulletpos[0];
				y_out = y_in + bulletpos[2:1];
				if (bulletpos != 3'b111)
					bulletpos <= bulletpos + 1'b1;

			end
		
	end
endmodule 

module controller_bullet(clk, reset, draw_signal, erase_signal, ld_bullet, draw, erase, counter);
		input clk;
		input reset;
		
		input draw_signal, erase_signal;
		
		output reg ld_bullet, draw, erase;
		
		//wires to indicate when its finished drawing
		reg finish_draw, finish_erase, start_counter, start_bullet;
		
		output reg [2:0] bullet_counter = 3'd0;
		
		//FSM state registers
		reg [1:0] current_state, next_state;
		
		//FSM states
		localparam  LOAD = 2'd0,
						DRAW = 2'd1,
						ERASE = 2'd2;
		//State table			
		always @(*)
		begin: state_table
			case(current_state)
				LOAD: next_state = draw_signal ? DRAW: LOAD;
				DRAW: next_state = erase_signal ? ERASE : DRAW;
				ERASE: next_state = finish_erase ? LOAD : ERASE;

				default: next_state = LOAD;
			endcase
		end
		
		//Output Logic (datapath)
		always @(*)
		begin
			start_draw = 1'b0;
			finish_draw = 1'b0;
			start_erase = 1'b0;
			finish_erase = 1'b0;
			start_counter = 1'b0;
			case(current_state)

				LOAD: begin
					ld_bullet = 1'b1;
				end
				DRAW: begin
					start_bullet = 1'b1;
					if (bullet_counter == 3'd4) begin
						start_bullet = 1'b0;
						finish_db = 1'b1;
					end
					else if (!finish_db)
						bullet_draw = 1'b1;
				end
				ERASE: begin
					start_bullet = 1'b1;
					if (bullet_counter == 3'd4) begin
						start_bullet = 1'b0;
						finish_eb = 1'b1;
					end
					else if (!finish_eb)
						bullet_draw = 1'b1;
				end
			endcase
		end
		
		//counter used to draw the player sprite
		always @(posedge clk)
		begin
			if (start_bullet) begin
				if (bullet_counter == 3'd4)
					bullet_counter <= 3'd0;
				else 
					bullet_counter <= bullet_counter + 1;
			end
		end
		
		//current state registers
		always@(posedge clk)
		begin: state_FFS
		if(!reset)
			current_state <= LOAD;
		else
			current_state <= next_state;
		end
		
endmodule

