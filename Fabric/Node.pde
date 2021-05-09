class Node {
  float x_origin, y_origin, x, y, vx, vy, ax, ay, fx, fy, mass, friction;
  
  float factor, h, s, b, diameter, speed;
  int fill_colour, stroke_colour;
  
  float speed_threshold = 0.1;
        
  Node(float _x_origin, float _y_origin, float _mass, float _friction) {
    x_origin = _x_origin;
    y_origin = _y_origin;
    
    x = x_origin;
    y = y_origin;
    vx = 0;
    vy = 0;
    ax = 0;
    ay = 0;
    fx = 0;
    fy = 0;
    
    mass = _mass;
    friction = _friction;
  }
  
  void update() {
    ax = fx / mass;
    ay = fy / mass;
    
    factor = 1 - friction;
    vx = (vx + ax) * factor;
    vy = (vy + ay) * factor;
    
    x += vx;
    y += vy;
    
    fx = 0;
    fy = 0;
  }
  
  void draw() {    
    if (mass < inf) {      
      pushStyle();
      colorMode(HSB, 1.0, 1.0, 1.0);
      
      speed = sqrt(pow(vx, 2) + pow(vy, 2));
      diameter = mass * 2;
      
      h = min(1.0, speed);
      s = 1;
      b = pow(h, 2);
      
      if (speed > speed_threshold) {
        fill_colour = color(h, s, b);
        
        shapeMode(CENTER);
        fill(fill_colour);
        noStroke();
        ellipse(x, y, diameter, diameter);
      }
    
      stroke_colour = color(0, 0, (1 - b) / 8);
      noFill();
      stroke(stroke_colour);
      ellipse(x, y, diameter, diameter);
    
      popStyle();
    }
  }
}
