`timescale 1ns / 1ps

import noc_params::*;
 
int i = 0;
int j = 0;
module tb_rc_unit #(
    parameter X_CURRENT = MESH_SIZE_X / 2,
    parameter Y_CURRENT = MESH_SIZE_Y / 2,
    parameter DEST_ADDR_SIZE_X = DEST_ADDR_SIZE_X,
    parameter DEST_ADDR_SIZE_Y = DEST_ADDR_SIZE_Y    
);
    logic [DEST_ADDR_SIZE_X-1 : 0] x_dest_i;
    logic [DEST_ADDR_SIZE_Y-1 : 0] y_dest_i;
    port_t out_port_o;

    initial
    begin
        dump_output();
        compute_all_destinations_mesh();
        #5 $finish;
    end

    rc_unit #(
        .X_CURRENT(X_CURRENT),
        .Y_CURRENT(Y_CURRENT)
    )
    rc_unit (
        .x_dest_i(x_dest_i),
        .y_dest_i(y_dest_i),
        .out_port_o(out_port_o)
    );

    task dump_output();
        $dumpfile("out.vcd");
        $dumpvars(0, tb_rc_unit);
    endtask

    task compute_all_destinations_mesh();
        repeat(MESH_SIZE_Y)
        begin
            repeat(MESH_SIZE_X)
            begin
                #5
                x_dest_i = i;
                y_dest_i = j;
                #5 
                if(~check_dest())
                begin
                    $display("[RCUNIT] Failed");
                    return;
                end
                i = i + 1;
            end
            i = 0;
            j = j + 1;
        end
        $display("[RCUNIT] Passed");
    endtask

    function logic check_dest();
        if(x_dest_i < X_CURRENT & out_port_o == WEST)
            check_dest = 1;
        else if(x_dest_i > X_CURRENT & out_port_o == EAST)
            check_dest = 1;
        else if(x_dest_i == X_CURRENT & y_dest_i < Y_CURRENT & out_port_o == NORTH)
            check_dest = 1;
        else if(x_dest_i == X_CURRENT & y_dest_i > Y_CURRENT & out_port_o == SOUTH)
            check_dest = 1;
        else if(x_dest_i == X_CURRENT & y_dest_i == Y_CURRENT & out_port_o == LOCAL)
            check_dest = 1;
        else
            check_dest = 0;
    endfunction

endmodule