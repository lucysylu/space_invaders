module bullet(clk, reset, fire, pos_x, pos_y, clk_draw, clk_erase, collision, collision_2, collision_3, x, y, colour, finish);
	
	input clk, reset, collision, collision_2, collision_3, clk_draw, clk_erase, fire;
	input [8:0] pos_x;
	input [7:0] pos_y;

	wire draw_signal, erase_signal, ldx, ldy;
	output [2:0] colour;
	output [8:0] x;
	output [7:0] y;
	output finish;
	
	wire [2:0] counter;
	
	datapath_bullet db(
		.clk(clk),
		.reset(reset),
		.collision(collision),
		.collision_2(collision_2),
		.collision_3(collision_3),
		.counter(counter),
		.fire(fire),
		.ldx(ldx),
		.ldy(ldy),
		.draw_signal(clk_draw),
		.erase_signal(clk_erase),
		.x_in(pos_x),
		.y_in(pos_y),
		.colour(colour), 
		.start_draw(draw_signal), 
		.start_erase(erase_signal), 
		.x_out(x), 
		.y_out(y));
		
	controller_bullet cb(
		.clk(clk), 
		.reset(reset), 
		.draw_signal(clk_draw), 
		.erase_signal(clk_erase), 
		.ldx(ldx),
		.ldy(ldy),
		.start_draw(draw_signal), 
		.start_erase(erase_signal),
		.bullet_counter(counter),
		.finish_draw(finish));
		
	
endmodule

module datapath_bullet(clk, reset, collision, collision_2, collision_3, counter, fire, ldx, ldy, draw_signal, erase_signal, x_in, 
				y_in, colour, start_draw, start_erase, x_out, y_out);
	
	//enable signals
	input clk, reset, collision, collision_2, collision_3, fire, ldx, ldy, start_draw, start_erase, draw_signal, erase_signal;
	input [2:0] counter;		
	
	input [8:0] x_in;
	input [7:0] y_in;
	
	reg [8:0] x_inter;
	reg [7:0] y_inter;
	reg quick_erase = 1'b0;
	reg active = 1'b0;
	
	output reg [8:0] x_out;
	output reg [7:0] y_out;
	
	//colour wires
	output reg [2:0] colour;
	
	always @(posedge draw_signal)
	begin
		if (!reset) begin
			x_inter <= x_in - 3'd5;
			y_inter <= y_in - 3'd4;
		end
		if (active == 1'b1) begin
			y_inter <= y_inter - 2'd2;
			if (y_inter < 3'd5 || collision || collision_2 || collision_3) begin
				quick_erase <= 1'b1;
				active <= 1'b0;
			end

		end
		if (fire == 1'b1 && active == 1'b0) begin
			x_inter <= x_in - 3'd5;
			y_inter <= y_in - 3'd4;
			active <= 1'b1;
			quick_erase <= 1'b0;
		end
	end
	
	always @(posedge clk)
	begin
	
			if (!reset) begin
				x_out <= x_inter;
				y_out <= y_inter;
			end
			if (ldx) begin
				x_out <= x_inter;
			end
			if (ldy) begin
				y_out <= y_inter;
			end
			if (start_draw || start_erase)
			begin
				if (start_draw) begin
					colour <= 3'b001;
					x_out <= x_inter + counter[0];
					y_out <= y_inter + counter[2:1];
				end
				if(start_erase || quick_erase) begin
					colour <= 3'b000;
					x_out <= x_inter + counter[0];
					y_out <= y_inter + counter[2:1];
				end
			end
		
	end
endmodule 

module controller_bullet(clk, reset, draw_signal, erase_signal, ldx, ldy, start_draw, start_erase, bullet_counter, finish_draw);
		input clk;
		input reset;
		
		input draw_signal, erase_signal;
		
		//enable signals
		output reg ldx, ldy, start_draw, start_erase;
		output reg [2:0] bullet_counter = 3'd0;
		
		//wires to indicate when its finished drawing
		output reg finish_draw;
		reg finish_erase, start_counter;
		
		//FSM state registers
		reg [2:0] current_state, next_state;
		
		//FSM states
		localparam  LOAD_X_DRAW = 3'd0,
						LOAD_Y_DRAW = 3'd1,
						DRAW_WAIT = 3'd2,
						DRAW = 3'd3,
						LOAD_X_ERASE = 3'd4,
						LOAD_Y_ERASE = 3'd5,
						ERASE_WAIT = 3'd6,
						ERASE = 3'd7;
		//State table			
		always @(*)
		begin: state_table
			case(current_state)
				LOAD_X_DRAW: next_state = draw_signal ? LOAD_Y_DRAW : LOAD_X_DRAW;
				LOAD_Y_DRAW: next_state = DRAW_WAIT;
				DRAW_WAIT: next_state = DRAW;
				DRAW: next_state = erase_signal ? LOAD_X_ERASE : DRAW;
				LOAD_X_ERASE: next_state = LOAD_Y_ERASE;
				LOAD_Y_ERASE: next_state = ERASE_WAIT;
				ERASE_WAIT : next_state = ERASE;
				ERASE: next_state = finish_erase ? LOAD_X_DRAW : ERASE;
				default: next_state = LOAD_X_DRAW;
			endcase
		end
//		
		always @(*)
		begin: enable_signals
			ldx = 1'b0;
			ldy = 1'b0;
			start_draw = 1'b0;
			finish_draw = 1'b0;
			start_erase = 1'b0;
			finish_erase = 1'b0;
			start_counter = 1'b0;
			case(current_state)
				LOAD_X_DRAW: begin
					ldx = 1'b1;
				end
				LOAD_Y_DRAW: begin
					ldy = 1'b1;
				end
				DRAW_WAIT: begin
					start_counter = 1'b1;
				end
				DRAW: begin
					//starts counter and starts drawing
					start_counter = 1'b1;
					//finished drawing
					if(bullet_counter == 3'd6) begin
						start_draw = 1'b0;
						finish_draw = 1'b1;
						start_counter = 1'b0;
					end
					//starts or continues drawing
					else if(!finish_draw)
						start_draw = 1'b1;
				end
				LOAD_X_ERASE: begin
					ldx = 1'b1;
				end
				LOAD_Y_ERASE: begin
					ldy = 1'b1;
				end
				ERASE_WAIT: begin
					start_counter = 1'b1;
				end
				ERASE: begin
					start_counter = 1'b1;
					//starts counter and starts erasing
					//finishes erasing
					if(bullet_counter == 3'd6) begin
						start_erase = 1'b0;
						finish_erase = 1'b1;
						start_counter = 1'b0;
					end
					//starts or continues erasing
					else if(!finish_erase)
						start_erase = 1'b1;
				end
			endcase
		end
		
		
		always @(posedge clk)
		begin
			if (start_counter) begin
				if (bullet_counter == 3'd6)
					bullet_counter <= 3'd0;
				else 
					bullet_counter <= bullet_counter + 1;
			end
		end
		
		//current state registers
		always@(posedge clk)
		begin: state_FFS
		if(!reset)
			current_state <= LOAD_X_DRAW;
		else
			current_state <= next_state;
		end
		
endmodule

