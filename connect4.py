import pygame, os, processor, threading, sys, copy, ctypes, random
pygame.init()
size = width, height = 840, 720
screen = pygame.display.set_mode(size)

dire = os.getcwd()
board = pygame.image.load(f"{dire}\\Connect4Board.png").convert_alpha()

X_TO_COORD = {0:60, 1:180, 2:300, 3:420, 4:540, 5:660, 6:780}
Y_TO_COORD = {0:660, 1:540, 2:420, 3:300, 4:180, 5:60, 6:-60}
PLAYER_TO_COLOUR = {1:(255,0,0), 2:(255,255,0)}
PLAYER_TO_TRANSPARENT = {1:(255,85,85), 2:(234,215,120)}

def replaceChar(string, newchar, index):
    return string[:index] + newchar + string[(index+1):]

def getsq(x, y):
    return(x*6 + y)

def posToBinary(board, friendly_id, opponent_id):
    friendly = 0
    opponent = 0
    for y in range(6):
        for x in range(7):
            if board[7*y + (6 - x)] == friendly_id: friendly += 2**(7*y + x)
            elif board[7*y + (6 - x)] == friendly_id: opponent += 2**(7*y + x)
    return [friendly, opponent]

class Game():
    def __init__(self, PLAYERS, CPU_TYPE="minimax"):
        self.PLAYERS = PLAYERS #1:playerType, 2:playerType. playerType can be either "CPU" for computer or "HUM" for human.
        self.CPU_TYPE = CPU_TYPE
        self.winner = 0
        self.turn = 1

        self.board = "0"*7*6
        #self.board = "000000222120000000121112222111122121000000"
        self.boardHistory = []
        self.moves = [int(x) for x in processor.getMoves(self.board)]

        self.mousepressed = pygame.mouse.get_pressed()
        self.mousepos = pygame.mouse.get_pos()
        self.mouseregion = [self.mousepos[0]//120, 5-self.mousepos[1]//120]
        self.mousedown = False
        self.doneAction = False

    def play(self):
        n = threading.Thread(target = self.turnThread)
        n.daemon = True
        n.start()
        
        while True:
            for event in pygame.event.get():
                if event.type == pygame.QUIT: 
                    sys.exit()
                elif event.type == pygame.MOUSEBUTTONDOWN:
                    self.mousedown = True
                elif event.type == pygame.MOUSEBUTTONUP:
                    self.mousedown = False
                if event.type == pygame.KEYDOWN:
                    if event.key == pygame.K_LEFT and not self.doneAction and self.PLAYERS[self.turn] == "HUM":
                        print("undoing!")
                        self.doneAction = True
                        self.undo()
                else: self.doneAction = False
                    
            self.mousepos = pygame.mouse.get_pos()
            self.mouseregion = [self.mousepos[0]//120, 5-self.mousepos[1]//120]

            screen.fill([0,0,0])
            screen.blit(board, (0,0))
            self.draw()
            if self.PLAYERS[self.turn] == "HUM" and pygame.mouse.get_focused():
                pygame.draw.circle(screen, PLAYER_TO_TRANSPARENT[self.turn], (X_TO_COORD[self.mouseregion[0]], Y_TO_COORD[self.moves[self.mouseregion[0]]]), 40)
            pygame.display.flip()

    def turnThread(self):
        while self.winner == 0 and "0" in self.board:
            if self.PLAYERS[self.turn] == "HUM":
                print(f"Player {self.turn}(HUM)'s turn!")
                while True:
                    if self.mousedown and self.moves[self.mouseregion[0]] <= 5: break
                self.mousedown = False
                self.makeMove([self.mouseregion[0], self.moves[self.mouseregion[0]]])
            elif self.PLAYERS[self.turn] == "CPU":
                print(f"Player {self.turn}(CPU)'s turn!")
                #BELOW (usually 'minimax', board, initial moves forward, turn, time limit)
                if self.CPU_TYPE == "minimax2":
                    binaryBoard = posToBinary(self.board, self.turn, self.turn*-1 + 3)
                    move = minimax2.minimax_to_python(binaryBoard[0], binaryBoard[1], 7)
                else:
                    move = processor.cpumove(self.CPU_TYPE, self.board, 6, self.turn, 2)

                if move == -1:
                    print(f"Player {self.turn} thinks they will lose!")
                    self.moves = [int(x) for x in processor.getMoves(self.board)]
                    move = self.moves[random.randint(0,len(self.moves)-1)]
                    self.makeMove([move, self.moves[move]])
                else:
                    print(f"move: {move}")
                    self.makeMove([move, self.moves[move]])
        if "0" not in self.board: print("draw!")
        else: print(f"{self.winner} wins!")

    def makeMove(self, movepos):
        self.boardHistory.append(self.board)
        self.board = replaceChar(self.board, str(self.turn), getsq(movepos[0], movepos[1]))
        self.moves = [int(x) for x in processor.getMoves(self.board)]
        
        self.winner = processor.detectVictory(self.board)
        self.turn = self.turn*-1 + 3

    def undo(self):
        self.board = self.boardHistory[-2]
        del self.boardHistory[-1]
        del self.boardHistory[-1]
        self.moves = [int(x) for x in processor.getMoves(self.board)]

    def draw(self):
        for i in range(7):
            for j in range(6):
                if self.board[getsq(i, j)] != "0":
                    pygame.draw.circle(screen, PLAYER_TO_COLOUR[int(self.board[getsq(i, j)])], (X_TO_COORD[i], Y_TO_COORD[j]), 40)

#a = Game({1:"HUM", 2:"CPU"})
a = Game({1:"HUM", 2:"CPU"})
a.play()
