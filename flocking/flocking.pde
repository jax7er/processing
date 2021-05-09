int n_birds = 1000;
float repel_r = 500;


class Bird {
  float r;
  PVector pos;
  PVector vel;
  PVector acc;
  int fill;
  int stroke;
  PShape shape;

  Bird(float r, PVector pos, PVector vel, PVector acc, int fill, int stroke) {
    this.r = r;
    this.pos = pos;
    this.vel = vel;
    this.acc = acc;
    this.fill = fill;
    this.stroke = stroke;
    this.shape = createShape();
    this.shape.beginShape();
    this.shape.vertex(this.r / 2, 0);
    this.shape.vertex(-this.r / 2, this.r / 2);
    this.shape.vertex(-this.r / 4, 0);
    this.shape.vertex(-this.r / 2, -this.r / 2);
    this.shape.endShape(CLOSE);
    this.shape.setFill(this.fill);
    this.shape.setStroke(this.stroke);
  }

  void update(float friction) {
    this.vel.add(this.acc);
    this.vel.mult(1 - friction);
    this.pos.add(this.vel);

    //# if this.pos.x < 0:
    //#     this.pos.x += width
    //# elif this.pos.x > width:
    //#     this.pos.x -= width        
    //# if this.pos.y < 0:
    //#     this.pos.y += height
    //# elif this.pos.y > height:
    //    # this.pos.y -= height
  }

  void draw() {
    this.shape.resetMatrix();
    this.shape.rotate(this.vel.heading());
    //# circle(this.pos.x, this.pos.y, this.r)
    //# stroke(255, 0, 0)
    //# line(this.pos.x, this.pos.y, this.pos.x + 10 * this.acc.x, this.pos.y + 10 * this.acc.y)
    //# stroke(255, 255, 0)
    //# line(this.pos.x, this.pos.y, this.pos.x + 2 * this.vel.x, this.pos.y + 2 * this.vel.y)
    shape(this.shape, this.pos.x, this.pos.y);
    //noFill();
    //stroke(255, 0, 0);
    //circle(this.pos.x, this.pos.y, repel_r);
  }
}


Bird[] birds;


void setup() {
  // size(1000, 750);
  frameRate(30);
  fullScreen();

  birds = new Bird[n_birds];
  for (int i = 0; i < n_birds; i++) {
    birds[i] = new Bird(20, new PVector(width / 2, height / 2), new PVector(), new PVector(), color(random(128) + 127, random(128) + 127, random(128) + 127), color(0));
  }
}


PVector get_force(Bird bird, PVector to, float mass) {
  PVector diff = to.copy().sub(bird.pos);
  float dist = diff.mag();

  if (dist == 0) {
    return bird.vel.copy().normalize().mult(mass).mult(repel_r);
  } else if (dist > repel_r) {
    return diff.mult(mass);
  } else {
    return diff.normalize().mult(-1).mult(mass).mult(repel_r - dist);
  }
}


void draw() {
  background(0);
  
  PVector target = PVector.fromAngle(TWO_PI * frameCount / 300);
  target.mult(height / 3).add(new PVector(width / 2, height / 2));
  
  fill(255, 255, 255);
  circle(target.x, target.y, 20);

  for (Bird bird : birds) {
    bird.acc = new PVector();

    for (Bird other_bird : birds) {
      if (bird != other_bird) {
        bird.acc.add(get_force(bird, other_bird.pos, other_bird.r));
      }
    }
    
    bird.acc.add(get_force(bird, target, n_birds));

    //bird.acc.add(get_acc(bird, new PVector(0 - bird.pos.x, 0 - bird.pos.y), n_birds));
    //bird.acc.add(get_acc(bird, new PVector(0 - bird.pos.x, height - bird.pos.y), n_birds));
    //bird.acc.add(get_acc(bird, new PVector(width - bird.pos.x, 0 - bird.pos.y), n_birds));
    //bird.acc.add(get_acc(bird, new PVector(width - bird.pos.x, height - bird.pos.y), n_birds));
    
    bird.acc.div(1000 * bird.r * n_birds);

    bird.update(0.001);
    bird.draw();
    
    //println(bird.acc);
  }
  
  //noLoop();
}

void mousePressed() {
  loop();
}
