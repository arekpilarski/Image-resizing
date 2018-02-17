// Imię:     Arkadiusz
// Nazwisko: Pilarski
// Rok akademicki: 2017/2018

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using System.Diagnostics;
using System.Threading;

namespace ImageScaling
{

    public partial class Form1 : Form
    {
        private Bitmap loaded;                      // Tutaj przechowywana będzie załadowana bitmapa.
        private Bitmap generated;                   // Tutaj przechowywana będzie wygenerowana bitmapa.
        Stopwatch clockGenerated, clockLoaded;      // Zmienne wykorzystywane do mierzenia czasu trwania instrukcji.
        bool correctFile = false;                   // Zmienna przechowująca informację czy załadowany został poprawny plik (bitmapa).
        bool imageIsGenerated;

        const string C = @"DLLinC.dll";             // Link do biblioteki C.
        const string Asm = @"DLLinASM.dll";         // Link do biblioteki ASM.

        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            int workerThreads;                      // Zmienna przechowująca liczbę możliwych do utworzenia wątków.
            int portThreads;                        // Port.
            ThreadPool.GetAvailableThreads(out workerThreads, out portThreads);     // Odczytanie liczby dostępnych wątków.
            if (workerThreads > 64)                                                 // Ustawienie maksymalnej liczby wątków.
            {
                threadsSlider.Maximum = 64;                                         // Ustawienie maksimum slidera.
                maxThreadsValue.Text = Convert.ToString(64);                        // Wyświetlenie maksimum w oknie programu.
            }
            else
            {
                threadsSlider.Maximum = workerThreads;                              // Ustawienie maksimum slidera.
                maxThreadsValue.Text = Convert.ToString(workerThreads);             // Wyświetlenie maksimum w programie.
            }
        }

        //----------------------------------------------------------------------------
        // Zaimportowanie funkcji/procedur z bibliotek C i ASM.

        [DllImport(C, CallingConvention = CallingConvention.StdCall)]
        public static extern float InterpolacjaNorm(float f1, float f2, float f3, float d);
        [DllImport(C, CallingConvention = CallingConvention.StdCall)]
        public static extern float Interpolacja(float f1, float f2, float f3, float d);
        [DllImport(C, CallingConvention = CallingConvention.StdCall)]
        public static extern long InterpolacjaDwukwadratowaC(IntPtr table, float x, float y, int sourceWidth, int sourceHeight);
        [DllImport(Asm)]
        unsafe static extern int InterpolacjaDwukwadratowaASM(IntPtr table, float x, float y, int x1, int x2);
        [DllImport(Asm)]
        unsafe static extern int TestProcedure(IntPtr table, int x1, float x2);

        //-----------------------------------------------------------------------------

        private void LoadBitmap_Click(object sender, EventArgs e)       // Funkcja przeprowadzająca proces wybrania i wyświetlenia bitmapy w programie.
        {
            string path = "";                       // Zmienna przechowująca ścieżkę do bitmapy.                       
            int imageWidth;                         // Szerokość bitmapy.
            int imageHeight;                        // Wysokość bitmapy.  

            DialogResult result = OpenFileDIalogBitmap.ShowDialog();    // Eksplorator plików.
            if (result == DialogResult.OK)                              
            {
                correctFile = false;                                    // Plik nie został jeszcze poprawnie wczytany.
                path = OpenFileDIalogBitmap.FileName;                   // Przypisanie ścieżki do wybranego pliku.
                try
                {
                    BmpPath.Text = path;                                // Wyświetlenie wybranej ścieżki w programie.
                    loaded = new Bitmap(path);                          // Załadowanie pliku z podanej ścieżki.
                    LoadedImage.Image = loaded;                         // Wyświetlenie pliku w programie.
                    imageWidth = LoadedImage.Image.Size.Width;          // Wczytanie szerokości bitmapy.
                    imageHeight = LoadedImage.Image.Size.Height;        // Wczytanie wysokości bitmapy.
                    LoadedBoxInfo.Text = ("Height: " + imageHeight);    // Wyświetlenie informacji o wczytanym pliku.
                    LoadedBoxInfo.AppendText(Environment.NewLine);          
                    LoadedBoxInfo.Text += ("Width: " + imageWidth);
                    LoadedImage.SizeMode = PictureBoxSizeMode.Zoom;     // Ustawienie wyświetlanego obrazka w centrum pola.
                    correctFile = true;                                 // Wczytany został prawidłowy plik (obraz).

                }
                catch (Exception ex)
                {
                    MessageBox.Show(ex.Message, "Error");
                }
            }
        }

