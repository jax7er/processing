final float fps = 50;
final boolean mouseControl = true;

class Link {
  float mass = 20, radius = 10;
  float angle = 0, angleVel = 0, angleAccel = 0;
  //float x = 0, y = 0;
  float anchorX = 0, anchorY = 0, anchorVelX = 0, anchorVelY = 0, anchorAccelX = 0, anchorAccelY = 0;
  Link connectedLink = null;

  Link(float _mass, float _radius, Link _connectedLink) {
    mass = _mass;
    radius = _radius;
    connectedLink = _connectedLink;
  }

  Link() {
  }
}

int numLinks = 2;
float friction = 0.1;
float gravityAccel = 1;
float linkMass = 20;
float linkRadius = 50;
Link[] links = new Link[numLinks];
Link anchorLink = new Link();

void setup() {
  //size(1000, 800);
  fullScreen();
  background(0);
  frameRate(fps);
  linkRadius = height / (numLinks + 2);
  links[0] = new Link(linkMass, linkRadius, null);
  for (int i = 1; i < numLinks; i++) {
    links[i] = new Link(linkMass, linkRadius, links[i - 1]);
  }
}

float anchorAngle = 0;
float gravityAngle = 0;
void draw() {
  clear();

  rect(0, 0, 10, 10);

  //gravityAccel = cos(gravityAngle);
  //gravityAngle += 0.01;

  float newAnchorX, newAnchorY, newAnchorVelX, newAnchorVelY;
  for (int i = 0; i < numLinks; i++) {
    Link l = links[i];
    
    if (l.connectedLink == null) { // first link
      if (mouseControl) {
        newAnchorX = mouseX;
        newAnchorY = mouseY;
      } else {    
        //if (anchorAngle < PI) {
        anchorAngle = (anchorAngle + 0.02) % TWO_PI;
        //}
        newAnchorX = 100 + 0.5 * (width - 200) * (1 - sin(anchorAngle));
        newAnchorY = height / 10;
      }
    } else {
      newAnchorX = l.connectedLink.anchorX + l.connectedLink.radius * sin(l.connectedLink.angle);
      newAnchorY = l.connectedLink.anchorY + l.connectedLink.radius * cos(l.connectedLink.angle);
    }
      
    newAnchorVelX = newAnchorX - l.anchorX;
    newAnchorVelY = newAnchorY - l.anchorY;
    
    l.anchorAccelX = newAnchorVelX - l.anchorVelX;
    l.anchorAccelY = newAnchorVelY - l.anchorVelY;
    l.anchorVelX = newAnchorVelX;
    l.anchorVelY = newAnchorVelY;
    l.anchorX = newAnchorX;
    l.anchorY = newAnchorY;

    //float xVel = l.anchorX - l.prevAnchorX;
    //float yVel = l.anchorY - l.prevAnchorY;

    //l.angleAccel = gravityAccel * -sin(l.angle); // gravity
    //l.angleAccel /= fps;

    //l.angleVel += l.angleAccel;
    //if (xVel != 0) {
    //  l.angleVel += (xVel > 0 ? -0.1 : 0.1) * atan(abs(xVel) / l.radius) * abs(cos(l.angle)); // x movement
    //}
    //if (yVel != 0) {
    //  l.angleVel += (yVel > 0 ? -0.1 : 0.1) * atan(abs(yVel) / l.radius) * abs(sin(l.angle)); // y movement
    //}
    //l.angleVel *= 1 - friction;

    float angle = l.angle;
    float radius = l.radius;

    l.angleAccel = 0;
    l.angleAccel -= cos(angle) * l.anchorAccelX;
    l.angleAccel += sin(angle) * l.anchorAccelY;
    l.angleAccel -= l.angleVel * 10 / l.mass / radius;
    l.angleAccel -= sin(angle) * gravityAccel;
    l.angleAccel /= radius;

    l.angleVel += l.angleAccel;
    l.angle += l.angleVel;

    float x = l.anchorX + radius * sin(angle);
    float y = l.anchorY + radius * cos(angle);
    float fraction = float(i) / float(numLinks);
    stroke(255);
    noFill();
    //ellipse(x, y, l.mass, l.mass);
    line(l.anchorX, l.anchorY, x, y);
    noStroke();
    fill(128 * (1 + sin(PI * fraction)), 128 * (1 + sin(PI * (0.333 + fraction))), 128 * (1 + sin(PI * (0.667 + fraction))));    
    ellipse(x, y, l.mass, l.mass);
  }
}

void mouseClicked() {
  anchorAngle = 0;
}
