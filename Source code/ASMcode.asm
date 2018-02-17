
; Imiê:     Arkadiusz
; Nazwisko: Pilarski
; Rok akademicki: 2017/2018

.code

;////////////////////////////////////////////////////////////////////////////////////////////////////////////

InterpolacjaDwukwadratowaASM PROC tabela:QWORD, X:Real4, Y:Real4, W:QWORD, H:QWORD	;Pocz¹tek procedury, przechowanie parametrów w zmiennych.
local  wynikA:QWORD, wynikR:QWORD, wynikG:QWORD, wynikB:QWORD						;Zmienne przechowuj¹ce wartoœci wyznaczonych sk³adowych nowego piksela.


;Oznaczenia zmiennych u¿ywanych w programie:
;tabela -> rcx   X  -> xmm1   Y  -> xmm2   x1 -> rdx    y1 -> r8   x0 -> r10   y0 -> r11
;   x2  -> r12   y2 -> r13    dx -> xmm3   dy -> xmm4   W  -> r9   H  -> H


;Kod procedury
;------------------------------------------------------------------------------------------------------------
; x1: rdx: (int)X					
			cvtss2si	rdx,xmm1	;Konwersja parametru X (przekazanego do funkcji) na wartoœæ typu INTEGER.

; y1: r8: (int)Y
			cvtss2si	r8,xmm2		;Konwersja parametru Y (przekazanego do funkcji) na wartoœæ typu INTEGER.


;Kontrola indeksu tablicy
			cmp rdx,r9				;Sprawdzenie czy wartoœæ wspó³rzêdnej x1 jest mniejsza od granicy rozmiaru obrazu.
			jl KONTYNUUJ			;Jeœli jest mniejsza, program kontynuuje dzia³anie.
ZAKRES:								;Jeœli nie jest mniejsza, ustawiana jest maksymalna dozwolona wartoœæ 
			dec rdx					;równa szerokoœci obrazu pomniejszonej o 1 (indeksowanie tablicy od 0).
KONTYNUUJ:							;Kontynuacja pracy programu.
			cmp r8,H				;Sprawdzenie czy wartoœæ wspó³rzêdnej y1 jest mniejsza od granicy rozmiaru obrazu.
			jl KONTYNUUJ2			;Jeœli jest mniejsza, program kontynuuje dzia³anie.
ZAKRES2:							;Jeœli nie jest mniejsza, ustawiana jest maksymalna dozwolona wartoœæ 
			dec r8					;równa wysokoœci obrazu pomniejszonej o 1 (indeksowanie tablicy od 0).
KONTYNUUJ2:							;Kontynuacja pracy programu.

; dx: xmm3:= (float)(x - x1)		
			movss		xmm3,xmm1	;Przepisanie wartoœci X do rejestru xmm3, gdzie zostanie wyznaczona wartoœæ dx
			cvtsi2ss	xmm6,rdx	;Konwersja wartoœci X1 do zmiennej typu FLOAT.
			subss		xmm3,xmm6	;Odjêcie otrzymanej wartoœci od przechowywanej wartoœci X (wyznaczenie wartoœci dx)

; dy: xmm4:= (float)(y - y1)
			movss		xmm4,xmm2	;Przepisanie wartoœci Y do rejestru xmm4, gdzie zostanie wyznaczona wartoœæ dy
			cvtsi2ss	xmm6,r8		;Konwersja wartoœci Y1 do zmiennej typu FLOAT.
			subss		xmm4,xmm6	;Odjêcie otrzymanej wartoœci od przechowywanej wartoœci Y (wyznaczenie wartoœci dy)

WARUNEK1:							;Wyznaczanie wspó³rzêdnych punktów, na podstawie których zostanie wyznaczona wartoœæ piksela 
; if (x1 - 1 >= 0)					;nowej bitmapy. Instrukcje warunkowe zapobiegaj¹ wyznaczeniu punktów spoza bitmapy. 
			dec		rdx				;Dekrementacja wspó³rzêdnej x1.
			test	rdx,rdx			;Sprawdzenie czy wyznaczona wspó³rzêdna nie jest ujemna (ustawienie wartoœci Sign Flag).
			js		X0ujemna		;Jeœli jest ujemna (Sign Flag == 1) skok do etykiety X0ujemna.

; x0 = x1 - 1
			mov		r10,rdx			;Jeœli nie jest ujemna (Sign Flag == 0 ) przeniesienie zdekrementowanej wartoœci x1 do rejestru r10 (wspó³rzêdnej x0).
			inc		rdx				;Inkrementacja rdx w celu przywrócenia wartoœci x1.
			jmp		WARUNEK2		;Skok do etykiety z kolejn¹ instrukcj¹ warunkow¹.

X0ujemna:
; else x0 = x1;
			inc		rdx				;Inkrementacja ujemnej wartoœci do dolnej wartoœci granicznej równej 0.
			mov		r10,rdx			;Ustawienie wartoœci r10 (wspó³rzêdnej x0) jako 0 (aktualna wartoœæ wspó³rzêdnej x1).

WARUNEK2:
; if (y1 - 1 >= 0)
			dec		r8				;Dekrementacja wspó³rzêdnej y1.
			test	r8,r8			;Sprawdzenie czy wyznaczona wspó³rzêdna nie jest ujemna (ustawienie wartoœci Sign Flag).
			js		Y0ujemna		;Jeœli jest ujemna (Sign Flag == 1) skok do etykiety Y0ujemna.

