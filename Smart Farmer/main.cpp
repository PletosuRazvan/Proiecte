#include <iostream>
#include <winbgim.h>
using namespace std;

struct animal
{
    int specie;
    int rand;
    int coloana;
};

struct piesa
{
    int piesa, esteFolosita, pozitie;
};

struct piesaPeTabla
{
    int piesa, pozitiaPeTabla, pozitie;
};

struct gard
{
    int tip;
    int lungime;
    int directie;
    int xInceput;
    int yInceput;
    int xSfarsit;
    int ySfarsit;
};

struct apa
{
    int rand;
    int coloana;
};

/*void plaseazaGard(...){
    //desenezi linii
}*/

struct nivel
{
    int dificultate;
};

void desenareApa(int left, int top, int right, int bottom)
{
    setcolor(RED);
    setfillstyle(SOLID_FILL, RED);
    rectangle(left, top, right, bottom);
    floodfill(left+1, top+1, RED);
    setcolor(BLUE);
    setfillstyle(SOLID_FILL, BLUE);
    rectangle(left+10, top+10, right-10, bottom-10);
    floodfill(left+11, top+11, BLUE);
}

void startMeniu(bool &start, bool &instructiuni)
{
    if(ismouseclick(WM_LBUTTONDOWN))
    {
        int x = mousex();
        int y = mousey();

        printf("%s %d %d", "The mouse was right clicked at: ", x, y);

        if(x >= 400 && x <= 800)
        {
            if( y >= 400 && y <= 500)
            {
                start = true;
                setfillstyle(SOLID_FILL, BLACK);
                bar(0, 0, 1200, 1000);
            }
            else if (y >= 550 && y <= 650)
            {
                instructiuni = true;

                setfillstyle(SOLID_FILL, BLACK);
                bar(0, 0, 1200, 1000);

                setcolor(WHITE);
                settextstyle(BOLD_FONT, HORIZ_DIR, 5);
                outtextxy(450, 25, "Ajutor");

                settextstyle(SANS_SERIF_FONT, HORIZ_DIR, 2);
                outtextxy(75, 100, "Animalele de la ferma fac mizerie si fermierul trebuie sa le separe, insa acesta are la dispozitie doar trei garduri simple");
                outtextxy(50, 125, "pentru a imparti campul in pajisti separate. Poti sa il ajuti sa aseze inteligent gardurile, astfel incat vacile, caii, oile si porcii");
                outtextxy(50, 150, "sa aiba propriile spatii? Asigura-te insa ca toti au apa de baut!");
                outtextxy(75, 175, "Jocul contine: 1 tabla de joc cu 4 garduri fixe, 2 cai, 2 vaci, 2 oi, 2 porci, 3 jgheaburi de apa, 3 garduri.");

                settextstyle(BOLD_FONT, HORIZ_DIR, 3);
                outtextxy(75, 225, "REGULI:");

                settextstyle(SANS_SERIF_FONT, HORIZ_DIR, 2);
                outtextxy(75, 250, "1. Rotirea piesei se realizeaza prin click dreapta.");
                outtextxy(75, 275, "2. Selectia piesei se realizeaza prin dublu click stanga.");
                outtextxy(75, 300, "3. Asezarea piesei pe tabla se realizeaza prin click stanga pe pozitia de pe tabla, dupa ce piesa a fost selectata.");
                outtextxy(75, 325, "4. In caz de neatentie, la pozitionarea unei piese in mod gresit, puteti face reset la joc printr-un simplu click pe butonul de reset.");

                settextstyle(BOLD_FONT, HORIZ_DIR, 3);
                rectangle (50, 25, 150, 60);
                outtextxy(60, 30, "Inapoi");
            }

        }
        clearmouseclick(WM_LBUTTONDOWN);
    }
}

void inapoiDinInstructiuni(bool& instructiuni)
{
    if(ismouseclick(WM_LBUTTONDOWN))
    {
        int x = mousex();
        int y = mousey();

        printf("%s %d %d", "The mouse was left clicked at: ", x, y);

        if (instructiuni && x >= 30 && x <= 170 && y >= 10 && y <= 75)
        {
            setfillstyle(SOLID_FILL, BLACK);
            bar(0, 0, 1200, 1000);
            instructiuni = false;

            settextstyle(BOLD_FONT, HORIZ_DIR, 5);
            outtextxy(450, 25, "Smart Farmer");

            rectangle (400, 400, 800, 500);
            outtextxy(480, 425, "Start joc!");

            rectangle (400, 550, 800, 650);
            outtextxy(525, 575, "Ajutor");
        }

        clearmouseclick(WM_LBUTTONDOWN);
    }
}

