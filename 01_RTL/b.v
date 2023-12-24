//----------------------------- DO NOT MODIFY THE I/O INTERFACE!! ------------------------------//
module CHIP #(                                                                                  //
    parameter BIT_W = 32                                                                        //
)(                                                                                              //
    // clock                                                                                    //
        input               i_clk,                                                              //
        input               i_rst_n,                                                            //
    // instruction memory                                                                       //
        input  [BIT_W-1:0]  i_IMEM_data,                                                        //
        output [BIT_W-1:0]  o_IMEM_addr,                                                        //
        output              o_IMEM_cen,                                                         //
    // data memory                                                                              //
        input               i_DMEM_stall,                                                       //
        input  [BIT_W-1:0]  i_DMEM_rdata,                                                       //
        output              o_DMEM_cen,                                                         //
        output              o_DMEM_wen,                                                         //
        output [BIT_W-1:0]  o_DMEM_addr,                                                        //
        output [BIT_W-1:0]  o_DMEM_wdata,                                                       //
    // finnish procedure                                                                        //
        output              o_finish,                                                           //
    // cache                                                                                    //
        input               i_cache_finish,                                                     //
        output              o_proc_finish                                                       //
);                                                                                              //
//----------------------------- DO NOT MODIFY THE I/O INTERFACE!! ------------------------------//

// ------------------------------------------------------------------------------------------------------------------------------------------------------
// Parameters
// ------------------------------------------------------------------------------------------------------------------------------------------------------

    // TODO: any declaration


// ------------------------------------------------------------------------------------------------------------------------------------------------------
// Wires and Registers
// ------------------------------------------------------------------------------------------------------------------------------------------------------
    
    // TODO: any declaration
        reg [BIT_W-1:0] PC, next_PC;
        wire mem_cen, mem_wen;
        wire [BIT_W-1:0] mem_addr, mem_wdata, mem_rdata;
        wire mem_stall;

    //ID
    reg [4:0]  id_rs1_r, id_rs1_w, id_rs2_r, id_rs2_w, id_rd_r, id_rd_w;
    reg [2:0]  id_func3_r, id_func3_w;
    reg [6:0]  id_func7_r, id_func7_w;
    reg [63:0] id_imm_r, id_imm_w;
    reg id_branch_r, id_branch_w;
    reg id_jump_r, id_jump_w;
    reg id_jr_r, id_jr_w;
    reg id_memread_r, id_memread_w;
    reg id_memtoreg_r, id_memtoreg_w;
    reg [1:0] id_alu_op_r, id_alu_op_w;
    reg id_memwrite_r, id_memwrite_w;
    reg id_alu_src_r, id_alu_src_w;
    reg id_regwrite_r, id_regwrite_w;
    reg id_end_r, id_end_w; 


    //EX
    wire [31:0] rs1_output, rs2_output;
    reg [31:0] ex_pc_cal_w, ex_pc_cal_r;
    reg [31:0] ex_result_w, ex_result_r;
    reg ex_memread_r, ex_memread_w;
    reg ex_memtoreg_r, ex_memtoreg_w;
    reg ex_memwrite_r, ex_memwrite_w;
    reg ex_regwrite_r, ex_regwrite_w;
    reg [4:0] ex_rs1_r, ex_rs1_w;
    reg [4:0] ex_rd_r, ex_rd_w;
    reg ex_branch_r, ex_branch_w;
    reg ex_jump_r, ex_jump_w;
    reg ex_jr_r, ex_jr_w;
    reg ex_end_r, ex_end_w;
    reg [31:0] ex_reg_rs1_r, ex_reg_rs1_w;
    reg [31:0] ex_reg_rs2_r, ex_reg_rs2_w;
    reg [31:0] ex_imm_r, ex_imm_w;

    //MEM
    reg [31:0] mem_out_w, mem_out_r;
    reg [4:0] mem_rs1_w, mem_rs1_r;
    reg [4:0] mem_rd_w, mem_rd_r;
    reg [31:0] mem_result_w, mem_result_r;
    reg mem_memtoreg_w, mem_memtoreg_r;
    reg mem_regwrite_w, mem_regwrite_r;
    reg mem_memread_r, mem_memread_w;
    reg mem_memwrite_r, mem_memwrite_w;
    reg [31:0] mem_reg_rs1_r, mem_reg_rs1_w;
    reg [31:0] mem_reg_rs2_r, mem_reg_rs2_w;
    reg [31:0] mem_imm_r, mem_imm_w;
    reg mem_jump_r, mem_jump_w;
    reg mem_jr_r, mem_jr_w;

    // reg mem_addr_w, mem_addr_r;


    reg finish_w, finish_r;

    reg wb_regwrite_w, wb_regwrite_r;
    reg [31:0] wb_rdata_w, wb_rdata_r;
    reg [4:0] wb_rd_r, wb_rd_w;

