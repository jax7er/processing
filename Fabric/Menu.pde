enum SettingType {
  NONE,
  BOOL,
  INT,
  FLOAT
}

enum Setting {
  RESET("Reset", '⌂', SettingType.NONE, 0, 0, 0),
  BOUNDARY("Boundary", '□', SettingType.BOOL, 0, 0, 1),
  NUM_X("No. X", '↔', SettingType.INT, 50, 1, 100),
  NUM_Y("No. Y", '↕', SettingType.INT, 50, 1, 100),
  MASS("Mass", '●' , SettingType.FLOAT, 2, 1, 10),
  MAX_TENSION("Max. Tension", '≠', SettingType.FLOAT, 10, 1, 100),
  STIFFNESS("Stiffness", '▬', SettingType.FLOAT, 0.5, 0, 1),
  FRICTION("Friction", '▒', SettingType.FLOAT, 0.2, 0, 1),
  FINGER_FORCE("Finger Force", '☼', SettingType.FLOAT, 1, 0, 3),
  LINKS("Links", '┼', SettingType.BOOL, 1, 0, 1),
  RANDOM("Random", '?', SettingType.NONE, 0, 0, 0);
  
  private float _value;
  
  static Setting[] values = Setting.values();
  
  String name;
  char abbr;
  float min, max;
  SettingType type;
  
  private Setting(String _name, char _abbr, SettingType _type, float init_value, float _min, float _max) {
    this.name = _name;
    this.abbr = _abbr;
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
      case BOOL: return (_value >= 0.5) ? "On" : "Off";
      case INT: return String.format("%d", round(_value));
      case FLOAT: return String.format("%.2f", _value);
      default: return null;
    }
  }
  
  public float get() {
    switch (type) {
      case BOOL: return int(_value >= 0.5);
      case INT: return int(round(_value));
      case FLOAT: return _value;
      default: return -1;
    }
  }
  
  public void set(float value) {
    switch (type) {
      case BOOL: _value = int(value >= 0.5);
      case INT: _value = int(round(value));
      case FLOAT: _value = value;
      default: break;
    }
    
    _value = min(max(_value, this.min), this.max);
  }
}

final int num_settings = Setting.values.length;

float menu_bar_height, setting_abbr_height, setting_value_height, x, y, w, middle_x, middle_y;
boolean modifying_setting;
Setting current_setting;

PFont value_font;

void setup_menu() {
  modifying_setting = false;
  
  menu_bar_height = height / 10;
  setting_abbr_height = menu_bar_height / 3;
  setting_value_height = setting_abbr_height / 2;
  
  //printArray(PFont.list());
  //abbr_font = createFont("Webdings", setting_abbr_height);
  value_font = createFont("Courier New Bold", menu_bar_height);
}

void draw_menu() {
  y = height - menu_bar_height;
  w = width / num_settings;
  
  for (Setting setting : Setting.values) {
    x = floor(setting.index() * float(width) / num_settings);
    noFill();
    stroke(32);  
    rect(x, y, w, menu_bar_height);
    
    switch (setting.type) {
      case NONE: fill(255); break;
      case BOOL: fill((setting.get() > 0) ? color(0, 255, 0) : color(255, 0, 0)); break;
      default: fill(map(setting.get(), setting.min, setting.max, 0, 255), map(setting.get(), setting.min, setting.max, 255, 0), 0); break;
    }
    noStroke();
    textFont(value_font);
    textSize(setting_abbr_height);
    middle_x = x + w / 2;
    middle_y = y + menu_bar_height / 2;
    if (setting.type == SettingType.NONE) {
      textAlign(CENTER, CENTER);
      text(setting.abbr, middle_x, middle_y);
    } else {
      textAlign(CENTER, BOTTOM);
      text(setting.abbr, middle_x, middle_y + setting_value_height);
      
      textSize(setting_value_height);
      textAlign(CENTER, TOP);      
      text(setting.toString(), middle_x, middle_y + setting_value_height);
    }
  }
}

void draw_modifying() {
  textFont(value_font);
  textAlign(CENTER, CENTER);
  textSize(menu_bar_height / 2);

  switch (current_setting.type) {
    case NONE: fill(255); break;
    case BOOL: fill((current_setting.get() > 0) ? color(0, 255, 0) : color(255, 0, 0)); break;
    default: fill(map(current_setting.get(), current_setting.min, current_setting.max, 0, 255), map(current_setting.get(), current_setting.min, current_setting.max, 255, 0), 0); break;
  }
  noStroke();
  
  if (current_setting.type == SettingType.NONE) {
    text(current_setting.name, width / 2, height / 2);
  } else {      
    text(current_setting.name + "\n" + current_setting.toString(), width / 2, height / 2) ;
  }
}

void randomise_settings() {
  for (Setting setting : Setting.values) {
    setting.set(random(setting.min, setting.max));
  }
}

float mouse_setting_value() {
  float mapped_value = map(mouseY, height, 0, current_setting.min, current_setting.max);
  
  switch (current_setting.type) {
    case BOOL: return int(mapped_value >= 0.5);
    case INT: return round(mapped_value);
    case FLOAT: return mapped_value;
    default: return -1;
  }
}
