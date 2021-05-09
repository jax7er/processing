import android.view.MotionEvent;

final float inf = Float.POSITIVE_INFINITY;


enum SettingType {
  NONE, BOOL, INT, FLOAT
}


enum Setting {
  RESET("Reset", "reset.png", SettingType.NONE, 0, 0, 0), 
    BOUNDARY("Boundary", "boundary.png", SettingType.BOOL, 0, 0, 1), 
    NUM_X("No. X", "num_x.png", SettingType.INT, 50, 1, 100), 
    NUM_Y("No. Y", "num_y.png", SettingType.INT, 50, 1, 100), 
    MASS("Mass", "mass.png", SettingType.FLOAT, 2, 1, 10), 
    MAX_TENSION("Max. Tension", "max_tension.png", SettingType.FLOAT, 10, 1, 100), 
    STIFFNESS("Stiffness", "stiffness.png", SettingType.FLOAT, 0.5, 0, 1), 
    FRICTION("Friction", "friction.png", SettingType.FLOAT, 0.2, 0, 1), 
    FINGER_FORCE("Force", "force.png", SettingType.FLOAT, 1, 0, 3), 
    LINKS("Links", "links.png", SettingType.BOOL, 1, 0, 1), 
    RANDOM("Random", "random.png", SettingType.NONE, 0, 0, 0);

  private float _value;

  static Setting[] values = Setting.values();

  String name, img_path;
  float min, max;
  SettingType type;

  private Setting(String _name, String _img_path, SettingType _type, float init_value, float _min, float _max) {
    this.name = _name;
    this.img_path = _img_path;
    this.type = _type;
    this.min = _min;
    this.max = _max;

    set(init_value);
  }

  public int index() {
    return this.ordinal();
  }

  public String toString() {
    switch (type) {
    case BOOL: 
      return (_value >= 0.5) ? "On" : "Off";
    case INT: 
      return String.format("%d", round(_value));
    case FLOAT: 
      return String.format("%.2f", _value);
    default: 
      return null;
    }
  }

  public float get() {
    switch (type) {
    case BOOL: 
      return int(_value >= 0.5);
    case INT: 
      return int(round(_value));
    case FLOAT: 
      return _value;
    default: 
      return -1;
    }
  }

  public void set(float value) {
    switch (type) {
    case BOOL: 
      _value = int(value >= 0.5);
    case INT: 
      _value = int(round(value));
    case FLOAT: 
      _value = value;
    default: 
      break;
    }

    _value = min(max(_value, this.min), this.max);
  }
}


final int num_settings = Setting.values.length;
PImage[] settings_images = new PImage[num_settings];

float menu_height, setting_abbr_height, setting_value_height, x, y, w, middle_x, middle_y;
float menu_top, menu_button_width;
boolean modifying_setting;
Setting current_setting;

PFont value_font;

Node[][] nodes;
Link[] links;

int action_pointer, num_pointers, pointer_id, dark_grey;
float fx, fy, dx, dy, distance, force, spacing_x, spacing_y, finger_diameter, mapped_value, centre_x, centre_y;

float[][] touches;


class Node {
  float x_origin, y_origin, x, y, vx, vy, ax, ay, fx, fy, mass, friction;

  float factor, h, s, b, diameter, speed;
  int fill_colour, stroke_colour;

  float speed_threshold = 0.2;

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
      speed = sqrt(pow(vx, 2) + pow(vy, 2));
      diameter = mass * 2;
      float amount = min(1.0, speed / 20.0);

      h = map(amount, 0, 1, 0.75, 0);
      s = 1;
      b = 1;

      //if (speed > speed_threshold) {
        shapeMode(CENTER);
        fill(h, s, b);
        noStroke();
        ellipse(x, y, diameter, diameter);
      //} else {
      //  stroke(dark_grey);
      //  noFill();
      //  ellipse(x, y, diameter, diameter);
      //}
    }
  }
}


class Link {
  Node[] nodes = null;  
  float nominal_length, max_tension, stiffness, length, tension;

  float h, s, b, tension_fraction;

  float tension_threshold = 0.1;

  Link(Node node_a, Node node_b, float _stiffness, float _max_tension) {
    if (node_a.x_origin < node_b.x_origin || node_a.y_origin < node_b.y_origin) {
      nodes = new Node[] {node_a, node_b};
    } else {
      nodes = new Node[] {node_b, node_a};
    }

    nominal_length = sqrt(pow(nodes[0].x_origin - nodes[1].x_origin, 2) + 
      pow(nodes[0].y_origin - nodes[1].y_origin, 2));

    stiffness = _stiffness;
    max_tension = _max_tension;

    length = nominal_length;
    tension = 0;
  }