; y0 = y1 - 1
			mov		r11,r8			;Jeœli nie jest ujemna (Sign Flag == 0 ) przeniesienie zdekrementowanej wartoœci y1 do rejestru r11 (wspó³rzêdnej y0).
			inc		r8				;Inkrementacja r8 w celu przywrócenia wartoœci y1.
			jmp		WARUNEK3			;Skok do etykiety z kolejn¹ instrukcj¹ warunkow¹.

Y0ujemna:
; else y0 = y1;
			inc		r8				;Inkrementacja ujemnej wartoœci do dolnej wartoœci granicznej równej 0.
			mov		r11,r8			;Ustawienie wartoœci r11 (wspó³rzêdnej y0) jako 0 (aktualna wartoœæ wspó³rzêdnej y1).

WARUNEK3:
; if (x1 + 1 >= sourceWidth)
			inc		rdx				;Inkrementacja wspó³rzêdnej x1.
			cmp		rdx,r9			;Sprawdzenie czy wartosc wspolrzednej X1 jest mniejsza od granicy rozmiaru obrazu (szerokoœæ).
			jl		X2mniejsza		;Jeœli jest mniejsza, nastêpuje skok do etykiety X2mniejsza.

;x2 = x1
			dec		rdx				;Dekrementacja rdx w celu przywrócenia wartoœci x1.
			mov		r12,rdx			;Przypisanie wartoœci x1 do nowej wspó³rzêdnej x2, przechowywanej w rejestrze r12.
			jmp		WARUNEK4		;Skok do kolejnej instrukcji warunkowej.

X2mniejsza:
; x2 = x1 + 1;
			mov		r12,rdx			;Przypisanie zinkrementowanej wartoœci x1 do nowej wspó³rzêdnej x2.
			dec		rdx				;Dekrementacja rdx w celu przywrócenia wartoœci x1.

WARUNEK4:
; if (y1 + 1 >= sourceHeight)

			inc		r8				;Inkrementacja wspó³rzêdnej y1.
			cmp		r8,H			;Sprawdzenie czy wartosc wspolrzednej y1 jest mniejsza od granicy rozmiaru obrazu (wysokoœæ).
			jl		Y2mniejsza		;Jeœli jest mniejsza, nastêpuje skok do etykiety Y2mniejsza.

; y2 = y1
			dec		r8				;Dekrementacja r8 w celu przywrócenia wartoœci y1.
			mov		r13,r8			;Przypisanie wartoœci y1 do nowej wspó³rzêdnej y2, przechowywanej w rejestrze r13.
			jmp		OBLICZENIA		;Skok do etykiety zawieraj¹cej instrukcje wyznaczaj¹ce wartoœæ piksela w oparciu o wyznaczone punkty (wspó³rzêdne).

Y2mniejsza:
; y2 = y1 + 1
			mov		r13,r8			;Przypisanie zinkrementowanej wartoœci y1 do nowej wspó³rzêdnej y2.
			dec		r8				;Dekrementacja r8 w celu przywrócenia wartoœci y1.

OBLICZENIA:

;OBLICZANIE SK£ADOWEJ A 
;-------------------------------------------------------------------------------------------------------------------------------------------
;Obliczenie nowej sk³adowej piksela polega na trzykrotnym wykonaniu interpolacji trzech wartoœci sk³adowej, pobranych z trzech (wyznaczonych wczeœniej) punktów.
;Ka¿dorazowe wykonanie operacji nastêpuje w oparciu o zestaw 3 innych punktów.
;Punkty te zosta³y wyznaczone dziêki otrzymanym wspó³rzêdnym x0, y0, x1, y1, x2, y2 (ich kombinacji).
;Po wykonanych operacjach, nastêpuje interpolacja wartoœci otrzymanych z poprzednich interpolacji z normalizacj¹ wartoœci.
			
;index:  x0 + y0 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel (punkt).
			mov		rax,r11			;Przeniesienie wartoœci y0 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r10			;Dodanie do akumulatora wartoœci wspó³rzêdnej x0. Otrzymana wartoœæ akumulatora to szukany indeks.
			
			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			shr		rax,24			;Przesuniêcie bitowe pobranej wartoœci piksela w prawo o 24 miejsca, aby wartoœæ sk³adowej A znalaz³a siê na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta³ych bajtów przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej A piksela.
			cvtsi2ss xmm10,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm10.

;index:  x1 + y0 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel.
			mov		rax,r11			;Przeniesienie wartoœci y0 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,rdx			;Dodanie do akumulatora wartoœci wspó³rzêdnej x1. Otrzymana wartoœæ akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			shr		rax,24			;Przesuniêcie bitowe pobranej wartoœci piksela w prawo o 24 miejsca, aby wartoœæ sk³adowej A znalaz³a siê na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta³ych bajtów przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej A piksela.
			cvtsi2ss xmm11,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm11.

;index:  x2 + y0 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel.
			mov		rax,r11			;Przeniesienie wartoœci y0 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r12			;Dodanie do akumulatora wartoœci wspó³rzêdnej x2. Otrzymana wartoœæ akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			shr		rax,24			;Przesuniêcie bitowe pobranej wartoœci piksela w prawo o 24 miejsca, aby wartoœæ sk³adowej A znalaz³a siê na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta³ych bajtów przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej A piksela.
			cvtsi2ss xmm12,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm12.


; Interpolacja obliczonych wartosci
			call Interpolacja		;Wywo³anie procedury przeprowadzaj¹cej interpolacjê otrzymanych wartoœci (przechowywanych w xmm10, xmm11, xmm12).
			movss	xmm5,xmm0		;Procedura ta zwraca wynik w rejestrze xmm0, któy jest tutaj przepisywany do rejestru xmm5.


