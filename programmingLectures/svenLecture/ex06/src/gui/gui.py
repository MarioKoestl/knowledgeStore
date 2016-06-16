from Tkinter import *
from PIL import Image, ImageTk
import ttk
from thread import start_new_thread
from threading import Thread
import time

import sys
sys.path.insert(0,'..') # import filereader from parent directory
import FileReader
import os

class ResizingCanvas(Canvas):
    """
    A canvas that computes not the control size, but the image size.
    Foreground and background images should have the same size.
    """
    ImageBackground=None
    PhotoImageBackground=None
    
    ImageForeground=None
    PhotoImageForeground=None
    
    Foreground=None
    def __init__(self,parent,**kwargs):
        Canvas.__init__(self,parent,**kwargs)
        #print self.winfo_reqwidth(),self.winfo_reqheight()
        self.bind("<Configure>", self.on_resize)
        self.width=None
        self.height=None

    def on_resize(self,event):
        self.width = event.width
        self.height = event.height
        #self.config(width=self.width, height=self.height)
        self.drawImage()
            
    def drawImage(self):
        if(self.ImageBackground):
            im = self.ImageBackground.resize((self.width, self.height), Image.ANTIALIAS)
            self.PhotoImageBackground = ImageTk.PhotoImage(im)
            self.delete("all")
            self.create_image(0,0,anchor=NW,image=self.PhotoImageBackground)
            
        if(self.ImageForeground):
            im = self.ImageForeground.resize((self.width, self.height), Image.ANTIALIAS)
            self.PhotoImageForeground = ImageTk.PhotoImage(im)
            self.Foreground = self.create_image(0,0,anchor=NW,image=self.PhotoImageForeground)
            
    def deleteForeground(self):
        self.ImageForeground = None
        self.delete(self.Foreground)
        
    def changeForeground(self,image):
        i = self.ImageForeground = image
        if(self.width):
            self.drawImage()
        self.itemconfig(i,fill="red")
        
    def changeBackground(self,image):
        self.ImageBackground = image
        if(self.width):
            self.drawImage()

      
