import random
import sys 
import getopt 

def usage():
    usage = "Usage: "+sys.argv[0]+ """
    -h --help      Prints this
    
    Bitte 5 Parameter eingeben:
    
    Zeilenanzahl (integer): mindestens 10
    Spaltenanzahl (integer): mindestens 20
    Rand (0 = kein Rand, 1 = Wasser, 2 = Berg)
    Schwierigkeitsgrad (1 = leicht, 2 = mittel, 3 = schwer)
    Dateiname zum Abspeichern der Karte (e.g.: testfeld.txt)

    Beispiel:
    python zufallskarte.py 21 57 0 1 testfeld.txt

    Ohne Eingabe bzw. bei fehlerhafter Eingabe
    werden die obigen Beispielparameter verwendet!
    """
    print usage
    
def linie(M,x,y,anz):
    #Waehle zufaelliges Zeichen; anz = anzahl der Zeichen in der Linie
    zz = random.randint(0,1)
    if zz == 0:
        zeichen = '^'
    else:
        zeichen = '~'
    #Abbruch, wenn ich einem anderen zu nahe komme
    M[x][y] = zeichen
    for i in range(anz):
        #Breche ab, wenn ich dem Rand zu nahe komme
        if y+i > n-1:
            exit
        #Breche ab, wenn zwei Zeichen danach kein Leerzeichen ist
        if y+2 < n-2:            
            if M[x][y+2] != ' ':
                exit
        #if y < n-2:
        M[x][y+i] = zeichen
    #noch 2 Leerzeichen vorher und nachher
    if y - 2 > 1:
        M[x][y-1] = ' '
        M[x][y-2] = ' '         
    if y + i + 2 < n:
        M[x][y+i+1] = ' '
        M[x][y+i+2] = ' '        
    return M


def cluster (M,x,y,anz1):
    #anz1 = Anzahl der Zeilen pro Cluster
    #print x,y,anz1, 'x,y,anz1 beginn cluster'
    for i in range (anz1):
        anz = random.randint(1,4)
        if x+i < k-1:
            #if y + anz + 1 < n:
            linie(M,x+i,y,anz)

    #print x,y,anz1, 'x,y,anz1 vor Leerzeile cluster'                
    #Leerzeichen unter dem Cluster
    for j in range(4):
        if x+i > k-1 or y+j > n-1:
            break
        M[x+i][y+j] =' '
    return M
        
   

def passt(M,x,y,n,k):	
    ergebnis = 0
    #print x,y,n,k, 'vorher'
    #if x > k-1 or y > n-1:
        #return ergebnis
    #if x < k-1:
        #if M[x+1][y] != ' ':
            #return ergebnis 
    #print 'x, y: ', x,y     
    for i in range(x-1,x+4):
        for j in range (y-1,y+6):
            if x-1 < 1 or x+4 > k-1 or y-1 < 1 or y+6 > n-1 :
                break
            if M[i][j] == ' ':
                #print 'i,j: ',i,j, M[i][j]
                ergebnis = 1
    #print x,y,n,k, 'nachher'
    return ergebnis



#def Zufallskarte
def zufallskarte(Zeilen, Spalten, Rand, Grad):
    #Spalten Parameteruebergabe
    n = Spalten
    #Zeilen
    k = Zeilen
    g = Grad
    if g == 1:
        anz_ab = n*k/60
    if g == 2:
        anz_ab = n*k/40
    if g == 3:
        anz_ab = n*k/20        
    # Leerzeichen = Landmasse
    #^ = Berg
    #~ = Wasser
    M = [[' ' for i in range(n)] for j in range(k)]
    #print printMatrix(M)

    for i in range(anz_ab):
        #print i
        endlos = 1
        while endlos == 1:
            x = random.randint(0,k-3)
            y = random.randint(0,n-6)
            #print 'x,y ',x,y
            if passt(M,x,y,n,k) == 1:
                endlos = 0
        anz = random.randint(1,5)
        #if anz + x  > k:
        #    anz = 1
        #print x,y,anz,'vor cluster'
        cluster(M,x,y,anz)
        
    #Einser- oder Zweierinsel eleminieren
    for i in range(1,k-1):
        for j in range (1,n-2):
            if M[i][j] == ' ':
                if M[i][j-1] != ' ' and M[i-1][j] != ' ' and M[i+1][j] != ' ':
                    if M[i][j+1]!= ' ':
                        M[i][j] = '^'
                    if M[i][j+1] == ' ':
                        if M[i][j+2] != ' ' and M[i-1][j+1] != ' ' and M[i+1][j+1] != ' ':
                            M[i][j] = '^'
                            M[i][j+1] = '^'
            if M[i][j] == ' ' and M[i][j+1] == ' ' and M[i+1][j] == ' ' and M[i+1][j+1] == ' ':
                if M[i][j-1] != ' ' and M[i-1][j] != ' ' and M[i-1][j+1] != ' ' and M[i+1][j] != ' ' and M[i+1][j+1] != ' ' and M[i][j+2] != ' ' :                   
                    M[i][j] = '^'
                    M[i][j+1] = '^'
                    M[i+1][j] == '^'
                    M[i+1][j+1] == '^'
                    
            


    #Oder: Gebe Rand rundherum:

    N = [['~' for i in range(n+2)] for j in range(k+2)]
    for i in range(1,k):
        for j in range(1,n):
            N[i][j]=M[i][j]
    O = [['^' for i in range(n+2)] for j in range(k+2)]
    for i in range(1,k):
        for j in range(1,n):
            O[i][j]=M[i][j]
            

    #Datei testfeld schreiben
    if Rand == 0:
        #print 'ohne Rand'
        f = open(filename,"w")
        for i in range(k):
            for j in range(n):
                f.writelines([M[i][j]])
            f.writelines("\n")
    if Rand == 1:   
        f = open(filename,"w")
        for i in range(k+1):
            for j in range(n+1):
                f.writelines([N[i][j]])
            f.writelines("\n")

    if Rand == 2:   
        f = open(filename,"w")
        for i in range(k+1):
            for j in range(n+1):
                f.writelines([O[i][j]])
            f.writelines("\n")

#Kommandozeilenparameter auswerten
try:
    opts,args=getopt.getopt (sys.argv[1:],"h",["help"])
except getopt.GetoptError:
    usage()
    sys.exit()
for opt, arg in opts:
    if opt in ("-h","--help"):
        usage()
        sys.exit()


#Uebernahme der Parameter
#Zeilen k (Anzahl), Spalten n (Anzahl) und Rand(0, 1 oder 2) eingeben
#Schwierigkeitsgrad (1,2 oder 3)

try:
    k = int(sys.argv[1])
    if k < 10:
        k = 21
    n = int(sys.argv[2])
    if n < 20:
        n = 57
    r = int(sys.argv[3])
    if r < 0 or r > 2 :
        r = 0
    g = int(sys.argv[4])
    if g < 1 or g > 4:
        g = 1   
    filename = sys.argv[5]    
except:
    k = 21
    n = 57
    r = 0
    g = 3
    filename = "testfeld.txt"
    

print k,n,r,g,filename
#Aufruf des Programms
zufallskarte(k,n,r,g)