;index:  x0 + y1 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel.
			mov		rax,r8			;Przeniesienie wartoœci y1 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r10			;Dodanie do akumulatora wartoœci wspó³rzêdnej x0. Otrzymana wartoœæ akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			shr		rax,24			;Przesuniêcie bitowe pobranej wartoœci piksela w prawo o 24 miejsca, aby wartoœæ sk³adowej A znalaz³a siê na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta³ych bajtów przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej A piksela.
			cvtsi2ss xmm10,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm10.

;index:  x1 + y1 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel.
			mov		rax,r8			;Przeniesienie wartoœci y1 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,rdx			;Dodanie do akumulatora wartoœci wspó³rzêdnej x1. Otrzymana wartoœæ akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			shr		rax,24			;Przesuniêcie bitowe pobranej wartoœci piksela w prawo o 24 miejsca, aby wartoœæ sk³adowej A znalaz³a siê na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta³ych bajtów przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej A piksela.
			cvtsi2ss xmm11,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm11.

;index:  x2 + y1 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel.
			mov		rax,r8			;Przeniesienie wartoœci y1 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r12			;Dodanie do akumulatora wartoœci wspó³rzêdnej x2. Otrzymana wartoœæ akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			shr		rax,24			;Przesuniêcie bitowe pobranej wartoœci piksela w prawo o 24 miejsca, aby wartoœæ sk³adowej A znalaz³a siê na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta³ych bajtów przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej A piksela.
			cvtsi2ss xmm12,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm12.


; Interpolacja obliczonych wartosci
			call Interpolacja		;Wywo³anie procedury przeprowadzaj¹cej interpolacjê otrzymanych wartoœci (przechowywanych w xmm10, xmm11, xmm12).
			movss	xmm6,xmm0		;Procedura ta zwraca wynik w rejestrze xmm0, któy jest tutaj przepisywany do rejestru xmm6.


;index:  x0 + y2 * sourceWudth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel.
			mov		rax,r13			;Przeniesienie wartoœci y2 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r10			;Dodanie do akumulatora wartoœci wspó³rzêdnej x0. Otrzymana wartoœæ akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			shr		rax,24			;Przesuniêcie bitowe pobranej wartoœci piksela w prawo o 24 miejsca, aby wartoœæ sk³adowej A znalaz³a siê na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta³ych bajtów przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej A piksela.
			cvtsi2ss xmm10,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm10.

;index:  x1 + y2 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel.
			mov		rax,r13			;Przeniesienie wartoœci y2 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,rdx			;Dodanie do akumulatora wartoœci wspó³rzêdnej x1. Otrzymana wartoœæ akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			shr		rax,24			;Przesuniêcie bitowe pobranej wartoœci piksela w prawo o 24 miejsca, aby wartoœæ sk³adowej A znalaz³a siê na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta³ych bajtów przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej A piksela.
			cvtsi2ss xmm11,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm11.

;index:  x2 + y2 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel.
			mov		rax,r13			;Przeniesienie wartoœci y2 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r12			;Dodanie do akumulatora wartoœci wspó³rzêdnej x2. Otrzymana wartoœæ akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			shr		rax,24			;Przesuniêcie bitowe pobranej wartoœci piksela w prawo o 24 miejsca, aby wartoœæ sk³adowej A znalaz³a siê na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta³ych bajtów przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej A piksela.
			cvtsi2ss xmm12,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm12.


; Interpolacja obliczonych wartosci
			call Interpolacja		;Wywo³anie procedury przeprowadzaj¹cej interpolacjê otrzymanych wartoœci (przechowywanych w xmm10, xmm11, xmm12).
			movss	xmm7,xmm0		;Procedura ta zwraca wynik w rejestrze xmm0, któy jest tutaj przepisywany do rejestru xmm7.


; Interpolacja z normalizacja
			call InterpolacjaNorm	;Wywo³anie procedury przeprowadzaj¹cej interpolacjê otrzymanych wartoœci (przechowywanych w xmm5, xmm6, xmm7).
									;Procedura ta normalizuje wartoœæ otrzymanego wyniku, aby zawiera³ siê on w przewidzianym przedziale.
									;Wynik zwracany jest w rejestrze rax.
;Sk³adowa A
			mov		wynikA,rax		;Zapisanie otrzymanej wartoœci z akumulatora jako sk³adowej A (alfa) nowego piksela.



;OBLICZANIE SK£ADOWEJ R 
;-------------------------------------------------------------------------------------------------------------------------------------------
;Obliczenie nowej sk³adowej piksela polega na trzykrotnym wykonaniu interpolacji trzech wartoœci sk³adowej, pobranych z trzech (wyznaczonych wczeœniej) punktów.
;Ka¿dorazowe wykonanie operacji nastêpuje w oparciu o zestaw 3 innych punktów.
;Punkty te zosta³y wyznaczone dziêki otrzymanym wspó³rzêdnym x0, y0, x1, y1, x2, y2 (ich kombinacji).
;Po wykonanych operacjach, nastêpuje interpolacja wartoœci otrzymanych z poprzednich interpolacji z normalizacj¹ wartoœci.
	
;index:  x0 + y0 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel (punkt).
			mov		rax,r11			;Przeniesienie wartoœci y0 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r10			;Dodanie do akumulatora wartoœci wspó³rzêdnej x0. Otrzymana wartoœæ akumulatora to szukany indeks.
			
			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			shr		rax,16			;Przesuniêcie bitowe pobranej wartoœci piksela w prawo o 16 miejsc, aby wartoœæ sk³adowej R znalaz³a siê na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta³ych bajtów przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej R piksela.
			cvtsi2ss xmm10,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm10.

