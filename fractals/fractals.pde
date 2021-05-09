class Z {
  float r, i;
  
  Z(float _r, float _i) {
    r = _r;
    i = _i;
  }
  
  Z(Z z) {
    this(z.r, z.i);
  }
  
  Z() {
    this(0, 0);
  }
  
  Z add(Z z) {
    r += z.r;
    i += z.i;
    return this;
  }
  
  Z subtract(Z z) {
    r -= z.r;
    i -= z.i;
    return this;
  }
  
  Z scale(float f) {
    r *= f;
    i *= f;
    return this;
  }
  
  Z reduce(float f) {
    r /= f;
    i /= f;
    return this;
  }
  
  Z multiply(Z z) {
    r = r * z.r - i * z.i;
    i = r * z.i + i * z.r;
    return this;
  }
  
  Z divide(Z z) {
    float r1xr2 = r * z.r;
    float i1xi2 = i * z.i;
    r = r1xr2 + i1xi2;
    i = i * z.r - r * z.i;
    reduce(r1xr2 - i1xi2);
    return this;
  }
  
  Z conjugate() {
    i *= -1;
    return this;
  }
  
  float magnitude() {
    return sqrt(r * r + i * i);
  }
  
  float angle() {
    return atan(i / r);
  }
}

Z doFunction(Z input) {
  return input.multiply(new Z(cos(input.angle()), tan(input.magnitude()))).multiply(input).scale(input.angle());
}

float getDivergence(Z z) {
  int numIterations = 0;
  float divergence = 0;
  Z zTemp = new Z(z);
  
  do {
    doFunction(zTemp);
    divergence = zTemp.magnitude() + 100;
  } while (divergence < maxDivergence && ++numIterations < maxIterations);
  
  return min(divergence, maxDivergence);
}

void settings() {
  size(displayWidth / 8, displayHeight / 8);
  //fullScreen();  
  smooth();
}

void setup() {
  //frameRate(50);
  noStroke();
}

int maxIterations = 4;
long maxDivergence = 1000000000;
float rLimits, iLimits;
float rShift = 0, iShift = 0;
float r, i;
float divergence;
float red, green, blue;
float angle = 0;
float scale, shift;
void draw() {  
  iLimits = 1000 * (1.01 + cos(angle));
  rLimits = 1000 * (1.01 + cos(angle));
  
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      r = 2 * rLimits * (float(x) / width - 0.5) + rShift;
      i = 2 * iLimits * (float(y) / height - 0.5) + iShift;
      
      divergence = getDivergence(new Z(r, i)) / maxDivergence;
      
      scale = (1 - divergence) * 128;
      shift = divergence + angle;
      red = scale * (1 + cos(PI * shift));
      green = scale * (1 + cos(PI * (shift + 0.333)));
      blue = scale * (1 + cos(PI * (shift + 0.667)));
      
      set(x, y, color(red, green, blue));
    }
  }
  
  angle += 0.01;
  
  if (angle > TWO_PI) {
    exit();
  } else {
    saveFrame();
  }
}
