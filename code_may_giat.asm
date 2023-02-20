;DAU BAI: dk may giat (dong co 1 chieu+ H)
;ban dau dong co STOP
;NEU NHAN DC: P thì dong co quay Phai
;NEU NHAN DC: T thi dong co quay Trai
;NEU NHAN DC: D thi dong co Dung
;NEU NHAN DC: G thi quay trai 3s
;             roi dung 1s
;			  ròi phai 3s
;			  roi dung 1s ... va lap lai

dk1 BIT P1.3
dk2 BIT P1.5
	
ORG 0
	; ban dau dong co Dung
	CLR dk1
	CLR dk2
	
	MOV TMOD,#21H    ; TIMER1 MODE 2 (8 BIT-AUTO RELOAD)
	                 ; TIMER0 MODE 1 (16 BIT)
	MOV TH1, #0FDH	 ; FDH <==> 9600 BPS
	SETB TR1		 ; START TIMER1
	MOV SCON, #50H   ; UART ENABLE TX, ENABLE RX
	
	;BIT SMOD DEFAULT = 0
	;BIT SMOD=1 THI TOC DO TRUYEN X 2
	;MUON TREN TOC DO 19200 -> THIET LAP 9600, BAT SMOD=1
	MOV A, PCON ; SAO CHEP THANH GHI DIEU KHIEN CHUONG TRINH
	SETB ACC.7  ; DAT BIT 7  = 1 (BIT CAO NHAT, DAY LA BIT SMOD)
	MOV PCON, A ; COPY TRA LAI PCON
	
	MOV A,#'D'  ; KO CAN NHAN, A BAN DAU LA 'D' SAN
	MAIN:
		ACALL nhan1kitu
		acall dieukhienDC
	JMP MAIN
	
	nhan1kitu:
		CLR RI   	;1. bat dau NHAN 1 KITU VE
		WAIT:
			acall dieukhienDC
		JNB RI, WAIT  ;2. doi nhan xong		
		MOV A, SBUF ;3. lay ki tu nhan dc		
	RET
	
	dieukhienDC:
		;ki tu dieu khien trong A
		cjne A,#'P',ko_phai_P
			;quay phai
			ACALL PHAI
			MOV A,#0   ; A KO CON LA 'P' NUA
			ret
		ko_phai_P:
		
		cjne A,#'T',ko_phai_T
			;quay trai
			ACALL TRAI
			MOV A,#0   ; A KO CON LA 'T' NUA
			RET
		ko_phai_T:
		
		
		cjne A,#'S',ko_phai_S
			JMP DO_STOP
		ko_phai_S:
		
		cjne A,#'D',ko_phai_D
			;stop
			DO_STOP:
			ACALL STOP
			MOV DPTR,#S4
			ACALL TRUYEN_STRING
			MOV A,#0   ; A KO CON LA 'D' NUA
			RET
		ko_phai_D:
		
		cjne A,#'G',ko_phai_G
			;PHAI2S
			ACALL PHAI
			ACALL DELAY1S
			ACALL DELAY1S	
			
			;DUNG1S
			ACALL STOP
			ACALL DELAY1S
			
			;TRAI2S
			ACALL TRAI
			ACALL DELAY1S
			ACALL DELAY1S	
			
			;DUNG1S
			ACALL STOP
			ACALL DELAY1S
			
			;MOV A,#0   ; A VAN LA 'G'
			RET
		ko_phai_G:
	ret
	
	DELAY1S:
		;SU DUNG TIMER0 MODE1 16 BIT
		MOV R0,#20
		LAP:                       ; -50000 = 3CB0H (16 BIT)
			MOV TH0,#HIGH(-50000 ) ; -50000 LA 1 DAY BIN MA + 50000 -> 0
			MOV TL0,#LOW (-50000)  ; HIGH TRA VE 8 BIT CAO = 3CH
			                       ; LOW TRA VE 8 BIT THAP = B0H
			SETB TR0   ; TIMER0 BAT DAU CHAY
			JNB TF0,$  ; DOI TIMER0 TRAN
			CLR TR0    ;XOA CO CHAY
			CLR TF0    ;XOA CO TRAN
		DJNZ R0,LAP    ; GIAM R0 DI 1 DV, SO SANH R0 NOT ZERO: THEN JUMP TO LAP
	RET
	
	TRAI:
		setb dk1
		clr  dk2
		MOV DPTR,#S1
		ACALL TRUYEN_STRING
	RET
	
	PHAI:
		setb dk2
		clr  dk1
		MOV DPTR,#S2
		ACALL TRUYEN_STRING
	RET
	
	STOP:
		SETB dk1
		SETB dk2
		MOV DPTR,#S3
		ACALL TRUYEN_STRING
	RET
	
	;DPTR DANG TRO VAO DAU STRING
	TRUYEN_STRING:
		MOV 30H,A		; BACKUP
		MOV R1,#0
		TRUYEN:
			MOV A,R1
			MOVC A,@A+DPTR			
			JZ TRUYEN_XONG
			MOV SBUF,A
			CLR TI
			JNB TI,$
			INC R1
		JMP TRUYEN
		TRUYEN_XONG:
		MOV A,30H		;RESTORE
	RET
	
	S1: DB " -> DANG QUAY TRAI",10,13,0
	S2: DB " -> DONG CO DANG QUAY PHAI",10,13,0
	S3: DB " -> STOP ROI NHE",10,13,0
	S4: DB " -> STOP DO S OR D NHE ",10,13,0
END