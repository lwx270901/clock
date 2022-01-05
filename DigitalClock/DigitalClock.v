`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:36:50 04/20/2015 
// Design Name: 
// Module Name:    DigitalClock 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

/*
 ------------------------------------------------------------------------------------------------
 | �������ʾ����ר��ģ��
 ------------------------------------------------------------------------------------------------
*/
module clk_7segff_sub(
	input [3:0]NUM,
	output reg[6:0]a_to_g
	);
	
	always @(*)
	case(NUM)
		0:a_to_g=7'b0000001;
		1:a_to_g=7'b1001111;
		2:a_to_g=7'b0010010;
		3:a_to_g=7'b0000110;
		4:a_to_g=7'b1001100;
		5:a_to_g=7'b0100100;
		6:a_to_g=7'b0100000;
		7:a_to_g=7'b0001111;
		8:a_to_g=7'b0000000;
		9:a_to_g=7'b0000100;
		'hA: a_to_g=7'b0001000;
		'hB: a_to_g=7'b1100000;
		'hC: a_to_g=7'b0110001;
		'hD: a_to_g=7'b1000010;
		'hE: a_to_g=7'b0110000;
		'hF: a_to_g=7'b0111000;
		default: a_to_g=7'b0000001;
	endcase
	
endmodule

/*
 ------------------------------------------------------------------------------------------------
 | ��ģ��
 ------------------------------------------------------------------------------------------------
*/

module DigitalClock_top(
	input [7:0]SW,
	input clk,
	input clr,			// Btn0 ���㣬Ĭ�Ͻ���24Сʱ��
	input alarm,		// Btn1 ��������
	input twelve,		// Btn2 12-24Сʱ�л�
	input shift,		// Btn3 ����ʱ�䣬���ǵ�12Сʱ����Ҫ���������磬�û����鲻�ѣ���ֻ����24Сʱ���½���
	output [7:0]led,
	output [3:0]an,
	output [6:0]a_to_g,
	output dp
	);
	
	reg [25:0] counter;						// Ƶ�ʼ�����
	reg colon = 1;							// ��ʾ��ĳ��ʱ����С����Ӧ��Ҫ����ʾ
	reg colonOfSecond = 1;					// ��С�����ڵڶ�λ��ʾ��
	reg [3:0] second_one = 0;           	// ʱ�ӵ���������
	reg [2:0] second_ten = 0;           	// 
	reg [3:0] minute_one = 0;				// 
	reg [3:0] minute_ten = 0;				// 
	reg [3:0] hour_one = 0;					// 
	reg [3:0] hour_ten = 0;					// 
	reg [3:0] alarm_minone = 0;				// ���ӵ��ĸ���������ʼ��Ϊ����12��
	reg [3:0] alarm_minten = 0;				//
	reg [3:0] alarm_hourone = 2;			//
	reg [3:0] alarm_hourten = 1; 			//
	wire [3:0] getalarm;					// �ж��Ƿ�ʱ��
	wire [1:0] s;							// ����һ������µ��������ʾ
	reg [1:0] m = 0;						// ���ڸ���ʱ��ʱ����ܵĽ���
	reg [3:0] l = 0;						// ���ڸ���ʱ��ʱled�Ľ���
	reg [3:0] NUM;							// �����ģ�鴫����
	reg [1:0] shiftMode = 0;				// �����趨ʱ��ģʽ��־λ,���趨�룬���趨���ӣ����趨Сʱ
	reg twelveMode = 0;						// 12-24�л���־�Ĵ�����Ϊ1ʱ����12Сʱ��
	reg [1:0] alarmMode = 0;				// �����趨����ģʽ��־λ,���趨���ӣ����趨Сʱ
	wire [3:0] timerr;
	reg shine = 0;
	// �������
	assign s = counter[16:15];				// ��Ƶ
	assign an[0] = s[0]|s[1]|m[0];			// m���������������������
	assign an[1] = ~s[0]|s[1]|m[0];
	assign an[2] = s[0]|~s[1]|m[1];
	assign an[3] = ~s[0]|~s[1]|m[1];
	assign dp = colonOfSecond;
	assign led[6:4] = second_ten|l;			// l�������������ĸ�led��
	assign led[3:0] = second_one|l;
	assign led[7] = shine;
	assign getalarm = alarm_minone^minute_one | alarm_hourone^hour_one | alarm_minten^minute_ten | alarm_hourten^hour_ten;	// �жϺ�ʱ���������趨ʱ��
   assign timerr = minute_ten^(4'b0000) |  minute_one^(4'b0000);
	// ����Btn1������������ģʽ
	always @(posedge alarm) begin
		alarmMode = alarmMode + 1;
		if(alarmMode==3) alarmMode = alarmMode + 1; // �������õ�һ���Ϊ���Ӳ�������
	end
	// ����Btn2�����޸�ʱ��ģʽ
	always @(posedge twelve)
		twelveMode = twelveMode + 1;
	// ����Btn3�����޸�ʱ��ģʽ
	always @(posedge shift)
		shiftMode = shiftMode + 1;

	always @(posedge clk) begin
		counter = counter + 1;
		/*
	 	 * һ������
	 	 */
		if(clr==1) begin
			counter = 0;
			second_one = 0;
			second_ten = 0;
			minute_one = 0;
			minute_ten = 0;
			hour_one = 0;
			hour_ten = 0;
			alarm_minone = 0;
			alarm_minten = 0;
			alarm_hourone = 2;	// ����ʱ������������12����
			alarm_hourten = 1;
			m=0;
			l=0;
		end
      
		/*������ʾʱ��ģʽ*/
		if(!shiftMode) begin
			m=0;	// ��ʼ���������LED
			l=0;
			if(counter>50000000) begin//1 							// ÿһ��һ�����Ƕ�Ҫ�������ж�
				counter = 0;										// 0.�ڲ�ʱ������
				colon = colon + 1;									// 1.С������˸,2sһ������
				second_one = second_one + 1;						// 2.����+1
				if(second_one==10) begin//2
					second_one = 0;
					second_ten = second_ten + 1;
					if(second_ten==6) begin//3
						second_ten = 0;
						minute_one = minute_one + 1;				// 3.һ���ӹ�ȥ��
						if(minute_one==10) begin//4
							minute_one = 0;
							minute_ten = minute_ten + 1;
							if(minute_ten==6) begin//5
								minute_ten = 0;
								hour_one = hour_one + 1;			// 4.һСʱ��ȥ��
								if(hour_one==10) begin 				
									hour_one = 0;
									hour_ten = hour_ten + 1;
								end
								else if(hour_one==4) begin
									if(hour_ten==2) begin
									hour_one = 0;					//5.һ���ȥ��
									hour_ten = 0;
									end
								end 
							end//5
						end//4
					end//3
				end//2
			end//1
			if(!alarmMode) begin
			// �ж�ʲôʱ����ʾð��
			if(s==2) colonOfSecond = colon;
			else colonOfSecond = 1;
			// ��Ƶ����������ʾ���
			if(getalarm==0) begin
				 case(colon)
			       1:m[1:0] = 2'b11;
			       0:m[1:0] = 2'b00;
			    endcase
				 if(!colon) begin	// 24 hour
					case(s) 
						3:NUM = hour_ten;
						2:NUM = hour_one;
						1:NUM = minute_ten;
						0:NUM = minute_one;
					endcase
				 end
			end
			else begin
	 	 		if(!twelveMode) begin	// 24 hour
					case(s) 
						3:NUM = hour_ten;
						2:NUM = hour_one;
						1:NUM = minute_ten;
						0:NUM = minute_one;
					endcase
				end
				else begin			// 12 hour
					case(s) 
						3: 	if(hour_ten==1) begin
								if(hour_one<3) NUM = hour_ten;
								else NUM = hour_ten - 1; 
							end
							else begin
								if(hour_ten==0) NUM = hour_ten; 
								else begin
									if(hour_ten==2) 
										if(hour_one==0) NUM = 4'b0000;
										else if(hour_ten==2) 
											if(hour_one==1) NUM = 4'b0000;
											else NUM = 1;
								end
							end
						2: 	if(hour_ten==1)
								if(hour_one<3) NUM = hour_one;
								else NUM = hour_one - 2; 
							else begin
								if(hour_ten==0) NUM = hour_one; 
								else begin
									if(hour_ten==2) 
										if(hour_one==0) NUM = 4'b1000;
										else if(hour_ten==2) 
											if(hour_one==1) NUM = 4'b1001;
											else NUM = hour_one - 2;
								end
							end
						1:	NUM = minute_ten;
						0:	NUM = minute_one;
					endcase
				end
			end
		end
		end
		
		/*���㱨ʱ*/
		if(timerr==0) begin
			case(colon)
			1: shine = 1;
			0: shine = 0;
			endcase
		   end
		if(timerr!=0) shine = 0;
		
		/*
		 * ��ʱ��ģʽ
		 */ 
	 	// �趨��������ʾ��led��
	 	if(alarmMode==0) begin
		if(shiftMode==1) begin
			m[1:0] = 2'b11;	// ����ܽ���
			l = 4'b0000;	// LED����
			if(SW[6:4]>5) second_ten = 0; else second_ten = SW[6:4];
			if(SW[3:0]>9) second_one[3:0] = 0; else second_one[3:0] = SW[3:0];
		end
		end
	 	// ���÷���������ʾ�����������λ
	 	if(alarmMode==0) begin
		if(shiftMode==2) begin
			l = 4'b1111;		// LED����
			m[1:0] = 2'b10;		// ����ܽ������λ
			// �����������ʾ����������һ����ֵ�Ա���
			case(counter[15]) 
				1: if(SW[7:4]<6) NUM = SW[7:4]; else NUM = 0;
				0: if(SW[3:0]<10) NUM = SW[3:0]; else NUM = 0;
			endcase
			// ��Ϊ�������ʾ������ģ�����Ҫ�����ȶ��ĸ�ֵ������������ܵ���ʾֵһ��
			if(SW[7:4]<6) minute_ten = SW[7:4]; else minute_ten = 0;
			if(SW[3:0]<10) minute_one = SW[3:0]; else minute_one = 0;
		end
		end
	 	// ����Сʱ����Сʱ�����������λ
	 	if(alarmMode==0) begin
		if(shiftMode==3) begin
			l = 4'b1111;		// LED����
			m[1:0] = 2'b01;		// ����ܽ����Ҷ�λ
			// �����������ʾ����������һ����ֵ�Ա���,�����÷�����ʱ���в�ͬ
			case(counter[15]) 
				1: if(SW[7:4]<3) NUM = SW[7:4]; else NUM = 0;
				0: if(SW[7:4]==2) 
						if(SW[3:0]<4) NUM = SW[3:0]; else NUM = 0;
					else 
						if(SW[3:0]<10) NUM = SW[3:0]; else NUM = 0;
			endcase
			// ���ø�ֵ������������ܵ���ʾֵһ��,�����÷�����ʱ���в�ͬ
			if(SW[7:4]<3) hour_ten = SW[7:4]; else hour_ten = 0;
			if(SW[7:4]==2) 
				if(SW[3:0]<4) hour_one = SW[3:0]; else hour_one = 0;
			else 
				if(SW[3:0]<10) hour_one = SW[3:0]; else hour_one = 0;
		end
		end
		/*
		 * ������ģʽ������ʵ�ֺ����������ͬ
		 */ 
		// ���÷���������ʾ�����������λ
		if(shiftMode==0) begin
		if(alarmMode==1) begin
			l = 4'b1111;
			m[1:0] = 2'b10;
			case(counter[15]) 
				1: if(SW[7:4]<6) NUM = SW[7:4]; else NUM = 0;
				0: if(SW[3:0]<10) NUM = SW[3:0]; else NUM = 0;
			endcase
			if(SW[7:4]<6) alarm_minten = SW[7:4]; else alarm_minten = 0;
			if(SW[3:0]<10) alarm_minone = SW[3:0]; else alarm_minone = 0;
		end
		end
	 	// ����Сʱ����Сʱ�����������λ	
		if(shiftMode==0) begin
		if(alarmMode==2) begin
			l = 4'b1111;
			m[1:0] = 2'b01;
			case(counter[15]) 
				1: if(SW[7:4]<3) NUM = SW[7:4]; else NUM = 0;
				0: if(SW[7:4]==2) 
						if(SW[3:0]<4) NUM = SW[3:0]; else NUM = 0;
					else 
						if(SW[3:0]<10) NUM = SW[3:0]; else NUM = 0;
			endcase
			if(SW[7:4]<3) alarm_hourten = SW[7:4]; else alarm_hourten = 0;
			if(SW[7:4]==2) 
				if(SW[3:0]<4) alarm_hourone = SW[3:0]; else alarm_hourone = 0;
			else 
				if(SW[3:0]<10) alarm_hourone = SW[3:0]; else alarm_hourone = 0;
		end
		end
	end
		
	clk_7segff_sub A1(.NUM(NUM),.a_to_g(a_to_g));
	

endmodule
