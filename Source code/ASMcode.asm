
; Imi�:     Arkadiusz
; Nazwisko: Pilarski
; Rok akademicki: 2017/2018

.code

;////////////////////////////////////////////////////////////////////////////////////////////////////////////

InterpolacjaDwukwadratowaASM PROC tabela:QWORD, X:Real4, Y:Real4, W:QWORD, H:QWORD	;Pocz�tek procedury, przechowanie parametr�w w zmiennych.
local  wynikA:QWORD, wynikR:QWORD, wynikG:QWORD, wynikB:QWORD						;Zmienne przechowuj�ce warto�ci wyznaczonych sk�adowych nowego piksela.


;Oznaczenia zmiennych u�ywanych w programie:
;tabela -> rcx   X  -> xmm1   Y  -> xmm2   x1 -> rdx    y1 -> r8   x0 -> r10   y0 -> r11
;   x2  -> r12   y2 -> r13    dx -> xmm3   dy -> xmm4   W  -> r9   H  -> H


;Kod procedury
;------------------------------------------------------------------------------------------------------------
; x1: rdx: (int)X					
			cvtss2si	rdx,xmm1	;Konwersja parametru X (przekazanego do funkcji) na warto�� typu INTEGER.

; y1: r8: (int)Y
			cvtss2si	r8,xmm2		;Konwersja parametru Y (przekazanego do funkcji) na warto�� typu INTEGER.


;Kontrola indeksu tablicy
			cmp rdx,r9				;Sprawdzenie czy warto�� wsp�rz�dnej x1 jest mniejsza od granicy rozmiaru obrazu.
			jl KONTYNUUJ			;Je�li jest mniejsza, program kontynuuje dzia�anie.
ZAKRES:								;Je�li nie jest mniejsza, ustawiana jest maksymalna dozwolona warto�� 
			dec rdx					;r�wna szeroko�ci obrazu pomniejszonej o 1 (indeksowanie tablicy od 0).
KONTYNUUJ:							;Kontynuacja pracy programu.
			cmp r8,H				;Sprawdzenie czy warto�� wsp�rz�dnej y1 jest mniejsza od granicy rozmiaru obrazu.
			jl KONTYNUUJ2			;Je�li jest mniejsza, program kontynuuje dzia�anie.
ZAKRES2:							;Je�li nie jest mniejsza, ustawiana jest maksymalna dozwolona warto�� 
			dec r8					;r�wna wysoko�ci obrazu pomniejszonej o 1 (indeksowanie tablicy od 0).
KONTYNUUJ2:							;Kontynuacja pracy programu.

; dx: xmm3:= (float)(x - x1)		
			movss		xmm3,xmm1	;Przepisanie warto�ci X do rejestru xmm3, gdzie zostanie wyznaczona warto�� dx
			cvtsi2ss	xmm6,rdx	;Konwersja warto�ci X1 do zmiennej typu FLOAT.
			subss		xmm3,xmm6	;Odj�cie otrzymanej warto�ci od przechowywanej warto�ci X (wyznaczenie warto�ci dx)

; dy: xmm4:= (float)(y - y1)
			movss		xmm4,xmm2	;Przepisanie warto�ci Y do rejestru xmm4, gdzie zostanie wyznaczona warto�� dy
			cvtsi2ss	xmm6,r8		;Konwersja warto�ci Y1 do zmiennej typu FLOAT.
			subss		xmm4,xmm6	;Odj�cie otrzymanej warto�ci od przechowywanej warto�ci Y (wyznaczenie warto�ci dy)

WARUNEK1:							;Wyznaczanie wsp�rz�dnych punkt�w, na podstawie kt�rych zostanie wyznaczona warto�� piksela 
; if (x1 - 1 >= 0)					;nowej bitmapy. Instrukcje warunkowe zapobiegaj� wyznaczeniu punkt�w spoza bitmapy. 
			dec		rdx				;Dekrementacja wsp�rz�dnej x1.
			test	rdx,rdx			;Sprawdzenie czy wyznaczona wsp�rz�dna nie jest ujemna (ustawienie warto�ci Sign Flag).
			js		X0ujemna		;Je�li jest ujemna (Sign Flag == 1) skok do etykiety X0ujemna.

; x0 = x1 - 1
			mov		r10,rdx			;Je�li nie jest ujemna (Sign Flag == 0 ) przeniesienie zdekrementowanej warto�ci x1 do rejestru r10 (wsp�rz�dnej x0).
			inc		rdx				;Inkrementacja rdx w celu przywr�cenia warto�ci x1.
			jmp		WARUNEK2		;Skok do etykiety z kolejn� instrukcj� warunkow�.

X0ujemna:
; else x0 = x1;
			inc		rdx				;Inkrementacja ujemnej warto�ci do dolnej warto�ci granicznej r�wnej 0.
			mov		r10,rdx			;Ustawienie warto�ci r10 (wsp�rz�dnej x0) jako 0 (aktualna warto�� wsp�rz�dnej x1).

WARUNEK2:
; if (y1 - 1 >= 0)
			dec		r8				;Dekrementacja wsp�rz�dnej y1.
			test	r8,r8			;Sprawdzenie czy wyznaczona wsp�rz�dna nie jest ujemna (ustawienie warto�ci Sign Flag).
			js		Y0ujemna		;Je�li jest ujemna (Sign Flag == 1) skok do etykiety Y0ujemna.