        // ----------------------------------------------------------------------------

        static long[] LoadBitmapComponents(Bitmap bmp)                  // Funkcja wczytująca bitmapę do pamięci jako tabeli wartości pikseli.
        {
            int size = 0;                                               // Zmienna przechowująca rozmiar tablicy przechowującej wartości pikseli wczytanej bitmapy.
            size = bmp.Width * bmp.Height;                              // Ustawienie rozmiaru tablicy.

            long[] table = new long[size];                              // Alokacja pamięci o ustalonym rozmiarze.
            byte sourceA, sourceR, sourceG, sourceB;                    // Zmienne przechowujące składowe piksela (alfa, red, green, blue).
            int tableIndex = 0;                                         // Indeks tabeli wartości pikseli.                                     
            for (int i = 0; i < bmp.Height; i++)                        // Pętla wczytująca wartości z bitmapy do tabeli.
            {
                for (int j = 0; j < bmp.Width; j++)
                {
                    table[tableIndex] =  (long)bmp.GetPixel(j, i).A << 24;  // Wczytanie składowej A.
                    sourceA = bmp.GetPixel(j, i).A;
                    table[tableIndex] += (long)bmp.GetPixel(j, i).R << 16;  // Wczytanie składowej R.
                    sourceR = bmp.GetPixel(j, i).R;
                    table[tableIndex] += (long)bmp.GetPixel(j, i).G << 8;   // Wczytanie składowej G.
                    sourceG = bmp.GetPixel(j, i).G;
                    table[tableIndex] += (long)bmp.GetPixel(j, i).B;        // Wczytanie składowej B.
                    sourceB = bmp.GetPixel(j, i).B;
                    tableIndex++;
                }
            }
            return table;
        }

        //-----------------------------------------------------------------------------

        static Bitmap SetBitmapComponents(long[] table, int width, int height, System.Drawing.Imaging.PixelFormat format)
        // Funkcja tworząca bitmapę na podstawie tabeli wartości pikseli.
        {
            Bitmap tmp = new Bitmap(width, height, format);         // Tworzenie zmiennej przechowującej bitmapę.

            int index = 0;                                          // Indeks tabeli przechowującej wartości pikseli.
            for (int i = 0; i < height; i++)                        // Pętla tworząca bitmapę.
                for (int j = 0; j < width; j++)
                {
                    //Ustalenie wartości piksela.
                    Color color = Color.FromArgb((byte)(table[index] >> 24), (byte)(table[index] >> 16), (byte)(table[index] >> 8), (byte)(table[index]));
                    index++;

                    // Ustawienie piksela w bitmapie.
                    tmp.SetPixel(j, i, color);
                }
            return tmp;
        }
        
        //-----------------------------------------------------------------------------