;index:  x1 + y0 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel.
			mov		rax,r11			;Przeniesienie wartoœci y0 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,rdx			;Dodanie do akumulatora wartoœci wspó³rzêdnej x1. Otrzymana wartoœæ akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			shr		rax,16			;Przesuniêcie bitowe pobranej wartoœci piksela w prawo o 16 miejsc, aby wartoœæ sk³adowej R znalaz³a siê na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta³ych bajtów przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej R piksela.
			cvtsi2ss xmm11,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm11.

;index:  x2 + y0 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel.
			mov		rax,r11			;Przeniesienie wartoœci y0 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r12			;Dodanie do akumulatora wartoœci wspó³rzêdnej x2. Otrzymana wartoœæ akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			shr		rax,16			;Przesuniêcie bitowe pobranej wartoœci piksela w prawo o 16 miejsc, aby wartoœæ sk³adowej R znalaz³a siê na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta³ych bajtów przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej R piksela.
			cvtsi2ss xmm12,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm12.


; Interpolacja obliczonych wartosci
			call Interpolacja		;Wywo³anie procedury przeprowadzaj¹cej interpolacjê otrzymanych wartoœci (przechowywanych w xmm10, xmm11, xmm12).
			movss	xmm5,xmm0		;Procedura ta zwraca wynik w rejestrze xmm0, któy jest tutaj przepisywany do rejestru xmm5.


;index:  x0 + y1 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel.
			mov		rax,r8			;Przeniesienie wartoœci y1 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r10			;Dodanie do akumulatora wartoœci wspó³rzêdnej x0. Otrzymana wartoœæ akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			shr		rax,16			;Przesuniêcie bitowe pobranej wartoœci piksela w prawo o 16 miejsc, aby wartoœæ sk³adowej R znalaz³a siê na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta³ych bajtów przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej R piksela.
			cvtsi2ss xmm10,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm10.

;index:  x1 + y1 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel.
			mov		rax,r8			;Przeniesienie wartoœci y1 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,rdx			;Dodanie do akumulatora wartoœci wspó³rzêdnej x1. Otrzymana wartoœæ akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			shr		rax,16			;Przesuniêcie bitowe pobranej wartoœci piksela w prawo o 16 miejsc, aby wartoœæ sk³adowej R znalaz³a siê na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta³ych bajtów przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej R piksela.
			cvtsi2ss xmm11,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm11.

;index:  x2 + y1 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel.
			mov		rax,r8			;Przeniesienie wartoœci y1 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r12			;Dodanie do akumulatora wartoœci wspó³rzêdnej x2. Otrzymana wartoœæ akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			shr		rax,16			;Przesuniêcie bitowe pobranej wartoœci piksela w prawo o 16 miejsc, aby wartoœæ sk³adowej R znalaz³a siê na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta³ych bajtów przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej R piksela.
			cvtsi2ss xmm12,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm12.


; Interpolacja obliczonych wartosci
			call Interpolacja		;Wywo³anie procedury przeprowadzaj¹cej interpolacjê otrzymanych wartoœci (przechowywanych w xmm10, xmm11, xmm12).
			movss	xmm6,xmm0		;Procedura ta zwraca wynik w rejestrze xmm0, któy jest tutaj przepisywany do rejestru xmm6.


;index:  x0 + y2 * sourceWudth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel.
			mov		rax,r13			;Przeniesienie wartoœci y2 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r10			;Dodanie do akumulatora wartoœci wspó³rzêdnej x0. Otrzymana wartoœæ akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			shr		rax,16			;Przesuniêcie bitowe pobranej wartoœci piksela w prawo o 16 miejsc, aby wartoœæ sk³adowej R znalaz³a siê na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta³ych bajtów przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej R piksela.
			cvtsi2ss xmm10,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm10.

;index:  x1 + y2 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel.
			mov		rax,r13			;Przeniesienie wartoœci y2 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,rdx			;Dodanie do akumulatora wartoœci wspó³rzêdnej x1. Otrzymana wartoœæ akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			shr		rax,16			;Przesuniêcie bitowe pobranej wartoœci piksela w prawo o 16 miejsc, aby wartoœæ sk³adowej R znalaz³a siê na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta³ych bajtów przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej R piksela.
			cvtsi2ss xmm11,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm11.

;index:  x2 + y2 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel.
			mov		rax,r13			;Przeniesienie wartoœci y2 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r12			;Dodanie do akumulatora wartoœci wspó³rzêdnej x2. Otrzymana wartoœæ akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			shr		rax,16			;Przesuniêcie bitowe pobranej wartoœci piksela w prawo o 16 miejsc, aby wartoœæ sk³adowej R znalaz³a siê na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta³ych bajtów przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej R piksela.
			cvtsi2ss xmm12,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm12.


; Interpolacja obliczonych wartosci
			call Interpolacja		;Wywo³anie procedury przeprowadzaj¹cej interpolacjê otrzymanych wartoœci (przechowywanych w xmm10, xmm11, xmm12).
			movss	xmm7,xmm0		;Procedura ta zwraca wynik w rejestrze xmm0, któy jest tutaj przepisywany do rejestru xmm7.


; Interpolacja z normalizacja
			call InterpolacjaNorm	;Wywo³anie procedury przeprowadzaj¹cej interpolacjê otrzymanych wartoœci (przechowywanych w xmm5, xmm6, xmm7).
									;Procedura ta normalizuje wartoœæ otrzymanego wyniku, aby zawiera³ siê on w przewidzianym przedziale.
									;Wynik zwracany jest w rejestrze rax.
