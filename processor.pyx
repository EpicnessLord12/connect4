import time

cdef dict POSITIONS = {}
cdef int progressedMoves = 0

cdef int getsq(int x, int y):
    return(x*6 + y)

cdef str replaceChar(str string, str newchar, int index):
    return string[:index] + newchar + string[(index+1):]

cpdef str getMoves(str board):
    cdef int i
    cdef int j
    cdef int x
    cdef int tokenPos
    cdef int moves[7]
    cdef str retmoves

    for i in range(7):
        tokenPos = 0
        for j in range(6):
            if board[getsq(i, j)] != "0": tokenPos = j+1
        moves[i] = tokenPos
    retmoves = "".join([str(x) for x in moves])
    return(retmoves)

cpdef int detectVictory(str board):
    cdef int p1streak
    cdef int p2streak
    cdef int winner = 0
    cdef int i
    cdef int j

    for i in range(7): #heading vertically from bottom
        p1streak, p2streak = 0, 0
        for j in range(6):
            if board[getsq(i, j)] == "0": p1streak, p2streak = 0, 0
            elif board[getsq(i, j)] == "1":
                p1streak += 1
                p2streak = 0
            elif board[getsq(i, j)] == "2":
                p2streak += 1
                p1streak = 0
            if p1streak >= 4 or p2streak >= 4: break
        if p1streak >= 4:
            winner = 1
            break
        elif p2streak >= 4:
            winner = 2
            break

    if winner == 0: #heading horizontally from left
        for i in range(6):
            p1streak, p2streak = 0, 0
            for j in range(7):
                if board[getsq(j, i)] == "0": p1streak, p2streak = 0, 0
                elif board[getsq(j, i)] == "1":
                    p1streak += 1
                    p2streak = 0
                elif board[getsq(j, i)] == "2":
                    p2streak += 1
                    p1streak = 0
                if p1streak >= 4 or p2streak >= 4: break
            if p1streak >= 4:
                winner = 1
                break
            elif p2streak >= 4:
                winner = 2
                break

    if winner == 0:
        for i in range(3,6): #heading diagonally from topleft(left)
            p1streak, p2streak = 0, 0
            for j in range(6):
                if board[getsq(j, i-j)] == "0": p1streak, p2streak = 0, 0
                elif board[getsq(j, i-j)] == "1":
                    p1streak += 1
                    p2streak = 0
                elif board[getsq(j, i-j)] == "2":
                    p2streak += 1
                    p1streak = 0
                if j == 6 or i-j == 0: break
                if p1streak >= 4 or p2streak >= 4: break
            if p1streak >= 4:
                winner = 1
                break
            elif p2streak >= 4:
                winner = 2
                break

    if winner == 0: #heading diagonally from topleft(right)
        for i in range(1,4):
            p1streak, p2streak = 0, 0
            for j in range(6):
                if board[getsq(i+j, 5-j)] == "0": p1streak, p2streak = 0, 0
                elif board[getsq(i+j, 5-j)] == "1":
                    p1streak += 1
                    p2streak = 0
                elif board[getsq(i+j, 5-j)] == "2":
                    p2streak += 1
                    p1streak = 0
                if i+j == 6 or 5-j == 0: break
                if p1streak >= 4 or p2streak >= 4: break
            if p1streak >= 4:
                winner = 1
                break
            elif p2streak >= 4:
                winner = 2
                break

    if winner == 0: #heading diagonally from bottomleft(right)
        for i in range(1,4):
            p1streak, p2streak = 0, 0
            for j in range(6):
                if board[getsq(i+j, j)] == "0": p1streak, p2streak = 0, 0
                elif board[getsq(i+j, j)] == "1":
                    p1streak += 1
                    p2streak = 0
                elif board[getsq(i+j, j)] == "2":
                    p2streak += 1
                    p1streak = 0
                if i+j == 6 or j == 5: break
                if p1streak >= 4 or p2streak >= 4: break
            if p1streak >= 4:
                winner = 1
                break
            elif p2streak >= 4:
                winner = 2
                break

    if winner == 0: #heading diagonally from bottomleft(left)
        for i in range(0,3):
            p1streak, p2streak = 0, 0
            for j in range(6):
                if board[getsq(j, i+j)] == "0": p1streak, p2streak = 0, 0
                elif board[getsq(j, i+j)] == "1":
                    p1streak += 1
                    p2streak = 0
                elif board[getsq(j, i+j)] == "2":
                    p2streak += 1
                    p1streak = 0
                if j == 6 or i+j == 5: break
                if p1streak >= 4 or p2streak >= 4: break
            if p1streak >= 4:
                winner = 1
                break
            elif p2streak >= 4:
                winner = 2
                break

    return winner

