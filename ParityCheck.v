module ParityCheckRX(
    concatdata,
    sipoe,
    out,
    paritygen,
    not_done
);

input [10:0]concatdata;
input sipoe;

output reg paritygen;
output reg [2:0]out;
output reg not_done;


always @(*)
begin

    if(sipoe)
    begin
        paritygen = ^concatdata[8:1];

        not_done = 1'b0;

        if(concatdata[10] == 1'b1)
            out[0] = 1'b0;
        else
            out[0] = 1'b1;

        if(concatdata[0] == 1'b0)
            out[1] = 1'b0;
        else
            out[1] = 1'b1;

        if(concatdata[9] == paritygen)
            out[2] = 1'b0;
        else
            out[2] = 1'b1;

    end

    else
    begin
        paritygen = 1'b0;
        not_done = 1'b1;
        out = 3'b000;

    end

end

endmodule
