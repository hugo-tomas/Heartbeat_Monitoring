#define ECGreader A6
#define LO_plus 10
#define LO_minus 11

// ECG READER CODE
float ecg[2];

// String matlabDATA;
const byte numChars = 10;
char comm[numChars];
int loopCount=1;
boolean newComm = true;
float duration;
float freq;
uint32_t DELAY;
float t=0;
float t0;

void setup() {
  // Initialize the serial communication:
  Serial.begin(115200); 
  pinMode(ECGreader, OUTPUT); // Analog output A6
  pinMode(LO_plus, INPUT); // Setup for leads off detection LO +
  pinMode(LO_minus, INPUT); // Setup for leads off detection LO -
}
 
void loop() {

    msg_wait();
    processCommand();
    if (t-t0<=duration*60*1000 && duration!=0) 
    {
      if((digitalRead(LO_plus) == 1)||(digitalRead(LO_minus) == 1)==false){
        t=millis();
        // Save a time of aquisition in seconds
        ecg[0] = t; 
        // Save the value of analog input 6:
        ecg[1] = analogRead(ECGreader);
        DELAY=1000/freq;
        blink(DELAY,t,ecg);
      }
    }  
}

void blink (uint32_t DELAY,float t,float* ecg){
  static uint32_t TIME=0;
  if(millis()-TIME>=DELAY){
    Serial.print(ecg[0]);
    Serial.print("|");
    Serial.println(ecg[1]);
    TIME=millis();
  }
}

void msg_wait() {
  char com;
  static byte ndx = 0;
  
  while (Serial.available() > 0) {
    t0=millis();
    com = Serial.read();
      comm[ndx] = com;
      ndx++;
      if (ndx >= numChars) {
        ndx = numChars - 1;
    }
  }
  ndx=0;
}

void processCommand() {
  char* token = strtok(comm, "|");
  byte index = 0;

  while (token != NULL && index < 2) {
    switch (index) {
      case 0:
        duration = static_cast<float>(atof(token));
        break;
      case 1:
        freq = static_cast<float>(atof(token));
        break;
    }

    token = strtok(NULL, " ");
    index++;
  }
  memset(comm, 0, sizeof(comm));
}