;Sk³adowa R
			mov		wynikR,rax		;Zapisanie otrzymanej wartoœci z akumulatora jako sk³adowej R (red) nowego piksela.



;OBLICZANIE SK£ADOWEJ G 
;-------------------------------------------------------------------------------------------------------------------------------------------
;Obliczenie nowej sk³adowej piksela polega na trzykrotnym wykonaniu interpolacji trzech wartoœci sk³adowej, pobranych z trzech (wyznaczonych wczeœniej) punktów.
;Ka¿dorazowe wykonanie operacji nastêpuje w oparciu o zestaw 3 innych punktów.
;Punkty te zosta³y wyznaczone dziêki otrzymanym wspó³rzêdnym x0, y0, x1, y1, x2, y2 (ich kombinacji).
;Po wykonanych operacjach, nastêpuje interpolacja wartoœci otrzymanych z poprzednich interpolacji z normalizacj¹ wartoœci.
	
;index:  x0 + y0 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel (punkt).
			mov		rax,r11			;Przeniesienie wartoœci y0 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r10			;Dodanie do akumulatora wartoœci wspó³rzêdnej x0. Otrzymana wartoœæ akumulatora to szukany indeks.
			
			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			shr		rax,8			;Przesuniêcie bitowe pobranej wartoœci piksela w prawo o 8 miejsc, aby wartoœæ sk³adowej G znalaz³a siê na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta³ych bajtów przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej G piksela.
			cvtsi2ss xmm10,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm10.

;index:  x1 + y0 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel.
			mov		rax,r11			;Przeniesienie wartoœci y0 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,rdx			;Dodanie do akumulatora wartoœci wspó³rzêdnej x1. Otrzymana wartoœæ akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			shr		rax,8			;Przesuniêcie bitowe pobranej wartoœci piksela w prawo o 8 miejsc, aby wartoœæ sk³adowej G znalaz³a siê na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta³ych bajtów przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej G piksela.
			cvtsi2ss xmm11,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm11.

;index:  x2 + y0 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel.
			mov		rax,r11			;Przeniesienie wartoœci y0 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r12			;Dodanie do akumulatora wartoœci wspó³rzêdnej x2. Otrzymana wartoœæ akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			shr		rax,8			;Przesuniêcie bitowe pobranej wartoœci piksela w prawo o 8 miejsc, aby wartoœæ sk³adowej G znalaz³a siê na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta³ych bajtów przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej G piksela.
			cvtsi2ss xmm12,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm12.


; Interpolacja obliczonych wartosci
			call Interpolacja		;Wywo³anie procedury przeprowadzaj¹cej interpolacjê otrzymanych wartoœci (przechowywanych w xmm10, xmm11, xmm12).
			movss	xmm5,xmm0		;Procedura ta zwraca wynik w rejestrze xmm0, któy jest tutaj przepisywany do rejestru xmm5.


;index:  x0 + y1 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel.
			mov		rax,r8			;Przeniesienie wartoœci y1 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r10			;Dodanie do akumulatora wartoœci wspó³rzêdnej x0. Otrzymana wartoœæ akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			shr		rax,8			;Przesuniêcie bitowe pobranej wartoœci piksela w prawo o 8 miejsc, aby wartoœæ sk³adowej G znalaz³a siê na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta³ych bajtów przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej G piksela.
			cvtsi2ss xmm10,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm10.

;index:  x1 + y1 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel.
			mov		rax,r8			;Przeniesienie wartoœci y1 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,rdx			;Dodanie do akumulatora wartoœci wspó³rzêdnej x1. Otrzymana wartoœæ akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			shr		rax,8			;Przesuniêcie bitowe pobranej wartoœci piksela w prawo o 8 miejsc, aby wartoœæ sk³adowej G znalaz³a siê na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta³ych bajtów przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej G piksela.
			cvtsi2ss xmm11,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm11.

;index:  x2 + y1 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel.
			mov		rax,r8			;Przeniesienie wartoœci y1 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r12			;Dodanie do akumulatora wartoœci wspó³rzêdnej x2. Otrzymana wartoœæ akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			shr		rax,8			;Przesuniêcie bitowe pobranej wartoœci piksela w prawo o 8 miejsc, aby wartoœæ sk³adowej G znalaz³a siê na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta³ych bajtów przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej G piksela.
			cvtsi2ss xmm12,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm12.


; Interpolacja obliczonych wartosci
			call Interpolacja		;Wywo³anie procedury przeprowadzaj¹cej interpolacjê otrzymanych wartoœci (przechowywanych w xmm10, xmm11, xmm12).
			movss	xmm6,xmm0		;Procedura ta zwraca wynik w rejestrze xmm0, któy jest tutaj przepisywany do rejestru xmm6.


;index:  x0 + y2 * sourceWudth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel.
			mov		rax,r13			;Przeniesienie wartoœci y2 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r10			;Dodanie do akumulatora wartoœci wspó³rzêdnej x0. Otrzymana wartoœæ akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			shr		rax,8			;Przesuniêcie bitowe pobranej wartoœci piksela w prawo o 8 miejsc, aby wartoœæ sk³adowej G znalaz³a siê na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta³ych bajtów przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej G piksela.
			cvtsi2ss xmm10,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm10.