        long[] changeBitmap(long[] table, int newWidth, int newHeight)
        // Funkcja przeprowadzająca proces skalowania bitmapy (zmiany wartości pikseli przechowywanych w tabeli).
        {
            double ratioX, ratioY;                                          // Zmienne przechowujące proporcje szerokości i wysokości.
            int sourceHeight = loaded.Size.Height;                          // Wczytanie szerokości załadowanej bitmapy.
            int sourceWidth = loaded.Size.Width;                            // Wczytanie wysokości załadowanej bitmapy.
            int oldSize = sourceHeight * sourceWidth;                       // Rozmiar tablicy przechowującej wartości pikseli załadowanej bitmapy.
            int newSize = newHeight * newWidth;                             // Rozmiar tablicy, która będzie przechowywać wartości pikseli dla nowej bitmapy.
            long[] newTable = new long[newSize];                            // Alokacja pamięci na tabelę przechowującą wartości pikseli nowotworzonej bitmapy.
            ratioX = (double)((sourceWidth * 1.0) / (newWidth * 1.0));      // Obliczenie proporcji szerokości (wczytany obraz / tworzony obraz).
            ratioY = (double)((sourceHeight * 1.0) / (newHeight * 1.0));    // Obliczenie proporcji szerokości (wczytany obraz / tworzony obraz).


            IntPtr tablePtr = Marshal.AllocHGlobal(oldSize * Marshal.SizeOf(typeof(long))); // Tworzenie wskaźnika na tabelę załadowanej bitmapy.
            Marshal.Copy(table, 0, tablePtr, oldSize);                          

            //-------------------------------------------------------------------------------------------------
            List<Thread> threads = new List<Thread>();                      // Lista wątków.

            int threadVal = Convert.ToInt32(numberOfThreads.Text);          // Wczytanie wybranej liczby wątków.
            if (threadVal > 1)                                              
            {
                int intervalValue = newHeight * newWidth / threadVal;       // Zmienna przechowująca liczbę komórek tabeli do przetworzenia przypadającej na jeden wątek.
                int[] valuesToProcess = new int[threadVal];                 // Alokacja pamięci na tablicę przechowującą indeksy tworzące zakres komórek do przetworzenia przez wątek.
                for (int i = 0; i<threadVal; i++)
                {
                    valuesToProcess[i] = intervalValue * i;                 // Ustawianie zakresów.
                }
                valuesToProcess[threadVal - 1] = newHeight * newWidth - 1;  // Ostatni wątek przetwarza wszystkie pozostałe komórki.

                for(int x = 0; x<threadVal - 1; x++)
                {
                    int startIndex, stopIndex;                              // Zmienne przechowujące zakres tablicy do przetworzenia (początkowy i końcowy indeks).
                    startIndex = valuesToProcess[x];                        // Wczytanie początkowego indeksu.
                    stopIndex  = valuesToProcess[x + 1];                    // Wczytanie końcowego indeksu.

                    //-----------------------------------------------------------------
                    // Zmienne wykorzystywane do ustalenia położenia piksela w bitmapie na podstawie indeksu tablicy.
                    // Wartości te służą wyznaczaniu nowych wartości pikseli.
                    int startI, startJ;                                     
                    startI= startIndex / newWidth;                          
                    if (startIndex % newWidth == 0)
                        startJ = 0;
                    else
                        startJ = startIndex - startI * newWidth;

                    int stopI, stopJ;
                    stopI = stopIndex / newWidth;
                    if (stopIndex % newWidth == 0)
                        stopJ = 0;
                    else
                        stopJ = stopIndex - stopI * newWidth;
                    //-----------------------------------------------------------------

                    if (ASMoption.Checked)                                      // Jeśli wybrano bibliotekę ASM.
                    {
                        threads.Add(new Thread(() =>                            // Tworzenie i dodanie nowego wątku do listy.
                        {
                            for (int i = startI; i < stopI + 1; i++)            // Pętla, w której wyznaczane są nowe wartości pikseli na podstawie współrzędnych pikseli starej bitmapy.
                                if (startI == i)                                // Jeśli przetwarzany jest pierwszy rząd wartości pikseli bitmapy.
                                {
                                    for (int j = startJ; j < newWidth; j++)
                                        if (i == stopI && j == stopJ)           // Jeśli zostanie osiągnięty indeks końca zakresu, wątek kończy działanie.
                                            break;
                                        else
                                            // Wyznaczenie nowej wartości piksela.
                                            newTable[i * newWidth + j] = InterpolacjaDwukwadratowaASM(tablePtr, (float)(j * ratioX), (float)(i * ratioY), sourceWidth, sourceHeight);
                                }
                                else                                            // Jeśli przetwarzane są kolejne rzędy wartości pikseli bitmapy.                     
                                {
                                    for (int j = 0; j < newWidth; j++)
                                        if (i == stopI && j == stopJ)
                                            break;                               // Jeśli zostanie osiągnięty indeks końca zakresu, wątek kończy działanie.
                                        else
                                            // Wyznaczenie nowej wartości piksela.
                                            newTable[i * newWidth + j] = InterpolacjaDwukwadratowaASM(tablePtr, (float)(j * ratioX), (float)(i * ratioY), sourceWidth, sourceHeight);
                                }

                        }));
                    }
                    else                                                        // Jeśli wybrano bibliotekę C.
                    {
                        threads.Add(new Thread(() =>                            // Tworzenie i dodanie nowego wątku do listy.
                        {
                           for (int i = startI; i < stopI + 1; i++)             // Pętla, w której wyznaczane są nowe wartości pikseli na podstawie współrzędnych pikseli starej bitmapy.
                                if (startI == i)                                // Jeśli przetwarzany jest pierwszy rząd wartości pikseli bitmapy.
                                {
                                   for (int j = startJ; j < newWidth; j++)
                                       if (i == stopI && j == stopJ)            // Jeśli zostanie osiągnięty indeks końca zakresu, wątek kończy działanie.
                                            break;
                                       else
                                            // Wyznaczenie nowej wartości piksela.
                                            newTable[i * newWidth + j] = InterpolacjaDwukwadratowaC(tablePtr, (float)(j * ratioX), (float)(i * ratioY), sourceWidth, sourceHeight);
                               }
                                else                                            // Jeśli przetwarzane są kolejne rzędy wartości pikseli bitmapy.
                                {
                                   for (int j = 0; j < newWidth; j++)
                                       if (i == stopI && j == stopJ)            // Jeśli zostanie osiągnięty indeks końca zakresu, wątek kończy działanie.
                                            break;
                                       else
                                            // Wyznaczenie nowej wartości piksela.
                                            newTable[i * newWidth + j] = InterpolacjaDwukwadratowaC(tablePtr, (float)(j * ratioX), (float)(i * ratioY), sourceWidth, sourceHeight);
                               }
                       }));
                   }
                }

                clockGenerated = Stopwatch.StartNew();                          // Rozpoczęcie zliczania taktów procesora.
                for(int i = 0; i<threadVal-1; i++)
                    threads[i].Start();                                         // Wystartowanie wszystkich utworzonych wątków w liście wątków.
                
                for (int i = 0; i < threadVal - 1; i++)
                    threads[i].Join();                                          // Oczekiwanie na ukończenie pracy wszystkich wątków.

            } 
            else                                                                // Jeśli wybrana liczba wątków jest większa od 1.
            {
                clockGenerated = Stopwatch.StartNew();                          // Rozpoczęcie zliczania taktów procesora.
                if (ASMoption.Checked)                                          // Jeśli wybrano bibliotekę ASM.
                {
                    for (int i = 0; i < newHeight; i++)                         // Pętla obliczająca wartości pikseli nowotworzonej bitmapy.
                        for (int j = 0; j < newWidth; j++)
                            newTable[i * newWidth + j] = InterpolacjaDwukwadratowaASM(tablePtr, (float)(j * ratioX), (float)(i * ratioY), sourceWidth, sourceHeight);
                }
                else                                                            // Jeśli wybrano bibliotekę C.
                {
                    for (int i = 0; i < newHeight; i++)                         // Pętla obliczająca wartości pikseli nowotworzonej bitmapy.
                        for (int j = 0; j < newWidth; j++)
                            newTable[i * newWidth + j] = InterpolacjaDwukwadratowaC(tablePtr, (float)(j * ratioX), (float)(i * ratioY), sourceWidth, sourceHeight);
                }
            }

            //-------------------------------------------------------------------------------------------------

            
            clockGenerated.Stop();                                              // Zakończenie zliczania taktów procesora.
            return newTable;                                                    // Funkcja zwraca tabelę z wartościami pikseli nowej bitmapy.
        }
        //---------------------------------------------------------------------------------------------

