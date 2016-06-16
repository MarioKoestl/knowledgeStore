import random


def linie(M,x,y,anz):
    #Waehle zufaelliges Zeichen
    zz = random.randint(0,1)
    if zz == 0:
        zeichen = '^'
    else:
        zeichen = '~'
    #Abbruch, wenn ich einem anderen zu nahe komme
    M[x][y] = zeichen
    for i in range(anz):
        if y+anz+1 > n:
            exit
        if y+2 < n-2:
            if M[x][y+2] != ' ':
                exit
        if y < n-2:
            M[x][y+i] = zeichen
    return M


def cluster (M,x,y,anz1):
    for i in range (anz1):
        anz = random.randint(1,4)
        if x+i < k-1:
            if y + anz + 1 < n:
                linie(M,x+i,y,anz)
    return M
        
   

def passt(M,x,y,n,k):	
    ergebnis = 0
    if x > k-1 or y > n-1:
        return ergebnis
    if x < k-1:
        if M[x+1][y] != ' ':
            return ergebnis    
    for i in range(x-1,x+3):
        for j in range (y-1,y+6):
            if i>k-1 or j>n-1:
                break
            if i<1 or k<1:
                break
            if M[i][j] == ' ':
                ergebnis = 1
    return ergebnis



#def Zufallskarte
def zufallskarte(Zeilen, Spalten, Rand, Grad):
    #Spalten Parameteruebergabe
    n = Spalten
    #Zeilen
    k = Zeilen
    g = Grad
    if g == 1:
        anz_ab = n*k/80
    if g == 2:
        anz_ab = n*k/60
    if g == 3:
        anz_ab = n*k/40        
    M = [[' ' for i in range(n)] for j in range(k)]

    for i in range(anz_ab):
        x = random.randint(0,k-1)
        y = random.randint(0,n-1)
        if passt(M,x,y,n,k) == 1:
            anz = random.randint(1,4)
            cluster(M,x,y,anz)        



    #Gebe Rand rundherum:

    N = [['~' for i in range(n+2)] for j in range(k+2)]
    for i in range(1,k):
        for j in range(1,n):
            N[i][j]=M[i][j]



    #Datei testfeld schreiben
    if Rand == 0:
        #print 'ohne Rand'
        f = open("karte.txt","w")
        for i in range(k):
            for j in range(n):
                f.writelines([M[i][j]])
            f.writelines("\n")
    else:    
        f = open("karte.txt","w")
        for i in range(k+1):
            for j in range(n+1):
                f.writelines([N[i][j]])
            f.writelines("\n")



#Aufruf im Hauptprogramm
#Zeilen k (Anzahl), Spalten n (Anzahl) und Rand(0 oder 1) eingeben
#Schwierigkeitsgrad (1,2 oder 3)
k = 21
n = 57
r = 1
g = 3


zufallskarte(k,n,r,g)