;index:  x1 + y2 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel.
			mov		rax,r13			;Przeniesienie wartoœci y2 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,rdx			;Dodanie do akumulatora wartoœci wspó³rzêdnej x1. Otrzymana wartoœæ akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			shr		rax,8			;Przesuniêcie bitowe pobranej wartoœci piksela w prawo o 8 miejsc, aby wartoœæ sk³adowej G znalaz³a siê na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta³ych bajtów przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej G piksela.
			cvtsi2ss xmm11,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm11.

;index:  x2 + y2 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel.
			mov		rax,r13			;Przeniesienie wartoœci y2 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r12			;Dodanie do akumulatora wartoœci wspó³rzêdnej x2. Otrzymana wartoœæ akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			shr		rax,8			;Przesuniêcie bitowe pobranej wartoœci piksela w prawo o 8 miejsc, aby wartoœæ sk³adowej G znalaz³a siê na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta³ych bajtów przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej G piksela.
			cvtsi2ss xmm12,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm12.


; Interpolacja obliczonych wartosci
			call Interpolacja		;Wywo³anie procedury przeprowadzaj¹cej interpolacjê otrzymanych wartoœci (przechowywanych w xmm10, xmm11, xmm12).
			movss	xmm7,xmm0		;Procedura ta zwraca wynik w rejestrze xmm0, któy jest tutaj przepisywany do rejestru xmm7.


; Interpolacja z normalizacja
			call InterpolacjaNorm	;Wywo³anie procedury przeprowadzaj¹cej interpolacjê otrzymanych wartoœci (przechowywanych w xmm5, xmm6, xmm7).
									;Procedura ta normalizuje wartoœæ otrzymanego wyniku, aby zawiera³ siê on w przewidzianym przedziale.
									;Wynik zwracany jest w rejestrze rax.
;skladowa G
			mov		wynikG,rax		;Zapisanie otrzymanej wartoœci z akumulatora jako sk³adowej G (green) nowego piksela.



;OBLICZANIE SK£ADOWEJ B
;-------------------------------------------------------------------------------------------------------------------------------------------
;Obliczenie nowej sk³adowej piksela polega na trzykrotnym wykonaniu interpolacji trzech wartoœci sk³adowej, pobranych z trzech (wyznaczonych wczeœniej) punktów.
;Ka¿dorazowe wykonanie operacji nastêpuje w oparciu o zestaw 3 innych punktów.
;Punkty te zosta³y wyznaczone dziêki otrzymanym wspó³rzêdnym x0, y0, x1, y1, x2, y2 (ich kombinacji).
;Po wykonanych operacjach, nastêpuje interpolacja wartoœci otrzymanych z poprzednich interpolacji z normalizacj¹ wartoœci.
	
;index:  x0 + y0 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel (punkt).
			mov		rax,r11			;Przeniesienie wartoœci y0 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r10			;Dodanie do akumulatora wartoœci wspó³rzêdnej x0. Otrzymana wartoœæ akumulatora to szukany indeks.
			
			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			and		rax,255			;Wyzerowanie wszystkich bajtów poza ostatnim (skrajnym) przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej B piksela.
			cvtsi2ss xmm10,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm10.

;index:  x1 + y0 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel.
			mov		rax,r11			;Przeniesienie wartoœci y0 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,rdx			;Dodanie do akumulatora wartoœci wspó³rzêdnej x1. Otrzymana wartoœæ akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			and		rax,255			;Wyzerowanie wszystkich bajtów poza ostatnim (skrajnym) przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej B piksela.
			cvtsi2ss xmm11,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm11.

;index:  x2 + y0 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel.
			mov		rax,r11			;Przeniesienie wartoœci y0 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r12			;Dodanie do akumulatora wartoœci wspó³rzêdnej x2. Otrzymana wartoœæ akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			and		rax,255			;Wyzerowanie wszystkich bajtów poza ostatnim (skrajnym) przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej B piksela.
			cvtsi2ss xmm12,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm12.


; Interpolacja obliczonych wartosci
			call Interpolacja		;Wywo³anie procedury przeprowadzaj¹cej interpolacjê otrzymanych wartoœci (przechowywanych w xmm10, xmm11, xmm12).
			movss	xmm5,xmm0		;Procedura ta zwraca wynik w rejestrze xmm0, któy jest tutaj przepisywany do rejestru xmm5.


;index:  x0 + y1 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel.
			mov		rax,r8			;Przeniesienie wartoœci y1 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r10			;Dodanie do akumulatora wartoœci wspó³rzêdnej x0. Otrzymana wartoœæ akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			and		rax,255			;Wyzerowanie wszystkich bajtów poza ostatnim (skrajnym) przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej B piksela.
			cvtsi2ss xmm10,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm10.

;index:  x1 + y1 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel.
			mov		rax,r8			;Przeniesienie wartoœci y1 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,rdx			;Dodanie do akumulatora wartoœci wspó³rzêdnej x1. Otrzymana wartoœæ akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			and		rax,255			;Wyzerowanie wszystkich bajtów poza ostatnim (skrajnym) przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej B piksela.
			cvtsi2ss xmm11,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm11.

;index:  x2 + y1 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel.
			mov		rax,r8			;Przeniesienie wartoœci y1 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r12			;Dodanie do akumulatora wartoœci wspó³rzêdnej x2. Otrzymana wartoœæ akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			and		rax,255			;Wyzerowanie wszystkich bajtów poza ostatnim (skrajnym) przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej B piksela.
			cvtsi2ss xmm12,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm12.


