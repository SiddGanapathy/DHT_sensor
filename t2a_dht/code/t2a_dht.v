`timescale 1ns/1ps


module t2a_dht(
    input clk_50M,
    input reset,
    inout sensor,
    output reg [7:0] T_integral,
    output reg [7:0] RH_integral,
    output reg [7:0] T_decimal,
    output reg [7:0] RH_decimal,
    output reg [7:0] Checksum,
    output reg data_valid
);
    initial begin
        T_integral  = 0;
        RH_integral = 0;
        T_decimal   = 0;
        RH_decimal  = 0;
        Checksum    = 0;
        data_valid  = 0;
    end
//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE //////////////////

    // Bidirectional sensor control
    reg sensor_drive_enable, sensor_drive_enable_next;  // 1 = output, 0 = input
    assign sensor = sensor_drive_enable ? 1'b0 : 1'bz;

    // State registers
    reg [5:0] bit_count, bit_count_next;
    reg [39:0] data_buffer, data_buffer_next;
    reg sensor_prev, sensor_prev_next;
    reg [11:0] high_time, high_time_next;
    reg measuring_high, measuring_high_next;
    reg data_ready, data_ready_next;

    // Output registers next values
    reg [7:0] T_integral_next;
    reg [7:0] RH_integral_next;
    reg [7:0] T_decimal_next;
    reg [7:0] RH_decimal_next;
    reg [7:0] Checksum_next;
    reg data_valid_next;

    reg [1:0] state;
    reg [1:0] next_state;
    reg i;

    reg [19:0]j, j_next;
    reg [1:0] k, k_next;

    //============================================
    // SEQUENTIAL LOGIC (always @posedge clk)
    //============================================
    always @(posedge clk_50M or negedge reset) begin
        if (!reset) begin
            bit_count 				<= 0;
            data_buffer 			<= 0;
            sensor_prev 			<= 1;
            high_time 				<= 0;
            measuring_high 		<= 0;
            T_integral 				<= 0;
            RH_integral 			<= 0;
            T_decimal 				<= 0;
            RH_decimal 				<= 0;
            Checksum 				<= 0;
            data_valid 				<= 0;
            sensor_drive_enable 	<= 0;  
            j							<= 0;
            k							<= 0;
        end else begin
            bit_count 				<= bit_count_next;
            data_buffer 			<= data_buffer_next;
            sensor_prev 			<= sensor_prev_next;
            high_time 				<= high_time_next;
            measuring_high 		<= measuring_high_next;
            sensor_drive_enable 	<= sensor_drive_enable_next;
            T_integral 				<= T_integral_next;
            RH_integral 			<= RH_integral_next;
            T_decimal 				<= T_decimal_next;
            RH_decimal 				<= RH_decimal_next;
            Checksum 				<= Checksum_next;
            data_valid 				<= data_valid_next;
            j							<= j_next;
            k							<= k_next;
        end
    end


    //============================================
    // COMBINATIONAL LOGIC (always @*)
    //============================================
    always @(*) begin
        bit_count_next 				= bit_count;
        data_buffer_next 			= data_buffer;
        sensor_prev_next 			= sensor;
        high_time_next 				= high_time;
        measuring_high_next 		= measuring_high;
        
        // Rising edge detection: sensor goes from 0 to 1 or HiZ
        if (sensor_prev === 1'b0 && (sensor === 1'b1)) 
        begin
            high_time_next 		= 1;
            measuring_high_next 	= 1;
        end 
        // Falling edge detection: sensor goes from 1/HiZ to 0
        else if ((sensor_prev === 1'b1 || sensor_prev === 1'bz) && ( sensor === 1'b0 || sensor === 1'bz)) 
        begin
            measuring_high_next = 0;
            
            // Valid pulse check (between thresholds)
            if (high_time > 0 && high_time <= 3800) 
            begin
                // Decode bit based on high pulse width
                // >2000 cycles = logic 1, <=2000 = logic 0  3500

                if (high_time >= 1299) 
                begin

                    if(high_time >= 3499)
                    begin
                        data_buffer_next = {data_buffer[38:0], 1'b1};
                    end
                    else
                    begin
                        data_buffer_next = {data_buffer[38:0], 1'b0};
                    end

                    if (bit_count == 6'd40) 
                    begin
                        bit_count_next = 0;
                    end 
                    else 
                    begin
                        bit_count_next = bit_count + 6'd1;
                    end
                end 
                            
            end
            high_time_next = 0;
        end 
        else if (measuring_high) 
        begin
            high_time_next = high_time + 1;
        end
    end    
    
    always @(*)
		begin
                if (bit_count == 6'd40) 
                begin
                    i=1;
                end 
                else if(state==0)
                begin
                    i=0;
                end
                else 
                begin
                    i=0;
                
                end
    end
	 
    always @(*)
		begin
    
        if((state ==  0) && (i==1)) begin
		  
            next_state 			= state + 4'd1;
            data_valid_next	= 0;
				T_integral_next 	= T_integral;
				RH_integral_next  = RH_integral;
				T_decimal_next 	= T_decimal;
				RH_decimal_next 	= RH_decimal;
				Checksum_next 		= Checksum;
        end  
        else if(state==1) begin
		  
            next_state 			= state + 4'd1;
            data_valid_next	= 0;
				T_integral_next 	= T_integral;
				RH_integral_next  = RH_integral;
				T_decimal_next 	= T_decimal;
				RH_decimal_next 	= RH_decimal;
				Checksum_next 		= Checksum;
        end
        else if((state ==  2) ) begin
		  
             RH_integral_next = data_buffer[39:32];
             RH_decimal_next 	= data_buffer[31:24];
             T_integral_next 	= data_buffer[23:16];
             T_decimal_next 	= data_buffer[15:8];
             Checksum_next 	= data_buffer[7:0];
             next_state			= state + 4'd1;
				 
				 if (data_buffer[7:0] == ((data_buffer[39:32] + data_buffer[31:24] + 
                                             data_buffer[23:16] + data_buffer[15:8]) & 8'hFF)) begin											
						data_valid_next	= 1;
             end
				 else begin
						data_valid_next	= data_valid;
				 end
        end    
        else if(state==3) begin 
		  
            if(bit_count==1)
            begin
                next_state= 0;
            end
            else
            begin
                next_state= state;
            end     
            data_valid_next	= 0;
				T_integral_next 	= T_integral;
				RH_integral_next  = RH_integral;
				T_decimal_next 	= T_decimal;
				RH_decimal_next 	= RH_decimal;
				Checksum_next 		= Checksum;

        end
        else begin
            next_state			= state;  
				data_valid_next	= 0;
				T_integral_next 	= T_integral;
				RH_integral_next  = RH_integral;
				T_decimal_next 	= T_decimal;
				RH_decimal_next 	= RH_decimal;
				Checksum_next 		= Checksum;
        end
    end
    
    
	always@(posedge clk_50M or negedge reset)
		begin
        if(!reset)
            state<=0;
        else
            state<=next_state;
        
    end
     
    always @(*)
		begin
        if(sensor_drive_enable)
        begin
        
                if(  (j<900000) &&(k==0) )
                begin
                    j_next 						= j_next+1;
                    k_next							= 0;
                    sensor_drive_enable_next	= 1;
                end
                else if( (k==0) && (j==900000))
                begin
                    j_next 				= 0;
                    k_next 				= 1;
                end
                else if((k==1) && (j<2000))
                begin
                    j_next 						= j_next + 1;
                    k_next							= 1;
                    sensor_drive_enable_next	= 1;
                end
                else if((k==1) && (j==2000))
                begin
                    j_next 						= 0;  
                    sensor_drive_enable_next	= 0;
                    
                    if(bit_count <40)
                    begin
                        k_next = 3;
                    end
                    else
                    begin
                        k_next = k;
                    end
                
                end
                else if(k==3)
                begin
                    sensor_drive_enable_next	= 0;
                    j_next = 0;
                    
                    if(bit_count <40)
                    begin
                        k_next = 3;
                    end
                    else
                    begin
                        k_next = 0;
                    end
                end
                else 
                begin
                    j_next 						= 0;
                    k_next 						= 0;
                    sensor_drive_enable_next	= sensor_drive_enable;
                end 
        end
        else if(state==0)
        begin
            if(k==3)
            begin
                sensor_drive_enable_next		= 0;
            end
            else
            begin
                sensor_drive_enable_next		= 1;
            end
        end
        else
        begin
            sensor_drive_enable_next	= sensor_drive_enable;
        end
    end
//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE //////////////////
  
endmodule