// ------------------------------------------------------------------------------------------------------------------------------------------------------
// Continuous Assignment
// ------------------------------------------------------------------------------------------------------------------------------------------------------

    // TODO: any wire assignment

    assign o_IMEM_addr   = PC;
    assign o_IMEM_cen    = 1;
    assign o_DMEM_cen    = mem_memread_r || mem_memwrite_r;
    assign o_DMEM_wen    = mem_memwrite_r;
    assign o_DMEM_addr   = mem_result_r;
    assign o_DMEM_wdata  = mem_reg_rs2_r;
    assign o_finish      = finish_r;
    // assign o_proc_finish =  

    wire hazard;
    assign hazard = (i_DMEM_stall == 0 && ex_end_r == 0 && (id_rs1_r != ex_rd_r || id_rs1_r == 0) && (id_rs2_r != ex_rd_r || id_rs2_r == 0) && (id_rs1_r != mem_rd_r || id_rs1_r == 0) && (id_rs2_r != mem_rd_r || id_rs2_r == 0));

// ------------------------------------------------------------------------------------------------------------------------------------------------------
// Submoddules
// ------------------------------------------------------------------------------------------------------------------------------------------------------

    // TODO: Reg_file wire connection
    // FIXME: fixed the input of regfile
    Reg_file reg0(               
        .i_clk  (i_clk),             
        .i_rst_n(i_rst_n),         
        .wen    (wb_regwrite_r),          
        .rs1    (id_rs1_r),                
        .rs2    (id_rs2_r),                
        .rd     (wb_rd_r),                 
        .wdata  (wb_rdata_r),             
        .rdata1 (rs1_output),           
        .rdata2 (rs2_output)
    );

// ------------------------------------------------------------------------------------------------------------------------------------------------------
// Always Blocks
// ------------------------------------------------------------------------------------------------------------------------------------------------------
    


