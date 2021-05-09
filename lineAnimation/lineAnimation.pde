class Point {
  float angle, colour, radius, angleAccel, angleVel, radiusAccel, radiusVel;
  
  Point(float _angle, float _colour, float _radius, float _angleAccel, float _angleVel, float _radiusAccel, float _radiusVel) {
    angle = _angle;
    colour = _colour;
    radius = _radius;
    angleAccel = _angleAccel;
    angleVel = _angleVel;
    radiusAccel = _radiusAccel;
    radiusVel = _radiusVel;
  }
  
  Point(float _angle, float _colour, float _radius) {
    this(_angle, _colour, _radius, 0, 0, 0, 0);
  }
}

final int NUM_POINTS = 100;
final float ACCEL_LIMIT = 0.001;
final float VEL_LIMIT = 0.01;
final float MIN_ACCEL = -ACCEL_LIMIT, MAX_ACCEL = ACCEL_LIMIT;
final float MIN_VEL = -VEL_LIMIT, MAX_VEL = VEL_LIMIT;

Point[] points = new Point[NUM_POINTS];

float minRadius, maxRadius;

void setup() {
  size(900, 900);
  //fullScreen();
  background(0);
  frameRate(50);
  
  float radius = width > height ? height * 0.4 : width * 0.4;
  minRadius = radius * 0.9;
  maxRadius = radius * 1.1;
  for (int i = 0; i < NUM_POINTS; i++) {
    float angle = randomGaussian();
    float colour = 128 * (1 + float(i) / float(NUM_POINTS)); 
    points[i] = new Point(angle, colour, radius);
  }
}

float rotation = 0;
void draw() {
  clear();
  
  for (int i = 0; i < NUM_POINTS; i++) {    
    points[i].angleAccel = min(max(points[i].angleAccel + randomGaussian() * 0.001, MIN_ACCEL), MAX_ACCEL);
    points[i].radiusAccel = min(max(points[i].radiusAccel + randomGaussian() * 0.01, 100 * MIN_ACCEL), 100 * MAX_ACCEL);
    
    points[i].angleVel = min(max(points[i].angleVel + points[i].angleAccel, MIN_VEL), MAX_VEL);
    points[i].radiusVel = min(max(points[i].radiusVel + points[i].radiusAccel, 100 * MIN_VEL), 100 * MAX_VEL);
    
    points[i].angle += points[i].angleVel;
    points[i].radius = min(max(points[i].radius + points[i].radiusVel, minRadius), maxRadius);
    
    points[i].colour = min(max(points[i].colour + randomGaussian(), 0), 255);
  }
  
  for (int i = 0; i < NUM_POINTS; i++) {
    int iNext = (i + 1) % NUM_POINTS;
    float x1 = width / 2 + points[i].radius * sin(points[i].angle);
    float y1 = height / 2 + points[i].radius * cos(points[i].angle);
    float x2 = width / 2 + points[iNext].radius * sin(points[iNext].angle);
    float y2 = height / 2 + points[iNext].radius * cos(points[iNext].angle);
    float red = 255 * (points[i].radius - minRadius) / (maxRadius - minRadius);
    float alpha = 255 * (points[i].angleVel - MIN_VEL) / (MAX_VEL - MIN_VEL);
    
    stroke(red, 0, 255 - red, alpha);
    line(x1, y1, x2, y2);
  }
  
  rotation = (rotation + 0.01) % TWO_PI;
  
  noFill();
  stroke(128, 128, 128, 255 * abs(cos(rotation * 2)));
  ellipse(width / 2, height / 2, maxRadius * 2, maxRadius * 2);
  
  stroke(0, 128, 0, 255 * abs(sin(rotation * 2)));
  ellipse(width / 2, height / 2, maxRadius * 2 * sin(rotation), maxRadius * 2);
  ellipse(width / 2, height / 2, maxRadius * 2 * cos(rotation), maxRadius * 2);
  ellipse(width / 2, height / 2, maxRadius * 2, maxRadius * 2 * sin(rotation));
  ellipse(width / 2, height / 2, maxRadius * 2, maxRadius * 2 * cos(rotation));
}