
import processing.serial.*;
import SimpleOpenNI.*;

SimpleOpenNI kinect;
Serial Arduino;

float RightshoulderAngle = 0;
float RightelbowAngle = 0;

void setup() {
  size(640, 480);
  kinect = new SimpleOpenNI(this);
  Arduino = new Serial(this, "COM5", 9600);
  kinect.enableDepth();
  kinect.enableUser();
  fill(255, 0, 0);
  kinect.setMirror(false);
}

void draw() {
  kinect.update();
  image(kinect.userImage(), 0, 0);
  IntVector userList = new IntVector();
  kinect.getUsers(userList);
  if (userList.size() > 0) {
    int userId = userList.get(0);
    if (kinect.isTrackingSkeleton(userId)) {
      drawSkeleton(userId);
      ArmsAngle(userId);
    }
  }
}

void drawSkeleton(int userId) {
  stroke(0);
  strokeWeight(5);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
  noStroke();
  fill(255, 0, 0);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HAND);
}

void drawJoint(int userId, int jointID) {
  PVector joint = new PVector();
  float confidence = kinect.getJointPositionSkeleton(userId, jointID, joint);
  if (confidence < 0.5) {
    return;
  }
  PVector convertedJoint = new PVector();
  kinect.convertRealWorldToProjective(joint, convertedJoint);
  ellipse(convertedJoint.x, convertedJoint.y, 5, 5);
}

float angleOf(PVector one, PVector two, PVector axis) {
  PVector limb = PVector.sub(two, one);
  return degrees(PVector.angleBetween(limb, axis));
}

public void ArmsAngle(int userId) {
  PVector rightHand = new PVector();
  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, rightHand);
  PVector rightElbow = new PVector();
  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, rightElbow);
  PVector rightShoulder = new PVector();
  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, rightShoulder);
  PVector rightHip = new PVector();
  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HIP, rightHip);

  PVector rightHand2D = new PVector(rightHand.x, rightHand.y);
  PVector rightElbow2D = new PVector(rightElbow.x, rightElbow.y);
  PVector rightShoulder2D = new PVector(rightShoulder.x, rightShoulder.y);
  PVector rightHip2D = new PVector(rightHip.x, rightHip.y);

  PVector torsoOrientation = PVector.sub(rightShoulder2D, rightHip2D);
  PVector upperArmOrientation = PVector.sub(rightElbow2D, rightShoulder2D);

    RightshoulderAngle = angleOf(rightElbow2D, rightShoulder2D, torsoOrientation);
  RightelbowAngle = angleOf(rightHand2D, rightElbow2D, upperArmOrientation);

  fill(255, 0, 0);
  scale(1);
  textSize(40);
  text("Right shoulder:" + int(RightshoulderAngle) + "\n" + "Right elbow:" + int(RightelbowAngle), 20, 40);

  Arduino.write("shoulder/" + RightshoulderAngle + "\n");
  Arduino.write("Elbow/" + RightelbowAngle + "\n");
}

void onNewUser(SimpleOpenNI kinect, int userID) {
  println("Start skeleton tracking");
  kinect.startTrackingSkeleton(userID);
}

void onLostUser(SimpleOpenNI curContext, int userId) {
  println("onLostUser - userId: " + userId);
}

