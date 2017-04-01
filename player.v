module player(clk, reset, draw_signal, erase_signal, left, right, finish, x_out, y_out, colour);

	input clk, reset, left, right;
	input draw_signal, erase_signal;
	wire start_draw, start_erase;
	output [2:0] colour;
	output finish;
	wire ldx, ldy;
	wire [5:0] counter;
	output [8:0] x_out;
	output [7:0] y_out;
	
	
	//datapath
	datapath_ship d0(
				.clk(clk),
				.reset(reset),
				.new_Ship_X(x_out),
				.new_Ship_Y(y_out),
				.left(left),
				.right(right),
				.ldx(ldx),
				.ldy(ldy),
				.draw_signal(draw_signal),
				.erase_signal(erase_signal),
				.colour(colour),
				.start_draw(start_draw),
				.start_erase(start_erase),
				.counter(counter));
	//controller
	controller_ship c0(
				.clk(clk),
				.reset(reset),
				.ldx(ldx),
				.ldy(ldy),
				.draw_signal(draw_signal),
				.erase_signal(erase_signal),
				.start_draw(start_draw),
				.start_erase(start_erase),
				.finish_draw(finish),
				.counter(counter));
endmodule


module datapath_ship(clk, reset, new_Ship_X, new_Ship_Y, left, right, ldx, ldy, draw_signal, erase_signal, colour, start_draw, start_erase, counter);
	//Player sprite
	reg [8:0] Ship_X = 9'd160;
	reg [7:0] Ship_Y = 8'd200;
	
	//clock and reset
	input clk, reset;
	
	//input directions
	input left, right;
	
	//colour wires
	output reg [2:0] colour;
	
	//enable signals
	input ldx, ldy, draw_signal, erase_signal, start_draw, start_erase;
	input [5:0] counter;
	
	//register used for drawing the sprites
	output reg [8:0] new_Ship_X;
	output reg [7:0] new_Ship_Y;
	
	
	//determines the new position of the player sprite whenever its ready to draw, collision is implemented as well
	always @(posedge draw_signal)
	begin
		if(!reset) begin
			Ship_X <= 9'd160;
			Ship_Y <= 8'd200;
		end
		if(left && Ship_X == 1'b0)
			Ship_X <= Ship_X;
		else if(left && Ship_X != 1'b0)
			Ship_X <= Ship_X - 1'b1;
		else if(right && Ship_X == 9'd309)
			Ship_X <= Ship_X;
		else if(right && Ship_X != 9'd309)
			Ship_X <= Ship_X + 1'b1;
	end

	//Drawing the ships
	always @(posedge clk)
	begin
		if(!reset) begin
			new_Ship_X <= 9'd160;
			new_Ship_Y <= 8'd200;
		end
		if(ldx)
			new_Ship_X <= Ship_X;
		if(ldy)
			new_Ship_Y <= Ship_Y;
		if(draw_signal)
			colour <= 3'b111;
		if(erase_signal)
			colour <= 3'b000;
		//Sends appropriate coordinates to VGA adapter
		if(start_draw || start_erase) begin
			if(counter < 6'd10)
				new_Ship_X <= new_Ship_X + 1;
			else if(counter == 6'd10) begin
				new_Ship_X <= Ship_X;
				new_Ship_Y <= new_Ship_Y + 1;
			end
			else if(counter < 6'd20)
				new_Ship_X <= new_Ship_X + 1;
			else if(counter == 6'd20) begin
				new_Ship_X <= Ship_X;
				new_Ship_Y <= new_Ship_Y + 1;
			end
			else if(counter < 6'd30)
				new_Ship_X <= new_Ship_X + 1;
			else if(counter == 6'd30) begin
				new_Ship_X <= Ship_X;
				new_Ship_Y <= new_Ship_Y + 1;
			end
			else if(counter < 6'd40)
				new_Ship_X <= new_Ship_X + 1;
		end
	end
endmodule
		
module controller_ship(clk, reset, ldx, ldy, draw_signal, erase_signal, start_draw, start_erase, finish_draw, counter);
		input clk;
		input reset;
		
		input draw_signal, erase_signal;
		
		//enable signals
		output reg ldx, ldy, start_draw, start_erase, finish_draw;
		output reg [5:0] counter = 6'd0;
		
		//wires to indicate when its finished drawing
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
		
		//Output Logic (datapath)
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
					if(counter == 6'd40) begin
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
					if(counter == 6'd40) begin
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
		
		//counter used to draw the player sprite
		always @(posedge clk)
		begin
			if(start_counter) begin
				if(counter == 6'd40)
					counter <= 6'd1;
				else
					counter <= counter + 1;
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

