org 0000h
ljmp rewrite



org 0200h
rewrite:			;najpierw tablica zostaje przepisana do zewnętrznej pamięci

	MOV DPTR,#0900H
	mov r0,DPL
	MOV R1,DPH
	MOV R3,#30H
	MOV R2,#00H
	ljmp loop
loop:
	mov DPL,R0
	mov DPH, R1  	; WRZUĆ DO DPTR ADRES TABLICY
	movc a,@A+DPTR 	;WEŹ WARTOŚC Z TABLICY
	mov DPL,R2
	mov DPH,R3	; WRZUĆ ADRES ZEWNĘTRZNEJ PAMIECI DO DPTR
	movx @dptr,a	;WRZUĆ WARTOŚC DO ZEWNETRZNEJ PAMIETCI
	LCALL incrementPointers	;INKREMENTUJ POINTERY AKRESOW WEJSCIOWYCH I WYJSCIOWYCH
	CJNE R1,#0AH,loop	
	LJMP sort		;po zakończeniu przpisywania skok do sortowania

incrementPointers:
	MOV A,R0		;INKREMENTOWANIE ADRESU WEJSCIOWEGO
	ADD A,#01H
	JNB C,dontIncrementR1	;JESLI AKUMULATOR BYL PRZEPELNIONY TO INKREMENTUJ R1 
	INC R1			;To po to żeby można było przepisywac tablice dłuższe niz 256 znaków
	CLR C
DontIncrementR1:
	MOV R0,A
			;INKREMETOWANIE ADRESU WYJSCIOWEGO
	MOV A,R2
	ADDC A,#01H
	JNB C,dontIncrementR3
	INC R3
	CLR C
DontIncrementR3:
	MOV R2,A
	CLR A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sort:			;od adresów 10h pamiec zarezerwowana jest na stos
	mov 10h,#00h	;wartość początkowa początku tablicy
	mov 11h,#0ffh	;wartosć początkowa konca tablicy
	Mov r0,#12h	;wskaznik stosu	
	mov dptr,#3000h
quickSort:
	CJNE R0,#10H,sortuj	;SPRAWDZ CZY STOS JEST PUSTY
	ljmp end
sortuj:
	dec r0
	clr a
	mov a,@r0
	MOV R6,a	;pivot = koniec tablicy
	dec r0
	clr a
	mov a,@r0	;
	mov r4,a	;poczatek tablicy
	MOV R5,a 	;granica
	MOV R7,a	;indeks
loopSort:
	mov dph,#30h
	MOV DPL,R6
	Clr a
	movx A,@DPTR
	mov r1,a	;wyciagnecia wartosci spod wskaznika pivotu
	CLR A
	MOV DPL,R7
	movx A,@DPTR
	mov r2,a	;odczytanie wartosci spod indeksu
	CLR A
	LCALL compare
	INC R7		;inkrementuj indeks
	mov a,R7	
	SUBB A,R6		
	clr c
	JNZ loopsort	;jesli indeks != pivot to skocz do loopsort
	LCALL SwapGraniceZPivotem
	LCALL OdlozWskaznikiNaStos
	ljmp quickSort


compare:
	mov a,r2	;r1 - wartosc na prawo od granicy
	subb a,r1	;R0 - wartosc pivota
	JBC C,SWAP	;jeśli pivot mniejszy od wartosci to ok, jesli nie to zamien element z pierwszym elementem po
			;po prawo od granicy
	RET

swap:
	mov DPL,R5
	movx a,@dptr
	mov r3,a	;pobranie wartosci na granicy

	mov DPL,R7
	movx a,@dptr
	mov r2,a	;pobranie wartosci na indeksie

	mov a,r3
	movx @dptr,a	;wlozenie wartosci z granicy na indeks
	
	mov DPL,R5
	mov a,R2	
	movx @dptr,a	;wlozenie wartosci z indeksu na granice

	inc R5		;PRZESUNIECIE GRANICY O JEDEN W PRAWO
	CLR A
	clr c
	RET
	
SwapGraniceZPivotem:
	
	mov DPL,R5
	movx a,@dptr
	mov r3,a	;pobranie wartosci na granicy

	mov DPL,R6
	movx a,@dptr
	mov r1,a	;pobranie wartosci na na pivocie

	mov a,r3
	movx @dptr,a	;wlozenie wartosci z granicy na pivot
	
	mov DPL,R5
	mov a,R1	
	movx @dptr,a 	;wlozenie wartosci z pivotu na granice

	clr a
	RET

