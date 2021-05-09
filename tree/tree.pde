class Line {
  float x0 = 0, y0 = 0, x1 = 0, y1 = 0;
  
  Line(float _x0, float _y0, float _x1, float _y1) {
    x0 = _x0;
    y0 = _y0;
    x1 = _x1;
    y1 = _y1;
  }
  
  Line(float _x, float _y) {
    this(_x, _y, _x, _y);
  }
  
  float length() {
    return sqrt(pow(x1 - x0, 2) + pow(y1 - y0, 2));
  }
}

ArrayList<Line> lines = new ArrayList<Line>();

void settings() {
  //size(displayWidth / 2, displayHeight / 2);
  fullScreen();
  //smooth();
}

void setup() {
  frameRate(30);
  lines.add(new Line(width / 2, height / 2));
}

int layers = 1;
float deltaX = 0, deltaY = 0, angle;
void draw() {  
  int start = int(pow(2, layers - 1)) - 1;
  int end = start + int(pow(2, layers - 1));
  Line l;
  boolean addLayer = true;
  float radius = 5;
    
  angle = log(float(layers)) / 1;
  
  for (int i = start; i < end; i++) {
    l = lines.get(i);
    
    if (i % 2 == 0) {
      l.x1 += radius * sin(2.1 * angle);
    } else {
      l.x1 += radius * sin(0.05 * angle);
    }
    l.y1 += radius * cos(angle);
        
    if (l.length() < (height / 10)) {
      addLayer = false;
    }
  }
  
  if (addLayer) {    
    clear();
    stroke(255, 255, 255, 16);  
    text(layers, 10, 10);
    for (Line line : lines) {    
      line(line.x0, line.y0, line.x1, line.y1);
      line(width - line.x0, line.y0, width - line.x1, line.y1);
      line(line.x0, height - line.y0, line.x1, height - line.y1);
      line(width - line.x0, height - line.y0, width - line.x1, height - line.y1);
    }
    
    for (int i = start; i < end; i++) {
      l = lines.get(i);
      lines.add(new Line(l.x1, l.y1));
      lines.add(new Line(l.x1, l.y1));
    }
    
    layers++;
  }
}