        private void trackBar1_Scroll(object sender, EventArgs e)
        {
            numberOfThreads.Text = threadsSlider.Value.ToString();                  // Ustawienie liczby wątków.
        }

        private void GenerateButton_Click(object sender, EventArgs e)
        // Funkcja koordynująca proces wczytywania bitmapy do pamięci (w postaci tabeli wartości pikseli) oraz generowania
        // nowych wartości.
        {
            try
            {
                if (!correctFile)                                           // Jeśli nie został wczytany poprawny plik.
                {
                    MessageBox.Show("Load image first!", "Error");
                    return;
                }
                int newWidth = Convert.ToInt32(NewWidthBox.Text);           // Wczytanie szerokości nowej bitmapy.
                int newHeight = Convert.ToInt32(NewHeightBox.Text);         // Wczytanie wysokości nowej bitmapy.
                clockLoaded = Stopwatch.StartNew();                         // Rozpoczęcie zliczania taktów procesora.
                long[] table = LoadBitmapComponents(loaded);                // Wczytanie do tabeli wartości pikseli załadowanej bitmapy.
                clockLoaded.Stop();                                         // Zakończenie zliczania taktów procesora - czas wczytywania bitmapy (wartości pikseli) do tabeli.
                long[] table2 = changeBitmap(table, newWidth, newHeight);   // Wyznaczenie wartości pikseli nowotworzonej bitmapy i wczytanie ich do tabeli.
                generated = SetBitmapComponents(table2, newWidth, newHeight, loaded.PixelFormat);   // Tworzenie nowej bitmapy na podstawie wartości pikseli w tabeli.
                LoadedBoxInfo.Text = ("Height: " + LoadedImage.Image.Size.Height);                  // Wypisanie wysokości załadowanego obrazu do programu.
                LoadedBoxInfo.AppendText(Environment.NewLine);
                LoadedBoxInfo.Text += ("Width: " + LoadedImage.Image.Size.Width);                   // Wypisanie szerokości załadowanego obrazu do programu.
                GeneratedImage.Image = generated;                                                   // Wyświetlenie utworzonej bitmapy.
                LoadedBoxInfo.AppendText(Environment.NewLine);
                // Wypisanie informacji o czasie wczytywania bitmapy do tabeli.
                LoadedBoxInfo.Text += ("Loading bitmap to memory time: " + clockLoaded.Elapsed.TotalMilliseconds.ToString() + " ms " + clockLoaded.ElapsedTicks.ToString() + " ticks");
                GeneratedBoxInfo.Text = ("Height: " + GeneratedImage.Image.Size.Height);            // Wypisanie wysokości utworzonego obrazu w programie.
                GeneratedBoxInfo.AppendText(Environment.NewLine);
                GeneratedBoxInfo.Text += ("Width: " + GeneratedImage.Image.Size.Width);             // Wypisanie szerokości utworzonego obrazu w programie.
                GeneratedBoxInfo.AppendText(Environment.NewLine);
                // Wypisanie informacji o czasie generowania nowej bitmapy.
                GeneratedBoxInfo.Text += ("Generation time: " + clockGenerated.Elapsed.TotalMilliseconds.ToString() + " ms " + clockGenerated.ElapsedTicks.ToString() + " ticks");
                GeneratedImage.SizeMode = PictureBoxSizeMode.Zoom;
                imageIsGenerated = true;
            }
            catch (FormatException)
            {
                MessageBox.Show("Wrong height or width parameter entered!", "Error");               // Informacja o błędzie.
            }
            catch (Exception)
            {
                MessageBox.Show("Wrong bitmap type entered.", "Error");                                  // Informacja o błędzie.
            }
        }