void initJoc()
{
    settextstyle(BOLD_FONT, HORIZ_DIR, 5);
    outtextxy(450, 25, "Smart Farmer");

    rectangle (400, 400, 800, 500);
    outtextxy(480, 425, "Start joc!");

    rectangle (400, 550, 800, 650);
    outtextxy(525, 575, "Ajutor");
}

void cronometru(int &minute, int &secunde)
{
    settextstyle(BOLD_FONT, HORIZ_DIR,3);
    char minuteSiSecunde[40];
    sprintf(minuteSiSecunde, "Minute %d Secunde %d", minute, secunde);

    setlinestyle (SOLID_LINE, 0, 1);
    outtextxy(920, 25, minuteSiSecunde);

    Sleep(1000);

    secunde++;

    if (secunde==60)
    {
        minute++;
        secunde=0;
    }

    setfillstyle(SOLID_FILL, LIGHTGREEN);
    bar(900,10,1200,50);

}

void initBoard()
{
    setcolor(WHITE);
    rectangle(1,599,1,899);
    setfillstyle(SOLID_FILL, LIGHTGREEN);
    floodfill(200,200,LIGHTGREEN);
    setlinestyle(0,0xFFFF,10);
    rectangle(5,5,895,595);
    setcolor(GREEN);
    for(int i=201; i<400; i=i+196)
        line(15,i,885,i);
    for(int i=227; i<673; i=i+222)
        line(i,15,i,585);
    readimagefile("reset2.jpg",1100,900,1200,1000);
}


