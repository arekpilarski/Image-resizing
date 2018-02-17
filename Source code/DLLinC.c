// Imi�:     Arkadiusz
// Nazwisko: Pilarski
// Rok akademicki: 2017/2018

__declspec(dllexport) float _stdcall InterpolacjaNorm(float f1, float f2, float f3, float dy)
// Funkcja przeprowadzaj�ca interpolacj� kwadratow� po trzech warto�ciach (parametry f1, f2, f3).
// Wyznaczona warto�� jest dodatkowo normalizowana aby zawiera�a si� w przewidzianym przedziale 0 - 255.
{
	float result = 0;												// Zmienna przechowuj�ca wynik interpolacji.
	result = (f2 + (f3 - f1) * dy + (f1 - 2 * f2 + f3) * dy * dy);	// Obliczanie warto�ci.

	if (result > 255)												// Utrzymywanie otrzymanego wyniku w przedziale warto�ci 0 - 255.
		return 255;
	if (result < 0)
		return 0;
	return result;
}



__declspec(dllexport) float _stdcall Interpolacja(float f1, float f2, float f3, float dx)
// Funkcja przeprowadzaj�ca interpolacj� kwadratow� po trzech warto�ciach (parametry f1, f2, f3).
{
	float result = 0;												// Zmienna przechowuj�ca wynik interpolacji.
	result = (f2 + (f3 - f1) * dx + (f1 - 2 * f2 + f3) * dx * dx);	// Obliczanie warto�ci.
	return result;
}

__declspec(dllexport) long long _stdcall InterpolacjaDwukwadratowaC(long long * table, float x, float y, int sourceWidth, int sourceHeight)
// Funkcja wyznaczaj�ca warto�� piksela nowotworzonej bitmapy, wykorzystuj�c interpolacj� dwukwadratow� 
// (podw�jnie przeprowadzan� interpolacj� kwadratow� - w pionie i w poziomie).
{
	long result = 0;												// Zmienna przechowuj�ca warto�� zwracanego piksela.
	int x0 = 0, y0 = 0, x1 = 0, y1 = 0, x2 = 0, y2 = 0;				// Zmienne wykorzystywane do okre�lenia po�o�enia pikseli w bitmapie (wsp�rz�dne).
	float dx, dy;													// Wsp�czynniki interpolacji.

	//Wyznaczanie wsp�rz�dnych punkt�w s�siaduj�cych z punktem odniesienia w bitmapie �r�d�owej.
	x1 = (int) x;  
	y1 = (int) y; 
	dx = (float)((x - x1));											// Obliczanie wsp�czynnik�w.
	dy = (float)((y - y1));

	if (x1 - 1 >= 0)
		x0 = x1 - 1;
	else
		x0 = x1;
	if (y1 - 1 >= 0)
		y0 = y1 - 1;
	else
		y0 = y1;
	if (x1 + 1 >= sourceWidth)
		x2 = x1;
	else
		x2 = x1 + 1;
	if (y1 + 1 >= sourceHeight)
		y2 = y1;
	else
		y2 = y1 + 1;

	unsigned char resultA, resultR, resultG, resultB;				// Zmienne przechowuj�ce sk�adowe pikela.

	//Obliczanie poszczeg�lnych warto�ci sk�adowych piksela nowotworzonej bitmapy.
	resultA = (unsigned char)(InterpolacjaNorm(Interpolacja((unsigned char)(table[x0 + y0 * sourceWidth] >> 24), (unsigned char)(table[x1 + y0 * sourceWidth] >> 24), (unsigned char)(table[x2 + y0 * sourceWidth] >> 24), dx),
											   Interpolacja((unsigned char)(table[x0 + y1 * sourceWidth] >> 24), (unsigned char)(table[x1 + y1 * sourceWidth] >> 24), (unsigned char)(table[x2 + y1 * sourceWidth] >> 24), dx),
											   Interpolacja((unsigned char)(table[x0 + y2 * sourceWidth] >> 24), (unsigned char)(table[x1 + y2 * sourceWidth] >> 24), (unsigned char)(table[x2 + y2 * sourceWidth] >> 24), dx), dy));
	
	resultR = (unsigned char)(InterpolacjaNorm(Interpolacja((unsigned char)(table[x0 + y0 * sourceWidth] >> 16), (unsigned char)(table[x1 + y0 * sourceWidth] >> 16), (unsigned char)(table[x2 + y0 * sourceWidth] >> 16), dx),
											   Interpolacja((unsigned char)(table[x0 + y1 * sourceWidth] >> 16), (unsigned char)(table[x1 + y1 * sourceWidth] >> 16), (unsigned char)(table[x2 + y1 * sourceWidth] >> 16), dx),
											   Interpolacja((unsigned char)(table[x0 + y2 * sourceWidth] >> 16), (unsigned char)(table[x1 + y2 * sourceWidth] >> 16), (unsigned char)(table[x2 + y2 * sourceWidth] >> 16), dx), dy));

	resultG = (unsigned char)(InterpolacjaNorm(Interpolacja((unsigned char)(table[x0 + y0 * sourceWidth] >> 8), (unsigned char)(table[x1 + y0 * sourceWidth] >> 8),   (unsigned char)(table[x2 + y0 * sourceWidth] >> 8),  dx),
											   Interpolacja((unsigned char)(table[x0 + y1 * sourceWidth] >> 8), (unsigned char)(table[x1 + y1 * sourceWidth] >> 8),   (unsigned char)(table[x2 + y1 * sourceWidth] >> 8),  dx),
											   Interpolacja((unsigned char)(table[x0 + y2 * sourceWidth] >> 8), (unsigned char)(table[x1 + y2 * sourceWidth] >> 8),   (unsigned char)(table[x2 + y2 * sourceWidth] >> 8),  dx), dy));

	resultB = (unsigned char)(InterpolacjaNorm(Interpolacja((unsigned char)(table[x0 + y0 * sourceWidth]),		(unsigned char)(table[x1 + y0 * sourceWidth]),		  (unsigned char)(table[x2 + y0 * sourceWidth]),	   dx),
											   Interpolacja((unsigned char)(table[x0 + y1 * sourceWidth]),		(unsigned char)(table[x1 + y1 * sourceWidth]),		  (unsigned char)(table[x2 + y1 * sourceWidth]),	   dx),
											   Interpolacja((unsigned char)(table[x0 + y2 * sourceWidth]),		(unsigned char)(table[x1 + y2 * sourceWidth]),		  (unsigned char)(table[x2 + y2 * sourceWidth]),	   dx), dy));

	result = (long long)(resultB | (resultG << 8) | (resultR << 16) | (resultA << 24));		// Zapisywanie warto�ci piksela, tworzonej ze wszystkich sk�adowych.

	return result;
}