; Interpolacja obliczonych wartosci
			call Interpolacja		;Wywo³anie procedury przeprowadzaj¹cej interpolacjê otrzymanych wartoœci (przechowywanych w xmm10, xmm11, xmm12).
			movss	xmm6,xmm0		;Procedura ta zwraca wynik w rejestrze xmm0, któy jest tutaj przepisywany do rejestru xmm6.


;index:  x0 + y2 * sourceWudth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel.
			mov		rax,r13			;Przeniesienie wartoœci y2 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r10			;Dodanie do akumulatora wartoœci wspó³rzêdnej x0. Otrzymana wartoœæ akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			and		rax,255			;Wyzerowanie wszystkich bajtów poza ostatnim (skrajnym) przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej B piksela.
			cvtsi2ss xmm10,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm10.

;index:  x1 + y2 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel.
			mov		rax,r13			;Przeniesienie wartoœci y2 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,rdx			;Dodanie do akumulatora wartoœci wspó³rzêdnej x1. Otrzymana wartoœæ akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			and		rax,255			;Wyzerowanie wszystkich bajtów poza ostatnim (skrajnym) przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej B piksela.
			cvtsi2ss xmm11,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm11.

;index:  x2 + y2 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod którym znajduje siê szukany piksel.
			mov		rax,r13			;Przeniesienie wartoœci y2 do akumulatora.
			imul	rax,r9			;Pomno¿enie akumulatora przez szerokoœæ bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r12			;Dodanie do akumulatora wartoœci wspó³rzêdnej x2. Otrzymana wartoœæ akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej wartoœci z tablicy.
			and		rax,255			;Wyzerowanie wszystkich bajtów poza ostatnim (skrajnym) przy pomocy maski 255. Otrzymana wartoœæ akumulatora to szukana wartoœæ sk³adowej B piksela.
			cvtsi2ss xmm12,rax		;Konwersja otrzymanej wartoœci na wartoœæ typu FLOAT i przechowywanie jej w rejestrze xmm12.


; Interpolacja obliczonych wartosci
			call Interpolacja		;Wywo³anie procedury przeprowadzaj¹cej interpolacjê otrzymanych wartoœci (przechowywanych w xmm10, xmm11, xmm12).
			movss	xmm7,xmm0		;Procedura ta zwraca wynik w rejestrze xmm0, któy jest tutaj przepisywany do rejestru xmm7.


; Interpolacja z normalizacja
			call InterpolacjaNorm	;Wywo³anie procedury przeprowadzaj¹cej interpolacjê otrzymanych wartoœci (przechowywanych w xmm5, xmm6, xmm7).
									;Procedura ta normalizuje wartoœæ otrzymanego wyniku, aby zawiera³ siê on w przewidzianym przedziale.
									;Wynik zwracany jest w rejestrze rax.
;skladowa B
			mov		wynikB,rax		;Zapisanie otrzymanej wartoœci z akumulatora jako sk³adowej B (blue) nowego piksela.


;PRZYGOTOWANIE WYNIKU PIKSELA
;-------------------------------------------------------------------------------------------------------------------------------------------

			mov		rax,wynikA		;Wpisanie wartoœci sk³adowej A na ostatni bajt akumulatora.
			shl		rax,8			;Przesuniêcie bitowe akumulatora w prawo o jeden bajt.
			add		rax,wynikR		;Wpisanie wartoœci sk³adowej R na ostatni bajt akumulatora.
			shl		rax,8			;Przesuniêcie bitowe akumulatora w prawo o jeden bajt.
			add		rax,wynikG		;Wpisanie wartoœci sk³adowej G na ostatni bajt akumulatora.
			shl		rax,8			;Przesuniêcie bitowe akumulatora w prawo o jeden bajt.
			add		rax,wynikB		;Wpisanie wartoœci sk³adowej B na ostatni bajt akumulatora.

			ret						;W rejestrze rax znajduje siê teraz wartoœæ nowo wyznaczonego piksela, która zwracana jest przez procedurê jako wynik.						

InterpolacjaDwukwadratowaASM ENDP	;Koniec procedury.

;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;////////////////////////////////////////////////////////////////////////////////////////////////////////////

Interpolacja PROC	;Procedura przeprowadzaj¹ca interpolacjê kwadratow¹ po trzech wartoœciach (parametry f1, f2, f3).


;OPIS ZMIENNYCH

;xmm0  -> zwracany wynik Interpolacji (oraz lokalny akumulator)
;xmm3  -> parametr dx
;xmm10 -> parametr f1
;xmm11 -> parametr f2
;xmm12 -> parametr f3
;xmm14 xmm15 xmm2 -->  kontenery


;OBLICZENIA

;xmm14: f3-f1
			movss			xmm0,xmm12		;Przeniesienie wartoœci parametru f3 do rejestru xmm0.
			subss			xmm0,xmm10		;Odjêcie od niej wartoœci parametru f1.
			movss			xmm14,xmm0		;Zapisanie otrzymanego wyniku w rejestrze xmm14.

;xmm15: 2*f2
			movss			xmm0,xmm11		;Przeniesienie wartoœci paramteru f2 do rejestru xmm0.
			addss			xmm0,xmm0		;Dodanie do przeniesionej wartoœci jej samej.
			movss			xmm15,xmm0		;Zapisanie otrzymanego wyniku w rejestrze xmm15.

;xmm2: f1 - 2*f2 + f3
			movss			xmm0,xmm10		;Przeniesienie wartoœci parametru f1 do rejestru xmm0.
			subss			xmm0,xmm15		;Odjêcie od niej wartoœci zapisanej w rejestrze xmm15.
			addss			xmm0,xmm12		;Dodanie wartoœci parametru f3.
			movss			xmm2,xmm0		;Zapisanie otrzymanego wyniku w rejestrze xmm2.

