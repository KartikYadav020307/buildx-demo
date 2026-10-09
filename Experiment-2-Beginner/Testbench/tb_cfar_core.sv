`timescale 1ns / 1ps
module tb_cfar_core;
    reg clk=0; always #10 clk=~clk;
    reg reset=1, data_valid=0;
    reg [15:0] data_in=0;
    reg [1:0] scale_shift=2;
    wire result_valid, target_detected;
    wire [15:0] threshold_value, cut_value, cut_index;
    wire [18:0] threshold_full;
    cfar_core dut(.*);
    integer samples[0:4095];
    integer ev_valid[0:40000], ev_thr[0:40000], ev_cut[0:40000];
    integer ev_index[0:40000], ev_detect[0:40000];
    integer cycle=0, accepted=0, checked=0, total_accepted=0;
    integer i,j,s,th,k,fd,csv,case_id=0;
    reg [31:0] rng=32'h41cf2026;
    string outdir=".";

    // Independent chronological-array reference model, not the RTL delay line.
    always @(posedge clk) begin
        if(reset) begin
            accepted=0;
            for(j=0;j<3;j=j+1) ev_valid[cycle+j]=0;
        end else if(data_valid) begin
            if(accepted>=4096) $fatal(1,"Reference frame too large");
            samples[accepted]=data_in;
            if(accepted>=20) begin
                s=0;
                for(j=accepted-20;j<=accepted-13;j=j+1) s=s+samples[j];
                for(j=accepted-7;j<=accepted;j=j+1) s=s+samples[j];
                th=(s/16)*(1<<scale_shift);
                ev_valid[cycle+2]=1; ev_thr[cycle+2]=th;
                ev_cut[cycle+2]=samples[accepted-10];
                ev_index[cycle+2]=accepted-10;
                ev_detect[cycle+2]=(samples[accepted-10]>th);
            end
            accepted=accepted+1; total_accepted=total_accepted+1;
        end
        #1;
        if(result_valid !== (ev_valid[cycle]!=0))
            $fatal(1,"valid mismatch cycle=%0d case=%0d",cycle,case_id);
        if(ev_valid[cycle]) begin
            if(threshold_full !== ev_thr[cycle] ||
               threshold_value !== ((ev_thr[cycle]>65535)?65535:ev_thr[cycle]) ||
               cut_value !== ev_cut[cycle] || cut_index !== ev_index[cycle] ||
               target_detected !== (ev_detect[cycle]!=0))
                $fatal(1,"CFAR mismatch case=%0d cycle=%0d index=%0d got_thr=%0d exp_thr=%0d",
                    case_id,cycle,cut_index,threshold_full,ev_thr[cycle]);
            checked=checked+1;
            if(case_id==1) $fdisplay(csv,"%0d,%0d,%0d,%0d",cut_index,cut_value,threshold_full,target_detected);
        end else if(target_detected !== 1'b0) $fatal(1,"Detection without valid result");
        cycle=cycle+1;
    end
    task tick(input integer v,input integer d,input integer a);
        begin @(negedge clk); data_valid=v; data_in=d; scale_shift=a; end
    endtask
    task reset_frame;
        begin
            @(negedge clk); reset=1; data_valid=0;
            repeat(3) @(negedge clk);
            reset=0;
        end
    endtask
    task drain;
        begin tick(0,0,2); repeat(5) @(negedge clk); end
    endtask
    function integer next_random;
        begin rng=rng*32'd1664525+32'd1013904223; next_random=rng[30:0]; end
    endfunction
    initial begin
        for(k=0;k<40001;k=k+1) begin
            ev_valid[k]=0;ev_thr[k]=0;ev_cut[k]=0;ev_index[k]=0;ev_detect[k]=0;
        end
        if($value$plusargs("OUTDIR=%s",outdir)) begin end
        csv=$fopen({outdir,"/Simulation/core_standard_results.csv"},"w");
        if(!csv) $fatal(1,"Cannot write Simulation/core_standard_results.csv");
        $fdisplay(csv,"cut_index,cut_value,threshold_full,detected");
`ifdef __ICARUS__
        $dumpfile("Simulation/cfar_core.vcd"); $dumpvars(0,tb_cfar_core);
`endif
        reset_frame(); case_id=1;
        for(i=0;i<100;i=i+1)
            tick(1,(i==30)?1000:(i==60)?1200:(i==85)?900:100,2);
        drain();
        // Directed overflow, equality, guard isolation, and integer rounding.
        for(case_id=2;case_id<=9;case_id=case_id+1) begin
            reset_frame();
            for(i=0;i<100;i=i+1) begin
                case(case_id)
                    2: tick(1,65535,3);
                    3: tick(1,(i==30)?60000:20000,2);
                    4: tick(1,(i==30)?400:100,2); // Equality must not detect.
                    5: tick(1,(i>=29&&i<=31)?1000:100,2);
                    6: tick(1,100+(i%3),2); // Truncate average before scaling.
                    7: tick(1,(i==30)?300:100,1);
                    8: tick(1,(i==30)?300:100,2);
                    9: begin tick(1,(i==30)?1000:100,2); tick(0,65535,0);tick(0,1,3);end
                endcase
            end
            drain();
        end
        // Deterministic randomized frames: all widths, stalls and per-window alpha.
        for(case_id=10;case_id<110;case_id=case_id+1) begin
            reset_frame();
            for(i=0;i<120;i=i+1) begin
                tick(1,next_random()%65536,next_random()%4);
                for(k=0;k<(case_id%4);k=k+1)
                    tick(0,next_random()%65536,next_random()%4);
            end
            drain();
        end
        // Short frames produce no outputs; reset aborts in-flight outputs.
        case_id=110;reset_frame();for(i=0;i<20;i=i+1)tick(1,100,2);drain();
        case_id=111;reset_frame();for(i=0;i<22;i=i+1)tick(1,1000,2);
        reset_frame();for(i=0;i<21;i=i+1)tick(1,123,0);drain();
        $fclose(csv);
        fd=$fopen({outdir,"/Results/tb_cfar_core_PASS.txt"},"w");
        if(!fd) $fatal(1,"Cannot write PASS marker");
        $fdisplay(fd,"PASS checked=%0d accepted=%0d directed_and_random_frames=112",checked,total_accepted);
        $fclose(fd);
        $display("CORE SIMULATION PASS: checked=%0d accepted=%0d",checked,total_accepted);
        $finish;
    end
    initial begin #900000; $fatal(1,"Core test watchdog timeout"); end
endmodule