  void update() {
    length = sqrt(pow(nodes[0].x - nodes[1].x, 2) + pow(nodes[0].y - nodes[1].y, 2));
    tension = (length - nominal_length) * stiffness;
  }

  void draw() {    
    tension_fraction = tension / max_tension;

    if (tension_fraction > tension_threshold) {
      if (tension_fraction >= 0) {
        h = 0;
        s = 1;
        b = tension_fraction;
      } else {
        h = 0.5;
        s = 1;
        b = min(1, -tension_fraction);
      }

      stroke(h, s, b);
      noFill();
      line(nodes[0].x, nodes[0].y, nodes[1].x, nodes[1].y);
    }
  }
}


void reset() {
  noLoop();
  
  modifying_setting = false;
  
  int num_x = int(Setting.NUM_X.get());
  int num_y = int(Setting.NUM_Y.get());
  float mass = Setting.MASS.get();
  float friction = Setting.FRICTION.get();
  float stiffness = Setting.STIFFNESS.get();
  float max_tension = Setting.MAX_TENSION.get();

  spacing_x = float(width) / (num_x + 1);
  spacing_y = (height - menu_height) / (num_y + 1);
  finger_diameter = min(spacing_x, spacing_y) * min(num_x, num_y) / 5;

  nodes = new Node[num_x + 2][num_y + 2];
  float x, y;
  for (int x_i = 0; x_i < num_x + 2; ++x_i) {    
    for (int y_i = 0; y_i < num_y + 2; ++y_i) {
      x = spacing_x * (x_i + (y_i % 2 == 0 ? 0.25f : -0.25f));
      y = spacing_y * y_i;

      float use_mass = mass;
      if (x_i == 0 || x_i == num_x + 1 || y_i == 0 || y_i == num_y + 1) {
        use_mass = inf;
      }      

      nodes[x_i][y_i] = new Node(x, y, use_mass, friction);
    }
  }

  if (Setting.LINKS.get() > 0) {
    int num_x_1 = num_x + 1;
    int num_y_1 = num_y + 1;
    int num_links = num_x_1*num_y_1 + num_x*num_y_1 + num_x_1*num_y;   
    
    links = new Link[num_links];
    int[][] link_ids = new int[num_links][4];
    
    int[][] other_node_indexes = new int[6][2];
    boolean exists;
    int link_i = 0;
    int x2_i, y2_i;
    for (int x_i = 1; x_i < num_x + 1; ++x_i) {
      for (int y_i = 1; y_i < num_y + 1; ++y_i) {      
        other_node_indexes[0][0] = x_i;
        other_node_indexes[0][1] = y_i - 1;
        other_node_indexes[1][0] = x_i;
        other_node_indexes[1][1] = y_i + 1;
        other_node_indexes[2][0] = x_i - 1;
        other_node_indexes[2][1] = y_i;
        other_node_indexes[3][0] = x_i + 1;
        other_node_indexes[3][1] = y_i;
        if (y_i % 2 == 0) {
          other_node_indexes[4][0] = x_i + 1;
          other_node_indexes[5][0] = x_i + 1;
        } else {
          other_node_indexes[4][0] = x_i - 1;
          other_node_indexes[5][0] = x_i - 1;
        }
        other_node_indexes[4][1] = y_i - 1;
        other_node_indexes[5][1] = y_i + 1;   

        for (int[] other_i : other_node_indexes) {           
          if (link_i == links.length) {
            print("links length reached:");
            print(link_i);
            break;
          }

          x2_i = other_i[0];
          y2_i = other_i[1];

          exists = false;        
          for (int[] ids : link_ids) {
            if ((ids[0] == x_i && ids[1] == y_i && ids[2] == x2_i && ids[3] == y2_i) ||
              (ids[0] == x2_i && ids[1] == y2_i && ids[2] == x_i && ids[3] == y_i)) {
              exists = true;
              break;
            }
          }

          if (!exists) {
            link_ids[link_i][0] = x_i;
            link_ids[link_i][1] = y_i;
            link_ids[link_i][2] = x2_i;
            link_ids[link_i][3] = y2_i;

            links[link_i] = new Link(nodes[x_i][y_i], nodes[x2_i][y2_i], stiffness, max_tension);

            ++link_i;
          }
        }
      }
    }
  } else {
    links = new Link[] {null};
  }
  
  loop();
}


