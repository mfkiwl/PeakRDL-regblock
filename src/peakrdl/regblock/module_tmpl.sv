// TODO: Add a banner
module {{module_name}} (
        input wire clk,
        input wire rst,

        {%- for signal in user_out_of_hier_signals %}
        {%- if signal.width == 1 %}
        input wire {{signal.inst_name}},
        {%- else %}
        input wire [{{signal.width-1}}:0] {{signal.inst_name}},
        {%- endif %}
        {%- endfor %}

        {{cpuif.port_declaration|indent(8)}}
        {%- if hwif.has_input_struct or hwif.has_output_struct %},{% endif %}

        {{hwif.port_declaration|indent(8)}}
    );

    //--------------------------------------------------------------------------
    // CPU Bus interface logic
    //--------------------------------------------------------------------------
    logic cpuif_req;
    logic cpuif_req_is_wr;
    logic [{{cpuif.addr_width-1}}:0] cpuif_addr;
    logic [{{cpuif.data_width-1}}:0] cpuif_wr_data;
    logic cpuif_req_stall_wr;
    logic cpuif_req_stall_rd;

    logic cpuif_rd_ack;
    logic cpuif_rd_err;
    logic [{{cpuif.data_width-1}}:0] cpuif_rd_data;

    logic cpuif_wr_ack;
    logic cpuif_wr_err;

    {{cpuif.get_implementation()|indent}}

    logic cpuif_req_masked;
{% if min_read_latency == min_write_latency %}
    // Read & write latencies are balanced. Stalls not required
    assign cpuif_req_stall_rd = '0;
    assign cpuif_req_stall_wr = '0;
    assign cpuif_req_masked = cpuif_req;
{%- elif min_read_latency > min_write_latency %}
    // Read latency > write latency. May need to delay next write that follows a read
    logic [{{min_read_latency - min_write_latency - 1}}:0] cpuif_req_stall_sr;
    always_ff {{get_always_ff_event(cpuif.reset)}} begin
        if({{get_resetsignal(cpuif.reset)}}) begin
            cpuif_req_stall_sr <= '0;
        end else if(cpuif_req && !cpuif_req_is_wr) begin
            cpuif_req_stall_sr <= '1;
        end else begin
            cpuif_req_stall_sr <= (cpuif_req_stall_sr >> 'd1);
        end
    end
    assign cpuif_req_stall_rd = '0;
    assign cpuif_req_stall_wr = cpuif_req_stall_sr[0];
    assign cpuif_req_masked = cpuif_req & !(cpuif_req_is_wr & cpuif_req_stall_wr);
{%- else %}
    // Write latency > read latency. May need to delay next read that follows a write
    logic [{{min_write_latency - min_read_latency - 1}}:0] cpuif_req_stall_sr;
    always_ff {{get_always_ff_event(cpuif.reset)}} begin
        if({{get_resetsignal(cpuif.reset)}}) begin
            cpuif_req_stall_sr <= '0;
        end else if(cpuif_req && cpuif_req_is_wr) begin
            cpuif_req_stall_sr <= '1;
        end else begin
            cpuif_req_stall_sr <= (cpuif_req_stall_sr >> 'd1);
        end
    end
    assign cpuif_req_stall_rd = cpuif_req_stall_sr[0];
    assign cpuif_req_stall_wr = '0;
    assign cpuif_req_masked = cpuif_req & !(!cpuif_req_is_wr & cpuif_req_stall_rd);
{%- endif %}

    //--------------------------------------------------------------------------
    // Address Decode
    //--------------------------------------------------------------------------
    {{address_decode.get_strobe_struct()|indent}}
    decoded_reg_strb_t decoded_reg_strb;
    logic decoded_req;
    logic decoded_req_is_wr;
    logic [{{cpuif.data_width-1}}:0] decoded_wr_data;

    always_comb begin
        {{address_decode.get_implementation()|indent(8)}}
    end

    // Pass down signals to next stage
    assign decoded_req = cpuif_req_masked;
    assign decoded_req_is_wr = cpuif_req_is_wr;
    assign decoded_wr_data = cpuif_wr_data;

    // Writes are always granted with no error response
    assign cpuif_wr_ack = decoded_req & decoded_req_is_wr;
    assign cpuif_wr_err = '0;

    //--------------------------------------------------------------------------
    // Field logic
    //--------------------------------------------------------------------------
    {{field_logic.get_combo_struct()|indent}}

    {{field_logic.get_storage_struct()|indent}}

    {{field_logic.get_implementation()|indent}}

    //--------------------------------------------------------------------------
    // Readback
    //--------------------------------------------------------------------------
    logic readback_err;
    logic readback_done;
    logic [{{cpuif.data_width-1}}:0] readback_data;
    {{readback.get_implementation()|indent}}

{% if retime_read_response %}
    always_ff {{get_always_ff_event(cpuif.reset)}} begin
        if({{get_resetsignal(cpuif.reset)}}) begin
            cpuif_rd_ack <= '0;
            cpuif_rd_data <= '0;
            cpuif_rd_err <= '0;
        end else begin
            cpuif_rd_ack <= readback_done;
            cpuif_rd_data <= readback_data;
            cpuif_rd_err <= readback_err;
        end
    end
{% else %}
    assign cpuif_rd_ack = readback_done;
    assign cpuif_rd_data = readback_data;
    assign cpuif_rd_err = readback_err;
{% endif %}

endmodule