        private void button1_Click(object sender, EventArgs e)               // Funkcja realizująca zapis pliku na dysku.
        {
            if (!imageIsGenerated)                                           // Jeśli nie wygenerowano obrazu.
            {
                MessageBox.Show("Generate image first!", "Error");           // Informacja o błędzie.
                return;
            }
            if (SavePath.Text.Equals(""))                                    // Jeśli nie podano nazwy pliku.
            {
                MessageBox.Show("Enter file name.", "Error");               // Informacja o błędzie.
                return;
            }

            string path = "";                                               // Zmiena przechowująca ścieżkę do zapisu.
            if (folderBrowserDialog1.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                path += folderBrowserDialog1.SelectedPath + "\\" + SavePath.Text;   // Pobranie wybranej lokalizacji.
                try
                {
                    generated.Save(path + ".bmp");                          // Zapis pliku w podanej lokalizacji.
                }
                catch (Exception ex)
                {
                    MessageBox.Show(ex.Message, "Error");                   // Informacja o błędzie.
                }
            }
        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }

        private void OpenFileDIalogBitmap_FileOk(object sender, CancelEventArgs e)
        {

        }

        private void pictureBox1_Click(object sender, EventArgs e)
        {

        }

        private void LoadedImageBox_Enter(object sender, EventArgs e)
        {

        }

        private void radioButton3_CheckedChanged(object sender, EventArgs e)
        {

        }

        private void textBox1_TextChanged_1(object sender, EventArgs e)
        {

        }

        private void label5_Click(object sender, EventArgs e)
        {

        }
        
        private void pictureBox1_Click_1(object sender, EventArgs e)
        {

        }

        private void NewHeightBox_TextChanged(object sender, EventArgs e)
        {

        }
        
        private void groupBox1_Enter(object sender, EventArgs e)
        {

        }

        private void radioButton1_CheckedChanged(object sender, EventArgs e)
        {

        }

        private void radioButton2_CheckedChanged(object sender, EventArgs e)
        {

        }

        private void label7_Click(object sender, EventArgs e)
        {

        }

        private void SavePath_TextChanged(object sender, EventArgs e)
        {

        }

        private void GeneratedBoxInfo_TextChanged(object sender, EventArgs e)
        {

        }

        private void label8_Click(object sender, EventArgs e)
        {

        }

        private void label4_Click(object sender, EventArgs e)
        {

        }

        private void label10_Click(object sender, EventArgs e)
        {

        }

        private void label12_Click(object sender, EventArgs e)
        {

        }
        
        private void label9_Click(object sender, EventArgs e)
        {

        }
    }
}