void setup_menu() {
  menu_height = height / 10;
  setting_abbr_height = menu_height / 3;
  setting_value_height = setting_abbr_height / 2;

  menu_top = height - menu_height;
  menu_button_width = width / num_settings;
}


void draw_modifying() {
  textAlign(CENTER, CENTER);
  textSize(menu_height / 2);

  fill(setting_colour(current_setting));
  noStroke();

  if (current_setting.type == SettingType.NONE) {
    text(current_setting.name, centre_x, centre_y);
  } else {      
    text(current_setting.name + "\n" + current_setting.toString(), centre_x, centre_y) ;
  }
}


void update_draw_links() {
  for (int link_i = links.length - 1; link_i >= 0; --link_i) {
    Link link = links[link_i];

    if (link == null) {
      continue;
    }

    link.update();

    if (link.tension > link.max_tension) {
      links[link_i] = null;
      continue;
    }

    Node n1 = link.nodes[0];
    Node n2 = link.nodes[1];

    fx = link.tension * sin((n2.x - n1.x) / link.length);
    fy = link.tension * sin((n2.y - n1.y) / link.length);

    n1.fx += fx;
    n2.fx -= fx;
    n1.fy += fy;
    n2.fy -= fy;

    link.draw();
  }
}


void update_draw_nodes() {
  for (Node[] column : nodes) {
    for (Node node : column) {
      if (node != null) {
        for (float[] touch : touches) {
          if (touch[2] == -1) {
            continue;
          }

          dx = node.x - touch[0];
          dy = node.y - touch[1];

          distance = sqrt(pow(dx, 2) + pow(dy, 2));

          if (0 < distance && distance < finger_diameter / 2) {
            force = Setting.FINGER_FORCE.get() * (sqrt(pow(finger_diameter / 2, 2) - pow(distance, 2)));

            node.fx += force * sin(dx / distance);
            node.fy += force * sin(dy / distance);
          }
        }

        node.update();

        if (Setting.BOUNDARY.get() > 0) {
          if (node.x < 0) {
            node.x = 0;
            node.vx *= -1;
          }
          if (node.x > width) {
            node.x = width;
            node.vx *= -1;
          }
          if (node.y < 0) {
            node.y = 0;
            node.vy *= -1;
          }
          if (node.y > menu_top) {
            node.y = menu_top;
            node.vy *= -1;
          }
        }

        node.draw();
      }
    }
  }
}


void draw_menu() {
  for (Setting setting : Setting.values) {
    x = floor(setting.index() * menu_button_width);

    //noFill();
    //stroke(dark_grey);  
    //rect(x, menu_top, menu_button_width, menu_height);

    fill(setting_colour(setting));
    noStroke();
    textSize(setting_abbr_height);
    middle_x = x + menu_button_width / 2;
    middle_y = menu_top + menu_height / 2;
    
    if (setting.type == SettingType.NONE) {
      //textAlign(CENTER, CENTER);
      //text(setting.abbr, middle_x, middle_y);
      image(settings_images[setting.index()], middle_x, middle_y);
    } else {
      //textAlign(CENTER, BOTTOM);
      //text(setting.abbr, middle_x, middle_y + setting_value_height);
      image(settings_images[setting.index()], middle_x, middle_y - setting_value_height);

      textSize(setting_value_height);
      textAlign(CENTER, TOP);      
      text(setting.toString(), middle_x, middle_y + setting_value_height);
    }
  }
}


void randomise_settings() {
  for (Setting setting : Setting.values) {
    setting.set(random(setting.min, setting.max));
  }
}


float mouse_setting_value() {
  mapped_value = map(touches[action_pointer][1], height, 0, current_setting.min, current_setting.max);

  switch (current_setting.type) {
  case BOOL: 
    return int(mapped_value >= 0.5);
  case INT: 
    return round(mapped_value);
  case FLOAT: 
    return mapped_value;
  default: 
    return -1;
  }
}


int setting_colour(Setting setting) {  
  switch (setting.type) {
  case NONE:
    return color(0, 0, 1);
  case BOOL: 
    return color((setting.get() > 0) ? 0.333 : 0, 1, 1);
  default:
    return color(map(setting.get(), setting.min, setting.max, 0.333, 0), 1, 1);
  }
}


