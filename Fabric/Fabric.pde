final float inf = Float.POSITIVE_INFINITY;

Node[][] nodes = null;
Link[] links = null;

float spacing_x, spacing_y, finger_diameter;

void setup() {  
  size(800, 800);
  //fullScreen();
  smooth();
  frameRate(50);
  
  setup_menu();
  
  int num_x = int(Setting.NUM_X.get());
  int num_y = int(Setting.NUM_Y.get());
  float mass = Setting.MASS.get();
  float friction = Setting.FRICTION.get();
  float stiffness = Setting.STIFFNESS.get();
  float max_tension = Setting.MAX_TENSION.get();
  
  spacing_x = float(width) / (num_x + 1);
  spacing_y = (height - menu_bar_height) / (num_y + 1);
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
    boolean exists;
    int[][] other_node_indexes = new int[6][2];
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
}

void draw() {  
  background(0);
  
  if (modifying_setting) {
    draw_modifying();
    
    return;
  }
      
  float fx, fy;
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
  }
  
  if (mousePressed) {
    float dx, dy, distance, force;
    for (Node[] column : nodes) {
      for (Node node : column) {
        if (node != null) {
          dx = node.x - mouseX;
          dy = node.y - mouseY;
          
          distance = sqrt(pow(dx, 2) + pow(dy, 2));
          
          if (0 < distance && distance < finger_diameter / 2) {
            force = Setting.FINGER_FORCE.get() * (sqrt(pow(finger_diameter / 2, 2) - pow(distance, 2)));
  
            node.fx += force * sin(dx / distance);
            node.fy += force * sin(dy / distance);
          }
        }
      }
    }
  }
  
  for (Node[] column : nodes) {
    for (Node node : column) {
      if (node != null) {
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
          if (node.y > height - menu_bar_height) {
            node.y = height - menu_bar_height;
            node.vy *= -1;
          }
        }
      }
    }
  }
  
  for (Link link : links) {
    if (link != null) {
      link.draw();
    }
  }
  
  for (Node[] column : nodes) {
    for (Node node : column) {
      if (node != null) {
        node.draw();
      }
    }
  }
  
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

void mouseDragged() {
  if (modifying_setting) {
    if (current_setting.type != SettingType.BOOL) {
      current_setting.set(mouse_setting_value());
    }
  }
}

void mousePressed() {
  if (mouseY > height - menu_bar_height) {
    current_setting = Setting.values[floor(num_settings * mouseX / width)];
    
    modifying_setting = true;
    
    if (current_setting.type == SettingType.BOOL) {
      current_setting.set(1 - current_setting.get());
    }
  }
}

void mouseReleased() {
  if (modifying_setting) {
    if (current_setting.type != SettingType.BOOL) {
      if (current_setting == Setting.RANDOM) {
        randomise_settings();
      } else {
        current_setting.set(mouse_setting_value());
      }
    }
    
    setup();
  }
}
