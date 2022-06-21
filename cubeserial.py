import time
import serial

import serial.tools.list_ports
from tqdm import tqdm
import threading


class SerialConn:

    conn = None

    def __init__(self):
        self.lock = threading.Lock()

        ports = serial.tools.list_ports.comports()
        for port, desc, hwid in sorted(ports):
            try:
                ser = serial.Serial(
                    port=port,
                    baudrate=9600,
                    timeout=2
                )
                ser.isOpen()
            except:
                continue
            else:
                # ping
                ser.write("t")
                res = ser.readline()
                if len(res) > 0 and res.decode("utf-8").strip() == "y":
                    ser.timeout = 4
                    self.conn = ser
                    break
                ser.close()

        if self.conn == None:
            raise Exception("No board found")
        
        print("Board on " + self.conn.port)
    
    def sendMoves(self, moves):
        self.lock.acquire()

        for i in tqdm(range(len(moves))):
            move = moves[i]
            self.conn.write(move)
            res = self.conn.readline()
            #print("{}/{} ".format(i + 1, len(moves)) + res)
            #if len(res) > 0 and res.decode("utf-8").strip() == move:
            if len(res) > 0:
                time.sleep(2)
            else:
                raise Exception("No echo feedback")

        self.lock.release()

    def close(self):
        self.conn.close()