; y0 = y1 - 1
			mov		r11,r8			;Je�li nie jest ujemna (Sign Flag == 0 ) przeniesienie zdekrementowanej warto�ci y1 do rejestru r11 (wsp�rz�dnej y0).
			inc		r8				;Inkrementacja r8 w celu przywr�cenia warto�ci y1.
			jmp		WARUNEK3			;Skok do etykiety z kolejn� instrukcj� warunkow�.

Y0ujemna:
; else y0 = y1;
			inc		r8				;Inkrementacja ujemnej warto�ci do dolnej warto�ci granicznej r�wnej 0.
			mov		r11,r8			;Ustawienie warto�ci r11 (wsp�rz�dnej y0) jako 0 (aktualna warto�� wsp�rz�dnej y1).

WARUNEK3:
; if (x1 + 1 >= sourceWidth)
			inc		rdx				;Inkrementacja wsp�rz�dnej x1.
			cmp		rdx,r9			;Sprawdzenie czy wartosc wspolrzednej X1 jest mniejsza od granicy rozmiaru obrazu (szeroko��).
			jl		X2mniejsza		;Je�li jest mniejsza, nast�puje skok do etykiety X2mniejsza.

;x2 = x1
			dec		rdx				;Dekrementacja rdx w celu przywr�cenia warto�ci x1.
			mov		r12,rdx			;Przypisanie warto�ci x1 do nowej wsp�rz�dnej x2, przechowywanej w rejestrze r12.
			jmp		WARUNEK4		;Skok do kolejnej instrukcji warunkowej.

X2mniejsza:
; x2 = x1 + 1;
			mov		r12,rdx			;Przypisanie zinkrementowanej warto�ci x1 do nowej wsp�rz�dnej x2.
			dec		rdx				;Dekrementacja rdx w celu przywr�cenia warto�ci x1.

WARUNEK4:
; if (y1 + 1 >= sourceHeight)

			inc		r8				;Inkrementacja wsp�rz�dnej y1.
			cmp		r8,H			;Sprawdzenie czy wartosc wspolrzednej y1 jest mniejsza od granicy rozmiaru obrazu (wysoko��).
			jl		Y2mniejsza		;Je�li jest mniejsza, nast�puje skok do etykiety Y2mniejsza.

; y2 = y1
			dec		r8				;Dekrementacja r8 w celu przywr�cenia warto�ci y1.
			mov		r13,r8			;Przypisanie warto�ci y1 do nowej wsp�rz�dnej y2, przechowywanej w rejestrze r13.
			jmp		OBLICZENIA		;Skok do etykiety zawieraj�cej instrukcje wyznaczaj�ce warto�� piksela w oparciu o wyznaczone punkty (wsp�rz�dne).

Y2mniejsza:
; y2 = y1 + 1
			mov		r13,r8			;Przypisanie zinkrementowanej warto�ci y1 do nowej wsp�rz�dnej y2.
			dec		r8				;Dekrementacja r8 w celu przywr�cenia warto�ci y1.

OBLICZENIA:

;OBLICZANIE SK�ADOWEJ A 
;-------------------------------------------------------------------------------------------------------------------------------------------
;Obliczenie nowej sk�adowej piksela polega na trzykrotnym wykonaniu interpolacji trzech warto�ci sk�adowej, pobranych z trzech (wyznaczonych wcze�niej) punkt�w.
;Ka�dorazowe wykonanie operacji nast�puje w oparciu o zestaw 3 innych punkt�w.
;Punkty te zosta�y wyznaczone dzi�ki otrzymanym wsp�rz�dnym x0, y0, x1, y1, x2, y2 (ich kombinacji).
;Po wykonanych operacjach, nast�puje interpolacja warto�ci otrzymanych z poprzednich interpolacji z normalizacj� warto�ci.
			
;index:  x0 + y0 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel (punkt).
			mov		rax,r11			;Przeniesienie warto�ci y0 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r10			;Dodanie do akumulatora warto�ci wsp�rz�dnej x0. Otrzymana warto�� akumulatora to szukany indeks.
			
			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			shr		rax,24			;Przesuni�cie bitowe pobranej warto�ci piksela w prawo o 24 miejsca, aby warto�� sk�adowej A znalaz�a si� na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta�ych bajt�w przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej A piksela.
			cvtsi2ss xmm10,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm10.

;index:  x1 + y0 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel.
			mov		rax,r11			;Przeniesienie warto�ci y0 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,rdx			;Dodanie do akumulatora warto�ci wsp�rz�dnej x1. Otrzymana warto�� akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			shr		rax,24			;Przesuni�cie bitowe pobranej warto�ci piksela w prawo o 24 miejsca, aby warto�� sk�adowej A znalaz�a si� na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta�ych bajt�w przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej A piksela.
			cvtsi2ss xmm11,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm11.

;index:  x2 + y0 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel.
			mov		rax,r11			;Przeniesienie warto�ci y0 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r12			;Dodanie do akumulatora warto�ci wsp�rz�dnej x2. Otrzymana warto�� akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			shr		rax,24			;Przesuni�cie bitowe pobranej warto�ci piksela w prawo o 24 miejsca, aby warto�� sk�adowej A znalaz�a si� na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta�ych bajt�w przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej A piksela.
			cvtsi2ss xmm12,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm12.


; Interpolacja obliczonych wartosci
			call Interpolacja		;Wywo�anie procedury przeprowadzaj�cej interpolacj� otrzymanych warto�ci (przechowywanych w xmm10, xmm11, xmm12).
			movss	xmm5,xmm0		;Procedura ta zwraca wynik w rejestrze xmm0, kt�y jest tutaj przepisywany do rejestru xmm5.


