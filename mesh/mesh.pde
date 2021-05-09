class Node {
  float x, y, r;
  int colour;
  ArrayList<Link> links;
  
  Node(float _x, float _y, float _r, int _colour, ArrayList<Link> _links) {
    x = _x;
    y = _y;
    r = _r;
    colour = _colour;
    links = _links;
  }
  
  Node(Node n) {
    this(n.x, n.y, n.r, n.colour, n.links);
  }
  
  Node(float _x, float _y, int _colour) {
    this(_x, _y, 10, _colour, new ArrayList<Link>());
  }
  
  Node(float _x, float _y) {
    this(_x, _y, 10, color(255, 255, 255), new ArrayList<Link>());
  }
  
  Node() {
    this(0, 0);
  }
}

class Link {
  float strength;
  Node[] nodes;
  
  Link(float _strength, Node[] _nodes) {
    strength = _strength;
    nodes = _nodes;
  }
  
  Link(float _strength, Node n1, Node n2) {
    this(_strength, new Node[] {n1, n2});
  }
  
  Link(Node n1, Node n2) {
    this(10, new Node[] {n1, n2});
  }
}

int numNodes = 0;
int linksPerNode = 3;
float repelRadius = 100;
float largestDimension;
boolean mouseDown = false, prevMouseDown = false;
ArrayList<Node> nodes = new ArrayList<Node>();

void settings() {
  //size(displayWidth / 2, displayHeight / 2);
  fullScreen();
  largestDimension = width > height ? width : height;
  smooth();
}

void setup() {
  frameRate(30);
}

void draw() {
  clear();
  
  if (mouseDown) {
    if (mouseButton == LEFT) {
      numNodes++;
    } else if (mouseButton == RIGHT) {
      numNodes = max(numNodes - 1, 0);
    }
  }
  
  if (nodes.size() != numNodes) {
    Node node;
    if (numNodes > nodes.size()) {
      while (numNodes > nodes.size()) {
        node = new Node(
          mouseX, 
          mouseY, 
          color(255 * abs(sin(frameCount)), 255 * abs(sin(1.333 * frameCount)), 255 * abs(sin(1.667 * frameCount)))
        );
        nodes.add(node);
        
        if (mouseDown && prevMouseDown) {
          Link newLink;
          for (int i = 0; i < linksPerNode; i++) {
            if (i < nodes.size() - 1) {
              newLink = new Link(node, nodes.get(nodes.size() - 2 - i));
              node.links.add(newLink);
            } else {
              break;
            }
          }
        }
      }
    } else {
      while (numNodes < nodes.size()) {
        nodes.remove(nodes.size() - 1);
      }
    }
  }
  
  float x, y, r;
  ArrayList<Node> nudgedNodes = new ArrayList<Node>();
  for (Node n : nodes) {
    r = max(1, sqrt(pow(mouseX - n.x, 2) + pow(mouseY - n.y, 2)));
    x = n.x - repelRadius * (mouseX - n.x) / pow(r, 1.5);
    y = n.y - repelRadius * (mouseY - n.y) / pow(r, 1.5);
    nudgedNodes.add(new Node(x, y, n.r, n.colour, n.links));
  }
  ArrayList<Link> nudgedLinks = new ArrayList<Link>();
  boolean duplicateLink = false;
  for (Node n : nudgedNodes) {
    for (Link l : n.links) {
      duplicateLink = false;
      
      for (Link nl : nudgedLinks) {
        duplicateLink = 
          nl.nodes[0] == l.nodes[0] && nl.nodes[1] == l.nodes[1] ||
          nl.nodes[0] == l.nodes[1] && nl.nodes[1] == l.nodes[0];
      }
      
      if (!duplicateLink) {
        nudgedLinks.add(new Link(
            nudgedNodes.get(nodes.indexOf(l.nodes[0])), 
            nudgedNodes.get(nodes.indexOf(l.nodes[1]))
        ));
      }
    }
  }
  noStroke();
  for (Node n : nudgedNodes) {
    fill(n.colour);
    ellipse(n.x, n.y, n.r, n.r);
  }
  for (Link l : nudgedLinks) {
    stroke(258 * (0.5 + (1 - sqrt(pow(l.nodes[1].x - l.nodes[0].x, 2) + pow(l.nodes[1].y - l.nodes[0].y, 2)) / largestDimension / 2)));
    line(l.nodes[0].x, l.nodes[0].y, l.nodes[1].x, l.nodes[1].y);
  }
  
  prevMouseDown = mouseDown;
}

void mousePressed() {
  mouseDown = true;
}

void mouseReleased() {
  mouseDown = false;
}
