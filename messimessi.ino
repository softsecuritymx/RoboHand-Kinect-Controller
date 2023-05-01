#include <SoftwareSerial.h>
#include <Servo.h>

Servo Servohombro;
Servo Servocodo;
Servo Servomuneca;
Servo Servodedos;

int nextServo = 0;
int servoAngles[] = {0, 0, 0, 0};

void setup() {
  Serial.begin(9600);
  Servohombro.attach(3);
  Servocodo.attach(4);
  Servomuneca.attach(5);
  Servodedos.attach(6);
}

void loop() {
  if (Serial.available()) {
    int servoAngle = Serial.read();
    servoAngles[nextServo] = servoAngle;
    nextServo++;

    if (nextServo > 3) {
      nextServo = 0;
      Servohombro.write(servoAngles[0]);
      Servocodo.write(servoAngles[1]);
      Servomuneca.write(servoAngles[2]);
      Servodedos.write(servoAngles[3]);
    }
  }
}