class GUI(Thread):
    """
    Draws a checker board, and controls.
    The images for the board have to be in the same folder.
    """
    def __init__(self,onGridInitialized=None):
        """
        @param onGridInitialized - callback function
        """
        Thread.__init__(self)
        self.MainWindow = None
        self.WaterImage = None
        self.FloorImage = None
        self.WallImage = None
        self.CoinImage = None
        self.PlayerImage = None
        #cells that are generated with drawMap()
        self.GridCells = None
        #map as it was read from the input file
        self.Map = None
        #map indices to playerImages that are shown in the cells
        self.MapPlayerImages = {}
        #legend show the player's avatar and coins
        self.FrameLegend = None
        #player's coin labels for update function
        self.CoinLabels = {}
        #displays the remaining coins for the game
        self.LabelCoinsRemaining = None
        self.onGridInitialized=onGridInitialized
        self.loadImages()
        
    def run(self):
        self.startGUI()
        os._exit(0) # close the main thread if the ui is closed
            
    def startGUI(self):    
        self.MainWindow = Tk()
        self.MainWindow.protocol("WM_DELETE_WINDOW", self.on_closing)
        self.GridCells = self.drawMap(self.MainWindow)
        if self.onGridInitialized:
            self.onGridInitialized()
        
        self.MainWindow.mainloop()

    def loadMap(self,fileName):
        self.Map = FileReader.readMap(fileName)
            
            
    def drawMap(self,parentControl):
        """
        @return the grid of canvases
        """
        if not self.Map:
            print "Error: no map"
            return
        
        rows=len(self.Map)
        columns=len(self.Map[0])
        
        listCells = []
        frameCheckerBoard=Frame(parentControl)
        for i in range(0,rows):
            listCells.append([])
            for j in range(0,columns):
                cellType = self.Map[i][j]
                if(cellType == " "):
                    imgCell = self.createImageCell(frameCheckerBoard, (i, j),self.FloorImage)
                elif(cellType == "^"):
                    imgCell = self.createImageCell(frameCheckerBoard, (i, j),self.WallImage)
                elif(cellType == "~"):
                    imgCell = self.createImageCell(frameCheckerBoard, (i, j),self.WaterImage)
                elif(cellType == "$"):
                    imgCell = self.createImageCell(frameCheckerBoard, (i, j),self.FloorImage)
                    imgCell.changeForeground(self.CoinImage)
                elif(re.match("[a-zA-Z]", cellType)):
                    imgCell = self.createImageCell(frameCheckerBoard, (i, j),self.FloorImage)
                    imgCell.changeForeground(self.PlayerImage)
                listCells[i].append(imgCell)
        frameCheckerBoard.grid(row = 0, column = 0, sticky = N+E+W+S)
        self.drawLegend(parentControl)
        parentControl.rowconfigure(0, weight = 1)
        parentControl.columnconfigure(0, weight = 1)
        
        for x in range(0,rows):
            frameCheckerBoard.rowconfigure(x, weight=1)
        
        for y in range(0,columns):
            frameCheckerBoard.columnconfigure(y, weight=1)
        
        return listCells

    def drawLegend(self,parentControl):
        self.FrameLegend = Frame(parentControl)
        self.FrameLegend.grid(row = 0, column = 1, sticky = N+E)
        self.FrameLegend.rowconfigure(0, weight=1)
        l = Label(self.FrameLegend, anchor="w", text="Legend: ")#,width=20)
        l.grid(row=0,column=0)
        lcn = Label(self.FrameLegend,text='Remaining coins: ', anchor="w")
        lcn.grid(row=1,column=2,sticky=W)
        coinsRemaining = StringVar()
        coinsRemaining.set('10')
        lc = Label(self.FrameLegend,textvariable=coinsRemaining, anchor="w")
        lc.grid(row=1,column=3,sticky=W)
        self.LabelCoinsRemaining = coinsRemaining


    def readPlayerImageFiles(self):
        """
        get all possible player images from the same folder
        """
        currentPath = os.path.dirname(os.path.abspath(__file__))
        listOfFileNames=[]
        for i in os.listdir(currentPath):
            if re.match("player\_\d+",i): #i.endswith(".gif")
                listOfFileNames.append(currentPath+'/'+i)
        return listOfFileNames


    def loadImages(self):
        currentPath = os.path.dirname(os.path.abspath(__file__))
        currentPath += "/"
        image = Image.open(currentPath+"water.gif")
        self.WaterImage = image.copy()
        image.close()
        
        image = Image.open(currentPath+"coin.gif")
        self.CoinImage = image.copy()
        image.close()
        
        image = Image.open(currentPath+"floor.gif")
        self.FloorImage = image.copy()
        image.close()
        
        image = Image.open(currentPath+"wall.gif")
        self.WallImage = image.copy()
        image.close()
        
        playerImages = self.readPlayerImageFiles()
        self.MapPlayerImages.clear()
        for i in range(len(playerImages)):
            image = Image.open(playerImages[i])
            self.MapPlayerImages[i]= image.copy()
            image.close()
    
    def getMaxPlayers(self):
        return len(self.MapPlayerImages.keys())
    
    
    def createImageCell(self,control,cell,image):
        """
        @param window = the tkinter window
        @param cell = the position (tupel)
        """
        b = ResizingCanvas(control,width=400,height=400,borderwidth=0,highlightthickness=0)
        b.changeBackground(image)
        i,j = cell
        b.grid(row=i,column=j,sticky=N+E+W+S)
        return b
    
    def addCoinToCell(self,cell):
        i,j=cell
        control = self.GridCells[i][j]
        control.changeForeground(self.CoinImage)
        
    def addPlayerToCell(self,cell,playerIndex):
        if playerIndex >= self.getMaxPlayers():
            print("Error: gui.addPlayerToLegend -> image for playerIndex "+str(playerIndex)+" is not available")
            return 1
        i,j=cell
        control = self.GridCells[i][j]
        playerImage = self.MapPlayerImages[playerIndex]
        control.changeForeground(playerImage)

    def addPlayerToLegend(self,playerIndex,name):
        if playerIndex >= self.getMaxPlayers():
            print("Error: gui.addPlayerToLegend -> image for playerIndex "+str(playerIndex)+" is not available")
            return 1
        playerImage = self.MapPlayerImages[playerIndex]
        b = ResizingCanvas(self.FrameLegend,width=20,height=20,borderwidth=0,highlightthickness=0)
        b.changeForeground(playerImage)
        b.grid(row=playerIndex+2,column=0,sticky=W)
        ln = Label(self.FrameLegend,text='Name: '+name, anchor="w")
        ln.grid(row=playerIndex+2,column=1,sticky=W)
        lcn = Label(self.FrameLegend,text='Coins: ', anchor="w")
        lcn.grid(row=playerIndex+2,column=2,sticky=W)
        coins = StringVar()
        coins.set('0')
        lc = Label(self.FrameLegend,textvariable=coins, anchor="w")
        lc.grid(row=playerIndex+2,column=3,sticky=W)
        self.CoinLabels[playerIndex] = coins

    def updateCoins(self,playerIndex,coins):
        if playerIndex >= self.getMaxPlayers():
            print("Error: gui.addPlayerToLegend -> image for playerIndex "+str(playerIndex)+" is not available")
            return 1
        self.CoinLabels[playerIndex].set(str(coins))
        
    def updateCoinsRemaining(self,coins):
        self.LabelCoinsRemaining.set(str(coins))
        
    def removeItemFromCell(self,cell):
        i,j=cell
        control = self.GridCells[i][j]
        #control.changeForeground(None)
        control.deleteForeground()


    def on_closing(self):
        for k in self.CoinLabels.keys():
            self.CoinLabels[k].set('')
        del self.CoinLabels
        """
        for row in self.GridCells:
            for cell in row:
                if cell.PhotoImageBackground:
                    del cell.PhotoImageBackground
                if cell.PhotoImageForeground:
                    del cell.PhotoImageForeground
        """            
        self.MainWindow.destroy()

        
