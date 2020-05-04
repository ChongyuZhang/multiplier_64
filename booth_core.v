module booth_core #(parameter WIDTH=4) 
(
  input                    clk,
  input                    rst,
  input        [WIDTH-1:0] multiplier,                            
  input        [WIDTH-1:0] multiplicand,
  output reg               done,
  output reg [2*WIDTH-1:0] product
);

// state encodings
parameter   IDLE   = 3'b000,
				INIT   = 3'b001,
            ADD    = 3'b010,
            SHIFT  = 3'b011,
            OUTPUT = 3'b100;

reg  [2:0]              current_state, next_state;  // state registers.
reg  [2*WIDTH+1:0]      a_reg,s_reg,p_reg,sum_reg;  // computational values.
reg  [WIDTH-1:0]        iter_cnt;                   // iteration count for determining when done.

// state machine
always@(posedge clk or negedge rst)
begin
	if (!rst)
	begin
		current_state <= IDLE;
//		a_reg    <= 0;
//		s_reg    <= 0;
//		p_reg    <= 0;
//		sum_reg  <= 0;
//		iter_cnt <= 0;
//		done     <= 0;
	end
  else current_state <= next_state;
end

always@(current_state)
	begin
		case (current_state)
			IDLE :begin
						iter_cnt <= 0;
						done     <= 0;
						next_state <= INIT;
					end
			INIT :begin
						a_reg    <= {multiplier[WIDTH-1],multiplier,{(WIDTH+1){1'b0}}};
						s_reg    <= {{~{multiplier[WIDTH-1],multiplier}+1},{(WIDTH+1){1'b0}}};
						p_reg    <= {{(WIDTH+1){1'b0}},multiplicand,1'b0};
						next_state <= ADD;
					end
			ADD  :begin
						case(p_reg[1:0])
							2'b01       : sum_reg <= p_reg + a_reg;
							2'b10       : sum_reg <= p_reg + s_reg;
							2'b00,2'b11 : sum_reg <= p_reg;
						endcase
						iter_cnt <= iter_cnt + 1;
						next_state <= SHIFT;
					end
					
			SHIFT:begin
						p_reg <= {sum_reg[2*WIDTH+1],sum_reg[2*WIDTH+1:1]};
						if (iter_cnt == WIDTH)
							next_state <= OUTPUT;
						else
							next_state <= ADD;
					end
					
			OUTPUT:begin
						product <= p_reg[2*WIDTH:1];
						done <= 1'b1;
						next_state <= IDLE;
					 end
		endcase
	end
endmodule