OdlozWskaznikiNaStos:	;odlozenie na stos tablicy o wyzszym indeksie
	mov a,R6	;najpierw pocatek pozniej koniec
	subb a,R5
		;sprawdz czy indeksy do odlozenia nie sa takie same
	JZ  pominodlozenie
	subb a,#01h
	jz pominodlozenie
	
	mov a,R5
	inc a
	mov @r0,a
	inc r0
	mov a,R6
	mov @r0,A
	inc r0
pominOdlozenie:
	mov a,R4	;najpierw pocatek pozniej koniec
	subb a,R5
	JZ  pominodlozenie2
	ADD a,#01h	;sprawdz czy indeksy do odlozenia nie sa
	JZ  pominodlozenie2
	mov a,R4	;odkladanie na stos mniejszych indeksow
	mov @r0,a
	inc r0
	mov a,R5
	dec a
	mov @r0,a
	inc r0
pominOdlozenie2:
	ret

jumpend:
	ljmp end

ORG 900h
db 0BCh, 09Ch, 078h, 0ACh, 0DBh, 0EBh, 06Fh, 0A8h
db 088h, 03Eh, 018h, 04Fh, 013h, 0EEh, 0C3h, 0CFh
db 036h, 043h, 0DCh, 0DDh, 097h, 077h, 06Dh, 009h
db 086h, 095h, 0A9h, 014h, 065h, 0F8h, 0B2h, 0F3h
db 0C9h, 0FEh, 08Dh, 08Fh, 0E4h, 09Ch, 06Eh, 0AEh
db 034h, 00Eh, 06Ch, 0A4h, 0A0h, 081h, 03Eh, 058h
db 0AEh, 0D4h, 012h, 0DBh, 05Eh, 0E8h, 007h, 09Dh
db 009h, 04Eh, 0D9h, 0F5h, 06Eh, 0A4h, 02Bh, 088h
db 00Eh, 0F7h, 0DCh, 028h, 015h, 055h, 09Eh, 0EAh
db 068h, 07Eh, 09Dh, 01Ah, 016h, 004h, 0B7h, 0E9h
db 033h, 003h, 055h, 080h, 060h, 04Fh, 0C8h, 097h
db 07Ch, 02Bh, 06Bh, 05Fh, 0E7h, 0DDh, 00Fh, 031h
db 007h, 0CFh, 03Ah, 0E4h, 0BCh, 091h, 0A8h, 0FFh
db 0E6h, 01Ah, 0E7h, 0CBh, 0E8h, 039h, 00Fh, 036h
db 006h, 06Bh, 0C6h, 040h, 0EBh, 0EFh, 028h, 076h
db 0F6h, 04Dh, 0E1h, 026h, 085h, 0CEh, 023h, 092h
db 079h, 032h, 07Dh, 080h, 025h, 086h, 08Eh, 0A7h
db 0BFh, 0B8h, 0E6h, 092h, 0ECh, 076h, 027h, 04Bh
db 003h, 038h, 012h, 0C8h, 0F4h, 096h, 0E3h, 0B7h
db 006h, 074h, 0F3h, 05Fh, 024h, 01Eh, 0A2h, 0DBh
db 054h, 0EFh, 0D3h, 07Ah, 071h, 042h, 020h, 0DCh
db 07Dh, 02Bh, 0B7h, 001h, 0FEh, 0DBh, 07Bh, 057h
db 0B8h, 01Ch, 035h, 09Bh, 06Ah, 0D2h, 055h, 078h
db 0E4h, 0F2h, 075h, 0D9h, 032h, 0CAh, 0E5h, 019h
db 093h, 013h, 016h, 078h, 0CFh, 00Eh, 0F3h, 0E2h
db 00Ah, 0F0h, 028h, 09Ch, 0B3h, 035h, 024h, 06Fh
db 00Fh, 065h, 027h, 0DBh, 02Bh, 0A2h, 09Ah, 017h
db 024h, 07Eh, 009h, 084h, 0B8h, 0FAh, 024h, 03Eh
db 0FFh, 0F7h, 080h, 0F8h, 072h, 0CBh, 022h, 081h
db 00Ch, 0AFh, 0EBh, 058h, 026h, 035h, 0E3h, 02Ah
db 0FBh, 0ADh, 024h, 079h, 0FCh, 090h, 01Ch, 011h
db 05Dh, 073h, 0F8h, 0B0h, 0C2h, 02Dh, 00Ch, 059h

END:
	END