;index:  x0 + y1 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel.
			mov		rax,r8			;Przeniesienie warto�ci y1 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r10			;Dodanie do akumulatora warto�ci wsp�rz�dnej x0. Otrzymana warto�� akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			shr		rax,24			;Przesuni�cie bitowe pobranej warto�ci piksela w prawo o 24 miejsca, aby warto�� sk�adowej A znalaz�a si� na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta�ych bajt�w przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej A piksela.
			cvtsi2ss xmm10,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm10.

;index:  x1 + y1 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel.
			mov		rax,r8			;Przeniesienie warto�ci y1 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,rdx			;Dodanie do akumulatora warto�ci wsp�rz�dnej x1. Otrzymana warto�� akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			shr		rax,24			;Przesuni�cie bitowe pobranej warto�ci piksela w prawo o 24 miejsca, aby warto�� sk�adowej A znalaz�a si� na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta�ych bajt�w przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej A piksela.
			cvtsi2ss xmm11,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm11.

;index:  x2 + y1 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel.
			mov		rax,r8			;Przeniesienie warto�ci y1 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r12			;Dodanie do akumulatora warto�ci wsp�rz�dnej x2. Otrzymana warto�� akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			shr		rax,24			;Przesuni�cie bitowe pobranej warto�ci piksela w prawo o 24 miejsca, aby warto�� sk�adowej A znalaz�a si� na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta�ych bajt�w przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej A piksela.
			cvtsi2ss xmm12,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm12.


; Interpolacja obliczonych wartosci
			call Interpolacja		;Wywo�anie procedury przeprowadzaj�cej interpolacj� otrzymanych warto�ci (przechowywanych w xmm10, xmm11, xmm12).
			movss	xmm6,xmm0		;Procedura ta zwraca wynik w rejestrze xmm0, kt�y jest tutaj przepisywany do rejestru xmm6.


;index:  x0 + y2 * sourceWudth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel.
			mov		rax,r13			;Przeniesienie warto�ci y2 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r10			;Dodanie do akumulatora warto�ci wsp�rz�dnej x0. Otrzymana warto�� akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			shr		rax,24			;Przesuni�cie bitowe pobranej warto�ci piksela w prawo o 24 miejsca, aby warto�� sk�adowej A znalaz�a si� na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta�ych bajt�w przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej A piksela.
			cvtsi2ss xmm10,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm10.

;index:  x1 + y2 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel.
			mov		rax,r13			;Przeniesienie warto�ci y2 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,rdx			;Dodanie do akumulatora warto�ci wsp�rz�dnej x1. Otrzymana warto�� akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			shr		rax,24			;Przesuni�cie bitowe pobranej warto�ci piksela w prawo o 24 miejsca, aby warto�� sk�adowej A znalaz�a si� na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta�ych bajt�w przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej A piksela.
			cvtsi2ss xmm11,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm11.

;index:  x2 + y2 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel.
			mov		rax,r13			;Przeniesienie warto�ci y2 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r12			;Dodanie do akumulatora warto�ci wsp�rz�dnej x2. Otrzymana warto�� akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			shr		rax,24			;Przesuni�cie bitowe pobranej warto�ci piksela w prawo o 24 miejsca, aby warto�� sk�adowej A znalaz�a si� na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta�ych bajt�w przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej A piksela.
			cvtsi2ss xmm12,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm12.


; Interpolacja obliczonych wartosci
			call Interpolacja		;Wywo�anie procedury przeprowadzaj�cej interpolacj� otrzymanych warto�ci (przechowywanych w xmm10, xmm11, xmm12).
			movss	xmm7,xmm0		;Procedura ta zwraca wynik w rejestrze xmm0, kt�y jest tutaj przepisywany do rejestru xmm7.


; Interpolacja z normalizacja
			call InterpolacjaNorm	;Wywo�anie procedury przeprowadzaj�cej interpolacj� otrzymanych warto�ci (przechowywanych w xmm5, xmm6, xmm7).
									;Procedura ta normalizuje warto�� otrzymanego wyniku, aby zawiera� si� on w przewidzianym przedziale.
									;Wynik zwracany jest w rejestrze rax.
;Sk�adowa A
			mov		wynikA,rax		;Zapisanie otrzymanej warto�ci z akumulatora jako sk�adowej A (alfa) nowego piksela.



;OBLICZANIE SK�ADOWEJ R 
;-------------------------------------------------------------------------------------------------------------------------------------------
;Obliczenie nowej sk�adowej piksela polega na trzykrotnym wykonaniu interpolacji trzech warto�ci sk�adowej, pobranych z trzech (wyznaczonych wcze�niej) punkt�w.
;Ka�dorazowe wykonanie operacji nast�puje w oparciu o zestaw 3 innych punkt�w.
;Punkty te zosta�y wyznaczone dzi�ki otrzymanym wsp�rz�dnym x0, y0, x1, y1, x2, y2 (ich kombinacji).
;Po wykonanych operacjach, nast�puje interpolacja warto�ci otrzymanych z poprzednich interpolacji z normalizacj� warto�ci.
	
;index:  x0 + y0 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel (punkt).
			mov		rax,r11			;Przeniesienie warto�ci y0 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r10			;Dodanie do akumulatora warto�ci wsp�rz�dnej x0. Otrzymana warto�� akumulatora to szukany indeks.
			
			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			shr		rax,16			;Przesuni�cie bitowe pobranej warto�ci piksela w prawo o 16 miejsc, aby warto�� sk�adowej R znalaz�a si� na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta�ych bajt�w przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej R piksela.
			cvtsi2ss xmm10,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm10.

