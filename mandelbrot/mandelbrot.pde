enum DRAW_STATE {render, zoom}

DRAW_STATE last_draw_state, draw_state;

float x_min = -2;
float x_max = 0.5;
float y_min = -1;
float y_max = 1;

int x_drag_start, y_drag_start;

int n_x = 1000;
int n_y = int(n_x * (y_max - y_min) / (x_max - x_min));

float[] xs;
float[] ys;
float[][] reals;
float[][] imags;
float[][] mags;
int[] saved_pixels;
int x, y;
float h, new_real, new_imag, min_mag, max_mag;


float map_x_px(int x) {
  return map(x, 0, n_x - 1, x_min, x_max);
}


float map_y_px(int y) {
  return map(y, 0, n_y - 1, y_min, y_max);
}


void settings() {
  size(n_x, n_y);
  //fullScreen();
  smooth();
}


void setup() {
  //frameRate(1);
  colorMode(HSB, 1.0);
  
  last_draw_state = DRAW_STATE.render;
  draw_state = DRAW_STATE.render;
  
  xs = new float[n_x];
  ys = new float[n_y];
  reals = new float[n_x][n_y];
  imags = new float[n_x][n_y];
  mags = new float[n_x][n_y];
  saved_pixels = new int[n_x * n_y];
  
  for (x = 0; x < n_x; x++) {
    xs[x] = map(x, 0, n_x - 1, x_min, x_max);
  }
  
  for (y = 0; y < n_y; y++) {
    ys[y] = map(y, 0, n_y - 1, y_max, y_min);
  }
}


void draw() {
  switch (draw_state) {
    case render: {
      min_mag = Float.parseFloat("Infinity");
      max_mag = 0;
      
      for (x = 0; x < n_x; x++) {
        for (y = 0; y < n_y; y++) {
          if (Float.isFinite(reals[x][y]) && !Float.isNaN(reals[x][y]) && Float.isFinite(imags[x][y]) && !Float.isNaN(imags[x][y])) {        
            // square existing number
            new_real = pow(reals[x][y], 2) - pow(imags[x][y], 2);
            new_imag = reals[x][y] * imags[x][y] * 2;
            
            // add constant based on pixel location
            new_real += xs[x];
            new_imag += ys[y];
            
            // update arrays
            reals[x][y] = new_real;
            imags[x][y] = new_imag;      
            mags[x][y] = sqrt(pow(new_real, 2) + pow(new_imag, 2));
            
            // update min/max
            if (Float.isFinite(mags[x][y]) && !Float.isNaN(mags[x][y])) {
              min_mag = min(min_mag, mags[x][y]);
              max_mag = max(max_mag, mags[x][y]);
            }
          }
        }
      }
      
      for (x = 0; x < n_x; x++) {
        for (y = 0; y < n_y; y++) {
          if (Float.isFinite(mags[x][y]) && !Float.isNaN(mags[x][y])) {
            h = pow(mags[x][y], 0.9);
            
            set(x, y, color(h, 1.0, 1.0));
          } else {
            set(x, y, color(0.0, 0.0, 0.0));        
          }
          
          //if (mags[x][y] >= threshold) {
          //  set(x, y, color(255));
          //} else {
          //  set(x, y, color(0));
          //}
        }
      }
      
      //noLoop();
      
      break;
    } case zoom: {      
      pixels = saved_pixels;
      updatePixels();
      
      stroke(0.0, 0.0, 0.0);
      fill(0.333, 1.0, 1.0, 0.5);
      
      rect(x_drag_start, y_drag_start, mouseX - x_drag_start, mouseY - y_drag_start);
      
      break;
    } default: {
      println("Unknown draw state: " + draw_state);
      
      noLoop();
    }
  }
  
  last_draw_state = draw_state;
}


void mouseClicked() {
  println("x: " + map(mouseX, 0, n_x, x_min, x_max) + ", y: " + map(mouseY, 0, n_y, y_min, y_max));
}


void mouseDragged() {
  if (draw_state == DRAW_STATE.render) {
    x_drag_start = mouseX;
    y_drag_start = mouseY;
    
    draw_state = DRAW_STATE.zoom;
    
    loadPixels();
    saved_pixels = pixels;
  }
}


void mouseReleased() {
  if (draw_state == DRAW_STATE.zoom) {
    float x_start = map_x_px(x_drag_start);
    float y_start = map_y_px(n_y - y_drag_start);
    float x_end = map_x_px(mouseX);
    float y_end = map_y_px(n_y - mouseY);
    
    x_min = min(x_start, x_end);
    y_min = min(y_start, y_end);
    x_max = max(x_start, x_end);
    y_max = max(y_start, y_end);
    
    setup();
  }
}


void keyPressed() {
  x_min = -2;
  x_max = 0.5;
  y_min = -1;
  y_max = 1;
  
  setup();
}