; xmm14: (f3-f1)*dy
			mulss			xmm14,xmm3		;Przemno¿enie wartoœci przechowywanej w rejestrze xmm14 przez wspó³czynnik dy.
			
;xmm2: (f1-2*f2+f3)*dy*dy
			mulss			xmm2,xmm3		;Przemno¿enie wartoœci zapisanej w rejestrze xmm2 przez wspó³czynnik dy.
			mulss			xmm2,xmm3		;Ponowne przemno¿enie wartoœci zapisanej w rejestrze xmm2 przez wspó³czynnik dy.

;xmm0: wynik
			movss			xmm0,xmm11		;Przeniesienie wartoœci parametru f2 do rejestru xmm0.
			addss			xmm0,xmm14		;Dodanie do niej obliczonej wartoœci przechowywanej w rejestrze xmm14.
			addss			xmm0,xmm2		;Dodanie obliczonej wartoœci przechowywanej w rejestrze xmm2.
											;Otrzymana wartoœæ w rejestrze xmm0 to wynik interpolacji kwadratowej.

			ret								;Powrót z procedury.				

Interpolacja ENDP							;Koniec procedury.

;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;////////////////////////////////////////////////////////////////////////////////////////////////////////////

InterpolacjaNorm PROC												
;Procedura przeprowadzaj¹ca interpolacjê kwadratow¹ po trzech wartoœciach (parametry f1, f2, f3).
;Wyznaczona wartoœæ jest dodatkowo normalizowana aby zawiera³a siê w przewidzianym przedziale 0 - 255.


;OPIS ZMIENNYCH

;xmm0  -> zwracany wynik Interpolacji (oraz lokalny akumulator)
;xmm4  -> parametr dy
;xmm5 -> parametr f1
;xmm6 -> parametr f2
;xmm7 -> parametr f3
;xmm14 xmm15 xmm2 -->  kontenery


;OBLICZENIA

;xmm14: f3-f1
			movss			xmm0,xmm7		;Przeniesienie wartoœci parametru f3 do rejestru xmm0.
			subss			xmm0,xmm5		;Odjêcie od niej wartoœci parametru f1.
			movss			xmm14,xmm0		;Zapisanie otrzymanego wyniku w rejestrze xmm14.

;xmm15: 2*f2
			movss			xmm0,xmm6		;Przeniesienie wartoœci paramteru f2 do rejestru xmm0.
			addss			xmm0,xmm0		;Dodanie do przeniesionej wartoœci jej samej.
			movss			xmm15,xmm0		;Zapisanie otrzymanego wyniku w rejestrze xmm15.

;xmm2: f1 - 2*f2 + f3
			movss			xmm0,xmm5		;Przeniesienie wartoœci parametru f1 do rejestru xmm0.
			subss			xmm0,xmm15		;Odjêcie od niej wartoœci zapisanej w rejestrze xmm15.
			addss			xmm0,xmm7		;Dodanie wartoœci parametru f3.
			movss			xmm2,xmm0		;Zapisanie otrzymanego wyniku w rejestrze xmm2.

; xmm14: (f3-f1)*dy
			mulss			xmm14,xmm4		;Przemno¿enie wartoœci przechowywanej w rejestrze xmm14 przez wspó³czynnik dy.
			
;xmm2: (f1-2*f2+f3)*dy*dy
			mulss			xmm2,xmm4		;Przemno¿enie wartoœci zapisanej w rejestrze xmm2 przez wspó³czynnik dy.
			mulss			xmm2,xmm4		;Ponowne przemno¿enie wartoœci zapisanej w rejestrze xmm2 przez wspó³czynnik dy.

;xmm0: wynik
			movss			xmm0,xmm6		;Przeniesienie wartoœci parametru f2 do rejestru xmm0.
			addss			xmm0,xmm14		;Dodanie do niej obliczonej wartoœci przechowywanej w rejestrze xmm14.
			addss			xmm0,xmm2		;Dodanie obliczonej wartoœci przechowywanej w rejestrze xmm2.
											;Otrzymana wartoœæ w rejestrze xmm0 to wynik interpolacji kwadratowej.

KONWERSJA:
			cvtss2si	rax,xmm0			;Konwersja otrzymanej wartoœci na wartoœæ typu INTEGER i zapisanie jej w rejestrze rax.

;KONTROLA ZAKRESU

			cmp rax,255						;Sprawdzenie czy otrzymana wartoœæ jest mniejsza od 255.
			jnl MAXWYNIK					;Je¿eli nie jest mniejsza, nastêpuje skok do etykiety MAXWYNIK.

			cmp rax,0						;Sprawdzenie czy otrzymana wartoœæ nie jest ujemna.
			js MINWYNIK						;Jeœli jest ujemna, nastêpuje skok do etykiety MINWYNIK.

			jmp KONIEC						;Jeœli wartoœæ w rejestrze rax mieœci siê w zakresie 0 - 255, pozostaje niezmieniona.
											;Nastêuje skok do etykiety KONIEC.

MINWYNIK:
			mov rax, 0						;Do rejestru rax wpisywana jest najmniejsza przewidziana wartoœæ 0.
			jmp KONIEC						;Skok do etykiety KONIEC.

MAXWYNIK:
			mov rax,255						;Do rejestru rax wpisywana jest maksymalna przewidziana wartoœæ 255.

KONIEC:

			ret								;Powrót z procedury.				

InterpolacjaNorm ENDP						;Koniec procedury.

;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

END
