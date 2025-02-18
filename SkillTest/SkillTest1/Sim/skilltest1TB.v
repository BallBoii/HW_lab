`timescale 1ns / 1ps
// Do not modify this file!
module skilltest1TB ();
  // reg/wire declaration
  reg        Clk;
  reg        Reset;
  reg  [3:0] Trigger;
  wire [3:0] BCD0;
  wire [3:0] BCD1;
  wire [3:0] BCD2;
  wire [3:0] BCD3;

  // instantiate the Multiplexer module
  skilltest1 DUT (
      .Clk(Clk),
      .Reset(Reset),
      .Trigger(Trigger),
      .BCD0(BCD0),
      .BCD1(BCD1),
      .BCD2(BCD2),
      .BCD3(BCD3)
  );

  // instantiate variables
  integer i, j;
  integer        TotalScore = 0;
  reg     [30:0] TestcaseResult = 0;
  reg     [ 7:0] TestcaseResultDisplay = 0;
  integer        TestcaseStart             [7:0];
  integer        TestcaseEnd               [7:0];
  integer        TestcaseScore             [7:0];
  integer        flag = 0;

  // Define the clock parameters
  localparam CLK_PERIOD = 10;
  localparam CLK_OFFSET = 1;
  localparam DEBOUNCE_TIME = 1024;
  localparam WORKING_OFFSET = 4;
  always #(CLK_PERIOD / 2.0) Clk = ~Clk;

  // task to give trigger
  task give_trigger;
    input reg [3:0] trigger;
    input integer wait_time;
    begin
      Trigger = trigger;
      #(CLK_PERIOD);
      Trigger = 4'b0000;
      #(CLK_PERIOD * wait_time);
    end
  endtask

  task reset_system;
    begin
      Reset = 1;
      #(CLK_PERIOD);
      Reset = 0;
      #(CLK_PERIOD * WORKING_OFFSET);
    end
  endtask

  // task to check the output
  task check_output;
    input integer TestCaseNo;
    input reg [3:0] expected_BCD3;  // Expected output
    input reg [3:0] expected_BCD2;  // Expected output
    input reg [3:0] expected_BCD1;  // Expected output
    input reg [3:0] expected_BCD0;  // Expected output
    begin
      if (BCD0 !== expected_BCD0 || BCD1 !== expected_BCD1 || BCD2 !== expected_BCD2 || BCD3 !== expected_BCD3) begin
        TestcaseResult[TestCaseNo] = 0;
      end else begin
        TestcaseResult[TestCaseNo] = 1;
      end
    end
  endtask

  // task to display the test results
  task display_test_results;
    begin
      $display("Test Results:");
      for (i = 0; i < 8; i = i + 1) begin
        flag = 0;
        for (j = TestcaseStart[i]; j <= TestcaseEnd[i]; j = j + 1) begin
          if (TestcaseResult[j] == 0) begin
            flag = 1;
          end
        end
        if (flag == 1) begin
          TestcaseResultDisplay[i] = 0;
          $display("Criteria %0d: Failed", i + 1);
        end else begin
          TestcaseResultDisplay[i] = 1;
          TotalScore = TotalScore + TestcaseScore[i];
        end
      end
      for (i = 0; i < 8; i = i + 1) begin
        if (TestcaseResultDisplay[i] == 1) begin
          $write("P");
        end else begin
          $write("X");
        end
      end
      $display("");
      $display("Total Score: %0d/100", TotalScore);
    end
  endtask



  // test cases
  initial begin
    // Initialize some boundary
    TestcaseStart[0] = 0;
    TestcaseEnd[0]   = 4;
    TestcaseScore[0] = 10;
    TestcaseStart[1] = 5;
    TestcaseEnd[1]   = 8;
    TestcaseScore[1] = 15;
    TestcaseStart[2] = 9;
    TestcaseEnd[2]   = 12;
    TestcaseScore[2] = 15;
    TestcaseStart[3] = 13;
    TestcaseEnd[3]   = 15;
    TestcaseScore[3] = 15;
    TestcaseStart[4] = 16;
    TestcaseEnd[4]   = 17;
    TestcaseScore[4] = 15;
    TestcaseStart[5] = 18;
    TestcaseEnd[5]   = 22;
    TestcaseScore[5] = 15;
    TestcaseStart[6] = 23;
    TestcaseEnd[6]   = 26;
    TestcaseScore[6] = 10;
    TestcaseStart[7] = 27;
    TestcaseEnd[7]   = 30;
    TestcaseScore[7] = 5;
    $display("Running test cases");
    // Initialize the inputs
    Clk = 0;
    Reset = 0;
    Trigger = 4'b0000;
    #(CLK_PERIOD + CLK_OFFSET);  // Wait for 1 clock cycle and add delay for easier debugging

    /*** RESET Criteria ***/
    // Test case 0 - Typical Reset
    reset_system;
    check_output(0, 4'b0000, 4'b0000, 4'b0000, 4'b0000);
    #(CLK_PERIOD);
    // Test case 1-4 - Reset with Trigger#i
    for (i = 0; i < 4; i = i + 1) begin
      Reset   = 1;
      Trigger = 4'b0001;
      #(CLK_PERIOD);
      Reset   = 0;
      Trigger = 4'b0000;
      #(CLK_PERIOD * WORKING_OFFSET);
      check_output(i + 1, 4'b0000, 4'b0000, 4'b0000, 4'b0000);
      #(CLK_PERIOD);
    end

    /*** Trigger#1 Criteria ***/
    // Test case 5 - +1 to 2
    give_trigger(4'b0001, WORKING_OFFSET);
    check_output(5, 4'b0000, 4'b0000, 4'b0000, 4'b0001);
    #(CLK_PERIOD * DEBOUNCE_TIME);
    // Test case 6 - +1 10 time
    for (i = 0; i < 10; i = i + 1) begin
      give_trigger(4'b0001, DEBOUNCE_TIME + 1);
    end
    check_output(6, 4'b0000, 4'b0000, 4'b0001, 4'b0001);
    // Test case 7 - +1 100 time
    for (i = 0; i < 100; i = i + 1) begin
      give_trigger(4'b0001, DEBOUNCE_TIME + 1);
    end
    check_output(7, 4'b0000, 4'b0001, 4'b0001, 4'b0001);
    // Test case 8 - +1 to 9999
    for (i = 0; i < 9888; i = i + 1) begin
      give_trigger(4'b0001, DEBOUNCE_TIME + 1);
    end
    check_output(8, 4'b1001, 4'b1001, 4'b1001, 4'b1001);

    /*** Trigger#2 Criteria ***/
    // Reset
    reset_system;
    // Test case 9 - +3 to 3
    give_trigger(4'b0010, WORKING_OFFSET);
    check_output(9, 4'b0000, 4'b0000, 4'b0000, 4'b0011);
    #(CLK_PERIOD * DEBOUNCE_TIME);
    // Test case 10 - +3 10 time
    for (i = 0; i < 10; i = i + 1) begin
      give_trigger(4'b0010, DEBOUNCE_TIME + 1);
    end
    check_output(10, 4'b0000, 4'b0000, 4'b0011, 4'b0011);
    // Test case 11 - +3 100 time
    for (i = 0; i < 100; i = i + 1) begin
      give_trigger(4'b0010, DEBOUNCE_TIME + 1);
    end
    check_output(11, 4'b0000, 4'b0011, 4'b0011, 4'b0011);
    // Test case 12 - +3 to 9999
    for (i = 0; i < 3222; i = i + 1) begin
      give_trigger(4'b0010, DEBOUNCE_TIME + 1);
    end
    check_output(12, 4'b1001, 4'b1001, 4'b1001, 4'b1001);

    /*** Trigger#3 Criteria ***/
    // Reset
    reset_system;
    give_trigger(4'b0001, DEBOUNCE_TIME + 1);
    // Test case 13 - *2 to 2
    give_trigger(4'b0100, WORKING_OFFSET);
    check_output(13, 4'b0000, 4'b0000, 4'b0000, 4'b0010);
    #(CLK_PERIOD * DEBOUNCE_TIME);
    // Test case 14 - *2 to 128
    for (i = 0; i < 6; i = i + 1) begin
      give_trigger(4'b0100, DEBOUNCE_TIME + 1);
    end
    check_output(14, 4'b0000, 4'b0001, 4'b0010, 4'b1000);
    // Test case 15 - *2 to 8192
    for (i = 0; i < 6; i = i + 1) begin
      give_trigger(4'b0100, DEBOUNCE_TIME + 1);
    end
    check_output(15, 4'b1000, 4'b0001, 4'b1001, 4'b0010);

    /*** Trigger#4 Criteria ***/
    // Reset
    reset_system;
    give_trigger(4'b0001, DEBOUNCE_TIME + 1);
    // Test case 16 - *3 to 3
    give_trigger(4'b1000, WORKING_OFFSET);
    check_output(16, 4'b0000, 4'b0000, 4'b0000, 4'b0011);
    #(CLK_PERIOD * DEBOUNCE_TIME);
    // Test case 17 - *3 to 6561
    for (i = 0; i < 7; i = i + 1) begin
      give_trigger(4'b1000, DEBOUNCE_TIME + 1);
    end
    check_output(17, 4'b0110, 4'b0101, 4'b0110, 4'b0001);

    /*** Overflow Criteria ***/
    // Reset
    reset_system;
    // Test case 18 - Trigger#0 Till overflow
    for (i = 0; i < 10002; i = i + 1) begin
      give_trigger(4'b0001, DEBOUNCE_TIME + 1);
    end
    check_output(18, 4'b1111, 4'b1111, 4'b1111, 4'b1111);
    // Test case 19 - Trigger#1 Till overflow
    reset_system;
    for (i = 0; i < 3335; i = i + 1) begin
      give_trigger(4'b0010, DEBOUNCE_TIME + 1);
    end
    check_output(19, 4'b1111, 4'b1111, 4'b1111, 4'b1111);
    // Test case 20 - Trigger#2 Till overflow
    reset_system;
    give_trigger(4'b0001, DEBOUNCE_TIME + 1);
    for (i = 0; i < 20; i = i + 1) begin
      give_trigger(4'b0100, DEBOUNCE_TIME + 1);
    end
    check_output(20, 4'b1111, 4'b1111, 4'b1111, 4'b1111);
    // Test case 21 - Trigger#3 Till overflow
    reset_system;
    give_trigger(4'b0001, DEBOUNCE_TIME + 1);
    for (i = 0; i < 20; i = i + 1) begin
      give_trigger(4'b1000, DEBOUNCE_TIME + 1);
    end
    check_output(21, 4'b1111, 4'b1111, 4'b1111, 4'b1111);
    // Test case 22 - Some Trigger after overflow
    give_trigger(4'b0001, DEBOUNCE_TIME + 1);
    give_trigger(4'b0010, DEBOUNCE_TIME + 1);
    give_trigger(4'b0100, DEBOUNCE_TIME + 1);
    give_trigger(4'b1000, DEBOUNCE_TIME + 1);
    check_output(22, 4'b1111, 4'b1111, 4'b1111, 4'b1111);
    #(CLK_PERIOD * DEBOUNCE_TIME);

    /*** Continuous Trigger Criteria ***/
    // Reset
    reset_system;
    // Test case 23 - Continuous Trigger#1
    Trigger = 4'b0001;
    #(CLK_PERIOD * DEBOUNCE_TIME * 4);
    Trigger = 4'b0000;
    check_output(23, 4'b0000, 4'b0000, 4'b0000, 4'b0001);
    #(CLK_PERIOD);
    // Test case 24 - Continuous Trigger#2
    Trigger = 4'b0010;
    #(CLK_PERIOD * DEBOUNCE_TIME * 4);
    Trigger = 4'b0000;
    check_output(24, 4'b0000, 4'b0000, 4'b0000, 4'b0100);
    #(CLK_PERIOD);
    // Test case 25 - Continuous Trigger#3
    Trigger = 4'b0100;
    #(CLK_PERIOD * DEBOUNCE_TIME * 4);
    Trigger = 4'b0000;
    check_output(25, 4'b0000, 4'b0000, 4'b0000, 4'b1000);
    #(CLK_PERIOD);
    // Test case 26 - Continuous Trigger#4
    Trigger = 4'b1000;
    #(CLK_PERIOD * DEBOUNCE_TIME * 4);
    Trigger = 4'b0000;
    check_output(26, 4'b0000, 4'b0000, 4'b0010, 4'b0100);
    #(CLK_PERIOD);

    /*** Debounce Criteria ***/
    // Reset
    reset_system;
    // Test case 27 - Debounce Trigger#1
    Trigger = 4'b0001;
    #(CLK_PERIOD * 3);
    Trigger = 4'b0000;
    #(CLK_PERIOD * 10);
    Trigger = 4'b0001;
    #(CLK_PERIOD * 100);
    Trigger = 4'b0000;
    #(CLK_PERIOD * 1000);
    check_output(27, 4'b0000, 4'b0000, 4'b0000, 4'b0001);
    // Test case 28 - Debounce Trigger#2
    Trigger = 4'b0010;
    #(CLK_PERIOD * 3);
    Trigger = 4'b0000;
    #(CLK_PERIOD * 10);
    Trigger = 4'b0010;
    #(CLK_PERIOD * 100);
    Trigger = 4'b0000;
    #(CLK_PERIOD * 1000);
    check_output(28, 4'b0000, 4'b0000, 4'b0000, 4'b0100);
    // Test case 29 - Debounce Trigger#3
    Trigger = 4'b0100;
    #(CLK_PERIOD * 3);
    Trigger = 4'b0000;
    #(CLK_PERIOD * 10);
    Trigger = 4'b0100;
    #(CLK_PERIOD * 100);
    Trigger = 4'b0000;
    #(CLK_PERIOD * 1000);
    check_output(29, 4'b0000, 4'b0000, 4'b0000, 4'b1000);
    // Test case 30 - Debounce Trigger#4
    Trigger = 4'b1000;
    #(CLK_PERIOD * 3);
    Trigger = 4'b0000;
    #(CLK_PERIOD * 10);
    Trigger = 4'b1000;
    #(CLK_PERIOD * 100);
    Trigger = 4'b0000;
    #(CLK_PERIOD * 1000);
    check_output(30, 4'b0000, 4'b0000, 4'b0010, 4'b0100);

    $display("Finished test cases");
    display_test_results;
    $finish;
  end
endmodule