;index:  x1 + y0 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel.
			mov		rax,r11			;Przeniesienie warto�ci y0 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,rdx			;Dodanie do akumulatora warto�ci wsp�rz�dnej x1. Otrzymana warto�� akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			shr		rax,16			;Przesuni�cie bitowe pobranej warto�ci piksela w prawo o 16 miejsc, aby warto�� sk�adowej R znalaz�a si� na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta�ych bajt�w przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej R piksela.
			cvtsi2ss xmm11,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm11.

;index:  x2 + y0 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel.
			mov		rax,r11			;Przeniesienie warto�ci y0 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r12			;Dodanie do akumulatora warto�ci wsp�rz�dnej x2. Otrzymana warto�� akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			shr		rax,16			;Przesuni�cie bitowe pobranej warto�ci piksela w prawo o 16 miejsc, aby warto�� sk�adowej R znalaz�a si� na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta�ych bajt�w przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej R piksela.
			cvtsi2ss xmm12,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm12.


; Interpolacja obliczonych wartosci
			call Interpolacja		;Wywo�anie procedury przeprowadzaj�cej interpolacj� otrzymanych warto�ci (przechowywanych w xmm10, xmm11, xmm12).
			movss	xmm5,xmm0		;Procedura ta zwraca wynik w rejestrze xmm0, kt�y jest tutaj przepisywany do rejestru xmm5.


;index:  x0 + y1 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel.
			mov		rax,r8			;Przeniesienie warto�ci y1 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r10			;Dodanie do akumulatora warto�ci wsp�rz�dnej x0. Otrzymana warto�� akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			shr		rax,16			;Przesuni�cie bitowe pobranej warto�ci piksela w prawo o 16 miejsc, aby warto�� sk�adowej R znalaz�a si� na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta�ych bajt�w przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej R piksela.
			cvtsi2ss xmm10,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm10.

;index:  x1 + y1 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel.
			mov		rax,r8			;Przeniesienie warto�ci y1 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,rdx			;Dodanie do akumulatora warto�ci wsp�rz�dnej x1. Otrzymana warto�� akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			shr		rax,16			;Przesuni�cie bitowe pobranej warto�ci piksela w prawo o 16 miejsc, aby warto�� sk�adowej R znalaz�a si� na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta�ych bajt�w przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej R piksela.
			cvtsi2ss xmm11,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm11.

;index:  x2 + y1 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel.
			mov		rax,r8			;Przeniesienie warto�ci y1 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r12			;Dodanie do akumulatora warto�ci wsp�rz�dnej x2. Otrzymana warto�� akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			shr		rax,16			;Przesuni�cie bitowe pobranej warto�ci piksela w prawo o 16 miejsc, aby warto�� sk�adowej R znalaz�a si� na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta�ych bajt�w przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej R piksela.
			cvtsi2ss xmm12,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm12.


; Interpolacja obliczonych wartosci
			call Interpolacja		;Wywo�anie procedury przeprowadzaj�cej interpolacj� otrzymanych warto�ci (przechowywanych w xmm10, xmm11, xmm12).
			movss	xmm6,xmm0		;Procedura ta zwraca wynik w rejestrze xmm0, kt�y jest tutaj przepisywany do rejestru xmm6.


;index:  x0 + y2 * sourceWudth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel.
			mov		rax,r13			;Przeniesienie warto�ci y2 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r10			;Dodanie do akumulatora warto�ci wsp�rz�dnej x0. Otrzymana warto�� akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			shr		rax,16			;Przesuni�cie bitowe pobranej warto�ci piksela w prawo o 16 miejsc, aby warto�� sk�adowej R znalaz�a si� na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta�ych bajt�w przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej R piksela.
			cvtsi2ss xmm10,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm10.

;index:  x1 + y2 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel.
			mov		rax,r13			;Przeniesienie warto�ci y2 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,rdx			;Dodanie do akumulatora warto�ci wsp�rz�dnej x1. Otrzymana warto�� akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			shr		rax,16			;Przesuni�cie bitowe pobranej warto�ci piksela w prawo o 16 miejsc, aby warto�� sk�adowej R znalaz�a si� na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta�ych bajt�w przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej R piksela.
			cvtsi2ss xmm11,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm11.

;index:  x2 + y2 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel.
			mov		rax,r13			;Przeniesienie warto�ci y2 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r12			;Dodanie do akumulatora warto�ci wsp�rz�dnej x2. Otrzymana warto�� akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			shr		rax,16			;Przesuni�cie bitowe pobranej warto�ci piksela w prawo o 16 miejsc, aby warto�� sk�adowej R znalaz�a si� na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta�ych bajt�w przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej R piksela.
			cvtsi2ss xmm12,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm12.


; Interpolacja obliczonych wartosci
			call Interpolacja		;Wywo�anie procedury przeprowadzaj�cej interpolacj� otrzymanych warto�ci (przechowywanych w xmm10, xmm11, xmm12).
			movss	xmm7,xmm0		;Procedura ta zwraca wynik w rejestrze xmm0, kt�y jest tutaj przepisywany do rejestru xmm7.


; Interpolacja z normalizacja
			call InterpolacjaNorm	;Wywo�anie procedury przeprowadzaj�cej interpolacj� otrzymanych warto�ci (przechowywanych w xmm5, xmm6, xmm7).
									;Procedura ta normalizuje warto�� otrzymanego wyniku, aby zawiera� si� on w przewidzianym przedziale.
									;Wynik zwracany jest w rejestrze rax.
