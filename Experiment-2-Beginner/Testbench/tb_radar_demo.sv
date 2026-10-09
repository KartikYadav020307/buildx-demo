`timescale 1ns / 1ps
module tb_radar_demo;
    reg clk=0;always #10 clk=~clk;
    reg reset=1,start=0,gap_mode=0;
    reg [1:0] scenario=0,scale_shift=2;
    wire busy,done,timeout_error;
    wire [7:0] detection_count;
    wire [15:0] result_count,target_pos0,target_pos1,target_pos2;
    wire [127:0] detection_mask;
    wire [15:0] last_threshold,run_cycles,frame_id;
    wire [18:0] last_threshold_full;
    wire [1:0] active_scenario,active_scale;
    wire active_gap;
    radar_demo dut(.*);
    integer tests=0,fd,cycles,i,j,g;
    reg [15:0] old_id;
    reg [127:0] expected_mask;
    string outdir=".";
    task run_case(input integer sc,input integer a,input integer gap);
        integer count_expected;
        begin
            @(negedge clk);start=0;scenario=sc;scale_shift=a;gap_mode=gap;
            old_id=frame_id;
            @(negedge clk);start=1;
            @(negedge clk);start=0;
            // While busy, altered live controls must not alter a latched frame.
            scenario=0;scale_shift=0;gap_mode=0;
            cycles=0;
            while((!done || frame_id==old_id) && cycles<1100) begin
                @(negedge clk);cycles=cycles+1;
            end
            if(!done||busy||timeout_error||result_count!=80||frame_id!=old_id+1)
                $fatal(1,"Frame completion failed sc=%0d a=%0d gap=%0d",sc,a,gap);
            if(active_scenario!=sc||active_scale!=a||active_gap!=gap)
                $fatal(1,"Latched controls mismatch");
            expected_mask=0;
            if(sc==1) expected_mask=(128'b1<<30)|(128'b1<<60)|(128'b1<<85);
            if(sc==2 && a<=1) expected_mask=128'b1<<30;
            if(sc==3 && a<=1) expected_mask=128'b1<<30;
            count_expected=(sc==1)?3:((expected_mask!=0)?1:0);
            if(detection_count!=count_expected || detection_mask!==expected_mask)
                $fatal(1,"Detection mismatch sc=%0d a=%0d got=%0d",sc,a,detection_count);
            if(target_pos0!=((count_expected>0)?30:65535)||
               target_pos1!=((count_expected==3)?60:65535)||
               target_pos2!=((count_expected==3)?85:65535)) $fatal(1,"Position mismatch");
            if(last_threshold_full!=((sc==3)?20000:(sc==1)?150:100)*(1<<a) ||
               last_threshold!=((((sc==3)?20000:(sc==1)?150:100)*(1<<a)>65535)?65535:((sc==3)?20000:(sc==1)?150:100)*(1<<a)))
                $fatal(1,"Final threshold mismatch");
            if(run_cycles!=((gap==0)?104:302))
                $fatal(1,"Cycle count mismatch got=%0d gap=%0d",run_cycles,gap);
            tests=tests+1;
            $display("DEMO PASS sc=%0d alpha=%0d gap=%0d detections=%0d results=%0d cycles=%0d",
                sc,1<<a,gap,detection_count,result_count,run_cycles);
            // Results and done must remain stable while idle.
            repeat(8) @(negedge clk);
            if(!done||result_count!=80||detection_mask!==expected_mask)$fatal(1,"Results not retained");
        end
    endtask
    initial begin
        if($value$plusargs("OUTDIR=%s",outdir)) begin end
`ifdef __ICARUS__
        $dumpfile("Simulation/radar_demo.vcd");$dumpvars(0,tb_radar_demo);
`endif
        repeat(4) @(negedge clk); reset=0;
        for(i=0;i<4;i=i+1)for(j=0;j<4;j=j+1)for(g=0;g<2;g=g+1)run_case(i,j,g);
        // Held start causes one frame only.
        @(negedge clk);start=1;scenario=1;scale_shift=2;old_id=frame_id;
        repeat(150) @(negedge clk);
        if(!done||frame_id!=old_id+1)$fatal(1,"Held start repeats a frame");
        @(negedge clk);start=0;
        // An active frame can be reset, followed by a clean repeat.
        @(negedge clk);start=1;
        repeat(30) @(negedge clk);reset=1;start=0;
        repeat(3) @(negedge clk);reset=0;
        if(busy||done||frame_id!=0||result_count!=0)$fatal(1,"Reset failed");
        run_case(1,2,0);
        fd=$fopen({outdir,"/Results/tb_radar_demo_PASS.txt"},"w");
        if(!fd)$fatal(1,"Cannot write PASS marker");
        $fdisplay(fd,"PASS frame_checks=%0d plus held-start and active-reset",tests);$fclose(fd);
        $display("DEMO SIMULATION PASS: %0d frame checks",tests);$finish;
    end
    initial begin #500000;$fatal(1,"Demo watchdog timeout");end
endmodule