// adapted from https://stackoverflow.com/questions/17166522/can-processing-handle-multi-touch
public boolean surfaceTouchEvent(MotionEvent event) {
  num_pointers = event.getPointerCount();

  for (int i = 0; i < num_pointers; i++) {
    pointer_id = event.getPointerId(i);
    touches[pointer_id][0] = event.getX(i); 
    touches[pointer_id][1] = event.getY(i);
  }

  action_pointer = event.getPointerId(event.getActionIndex());

  switch (event.getActionMasked()) {
  case 0: // ACTION_DOWN 
  case 5: // ACTION_POINTER_DOWN
    touches[action_pointer][2] = action_pointer;

    if (touches[action_pointer][1] > height - menu_height) {
      modifying_setting = true;

      current_setting = Setting.values[floor(num_settings * touches[action_pointer][0] / width)];

      if (current_setting.type == SettingType.BOOL) {
        current_setting.set(1 - current_setting.get());
      }
    }

    break;
  case 2: // ACTION_MOVED
    if (modifying_setting) {
      if (current_setting.type != SettingType.BOOL && current_setting.type != SettingType.NONE) {
        current_setting.set(mouse_setting_value());
      }
    }
    break;
  case 1: // ACTION_UP 
  case 3: // ACTION_CANCEL
  case 6: // ACTION_POINTER_UP
    touches[action_pointer][2] = -1;

    if (modifying_setting) {
      switch (current_setting) {
        case RANDOM:
          randomise_settings();
          // allow fallthrough
        case BOUNDARY:
        case LINKS:
        case NUM_X:
        case NUM_Y:
        case RESET:
          reset();
          break;
        case MASS:        
          float mass = Setting.MASS.get();
          
          for (int x = 0; x < Setting.NUM_X.get(); ++x) {
            for (int y = 0; y < Setting.NUM_Y.get(); ++y) {
              nodes[x][y].mass = mass;
            }
          }
          
          break;
        case FRICTION:              
          float friction = Setting.FRICTION.get();
          
          for (int x = 0; x < Setting.NUM_X.get(); ++x) {
            for (int y = 0; y < Setting.NUM_Y.get(); ++y) {
              nodes[x][y].friction = friction;
            }
          }
          
          break;
        case STIFFNESS:              
          float stiffness = Setting.STIFFNESS.get();
          
          for (int i = 0; i < links.length; ++i) {
            if (links[i] != null) {
              links[i].stiffness = stiffness;
            }
          }
          
          break;
        case MAX_TENSION:              
          float max_tension = Setting.MAX_TENSION.get();
          
          for (int i = 0; i < links.length; ++i) {
            if (links[i] != null) {
              links[i].max_tension = max_tension;
            }
          }
          
          break;
        default:
          break;
      }
      
      modifying_setting = false;
    }

    break;
  }

  return super.surfaceTouchEvent(event);
}


void setup() {      
  //size(300, 300);
  fullScreen();
  //smooth();
  frameRate(50);
  
  for (int i = 0; i < num_settings; i++) {
    settings_images[i] = loadImage(Setting.values[i].img_path);
    
    settings_images[i].filter(INVERT);
    
    settings_images[i].mask(settings_images[i]);
    
    settings_images[i].resize(width / num_settings, 0);
  }
  
  imageMode(CENTER);
  
  centre_x = width / 2;
  centre_y = height / 2;

  // hue, saturation, brightness, alpha, 0.0-1.0
  colorMode(HSB, 1.0, 1.0, 1.0, 1.0);
  dark_grey = color(0, 0, 0.2);

  // 10 touches max, store x pos, y pos, and id (-1 up, >-1 down)
  touches = new float[10][3];
  for (float[] touch : touches) {
    touch[2] = -1;
  }

  setup_menu();

  reset();
}


void draw() {  
  background(0);

  if (modifying_setting) {
    draw_modifying();

    return;
  }

  update_draw_links();

  update_draw_nodes();

  draw_menu();

  //for (float[] touch : touches) {
  //  if (touch[2] != -1) {
  //    shapeMode(CENTER);
  //    fill(0, 255, 255);
  //    stroke(0, 255, 255);
  //    ellipse(touch[0], touch[1], finger_diameter, finger_diameter);
  //    text(touch[2], touch[0], touch[1] - 200);
  //  }
  //}
}