;Sk�adowa R
			mov		wynikR,rax		;Zapisanie otrzymanej warto�ci z akumulatora jako sk�adowej R (red) nowego piksela.



;OBLICZANIE SK�ADOWEJ G 
;-------------------------------------------------------------------------------------------------------------------------------------------
;Obliczenie nowej sk�adowej piksela polega na trzykrotnym wykonaniu interpolacji trzech warto�ci sk�adowej, pobranych z trzech (wyznaczonych wcze�niej) punkt�w.
;Ka�dorazowe wykonanie operacji nast�puje w oparciu o zestaw 3 innych punkt�w.
;Punkty te zosta�y wyznaczone dzi�ki otrzymanym wsp�rz�dnym x0, y0, x1, y1, x2, y2 (ich kombinacji).
;Po wykonanych operacjach, nast�puje interpolacja warto�ci otrzymanych z poprzednich interpolacji z normalizacj� warto�ci.
	
;index:  x0 + y0 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel (punkt).
			mov		rax,r11			;Przeniesienie warto�ci y0 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r10			;Dodanie do akumulatora warto�ci wsp�rz�dnej x0. Otrzymana warto�� akumulatora to szukany indeks.
			
			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			shr		rax,8			;Przesuni�cie bitowe pobranej warto�ci piksela w prawo o 8 miejsc, aby warto�� sk�adowej G znalaz�a si� na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta�ych bajt�w przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej G piksela.
			cvtsi2ss xmm10,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm10.

;index:  x1 + y0 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel.
			mov		rax,r11			;Przeniesienie warto�ci y0 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,rdx			;Dodanie do akumulatora warto�ci wsp�rz�dnej x1. Otrzymana warto�� akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			shr		rax,8			;Przesuni�cie bitowe pobranej warto�ci piksela w prawo o 8 miejsc, aby warto�� sk�adowej G znalaz�a si� na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta�ych bajt�w przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej G piksela.
			cvtsi2ss xmm11,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm11.

;index:  x2 + y0 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel.
			mov		rax,r11			;Przeniesienie warto�ci y0 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r12			;Dodanie do akumulatora warto�ci wsp�rz�dnej x2. Otrzymana warto�� akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			shr		rax,8			;Przesuni�cie bitowe pobranej warto�ci piksela w prawo o 8 miejsc, aby warto�� sk�adowej G znalaz�a si� na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta�ych bajt�w przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej G piksela.
			cvtsi2ss xmm12,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm12.


; Interpolacja obliczonych wartosci
			call Interpolacja		;Wywo�anie procedury przeprowadzaj�cej interpolacj� otrzymanych warto�ci (przechowywanych w xmm10, xmm11, xmm12).
			movss	xmm5,xmm0		;Procedura ta zwraca wynik w rejestrze xmm0, kt�y jest tutaj przepisywany do rejestru xmm5.


;index:  x0 + y1 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel.
			mov		rax,r8			;Przeniesienie warto�ci y1 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r10			;Dodanie do akumulatora warto�ci wsp�rz�dnej x0. Otrzymana warto�� akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			shr		rax,8			;Przesuni�cie bitowe pobranej warto�ci piksela w prawo o 8 miejsc, aby warto�� sk�adowej G znalaz�a si� na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta�ych bajt�w przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej G piksela.
			cvtsi2ss xmm10,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm10.

;index:  x1 + y1 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel.
			mov		rax,r8			;Przeniesienie warto�ci y1 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,rdx			;Dodanie do akumulatora warto�ci wsp�rz�dnej x1. Otrzymana warto�� akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			shr		rax,8			;Przesuni�cie bitowe pobranej warto�ci piksela w prawo o 8 miejsc, aby warto�� sk�adowej G znalaz�a si� na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta�ych bajt�w przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej G piksela.
			cvtsi2ss xmm11,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm11.

;index:  x2 + y1 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel.
			mov		rax,r8			;Przeniesienie warto�ci y1 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r12			;Dodanie do akumulatora warto�ci wsp�rz�dnej x2. Otrzymana warto�� akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			shr		rax,8			;Przesuni�cie bitowe pobranej warto�ci piksela w prawo o 8 miejsc, aby warto�� sk�adowej G znalaz�a si� na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta�ych bajt�w przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej G piksela.
			cvtsi2ss xmm12,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm12.


; Interpolacja obliczonych wartosci
			call Interpolacja		;Wywo�anie procedury przeprowadzaj�cej interpolacj� otrzymanych warto�ci (przechowywanych w xmm10, xmm11, xmm12).
			movss	xmm6,xmm0		;Procedura ta zwraca wynik w rejestrze xmm0, kt�y jest tutaj przepisywany do rejestru xmm6.


;index:  x0 + y2 * sourceWudth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel.
			mov		rax,r13			;Przeniesienie warto�ci y2 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r10			;Dodanie do akumulatora warto�ci wsp�rz�dnej x0. Otrzymana warto�� akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			shr		rax,8			;Przesuni�cie bitowe pobranej warto�ci piksela w prawo o 8 miejsc, aby warto�� sk�adowej G znalaz�a si� na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta�ych bajt�w przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej G piksela.
			cvtsi2ss xmm10,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm10.

;index:  x1 + y2 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel.
			mov		rax,r13			;Przeniesienie warto�ci y2 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,rdx			;Dodanie do akumulatora warto�ci wsp�rz�dnej x1. Otrzymana warto�� akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			shr		rax,8			;Przesuni�cie bitowe pobranej warto�ci piksela w prawo o 8 miejsc, aby warto�� sk�adowej G znalaz�a si� na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta�ych bajt�w przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej G piksela.
			cvtsi2ss xmm11,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm11.

