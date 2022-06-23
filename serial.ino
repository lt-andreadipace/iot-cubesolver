//--------------------------------------------------------------------------------- MOTOR

class Motor {
  private:
    int p1, p2, p3, p4;

    void writeState(int s1, int s2, int s3, int s4) {
      digitalWrite(this->p1, s1);
      digitalWrite(this->p2, s2);
      digitalWrite(this->p3, s3);
      digitalWrite(this->p4, s4);
      delay(1);
    }

    void oneStepAnti() {
      writeState(HIGH,LOW,LOW,LOW);
      writeState(HIGH,HIGH,LOW,LOW);
      writeState(LOW,HIGH,LOW,LOW);
      writeState(LOW,HIGH,HIGH,LOW);
      writeState(LOW,LOW,HIGH,LOW);
      writeState(LOW,LOW,HIGH,HIGH);
      writeState(LOW,LOW,LOW,HIGH);
      writeState(HIGH,LOW,LOW,HIGH);
      writeState(HIGH,LOW,LOW,LOW);
    }

    void oneStep() {
      writeState(HIGH,LOW,LOW,LOW);
      writeState(HIGH,LOW,LOW,HIGH);
      writeState(LOW,LOW,LOW,HIGH);
      writeState(LOW,LOW,HIGH,HIGH);
      writeState(LOW,LOW,HIGH,LOW);
      writeState(LOW,HIGH,HIGH,LOW);
      writeState(LOW,HIGH,LOW,LOW);
      writeState(HIGH,HIGH,LOW,LOW);
      writeState(HIGH,LOW,LOW,LOW);
    }
  public:
    
    int MIN_DELAY;
    int ONEREVOLUTION;
    
    Motor(int p1, int p2, int p3, int p4) {
      this->MIN_DELAY = 5;
      this->ONEREVOLUTION = 512;
      this->p1 = p1;
      this->p2 = p2;
      this->p3 = p3;
      this->p4 = p4;
      // setup pin

      pinMode(this->p1, OUTPUT);
      pinMode(this->p2, OUTPUT);
      pinMode(this->p3, OUTPUT);
      pinMode(this->p4, OUTPUT);
    }

    void oneTurn() {
      for (int i = 0; i < ONEREVOLUTION / 4; i++) {
        oneStep();
      }
      delay(100);
      //giraPoco();
    }

    void giraPoco() {
      for (int i = 0; i < ONEREVOLUTION / 40; i++) {
        oneStep();
      }
    }

    void oneTurnAnti() {
      for (int i = 0; i < ONEREVOLUTION / 4; i++) {
        oneStepAnti();
      }
      delay(100);

      //giraPocoAnti();
    }

    void giraPocoAnti() {
      for (int i = 0; i < ONEREVOLUTION / 40; i++) {
        oneStepAnti();
      }
    }
};

//--------------------------------------------------------------------------------- 

char c = 'a';
Motor R = Motor(P6_1, P4_0, P4_2, P4_4);
Motor L = Motor(P4_5, P4_7, P5_4, P5_5);
Motor F = Motor(P1_5, P4_6, P6_5, P6_4);
Motor B = Motor(P2_7, P2_6, P2_4, P5_6);
Motor D = Motor(P6_7, P2_3, P5_1, P3_5);

void setup() {
  // initialize serial:
  Serial.begin(9600);
  Serial.flush();
  Serial.flush();
    
}

void loop() {
  while (Serial.available()) {
    Serial.flush();
    c = (char)Serial.read(); 

    //c == 0 serve solo per vedere se la porta che stiamo provando è quella giusta
    if(c == 't') {
      Serial.println("y");
    }
    else if(c == 'R') {
      Serial.println("R");
      R.oneTurn();
    }
    else if(c == 'S') {
      Serial.println("R'");
      R.oneTurnAnti();
    }
    else if(c == 'L') {
      Serial.println("L");
      L.oneTurn();
    }
    else if(c == 'M') {
      Serial.println("L'");
      L.oneTurnAnti();
    }
    else if(c == 'F') {
      Serial.println("F");
      F.oneTurn();
    }
    else if(c == 'G') {
      Serial.println("F'");
      F.oneTurnAnti();
    }
    else if(c == 'B') {
      Serial.println("B");
      B.oneTurn();
    }
    else if(c == 'C') {
      Serial.println("B'");
      B.oneTurnAnti();
    }
    else if(c == 'D') {
      Serial.println("D");
      D.oneTurn();
    }
    else if(c == 'E') {
      Serial.println("D'");
      D.oneTurnAnti();
    }
    else if(c == 'W') {
      Serial.println("W"); //Pausina riflessiva
      delay(4000);
    }
    else if(c == '0') {
      Serial.println("R gira poco");
      R.giraPoco();
    }
    else if(c == '5') {
      Serial.println("R' gira poco");
      R.giraPocoAnti();
    }
    else if(c == '1') {
      Serial.println("L gira poco");
      L.giraPoco();
    }
    else if(c == '6') {
      Serial.println("L' gira poco");
      L.giraPocoAnti();
    }
    else if(c == '2') {
      Serial.println("F gira poco");
      F.giraPoco();
    }
    else if(c == '7') {
      Serial.println("F' gira poco");
      F.giraPocoAnti();
    }
    else if(c == '3') {
      Serial.println("B gira poco");
      B.giraPoco();
    }
    else if(c == '8') {
      Serial.println("B' gira poco");
      B.giraPocoAnti();
    }
    else if(c == '4') {
      Serial.println("D gira poco");
      D.giraPoco();
    }
    else if(c == '9') {
      Serial.println("D' gira poco");
      D.giraPocoAnti();
    }
    else {
      Serial.println(":(");
    }
  }
}

//--------------------------------------------------------------------------------
