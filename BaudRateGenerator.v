module baudrategenerator(clk,rate,baud,count,reset);

input clk;
input rate;
input reset;

output reg baud;
output reg [10:0]count;

parameter B9600  = 1'b0;
parameter B19200 = 1'b1;

always @(posedge clk)
begin
    if(reset)
    begin
        count <= 11'b00000000000;
        baud <= 1'b0;
    end

    else
    begin

        case(rate)

        B9600:
        begin
            if(count == 52)
            begin
                count <= 0;
                baud <= 1'b1;
            end
            else
            begin
                count <= count + 1;
                baud <= 1'b0;
            end
        end

        B19200:
        begin
            if(count == 26)
            begin
                count <= 0;
                baud <= 1'b1;
            end
            else
            begin
                count <= count + 1;
                baud <= 1'b0;
            end
        end

        default:
        begin
            count <= 0;
            baud <= 0;
        end

        endcase

    end
end

endmodule




