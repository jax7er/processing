class Link {
  Node[] nodes = null;  
  float nominal_length, max_tension, stiffness, length, tension;
  
  float h, s, b, tension_fraction;
  
  float tension_threshold = 0.01;
  
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
      pushStyle();
      colorMode(HSB, 1.0, 1.0, 1.0);
      //tension_limit = 0.01;
      //if (abs(tension_fraction) <= tension_limit) {
      //  h = 0;
      //  s = 0;
      //  b = 0;
      //} else 
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
      
      popStyle();
    }
  }
}