IsGridInitialized=False
def onGridInitialized():
    """
    callback function for the GUI thread.
    It is called after the grid is initialized and
    before the TK mainloop has been started.
    (this is before something is visible) 
    """
    global IsGridInitialized
    IsGridInitialized=True
    
    
if __name__ == '__main__':
    gui = GUI(onGridInitialized)
    #gui.loadMap("../boards/testBoard.txt")
    gui.Map = FileReader.readMap("../boards/testBoard.txt")
    gui.start()
    #start separate GUI thread and wait for the grid to be initialized
    while(not IsGridInitialized):
        time.sleep(0.1)
    
    time.sleep(0.1)
    gui.addCoinToCell((0,1))
    time.sleep(0.1)
    gui.addCoinToCell((0,2))
    time.sleep(0.1)
    gui.removeItemFromCell((0,1))
    
    numberOfPlayers = gui.getMaxPlayers()
    
    playerIndex = 0
    gui.addPlayerToCell((0,3), playerIndex)
    
    gui.addPlayerToLegend(playerIndex,'A')

    playerIndex = 1
    gui.addPlayerToCell((0,4), playerIndex)

    gui.addPlayerToLegend(playerIndex,'B')

    gui.updateCoins(playerIndex,5)
    gui.updateCoinsRemaining(5)
    for i in range(len(gui.Map[0])):
        if gui.is_alive():
            gui.addPlayerToCell((4,i), 1)
            time.sleep(0.1)
        if gui.is_alive():
            gui.removeItemFromCell((4,i))
    
    print "finish"
    #print gui.Map
    
    
    

