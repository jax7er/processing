//import android.view.MotionEvent;

//float[][] touches = null;

//void setup() {  
//  // 10 touches max, store x pos, y pos, and id (-1 up, >-1 down)
//  touches = new float[10][3];
//  for (float[] touch : touches) {
//    touch[2] = -1;
//  }
//}

//void draw() {
//  for (float[] touch : touches) {
//    if (touch[2] == -1) {
//      continue;
//    }
    
//    for (Node[] column : nodes) {
//      for (Node node : column) {
//        if (node != null) {
//          dx = node.x - touch[0];
//          dy = node.y - touch[1];
          
//          distance = sqrt(pow(dx, 2) + pow(dy, 2));
          
//          if (0 < distance && distance < finger_diameter / 2) {
//            force = Setting.FINGER_FORCE.value * (sqrt(pow(finger_diameter / 2, 2) - pow(distance, 2)));
  
//            node.fx += force * sin(dx / distance);
//            node.fy += force * sin(dy / distance);
//          }
//        }
//      }
//    }
//  }
//}

//// adapted from https://stackoverflow.com/questions/17166522/can-processing-handle-multi-touch
//public boolean surfaceTouchEvent(MotionEvent event) {
//  //if (event.getActionMasked() != 2) { // ACTION_MOVED
//  //  print(MotionEvent.actionToString(event.getAction()));
//  //}
  
//  int num_pointers = event.getPointerCount();
  
//  for (int i = 0; i < num_pointers; i++) {
//    int pointer_id = event.getPointerId(i);
//    touches[pointer_id][0] = event.getX(i); 
//    touches[pointer_id][1] = event.getY(i);
//  }
  
//  int action_pointer = event.getPointerId(event.getActionIndex());

//  switch (event.getActionMasked()) {
//    case 0: // ACTION_DOWN 
//    case 5: // ACTION_POINTER_DOWN
//      touches[action_pointer][2] = action_pointer;
      
//      if (touches[0][1] > height - menu_bar_height) {
//        modifying_setting = true;
//        current_setting = Setting.values[floor(num_settings * touches[0][0] / width)];
//      }
      
//      break;
//    case 1: // ACTION_UP 
//    case 3: // ACTION_CANCEL
//    case 6: // ACTION_POINTER_UP
//      touches[action_pointer][2] = -1;
      
//      if (modifying_setting) {
//        if (current_setting == Setting.RANDOM) {
//          randomise_settings();
//        } else if (current_setting != Setting.RESET) {
//          current_setting.value = map(mouseY, height, 0, current_setting.min, current_setting.max);
//        }
        
//        setup();        
        
//        modifying_setting = false;
//      }
      
//      break;
//  }

//  return super.surfaceTouchEvent(event);
//}