cpdef int cpumove(str typ, str board, int movesForward, int turn, float timelimit): #timelimit is in seconds
    print("Rev1")
    global POSITIONS, progressedMoves
    if progressedMoves < movesForward:
        progressedMoves = movesForward
    cdef int move
    cdef str moves
    moves = getMoves(board)
    cdef int filled_count = 0
    cdef str i
    cdef int filled_columns = 0
    cdef double timer = 0
    #cdef int old = movesForward

    for i in moves:
        if i == "6": filled_columns += 1
        filled_count += int(i)
    # if filled_columns == 1: movesForward += 1
    # if filled_columns == 2: movesForward *= 3
    # if filled_columns == 3: movesForward *= 9
    # if filled_columns >= 4: movesForward *= 27
    # movesForward += round((filled_count-1)/8.0)
    # if movesForward < old: movesForward = old
    # print(movesForward)
    
    # if typ == "minimax":
    #     while timer < 2*(7 / (7 - filled_columns)) and progressedMoves <= 42-filled_count:
    #         print(f"going with {progressedMoves}")
    #         POSITIONS = {}
    #         timer = time.time()
    #         move = minimax(board, progressedMoves, progressedMoves, turn, turn, -1001, 1001)
    #         timer = time.time() - timer
    #         if timer < 2*(7 / (7 - filled_columns)): progressedMoves += 1
    #         print(f"time taken: {timer}")
    #     #print(progressedMoves)
    #     return(move)

    if typ == "minimax":
        while True:
            POSITIONS = {}
            print(f"going with {progressedMoves}")
            timer = time.time()
            move = minimax(board, progressedMoves, progressedMoves, turn, turn, -1001, 1001)
            timer = time.time() - timer
            print(f"time taken: {timer}")

            if timer > timelimit*(7 / (7 - filled_columns)) or progressedMoves >= 42-filled_count:
                break
            else:
                progressedMoves += 1

        return move

    #for 7s per turn, go a move further if (time) < (7 / rows not completed)

cdef dict OPENING_BOOK
OPENING_BOOK = {}

cdef int minimax(str board, int movesForward, int master_movesForward, int turn, int master_turn, int prune_high, int prune_low):
    global POSITIONS
    cdef str strmoves
    cdef int moves[7]
    cdef str x
    cdef int i
    strmoves = getMoves(board)
    moves = [int(x) for x in strmoves]
    cdef int evaluation
    cdef int highest = -1000
    cdef int highest_mov
    cdef int lowest = 1000
    cdef int lowest_mov
    cdef str tempboard
    cdef int prune_high_loc = -1001
    cdef int prune_low_loc = 1001

    if board in POSITIONS:
        return POSITIONS[board]

    if movesForward == 0 or strmoves == "6666666":
        return evaluate(board, master_turn, 1)
    evaluation = evaluate(board, master_turn, 0)
    if evaluation == -1000 or evaluation == 1000:
        return evaluation
    else:
        for i in range(7):
            if moves[i] != 6:
                tempboard = replaceChar(board, str(turn), getsq(i, moves[i]))
                evaluation = minimax(tempboard, movesForward-1, master_movesForward, turn*-1 + 3, master_turn, prune_high_loc, prune_low_loc)
                if evaluation == 1000 and turn == master_turn:
                    if movesForward != master_movesForward:
                        return(1000)
                    else: highest_mov = i
                elif evaluation == -1000 and turn != master_turn:
                    if movesForward != master_movesForward:
                        return(-1000)
                    else: lowest_move = i
                # if prune_high != -1001 and evaluation <= prune_low and turn == master_turn*-1 + 3: #and not (movesForward == master_movesForward and abs(evaluation) == 1000):
                #     return(evaluation)
                # elif prune_low != 1001 and evaluation >= prune_high and turn == master_turn:
                #     return(evaluation)
                # if evaluation > prune_high_loc:
                #     prune_high_loc = evaluation
                # if evaluation < prune_low_loc:
                #     prune_low_loc = evaluation
                if evaluation <= lowest:
                    lowest = evaluation
                    lowest_mov = i
                if evaluation >= highest:
                    highest = evaluation
                    highest_mov = i
        if movesForward == master_movesForward:
            if highest == -1000: return(-1)
            else:
                print(f"highest_mov: {highest_mov}")
                return(highest_mov)
        else:
            if turn == master_turn:
                if board not in POSITIONS: POSITIONS[board] = highest
                return(highest)
            else:
                if board not in POSITIONS: POSITIONS[board] = lowest
                return(lowest)

cdef int POSITION_WEIGHTS[42]
POSITION_WEIGHTS = [50,50,50,50,50,50,100,100,100,100,100,100,200,200,200,200,200,200,250,250,250,250,250,250,200,200,200,200,200,200,100,100,100,100,100,100,50,50,50,50,50,50]

cpdef int evaluate(str board, int turn, int doPrecise): #returns a value for how good the position is between -1000 and 1000 (-1000 and 1000 being defeat and victory respectively)
    cdef int winner = detectVictory(board)
    cdef float avgweight = 0.0
    cdef float weightcounter = 0.0
    cdef int i
    if winner == turn: return 1000
    elif winner == turn*-1 + 3: return -1000
    elif doPrecise == 1:
        for i in range(len(board)):
            if board[i] == str(turn):
                avgweight += POSITION_WEIGHTS[i]
                weightcounter += 1
            elif board[i] != "0":
                avgweight -= POSITION_WEIGHTS[i]
                weightcounter += 1
        if weightcounter != 0:
            avgweight = avgweight/weightcounter
        return round(avgweight)
    else: return 0