;index:  x2 + y2 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel.
			mov		rax,r13			;Przeniesienie warto�ci y2 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r12			;Dodanie do akumulatora warto�ci wsp�rz�dnej x2. Otrzymana warto�� akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			shr		rax,8			;Przesuni�cie bitowe pobranej warto�ci piksela w prawo o 8 miejsc, aby warto�� sk�adowej G znalaz�a si� na ostatnim skrajnym bajcie.
			and		rax,255			;Wyzerowanie wszystkich pozosta�ych bajt�w przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej G piksela.
			cvtsi2ss xmm12,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm12.


; Interpolacja obliczonych wartosci
			call Interpolacja		;Wywo�anie procedury przeprowadzaj�cej interpolacj� otrzymanych warto�ci (przechowywanych w xmm10, xmm11, xmm12).
			movss	xmm7,xmm0		;Procedura ta zwraca wynik w rejestrze xmm0, kt�y jest tutaj przepisywany do rejestru xmm7.


; Interpolacja z normalizacja
			call InterpolacjaNorm	;Wywo�anie procedury przeprowadzaj�cej interpolacj� otrzymanych warto�ci (przechowywanych w xmm5, xmm6, xmm7).
									;Procedura ta normalizuje warto�� otrzymanego wyniku, aby zawiera� si� on w przewidzianym przedziale.
									;Wynik zwracany jest w rejestrze rax.
;skladowa G
			mov		wynikG,rax		;Zapisanie otrzymanej warto�ci z akumulatora jako sk�adowej G (green) nowego piksela.



;OBLICZANIE SK�ADOWEJ B
;-------------------------------------------------------------------------------------------------------------------------------------------
;Obliczenie nowej sk�adowej piksela polega na trzykrotnym wykonaniu interpolacji trzech warto�ci sk�adowej, pobranych z trzech (wyznaczonych wcze�niej) punkt�w.
;Ka�dorazowe wykonanie operacji nast�puje w oparciu o zestaw 3 innych punkt�w.
;Punkty te zosta�y wyznaczone dzi�ki otrzymanym wsp�rz�dnym x0, y0, x1, y1, x2, y2 (ich kombinacji).
;Po wykonanych operacjach, nast�puje interpolacja warto�ci otrzymanych z poprzednich interpolacji z normalizacj� warto�ci.
	
;index:  x0 + y0 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel (punkt).
			mov		rax,r11			;Przeniesienie warto�ci y0 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r10			;Dodanie do akumulatora warto�ci wsp�rz�dnej x0. Otrzymana warto�� akumulatora to szukany indeks.
			
			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			and		rax,255			;Wyzerowanie wszystkich bajt�w poza ostatnim (skrajnym) przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej B piksela.
			cvtsi2ss xmm10,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm10.

;index:  x1 + y0 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel.
			mov		rax,r11			;Przeniesienie warto�ci y0 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,rdx			;Dodanie do akumulatora warto�ci wsp�rz�dnej x1. Otrzymana warto�� akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			and		rax,255			;Wyzerowanie wszystkich bajt�w poza ostatnim (skrajnym) przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej B piksela.
			cvtsi2ss xmm11,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm11.

;index:  x2 + y0 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel.
			mov		rax,r11			;Przeniesienie warto�ci y0 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r12			;Dodanie do akumulatora warto�ci wsp�rz�dnej x2. Otrzymana warto�� akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			and		rax,255			;Wyzerowanie wszystkich bajt�w poza ostatnim (skrajnym) przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej B piksela.
			cvtsi2ss xmm12,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm12.


; Interpolacja obliczonych wartosci
			call Interpolacja		;Wywo�anie procedury przeprowadzaj�cej interpolacj� otrzymanych warto�ci (przechowywanych w xmm10, xmm11, xmm12).
			movss	xmm5,xmm0		;Procedura ta zwraca wynik w rejestrze xmm0, kt�y jest tutaj przepisywany do rejestru xmm5.


;index:  x0 + y1 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel.
			mov		rax,r8			;Przeniesienie warto�ci y1 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r10			;Dodanie do akumulatora warto�ci wsp�rz�dnej x0. Otrzymana warto�� akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			and		rax,255			;Wyzerowanie wszystkich bajt�w poza ostatnim (skrajnym) przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej B piksela.
			cvtsi2ss xmm10,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm10.

;index:  x1 + y1 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel.
			mov		rax,r8			;Przeniesienie warto�ci y1 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,rdx			;Dodanie do akumulatora warto�ci wsp�rz�dnej x1. Otrzymana warto�� akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			and		rax,255			;Wyzerowanie wszystkich bajt�w poza ostatnim (skrajnym) przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej B piksela.
			cvtsi2ss xmm11,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm11.

;index:  x2 + y1 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel.
			mov		rax,r8			;Przeniesienie warto�ci y1 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r12			;Dodanie do akumulatora warto�ci wsp�rz�dnej x2. Otrzymana warto�� akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			and		rax,255			;Wyzerowanie wszystkich bajt�w poza ostatnim (skrajnym) przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej B piksela.
			cvtsi2ss xmm12,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm12.


; Interpolacja obliczonych wartosci
			call Interpolacja		;Wywo�anie procedury przeprowadzaj�cej interpolacj� otrzymanych warto�ci (przechowywanych w xmm10, xmm11, xmm12).
			movss	xmm6,xmm0		;Procedura ta zwraca wynik w rejestrze xmm0, kt�y jest tutaj przepisywany do rejestru xmm6.


