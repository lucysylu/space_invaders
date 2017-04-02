module alien_2(clk, reset, bullet_x, bullet_y, draw_signal, erase_signal, finish, collision, x, y, colour);

	input clk, reset;
	input [8:0] bullet_x;
	input [7:0] bullet_y;
	output finish, collision;
	input draw_signal, erase_signal;
	wire start_draw, start_erase;
	wire ldx, ldy;
	wire [5:0] counter;
	
	output wire [2:0] colour;
	output wire [8:0] x;
	output wire [7:0] y;
	
	//datapath
	datapath_alien_2 d_alien(
				.clk(clk),
				.reset(reset),
				.bullet_x(bullet_x),
				.bullet_y(bullet_y),
				.new_Alien_X(x),
				.new_Alien_Y(y),
				.ldx(ldx),
				.ldy(ldy),
				.draw_signal(draw_signal),
				.erase_signal(erase_signal),
				.colour(colour),
				.start_draw(start_draw),
				.start_erase(start_erase),
				.collision(collision),
				.counter(counter));
	//controller
	controller_alien_2 c_alien(
				.clk(clk),
				.reset(reset),
				.ldx(ldx),
				.ldy(ldy),
				.draw_signal(draw_signal),
				.erase_signal(erase_signal),
				.start_draw(start_draw),
				.start_erase(start_erase),
				.counter(counter),
				.finish_draw(finish));		
endmodule

module datapath_alien_2(clk, reset, bullet_x, bullet_y, new_Alien_X, new_Alien_Y, ldx, ldy, draw_signal, erase_signal, colour, start_draw, start_erase, collision, counter);
	//Alien sprite
	reg [8:0] Alien_X = 9'd180;
	reg [7:0] Alien_Y = 8'd10;
	
	//clock and reset
	input clk, reset;
	
	//direction of alien, 0 means left, 1 means right
	reg direction = 1'b0;
	reg bump = 1'b0;
	//colour wires
	output reg [2:0] colour;
	
	//enable signals
	input ldx, ldy, draw_signal, erase_signal, start_draw, start_erase;
	input [5:0] counter;
	
	//bullet
	input [8:0] bullet_x;
	input [7:0] bullet_y;
	
	//register used for drawing the sprites
	output reg [8:0] new_Alien_X;
	output reg [7:0] new_Alien_Y;
	
	output reg collision = 1'b0;
	
	
	//determines the new position of the player sprite whenever its ready to draw, collision is implemented as well
	always @(posedge draw_signal)
	begin
		if(!reset || collision) begin
			Alien_X <= 9'd180;
			Alien_Y <= 8'd10;
			
		end
		else if(Alien_X == 9'd309 && direction == 1'b0 && bump == 1'b1) begin
			Alien_X <= Alien_X - 1;
			bump <= 1'b0;
		end
		else if(Alien_X == 9'd0 && direction == 1'b1 && bump == 1'b1) begin
			Alien_X <= Alien_X + 1;
			bump <= 1'b0;
		end
		else if(Alien_X == 9'd0 && direction == 1'b0) begin
			Alien_Y <= Alien_Y + 1;
			direction <= 1'b1;
			bump <= 1'b1;
		end
		else if(Alien_X == 9'd309 && direction == 1'b1) begin
			Alien_Y <= Alien_Y + 1;
			direction <= 1'b0;
			bump <= 1'b1;
		end
		else begin
			if(direction)
				Alien_X <= Alien_X + 1;
			else if(!direction)
				Alien_X <= Alien_X - 1;
		end
		
	end
	
	always @(posedge clk)
	begin
		if (!reset)
			collision <= 1'b0;
		if (new_Alien_X > bullet_x + 1 || bullet_x > new_Alien_X + 9)
			collision <= 1'b0;
		else if (new_Alien_Y < bullet_y + 2 || bullet_y < new_Alien_X + 3)
			collision <= 1'b0;
		else
			collision <= 1'b1;
	end
	
	//Drawing the ships
	always @(posedge clk)
	begin
		if(!reset) begin
			new_Alien_X <= 9'd0;
			new_Alien_Y <= 8'd0;
		end
		if(ldx)
			new_Alien_X <= Alien_X;
		if(ldy)
			new_Alien_Y <= Alien_Y;
		if(draw_signal)
			colour <= 3'b101;
		if(erase_signal || collision)
			colour <= 3'b000;
		//Sends appropriate coordinates to VGA adapter
		if(start_draw || start_erase) begin
			if(counter < 6'd10)
				new_Alien_X <= new_Alien_X + 1;
			else if(counter == 6'd10) begin
				new_Alien_X <= Alien_X;
				new_Alien_Y <= new_Alien_Y + 1;
			end
			else if(counter < 6'd20)
				new_Alien_X <= new_Alien_X + 1'b1;
			else if(counter == 6'd20) begin
				new_Alien_X <= Alien_X;
				new_Alien_Y <= new_Alien_Y + 1'b1;
			end
			else if(counter < 6'd30)
				new_Alien_X <= new_Alien_X + 1'b1;
			else if(counter == 6'd30) begin
				new_Alien_X <= Alien_X;
				new_Alien_Y <= new_Alien_Y + 1'b1;
			end
			else if(counter < 6'd40)
				new_Alien_X <= new_Alien_X + 1'b1;		
		end
	end
endmodule
		
module controller_alien_2(clk, reset, ldx, ldy, draw_signal, erase_signal, start_draw, start_erase, counter, finish_draw);
		input clk;
		input reset;
		
		input draw_signal, erase_signal;
		
		//enable signals
		output reg ldx, ldy, start_draw, start_erase;
		output reg [5:0] counter = 6'd0;
		
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


