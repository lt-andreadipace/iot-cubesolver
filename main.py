#!/usr/bin/env python2
import cubeserial

# U = R L F F B B R' L' D R L F F B B R' L'
# U' = R L F F B B R' L' D' R L F F B B R' L'

from rubik_solver import utils
from flask import Flask, request

import signal
import sys
import threading

app = Flask(__name__)

CUBE = cubeserial.SerialConn()

def adaptNotation(moves):
    ret = [m if not m.endswith("'") else chr(ord(m[0]) + 1) for m in moves]
    return ret

def parseMoves(solve):
    solve_adapted = []
    for m in solve:
        if m == "U":
            solve_adapted.extend("R L F F B B R' L' D R L F F B B R' L'".split())
        elif m == "U2":
            solve_adapted.extend("R L F F B B R' L' D D R L F F B B R' L'".split())
        elif m == "U'":
            solve_adapted.extend("R L F F B B R' L' D' R L F F B B R' L'".split())
        elif m == "U2'":
            solve_adapted.extend("R L F F B B R' L' D D R L F F B B R' L'".split())
        elif m.endswith("2") or m.endswith("2'"):
            m = m.replace("2", "")
            m = m.replace("'", "")
            solve_adapted.extend([m, m])
        else:
            solve_adapted.append(m)

    # from clockwise to counterclockwise and vice versa
    solve_rev = [x + "'" if not x.endswith("'") else x.replace("'", "") for x in solve_adapted]
    solve_rev.reverse()
    complete = []
    complete.extend(solve_rev)
    # stop to show cube
    complete.append("W")
    complete.extend(solve_adapted)
    return complete

@app.route('/solve', methods=['POST'])
def route_solve():
    cube_config = request.json['cube']
    try:
        solve = utils.solve(cube_config, 'Kociemba')
        solve = map(lambda x: str(x), solve)

        # transform the moves into the available ones
        moves = parseMoves(solve)
        # adapt notation: the counterclockwise moves becoming the next letter
        moves = adaptNotation(moves)

        # check if cube is busy
        if CUBE.lock.locked():
            return "Another solve is going"
        # start thread
        thread = threading.Thread(target=CUBE.sendMoves, args=(moves,))
        thread.start()
    except Exception as e:
        return "Wrong config"
    else:
        solveret = ' '.join(solve)
        return solveret

def signal_handler(sig, frame):
    print("Close connection")
    CUBE.close()
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)

if __name__ == "__main__":
    app.run("0.0.0.0", 5000)