;index:  x0 + y2 * sourceWudth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel.
			mov		rax,r13			;Przeniesienie warto�ci y2 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r10			;Dodanie do akumulatora warto�ci wsp�rz�dnej x0. Otrzymana warto�� akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			and		rax,255			;Wyzerowanie wszystkich bajt�w poza ostatnim (skrajnym) przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej B piksela.
			cvtsi2ss xmm10,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm10.

;index:  x1 + y2 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel.
			mov		rax,r13			;Przeniesienie warto�ci y2 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,rdx			;Dodanie do akumulatora warto�ci wsp�rz�dnej x1. Otrzymana warto�� akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			and		rax,255			;Wyzerowanie wszystkich bajt�w poza ostatnim (skrajnym) przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej B piksela.
			cvtsi2ss xmm11,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm11.

;index:  x2 + y2 * sourceWidth		;Obliczanie indeksu tablicy pikseli, pod kt�rym znajduje si� szukany piksel.
			mov		rax,r13			;Przeniesienie warto�ci y2 do akumulatora.
			imul	rax,r9			;Pomno�enie akumulatora przez szeroko�� bitmapy (przetrzymywaniej w rejestrze r9).
			add		rax,r12			;Dodanie do akumulatora warto�ci wsp�rz�dnej x2. Otrzymana warto�� akumulatora to szukany indeks.

			mov		rax,[rcx+rax*8]	;Pobranie szukanej warto�ci z tablicy.
			and		rax,255			;Wyzerowanie wszystkich bajt�w poza ostatnim (skrajnym) przy pomocy maski 255. Otrzymana warto�� akumulatora to szukana warto�� sk�adowej B piksela.
			cvtsi2ss xmm12,rax		;Konwersja otrzymanej warto�ci na warto�� typu FLOAT i przechowywanie jej w rejestrze xmm12.


; Interpolacja obliczonych wartosci
			call Interpolacja		;Wywo�anie procedury przeprowadzaj�cej interpolacj� otrzymanych warto�ci (przechowywanych w xmm10, xmm11, xmm12).
			movss	xmm7,xmm0		;Procedura ta zwraca wynik w rejestrze xmm0, kt�y jest tutaj przepisywany do rejestru xmm7.


; Interpolacja z normalizacja
			call InterpolacjaNorm	;Wywo�anie procedury przeprowadzaj�cej interpolacj� otrzymanych warto�ci (przechowywanych w xmm5, xmm6, xmm7).
									;Procedura ta normalizuje warto�� otrzymanego wyniku, aby zawiera� si� on w przewidzianym przedziale.
									;Wynik zwracany jest w rejestrze rax.
;skladowa B
			mov		wynikB,rax		;Zapisanie otrzymanej warto�ci z akumulatora jako sk�adowej B (blue) nowego piksela.


;PRZYGOTOWANIE WYNIKU PIKSELA
;-------------------------------------------------------------------------------------------------------------------------------------------

			mov		rax,wynikA		;Wpisanie warto�ci sk�adowej A na ostatni bajt akumulatora.
			shl		rax,8			;Przesuni�cie bitowe akumulatora w prawo o jeden bajt.
			add		rax,wynikR		;Wpisanie warto�ci sk�adowej R na ostatni bajt akumulatora.
			shl		rax,8			;Przesuni�cie bitowe akumulatora w prawo o jeden bajt.
			add		rax,wynikG		;Wpisanie warto�ci sk�adowej G na ostatni bajt akumulatora.
			shl		rax,8			;Przesuni�cie bitowe akumulatora w prawo o jeden bajt.
			add		rax,wynikB		;Wpisanie warto�ci sk�adowej B na ostatni bajt akumulatora.

			ret						;W rejestrze rax znajduje si� teraz warto�� nowo wyznaczonego piksela, kt�ra zwracana jest przez procedur� jako wynik.						

InterpolacjaDwukwadratowaASM ENDP	;Koniec procedury.

;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;////////////////////////////////////////////////////////////////////////////////////////////////////////////

Interpolacja PROC	;Procedura przeprowadzaj�ca interpolacj� kwadratow� po trzech warto�ciach (parametry f1, f2, f3).


;OPIS ZMIENNYCH

;xmm0  -> zwracany wynik Interpolacji (oraz lokalny akumulator)
;xmm3  -> parametr dx
;xmm10 -> parametr f1
;xmm11 -> parametr f2
;xmm12 -> parametr f3
;xmm14 xmm15 xmm2 -->  kontenery


;OBLICZENIA

;xmm14: f3-f1
			movss			xmm0,xmm12		;Przeniesienie warto�ci parametru f3 do rejestru xmm0.
			subss			xmm0,xmm10		;Odj�cie od niej warto�ci parametru f1.
			movss			xmm14,xmm0		;Zapisanie otrzymanego wyniku w rejestrze xmm14.

;xmm15: 2*f2
			movss			xmm0,xmm11		;Przeniesienie warto�ci paramteru f2 do rejestru xmm0.
			addss			xmm0,xmm0		;Dodanie do przeniesionej warto�ci jej samej.
			movss			xmm15,xmm0		;Zapisanie otrzymanego wyniku w rejestrze xmm15.

;xmm2: f1 - 2*f2 + f3
			movss			xmm0,xmm10		;Przeniesienie warto�ci parametru f1 do rejestru xmm0.
			subss			xmm0,xmm15		;Odj�cie od niej warto�ci zapisanej w rejestrze xmm15.
			addss			xmm0,xmm12		;Dodanie warto�ci parametru f3.
			movss			xmm2,xmm0		;Zapisanie otrzymanego wyniku w rejestrze xmm2.