int main()
{
    int minute=0, secunde=0;
    bool start=false, instructiuni=false;
    initwindow(1200,1000);
    initJoc();
    setcolor(BLACK);
    bool gata=false;
    do
    {
        startMeniu(start, instructiuni);
        inapoiDinInstructiuni(instructiuni);
        if(start)
        {
            FILE* joc;
            int n=3;
            int m=4;
            int i = 1;
            int numarScenarii = 10;
            char a[n][m];
            while(i <= numarScenarii)
            {

                char scenariu[14];
                sprintf(scenariu, "scenariu%d.txt", i);

                if ((joc = fopen (scenariu, "r")) == NULL)
                {
                    printf("Error! opening file");
                    exit(1);
                }
                for (int i=0; i<n; i++)
                {
                    for (int j=0; j<m; )
                    {
                        char ch = fgetc(joc);
                        if (!(ch == ' ' || ch == '\n'))
                        {
                            a[i][j] = ch;
                            j++;
                        }
                    }
                }
            piesa piesa1, piesa2, piesa3;

                fscanf(joc, "%d", &piesa1.piesa);
                fscanf(joc, "%d", &piesa1.esteFolosita);
                fscanf(joc, "%d", &piesa1.pozitie);

//    printf("%d %d %d\n", piesa1.piesa, piesa1.esteFolosita, piesa1.pozitie);

                fscanf(joc, "%d", &piesa2.piesa);
                fscanf(joc, "%d", &piesa2.esteFolosita);
                fscanf(joc, "%d", &piesa2.pozitie);

//    printf("%d %d %d\n", piesa2.piesa, piesa2.esteFolosita, piesa2.pozitie);

                fscanf(joc, "%d", &piesa3.piesa);
                fscanf(joc, "%d", &piesa3.esteFolosita);
                fscanf(joc, "%d", &piesa3.pozitie);

//    printf("%d %d %d\n", piesa3.piesa, piesa3.esteFolosita, piesa3.pozitie);

                fclose(joc);

            initBoard();
            setcolor(WHITE);
            int minute = 0;
            int secunde = 0;
            cronometru(minute, secunde);
            //piesa 1
            setlinestyle (SOLID_LINE, 0, 10);
            line (950, 120, 950, 630);

            // piesa2
            setlinestyle (SOLID_LINE, 0, 10);
            line (1000, 245, 1000, 580); //4

            // piesa 3
            line (1100, 245, 1100, 588); //5
            setlinestyle (SOLID_LINE, 0, 10);
            line (1100, 244, 1160, 244);
            setlinestyle (SOLID_LINE, 0, 10);
                for (i=0; i<n; i++)
                    for (int j=0; j<m;)
                    {
                        if (a[i][j]=='p') readimagefile("porc.jpg",60+j*222,50+i*196,165+j*222,150+i*196);
                        if (a[i][j]=='v') readimagefile("vaca.jpg",60+j*222,50+i*196,165+j*222,150+i*196);
                        if (a[i][j]=='o') readimagefile("oaie.jpg",60+j*222,50+i*196,165+j*222,150+i*196);
                        if (a[i][j]=='c') readimagefile("cal.jpg",60+j*222,50+i*196,165+j*222,150+i*196);
                        if (a[i][j]=='a') desenareApa(60+j*222,75+i*196,165+j*222,125+i*196);
                        if (a[i][j]=='0')
                        {
                            setcolor(WHITE);
                            circle(117+j*222,103+i*196,50);
                        }
                        j++;
                    }
            if(ismouseclick(WM_LBUTTONDOWN)){
                int x=mousex();
                int y=mousey();
                printf("%s %d %d", "The mouse was left clicked at: ", x, y);
                if((x>=282 && x<=387) && (y>=246 && y<346)){
                    readimagefile("cal.jpg",282, 246, 387, 346);
                }
                clearmouseclick(WM_LBUTTONDOWN);
            }
            int p1=0, p2=0, p3=0;
            int x,y;
            if(ismouseclick(WM_RBUTTONDOWN)){
                    x=mousex();
                    y=mousey();

            //piesa 1
            if((x>=900 && x<=950) && (y>=100 && y<=670) && p1%2==0)
                {
                    p1++;

                    setfillstyle(SOLID_FILL, LIGHTGREEN);
                    bar(900,100,1000,680);

                    setcolor(WHITE);
                    setlinestyle(SOLID_LINE, 0, 10);
                    line(50, 650, 560, 650);
                }
                if((x>=30 && x<600) && (y>=645 && y<690) && p1%2==1){
                    p1++;

                    setfillstyle(SOLID_FILL, BLACK);
                    bar(30, 656, 580, 656);

                    setcolor(WHITE);
                    setlinestyle(SOLID_LINE, 0, 10);
                    line (570, 120, 570, 630);
                }

                //piesa2
                if((x>=950 && x<1050) && (y>=200 && y<600) && p2%2==0){
                    p2++;
                    setfillstyle(SOLID_FILL, LIGHTGREEN);
                    bar(200, 950, 600, 1050);

                    setlinestyle(SOLID_LINE, 0 ,10);
                    line(50, 750, 385, 750);
                }
                if((x>=10 && x<400) && (y>=700 && y<780) && p2%2==1){
                    p2++;
                    setfillstyle(SOLID_FILL, LIGHTGREEN);
                    bar(20,700, 400, 720);

                    setlinestyle(SOLID_LINE, 0, 10);
                    line (1000, 245, 1000, 580);
                }

                //piesa3
                if((x>=1050  && x<1200) && (y>=200 && y<600)){
                    if(p3%8==0){
                        setfillstyle(SOLID_FILL, LIGHTGREEN);
                        bar(210,1100,250,1180);

                        setlinestyle(SOLID_LINE, 0, 10);
                        line(1040,244,1100,244);
                    }
                    if(p3%8==1){
                        setfillstyle(SOLID_FILL, LIGHTGREEN);
                        bar(1010,210,1100,250);

                        setlinestyle(SOLID_LINE, 0, 10);
                        line(1100, 588, 1160, 588);
                    }

                    if(p3%8==2){
                        setfillstyle(SOLID_FILL, LIGHTGREEN);
                        bar(1100, 560, 1180, 600);

                        setlinestyle(SOLID_LINE, 0, 10);
                        line(1040, 588, 1100, 588);
                    }

                    if(p3%8==3){
                        setfillstyle(SOLID_FILL, LIGHTGREEN);
                        bar(1010, 560, 1100, 600);

                        setlinestyle(SOLID_LINE, 0, 10);
                        line(50, 850, 290, 850);
                        line(290,850,290, 910);
                    }

                    if(p3&8==4){
                        setfillstyle(SOLID_FILL, LIGHTGREEN);
                        bar(270, 850, 300, 930);

                        setlinestyle(SOLID_LINE, 0, 10);
                        line(290, 790, 290, 850);
                    }

                    if(p3%8==5){
                        setfillstyle(SOLID_FILL, LIGHTGREEN);
                        bar(270, 760, 310, 870);

                        setlinestyle(SOLID_LINE, 0, 10);
                        line(50, 850, 50, 910);
                    }

                    if(p3%8==6){
                        setfillstyle(SOLID_FILL, LIGHTGREEN);
                        bar(30, 800, 50, 850);

                        setlinestyle(SOLID_LINE, 0, 10);
                        line(50, 790, 50, 850);
                    }

                    if(p3%8==7){
                        setfillstyle(SOLID_FILL, LIGHTGREEN);
                        bar(30, 750, 50, 800);

                        setlinestyle(SOLID_LINE, 0, 10);
                        line (1100, 245, 1100, 588);
                        line (1100, 244, 1160, 244);
                        p3=-1;
                    }
                    p3++;
                }
                clearmouseclick(WM_RBUTTONDOWN);}
            }

            }
        }while(true);
    return 0;
}