//TODO: ID

    always @(*) begin
        if(hazard == 0) begin
            id_rs1_w      = id_rs1_r;
            id_rs2_w      = id_rs2_r;
            id_rd_w       = id_rd_r;
            id_func3_w    = id_func3_r; 
            id_func7_w    = id_func7_r;
            id_branch_w   = id_branch_r;
            id_memread_w  = id_memread_r;
            id_alu_op_w   = id_alu_op_r;
            id_memwrite_w = id_memwrite_r;
            id_alu_src_w  = id_alu_src_r;
            id_regwrite_w = id_regwrite_r;
            id_imm_w      = id_imm_r;  
            id_jump_w     = id_jump_r;
            id_jr_w       = id_jr_r;
            id_end_w      = id_end_r;            
        end
        else if(id_jump_r || ex_jump_r || mem_jump_r) begin
            id_rs1_w      = 0;
            id_rs2_w      = 0;
            id_rd_w       = 0;
            id_func3_w    = 0; 
            id_func7_w    = 0;
            id_branch_w   = 0;
            id_memread_w  = 0;
            id_alu_op_w   = 0;
            id_memwrite_w = 0;
            id_alu_src_w  = 0;
            id_regwrite_w = 0;
            id_imm_w      = 0;  
            id_jump_w     = 0;
            id_jr_w       = 0;
            id_end_w      = 0;  
        end
        else if(ex_result_r == 0 & ex_branch_r == 1) begin
            id_rs1_w      = 0;
            id_rs2_w      = 0;
            id_rd_w       = 0;
            id_func3_w    = 0; 
            id_func7_w    = 0;
            id_branch_w   = 0;
            id_memread_w  = 0;
            id_alu_op_w   = 0;
            id_memwrite_w = 0;
            id_alu_src_w  = 0;
            id_regwrite_w = 0;
            id_imm_w      = 0;  
            id_jump_w     = 0;
            id_jr_w       = 0;
            id_end_w      = 0;  
        end
        else begin
            id_rs1_w   = i_IMEM_data[19:15];
            id_rs2_w   = i_IMEM_data[24:20];
            id_rd_w    = i_IMEM_data[11:7];
            id_func3_w = i_IMEM_data[14:12]; 
            id_func7_w = i_IMEM_data[31:25];
            if(i_IMEM_data[6:0] == 7'b1100011)begin //branch (SB type) //FINISH
                id_branch_w   = 1;
                id_memread_w  = 0;
                id_memtoreg_w = 0;
                id_alu_op_w   = 2'b01;
                id_memwrite_w = 0;
                id_alu_src_w  = 0; // 0 : from another register, 1 : from immediate 
                id_regwrite_w = 0;
                id_imm_w[63:13] = {51{i_IMEM_data[31]}};
                id_imm_w[12]    = i_IMEM_data[31];
                id_imm_w[11]    = i_IMEM_data[7];
                id_imm_w[10:5]  = i_IMEM_data[30:25];
                id_imm_w[4:1]   = i_IMEM_data[11:8];
                id_imm_w[0]     = 0;
                id_jump_w     = 0;
                id_jr_w       = 0;
                id_end_w      = 0;
            end
            else if(i_IMEM_data[6:0] == 7'b0010111)begin //auipc (U type) //FINISH
                id_branch_w   = 0;
                id_memread_w  = 0;
                id_memtoreg_w = 0;
                id_alu_op_w   = 2'b11;
                id_memwrite_w = 0;
                id_alu_src_w  = 1; // 0 : from another register, 1 : from immediate   
                id_regwrite_w = 1;
                id_imm_w[63:32] = 0;
                id_imm_w[31:12] = i_IMEM_data[31:12];
                id_imm_w[11:0]  = 0;      
                id_jump_w       = 0;
                id_jr_w         = 0;
                id_end_w        = 0;
            end
            else if(i_IMEM_data[6:0] == 7'b1101111)begin //jal (UJ type) //FINISH
                id_branch_w   = 0;
                id_memread_w  = 0;
                id_memtoreg_w = 0;
                id_alu_op_w   = 2'b01;
                id_memwrite_w = 0;
                id_alu_src_w  = 1; // 0 : from another register, 1 : from immediate 
                id_regwrite_w = 1;
                if(i_IMEM_data[31] == 0) begin
                    id_imm_w[63:21] = 0;
                end
                else begin
                    id_imm_w[63:21] = {43{1'b1}};
                end
                id_imm_w[20]    = i_IMEM_data[31];
                id_imm_w[19:12] = i_IMEM_data[19:12];
                id_imm_w[11]    = i_IMEM_data[20];
                id_imm_w[10:1]  = i_IMEM_data[30:21];
                id_imm_w[0]     = 0;
                id_jump_w       = 1;
                id_jr_w         = 0;
                id_end_w        = 0;
            end
            else if(i_IMEM_data[6:0] == 7'b1100111)begin //jalr (I type) //FINISH
                id_branch_w     = 0;
                id_memread_w    = 0;
                id_memtoreg_w   = 0;
                id_alu_op_w     = 2'b01;
                id_memwrite_w   = 0;
                id_alu_src_w    = 1;
                id_regwrite_w   = 1;
                if(i_IMEM_data[31] == 0) begin
                    id_imm_w[63:12] = 0;
                end
                else begin
                    id_imm_w[63:12] = {52{1'b1}};
                end
                id_imm_w[11:0]  = i_IMEM_data[31:20];
                id_jump_w       = 1;
                id_jr_w         = 1;
                id_end_w        = 0;
            end
            else if(i_IMEM_data[6:0] == 7'b0000011)begin //lw  (I type) //FINISH
                id_branch_w   = 0;
                id_memread_w  = 1;
                id_memtoreg_w = 1;
                id_alu_op_w   = 2'b00;
                id_memwrite_w = 0;
                id_alu_src_w  = 1; // 0 : from another register, 1 : from immediate 
                id_regwrite_w = 1;
                id_imm_w[63:12] = 0;
                id_imm_w[11:0]  = i_IMEM_data[31:20];
                id_jump_w       = 0;
                id_jr_w         = 0;
                id_end_w        = 0;
            end
            else if(i_IMEM_data[6:0] == 7'b0100011)begin //sw  (S type) //FINISH
                id_branch_w   = 0;
                id_memread_w  = 0;
                id_memtoreg_w = 0;
                id_alu_op_w   = 2'b00;
                id_memwrite_w = 1;
                id_alu_src_w  = 1; // 0 : from another register, 1 : from immediate
                id_regwrite_w = 0;
                id_imm_w[63:12] = 0;
                id_imm_w[11:5]  = i_IMEM_data[31:25];
                id_imm_w[4:0]   = i_IMEM_data[11:7]; 
                id_jump_w       = 0;  
                id_jr_w         = 0;    
                id_end_w        = 0;     
            end
            else if(i_IMEM_data[6:0] == 7'b0010011)begin //addi (I type) //FINISH
                id_branch_w   = 0;
                id_memread_w  = 0;
                id_memtoreg_w = 0;
                id_alu_op_w   = 2'b10;
                id_memwrite_w = 0;
                id_alu_src_w  = 1; // 0 : from another register, 1 : from immediate 
                id_regwrite_w = 1;
                id_imm_w[63:12] = {52{i_IMEM_data[31]}};
                id_imm_w[11:0]  = i_IMEM_data[31:20];
                id_jump_w       = 0;
                id_jr_w         = 0;
                id_end_w        = 0;
            end
            else if(i_IMEM_data[6:0] == 7'b0110011)begin //add  (R type) //FINISH
                id_branch_w   = 0;
                id_memread_w  = 0;
                id_memtoreg_w = 0;
                id_alu_op_w   = 2'b10;
                id_memwrite_w = 0;
                id_alu_src_w  = 0; // 0 : from another register, 1 : from immediate 
                id_regwrite_w = 1;
                id_imm_w      = 0;
                id_jump_w     = 0;
                id_jr_w       = 0;
                id_end_w      = 0;
            end
            else if(i_IMEM_data[6:0] == 7'b1110011)begin //ecall (I type)  //FINISH
                id_branch_w   = 0;
                id_memread_w  = 0;
                id_memtoreg_w = 0;
                id_alu_op_w   = 2'b00;
                id_memwrite_w = 0;
                id_alu_src_w  = 0; // 0 : from another register, 1 : from immediate 
                id_regwrite_w = 0;
                id_imm_w      = 0;
                id_jump_w     = 0;
                id_jr_w       = 0;
                id_end_w      = 1;
            end
            else begin  //FINISH
                id_branch_w   = 0;
                id_memread_w  = 0;
                id_memtoreg_w = 0;
                id_alu_op_w   = 2'b00;
                id_memwrite_w = 0;
                id_alu_src_w  = 0; // 0 : from another register, 1 : from immediate 
                id_regwrite_w = 0;
                id_imm_w      = 0;
                id_jump_w     = 0;
                id_jr_w       = 0;
                id_end_w      = 0;
            end
        end
    end

//TODO: EX

    always @(*) begin
        if(i_DMEM_stall) begin
            ex_pc_cal_w   = ex_pc_cal_r;
            ex_memread_w  = ex_memread_r;
            ex_memtoreg_w = ex_memtoreg_r;
            ex_memwrite_w = ex_memwrite_r;
            ex_regwrite_w = ex_regwrite_r; 
            ex_rd_w       = ex_rd_r;
            ex_branch_w   = ex_branch_r;
            ex_jump_w     = ex_jump_r;
            ex_jr_w       = ex_jr_r;
            ex_end_w      = ex_end_r;
            ex_reg_rs1_w  = ex_reg_rs1_r;
            ex_reg_rs2_w  = ex_reg_rs2_r;
            ex_imm_w      = ex_imm_r;
            ex_result_w   = ex_result_r; 
            ex_rs1_w      = ex_rs1_r;  
        end
        else if(ex_result_r == 0 & ex_branch_r == 1) begin
            ex_pc_cal_w   = 0;
            ex_memread_w  = 0;
            ex_memtoreg_w = 0;
            ex_memwrite_w = 0;
            ex_regwrite_w = 0; 
            ex_rd_w       = 0;
            ex_branch_w   = 0;
            ex_jump_w     = 0;
            ex_jr_w       = 0;
            ex_end_w      = 0;
            ex_reg_rs1_w  = 0;
            ex_reg_rs2_w  = 0;
            ex_imm_w      = 0;
            ex_result_w   = 0;             
        end
        else if((id_rs1_r == ex_rd_r && id_rs1_r != 0) || (id_rs2_r == ex_rd_r && id_rs2_r != 0) || (id_rs1_r == mem_rd_r && id_rs1_r != 0) || (id_rs2_r == mem_rd_r && id_rs2_r != 0)) begin
            ex_pc_cal_w   = 0;
            ex_memread_w  = 0;
            ex_memtoreg_w = 0;
            ex_memwrite_w = 0;
            ex_regwrite_w = 0; 
            ex_rd_w       = 0;
            ex_branch_w   = 0;
            ex_jump_w     = 0;
            ex_jr_w       = 0;
            ex_end_w      = 0;
            ex_reg_rs1_w  = 0;
            ex_reg_rs2_w  = 0;
            ex_imm_w      = 0;
            ex_result_w   = 0;           
        end
        else if(i_DMEM_stall == 0 && ex_end_r == 0) begin
            ex_pc_cal_w   = PC + id_imm_r - 4;
            ex_memread_w  = id_memread_r;
            ex_memtoreg_w = id_memtoreg_r;
            ex_memwrite_w = id_memwrite_r;
            ex_regwrite_w = id_regwrite_r; 
            ex_rd_w       = id_rd_r;
            ex_branch_w   = id_branch_r;
            ex_jump_w     = id_jump_r;
            ex_jr_w       = id_jr_r;
            ex_end_w      = id_end_r;
            ex_reg_rs1_w  = rs1_output;
            ex_reg_rs2_w  = rs2_output;
            ex_imm_w      = id_imm_r[31:0];
            ex_rs1_w      = id_rs1_r;
            if(id_alu_src_r == 0) begin // alu source is reg
                if(id_alu_op_r == 2'b00) begin
                    ex_result_w = rs1_output + rs2_output;
                end
                else if(id_alu_op_r == 2'b01) begin //branch
                    if(id_func3_r == 3'b000) begin  //BEQ
                        if(rs1_output == rs2_output) begin
                            ex_result_w = 0;
                        end
                        else begin
                            ex_result_w = 1;
                        end
                    end
                    else if(id_func3_r == 3'b001) begin //BNE
                        if(rs1_output == rs2_output) begin
                            ex_result_w = 1;
                        end
                        else begin
                            ex_result_w = 0;
                        end
                    end
                    else if(id_func3_r == 3'b100) begin //BLT
                        if($signed(rs1_output) < $signed(rs2_output)) begin
                            ex_result_w = 0;
                        end
                        else begin
                            ex_result_w = 1;
                        end
                    end
                    else if(id_func3_r == 3'b101) begin //BGE
                        if($signed(rs1_output) >= $signed(rs2_output)) begin
                            ex_result_w = 0;
                        end
                        else begin
                            ex_result_w = 1;
                        end
                    end
                    else begin
                        ex_result_w = 1;
                    end
                end
                else if(id_alu_op_r == 2'b10) begin
                    if(id_func3_r == 3'b000 && id_func7_r == 7'b0000000) begin //add
                        ex_result_w = rs1_output + rs2_output;
                    end
                    else if(id_func3_r == 3'b000 && id_func7_r == 7'b0100000) begin //sub
                        ex_result_w = $signed(rs1_output) - $signed(rs2_output);
                    end
                    else if(id_func3_r == 3'b100 && id_func7_r == 7'b0000000) begin //xor
                        ex_result_w = rs1_output ^ rs2_output;
                    end
                    else if(id_func3_r == 3'b111 && id_func7_r == 7'b0000000) begin //and
                        ex_result_w = rs1_output & rs2_output;
                    end
                    else begin //mul
                        ex_result_w = rs1_output * rs2_output; //FIXME: change this into alu in HW2
                    end
                end
                else if(id_alu_op_r == 2'b11) begin //Nothing
                    ex_result_w = 0;
                end
            end
            else begin           // alu source is imm
                if(id_alu_op_r == 2'b00) begin // lw, sw
                    ex_result_w = rs1_output + id_imm_r;
                end
                else if(id_alu_op_r == 2'b01) begin //jal, jalr
                    ex_result_w = PC;
                end
                else if(id_alu_op_r == 2'b10) begin //I type
                    if(id_func3_r == 3'b000) begin // addi
                        ex_result_w = rs1_output + id_imm_r;
                    end
                    else if(id_func3_r == 3'b010) begin //slti
                        if($signed(rs1_output) < $signed(id_imm_r[11:0])) begin
                            ex_result_w = 1;
                        end
                        else begin
                            ex_result_w = 0;
                        end
                    end
                    else if(id_func3_r == 3'b001) begin //slli
                        ex_result_w = rs1_output << id_imm_r;
                    end
                    else if(id_func3_r == 3'b101) begin //srai
                        ex_result_w = $signed(rs1_output) >>> id_imm_r;
                    end
                    else begin //Nothing
                        ex_result_w = 0;
                    end
                end
                else if(id_alu_op_r == 2'b11) begin //auipc
                    ex_result_w = id_imm_r[31:0] + PC - 4;
                end
            end
        end
        else begin
            ex_pc_cal_w   = ex_pc_cal_r;
            ex_memread_w  = ex_memread_r;
            ex_memtoreg_w = ex_memtoreg_r;
            ex_memwrite_w = ex_memwrite_r;
            ex_regwrite_w = ex_regwrite_r; 
            ex_rs1_w      = ex_rs1_r;
            ex_rd_w       = ex_rd_r;
            ex_result_w   = ex_result_r;
            ex_branch_w   = ex_branch_r;
            ex_jump_w     = ex_jump_r;
            ex_jr_w       = ex_jr_r;
            ex_end_w      = ex_end_r;
            ex_reg_rs1_w  = ex_reg_rs1_r;
            ex_reg_rs2_w  = ex_reg_rs2_r;
            ex_imm_w      = ex_imm_r;
        end
    end
//TODO: MEM

    always @(*) begin
        if(i_DMEM_stall == 0) begin
            mem_rs1_w      = ex_rs1_r;
            mem_rd_w       = ex_rd_r;
            mem_result_w   = ex_result_r;
            mem_memtoreg_w = ex_memtoreg_r;
            mem_regwrite_w = ex_regwrite_r;
            mem_memread_w  = ex_memread_r;
            mem_memwrite_w = ex_memwrite_r;
            mem_reg_rs1_w  = ex_reg_rs1_r;
            mem_reg_rs2_w  = ex_reg_rs2_r;
            mem_imm_w      = ex_imm_r;
            mem_jump_w     = ex_jump_r;
            mem_jr_w       = ex_jr_r;
            if(ex_memread_r || ex_memwrite_r) begin
                if(ex_memread_r) begin
                    mem_out_w  = i_DMEM_rdata; 
                end
                else begin
                    mem_out_w = 0;
                end
            end
            // if(mem_memread_r) begin
            //     if(mem_memread_r) begin
            //         mem_out_w  = i_DMEM_rdata; 
            //     end
            //     else begin
            //         mem_out_w = 0;
            //     end
            // end
            else begin
                mem_out_w = 0;
            end
        end
        else begin
            mem_rs1_w      = mem_rs1_r;
            mem_rd_w       = mem_rd_r;
            mem_result_w   = mem_result_r;
            mem_memtoreg_w = mem_memtoreg_r;
            mem_regwrite_w = mem_regwrite_r;
            mem_out_w      = mem_out_r;
            mem_memread_w  = mem_memread_r;
            mem_memwrite_w = mem_memwrite_r;
            mem_reg_rs1_w  = mem_reg_rs1_r;
            mem_reg_rs2_w  = mem_reg_rs2_r;
            mem_imm_w      = mem_imm_r;
            mem_jump_w     = mem_jump_r;
            mem_jr_w       = mem_jr_r;
        end
    end


//TODO: WB

    always @(*) begin
        wb_rd_w = mem_rd_r;
        if(ex_end_r) begin
            wb_regwrite_w = 0;
            wb_rdata_w    = 0;
        end
        else begin
            if(mem_regwrite_r) begin
                if(mem_memtoreg_r) begin
                    wb_regwrite_w = 1;
                    // wb_rdata_w = mem_out_r;
                    wb_rdata_w = i_DMEM_rdata;
                end
                else begin
                    wb_regwrite_w = 1;
                    wb_rdata_w = mem_result_r;
                end
            end
            else begin
                wb_regwrite_w = 0;
                wb_rdata_w = 0;
            end
        end
    end

//TODO: Branch
    always @(*) begin
        if(i_DMEM_stall == 0 && ex_end_r == 0) begin 
            if(ex_branch_r && ex_result_r == 0) begin
                next_PC = ex_pc_cal_r;
            end
            else if(mem_jump_r) begin
                if(mem_jr_r) begin //jalr
                    if(mem_rs1_r == wb_rd_r && wb_regwrite_r) begin
                        next_PC = wb_rdata_r + mem_imm_r;
                    end
                    else begin
                        next_PC = mem_reg_rs1_r + mem_imm_r;
                    end

                end
                else begin //jal
                    next_PC = PC + mem_imm_r - 12;
                end
            end
            else begin
                if((id_rs1_r != ex_rd_r || id_rs1_r == 0) && (id_rs2_r != ex_rd_r || id_rs2_r == 0) && (id_rs1_r != mem_rd_r || id_rs1_r == 0) && (id_rs2_r != mem_rd_r || id_rs2_r == 0)) begin
                    next_PC = PC + 4;
                end
                else begin
                    next_PC = PC;
                end
            end
        end
        else begin
            next_PC = PC;
        end
    end


    always @(*) begin
        if(ex_end_r) begin
            finish_w = 1;
        end 
        else begin
            finish_w = 0;
        end
    end

    // Todo: any combinational/sequential circuit

    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            PC <= 32'h00010000; // Do not modify this value!!!
            id_rs1_r       <= 0;
            id_rs2_r       <= 0;
            id_rd_r        <= 0;
            id_branch_r    <= 0;
            id_memread_r   <= 0;
            id_memtoreg_r  <= 0;
            id_alu_op_r    <= 0;
            id_memwrite_r  <= 0;
            id_alu_src_r   <= 0;
            id_regwrite_r  <= 0;
            id_func3_r     <= 0;
            id_func7_r     <= 0;
            id_jump_r      <= 0;
            id_jr_r        <= 0;
            id_end_r       <= 0;
            id_imm_r       <= 0;
            ex_pc_cal_r    <= 0;
            ex_memread_r   <= 0;
            ex_memtoreg_r  <= 0;
            ex_memwrite_r  <= 0;
            ex_regwrite_r  <= 0; 
            ex_rs1_r       <= 0;
            ex_rd_r        <= 0;
            ex_result_r    <= 0;
            ex_branch_r    <= 0;
            ex_reg_rs1_r   <= 0;
            ex_reg_rs2_r   <= 0;
            ex_imm_r       <= 0;
            ex_end_r       <= 0;
            ex_jump_r      <= 0;
            ex_jr_r        <= 0;
            mem_rs1_r      <= 0;
            mem_rd_r       <= 0;
            mem_result_r   <= 0;
            mem_memtoreg_r <= 0;
            mem_regwrite_r <= 0;
            mem_out_r      <= 0;
            mem_memread_r  <= 0;
            mem_memwrite_r <= 0;
            mem_reg_rs1_r  <= 0;
            mem_reg_rs2_r  <= 0;
            mem_imm_r      <= 0;
            mem_jump_r     <= 0;
            mem_jr_r       <= 0;
            wb_rdata_r     <= 0;
            wb_regwrite_r  <= 0;
            wb_rd_r        <= 0;
            finish_r       <= 0;
        end
        else begin
            PC             <= next_PC;
            id_rs1_r       <= id_rs1_w;
            id_rs2_r       <= id_rs2_w;
            id_rd_r        <= id_rd_w;
            id_branch_r    <= id_branch_w;
            id_memread_r   <= id_memread_w;
            id_memtoreg_r  <= id_memtoreg_w;
            id_alu_op_r    <= id_alu_op_w;
            id_memwrite_r  <= id_memwrite_w;
            id_alu_src_r   <= id_alu_src_w;
            id_regwrite_r  <= id_regwrite_w;
            id_func3_r     <= id_func3_w;
            id_func7_r     <= id_func7_w;
            id_jump_r      <= id_jump_w;
            id_jr_r        <= id_jr_w;
            id_end_r       <= id_end_w;
            id_imm_r       <= id_imm_w;
            ex_pc_cal_r    <= ex_pc_cal_w;
            ex_memread_r   <= ex_memread_w;
            ex_memtoreg_r  <= ex_memtoreg_w;
            ex_memwrite_r  <= ex_memwrite_w;
            ex_regwrite_r  <= ex_regwrite_w; 
            ex_rs1_r       <= ex_rs1_w;
            ex_rd_r        <= ex_rd_w;
            ex_result_r    <= ex_result_w;
            ex_branch_r    <= ex_branch_w;
            ex_reg_rs1_r   <= ex_reg_rs1_w;
            ex_reg_rs2_r   <= ex_reg_rs2_w;
            ex_imm_r       <= ex_imm_w;
            ex_end_r       <= ex_end_w;
            ex_jump_r      <= ex_jump_w;
            ex_jr_r        <= ex_jr_w;
            mem_rs1_r      <= mem_rs1_w;
            mem_rd_r       <= mem_rd_w;
            mem_result_r   <= mem_result_w;
            mem_memtoreg_r <= mem_memtoreg_w;
            mem_regwrite_r <= mem_regwrite_w;
            mem_out_r      <= mem_out_w;
            mem_memread_r  <= mem_memread_w;
            mem_memwrite_r <= mem_memwrite_w;
            mem_reg_rs1_r  <= mem_reg_rs1_w;
            mem_reg_rs2_r  <= mem_reg_rs2_w;
            mem_imm_r      <= mem_imm_w;
            mem_jump_r     <= mem_jump_w;
            mem_jr_r       <= mem_jr_w;
            wb_rdata_r     <= wb_rdata_w;
            wb_regwrite_r  <= wb_regwrite_w;
            wb_rd_r        <= wb_rd_w;
            finish_r       <= finish_w;
        end
    end
endmodule

module Reg_file(i_clk, i_rst_n, wen, rs1, rs2, rd, wdata, rdata1, rdata2);
   
    parameter BITS = 32;
    parameter word_depth = 32;
    parameter addr_width = 5; // 2^addr_width >= word_depth
    
    input i_clk, i_rst_n, wen; // wen: 0:read | 1:write
    input [BITS-1:0] wdata;
    input [addr_width-1:0] rs1, rs2, rd;

    output [BITS-1:0] rdata1, rdata2;

    reg [BITS-1:0] mem [0:word_depth-1];
    reg [BITS-1:0] mem_nxt [0:word_depth-1];

    integer i;

    assign rdata1 = mem[rs1];
    assign rdata2 = mem[rs2];

    always @(*) begin
        for (i=0; i<word_depth; i=i+1)
            mem_nxt[i] = (wen && (rd == i)) ? wdata : mem[i];
    end

    always @(negedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            mem[0] <= 0;
            for (i=1; i<word_depth; i=i+1) begin
                case(i)
                    32'd2: mem[i] <= 32'hbffffff0;
                    32'd3: mem[i] <= 32'h10008000;
                    default: mem[i] <= 32'h0;
                endcase
            end
        end
        else begin
            mem[0] <= 0;
            for (i=1; i<word_depth; i=i+1)
                mem[i] <= mem_nxt[i];
        end       
    end
endmodule

module MULDIV_unit(
    // TODO: port declaration
    );
    // Todo: HW2
endmodule

module Cache#(
        parameter BIT_W = 32,
        parameter ADDR_W = 32
    )(
        input i_clk,
        input i_rst_n,
        // processor interface
            input i_proc_cen,
            input i_proc_wen,
            input [ADDR_W-1:0] i_proc_addr,
            input [BIT_W-1:0]  i_proc_wdata,
            output [BIT_W-1:0] o_proc_rdata,
            output o_proc_stall,
            input i_proc_finish,
            output o_cache_finish,
        // memory interface
            output o_mem_cen,
            output o_mem_wen,
            output [ADDR_W-1:0] o_mem_addr,
            output [BIT_W*4-1:0]  o_mem_wdata,
            input [BIT_W*4-1:0] i_mem_rdata,
            input i_mem_stall,
            output o_cache_available
    );

    assign o_cache_available = 0; // change this value to 1 if the cache is implemented

    //------------------------------------------//
    //          default connection              //
    assign o_mem_cen = i_proc_cen;              //
    assign o_mem_wen = i_proc_wen;              //
    assign o_mem_addr = i_proc_addr;            //
    assign o_mem_wdata = i_proc_wdata;          //
    assign o_proc_rdata = i_mem_rdata[0+:BIT_W];//
    assign o_proc_stall = i_mem_stall;          //
    //------------------------------------------//

    // Todo: BONUS

endmodule