; xmm14: (f3-f1)*dy
			mulss			xmm14,xmm3		;Przemno�enie warto�ci przechowywanej w rejestrze xmm14 przez wsp�czynnik dy.
			
;xmm2: (f1-2*f2+f3)*dy*dy
			mulss			xmm2,xmm3		;Przemno�enie warto�ci zapisanej w rejestrze xmm2 przez wsp�czynnik dy.
			mulss			xmm2,xmm3		;Ponowne przemno�enie warto�ci zapisanej w rejestrze xmm2 przez wsp�czynnik dy.

;xmm0: wynik
			movss			xmm0,xmm11		;Przeniesienie warto�ci parametru f2 do rejestru xmm0.
			addss			xmm0,xmm14		;Dodanie do niej obliczonej warto�ci przechowywanej w rejestrze xmm14.
			addss			xmm0,xmm2		;Dodanie obliczonej warto�ci przechowywanej w rejestrze xmm2.
											;Otrzymana warto�� w rejestrze xmm0 to wynik interpolacji kwadratowej.

			ret								;Powr�t z procedury.				

Interpolacja ENDP							;Koniec procedury.

;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;////////////////////////////////////////////////////////////////////////////////////////////////////////////

InterpolacjaNorm PROC												
;Procedura przeprowadzaj�ca interpolacj� kwadratow� po trzech warto�ciach (parametry f1, f2, f3).
;Wyznaczona warto�� jest dodatkowo normalizowana aby zawiera�a si� w przewidzianym przedziale 0 - 255.


;OPIS ZMIENNYCH

;xmm0  -> zwracany wynik Interpolacji (oraz lokalny akumulator)
;xmm4  -> parametr dy
;xmm5 -> parametr f1
;xmm6 -> parametr f2
;xmm7 -> parametr f3
;xmm14 xmm15 xmm2 -->  kontenery


;OBLICZENIA

;xmm14: f3-f1
			movss			xmm0,xmm7		;Przeniesienie warto�ci parametru f3 do rejestru xmm0.
			subss			xmm0,xmm5		;Odj�cie od niej warto�ci parametru f1.
			movss			xmm14,xmm0		;Zapisanie otrzymanego wyniku w rejestrze xmm14.

;xmm15: 2*f2
			movss			xmm0,xmm6		;Przeniesienie warto�ci paramteru f2 do rejestru xmm0.
			addss			xmm0,xmm0		;Dodanie do przeniesionej warto�ci jej samej.
			movss			xmm15,xmm0		;Zapisanie otrzymanego wyniku w rejestrze xmm15.

;xmm2: f1 - 2*f2 + f3
			movss			xmm0,xmm5		;Przeniesienie warto�ci parametru f1 do rejestru xmm0.
			subss			xmm0,xmm15		;Odj�cie od niej warto�ci zapisanej w rejestrze xmm15.
			addss			xmm0,xmm7		;Dodanie warto�ci parametru f3.
			movss			xmm2,xmm0		;Zapisanie otrzymanego wyniku w rejestrze xmm2.

; xmm14: (f3-f1)*dy
			mulss			xmm14,xmm4		;Przemno�enie warto�ci przechowywanej w rejestrze xmm14 przez wsp�czynnik dy.
			
;xmm2: (f1-2*f2+f3)*dy*dy
			mulss			xmm2,xmm4		;Przemno�enie warto�ci zapisanej w rejestrze xmm2 przez wsp�czynnik dy.
			mulss			xmm2,xmm4		;Ponowne przemno�enie warto�ci zapisanej w rejestrze xmm2 przez wsp�czynnik dy.

;xmm0: wynik
			movss			xmm0,xmm6		;Przeniesienie warto�ci parametru f2 do rejestru xmm0.
			addss			xmm0,xmm14		;Dodanie do niej obliczonej warto�ci przechowywanej w rejestrze xmm14.
			addss			xmm0,xmm2		;Dodanie obliczonej warto�ci przechowywanej w rejestrze xmm2.
											;Otrzymana warto�� w rejestrze xmm0 to wynik interpolacji kwadratowej.

KONWERSJA:
			cvtss2si	rax,xmm0			;Konwersja otrzymanej warto�ci na warto�� typu INTEGER i zapisanie jej w rejestrze rax.

;KONTROLA ZAKRESU

			cmp rax,255						;Sprawdzenie czy otrzymana warto�� jest mniejsza od 255.
			jnl MAXWYNIK					;Je�eli nie jest mniejsza, nast�puje skok do etykiety MAXWYNIK.

			cmp rax,0						;Sprawdzenie czy otrzymana warto�� nie jest ujemna.
			js MINWYNIK						;Je�li jest ujemna, nast�puje skok do etykiety MINWYNIK.

			jmp KONIEC						;Je�li warto�� w rejestrze rax mie�ci si� w zakresie 0 - 255, pozostaje niezmieniona.
											;Nast�uje skok do etykiety KONIEC.

MINWYNIK:
			mov rax, 0						;Do rejestru rax wpisywana jest najmniejsza przewidziana warto�� 0.
			jmp KONIEC						;Skok do etykiety KONIEC.

MAXWYNIK:
			mov rax,255						;Do rejestru rax wpisywana jest maksymalna przewidziana warto�� 255.

KONIEC:

			ret								;Powr�t z procedury.				

InterpolacjaNorm ENDP						;Koniec procedury.

;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

END
