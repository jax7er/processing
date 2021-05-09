import grafica.*;
import processing.serial.*;

int maxPoints = 10;
boolean showAllPoints = false;
boolean drawEnable = true;

class GData {
  GPlot plot;
  GPointsArray points;
  int numPoints;
  boolean fixedYLimits = false;
  float yMin;
  float yMax;
  
  GData(GPlot _plot, GPointsArray _points, float _yMin, float _yMax) {
    this( _plot, _points);
    fixedYLimits = true;
    yMin = _yMin;
    yMax = _yMax;
  }
  
  GData(GPlot _plot, GPointsArray _points) {
    plot = _plot;
    points = _points;
    numPoints = 0;
    plot.setBgColor(0);
    plot.setBoxBgColor(0);
    plot.setBoxLineColor(255);
    plot.setGridLineColor(64);
    plot.setPointColor(255);
    plot.setLineColor(255);
    plot.setAllFontProperties("CMU Sans Serif", 255, 16);
    plot.getTitle().setFontProperties("CMU Serif", 255, 20);
  }  

  void updatePlot() {
    //if (numPoints >= maxPoints) {
    //  points.remove(0);
    //}      
    points.add(numPoints, float(data));
    numPoints++;
          
    plot.setPoints(points);
    
    if (showAllPoints || numPoints <= maxPoints) {
      plot.setXLim(0, numPoints - 1);
    } else {
      plot.setXLim(numPoints - maxPoints, numPoints - 1);    
    }
    
    if (fixedYLimits) {
      plot.setYLim(yMin, yMax);   
    }
  
    if (drawEnable) {
      plot.beginDraw();
      plot.drawBackground();
      plot.drawGridLines(GPlot.BOTH);
      plot.drawXAxis();
      plot.drawYAxis();
      plot.drawTitle();
      plot.drawLabels();
      plot.drawPoints();
      plot.drawLines();
      plot.endDraw();
    }
  }
  
  void clear() {
    for (int i = numPoints - 1; i >= 0; i--) {
      points.remove(i);
    }
    numPoints = 0;
  }
}

// The serial port:
Serial myPort;
GData dataSeq, dataAdc, dataTemp, dataRh;

char id = 255;
String data = "";

void setup() {  
  //size(1600, 800);
  fullScreen();
  frameRate(30);

  // Create a new plot and set its position on the screen
  dataSeq = new GData(new GPlot(this, 0, 0, width / 2, height / 2), new GPointsArray(), 0, 255);
  dataAdc = new GData(new GPlot(this, width / 2, 0, width / 2, height / 2), new GPointsArray(), 0, 3.3);
  dataTemp = new GData(new GPlot(this, 0, height / 2, width / 2, height / 2), new GPointsArray(), 20, 40);
  dataRh = new GData(new GPlot(this, width / 2, height / 2, width / 2, height / 2), new GPointsArray(), 0, 100);

  // Set the plot title and the axis labels
  dataSeq.plot.setTitleText("Sequence Number");
  dataSeq.plot.getYAxis().setAxisLabelText("Number");  
  dataAdc.plot.setTitleText("ADC");
  dataAdc.plot.getYAxis().setAxisLabelText("Voltage (V)");  
  dataTemp.plot.setTitleText("Sensor 1 - Temperature");
  dataTemp.plot.getYAxis().setAxisLabelText("Temperature (°C)");  
  dataRh.plot.setTitleText("Sensor 2 - Relative Humidity");
  dataRh.plot.getYAxis().setAxisLabelText("RH (%)");  
  
  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[1], 115200);
  
  // wait for start of element
  waitForChar('|');
}

void draw() {  
  // wait for beginning of new transmission
  id = 255;
  do {
    data = waitForChar(':');
    if (data.length() > 0) {
      id = data.charAt(data.length() - 1);
    }
  } while (id != 'n');
    
  // wait for data
  data = waitForChar('|');
  dataSeq.updatePlot();
  
  waitForChar(':');
  data = waitForChar('|');
  data = "" + ((float(data) * 3.3) / 4095);
  dataAdc.updatePlot();
  
  waitForChar(':');
  data = waitForChar('|');
  if (float(data) > 100.0) data = "100";
  dataRh.updatePlot();
  
  waitForChar(':');
  data = waitForChar('|');
  dataTemp.updatePlot();
  
  //switch (id) {
  //  case 'n':
  //    //print("seq = ");
  //    dataSeq.updatePlot();
  //    break;
  //  case 'a':
  //    //print("adc = ");
  //    data = "" + ((float(data) * 3.3) / 4095);
  //    dataAdc.updatePlot();
  //    break;
  //  case 't':
  //    //print("temp = ");
  //    dataTemp.updatePlot();
  //    break;
  //  case 'h':
  //    //print("rh = ");
  //    dataRh.updatePlot();
  //    break;
  //  case 's':
  //    //print("str = ");
  //    break;
  //  default:
  //    //print("??? = ");
  //}
  
  //println(myPort.available());
  
  //if (myPort.available() > 100) {
    myPort.clear();
  //}
  
  if (showAllPoints) {
    text("All", width / 2, height / 2);
  } else {
    text(maxPoints, width / 2, height / 2);
  }
}

String waitForChar(char c) {
  char rx = 0;
  String data = "";
  do {
    while (myPort.available() > 0) {
      rx = myPort.readChar();
      if (rx == c) {
        return data;
      } else {
        data += rx;
      }
    }
    delay(1);
  } while (true);
}

void keyPressed() {
  if (keyCode == SHIFT) {
    dataSeq.clear();
    dataAdc.clear();
    dataTemp.clear();
    dataRh.clear();
    println("Data cleared");
    return;
  } else if (keyCode == UP) {
    maxPoints += 10;
  } else if (keyCode == RIGHT) {
    maxPoints += 1;
  } else if (keyCode == DOWN) {
    if (maxPoints > 11) maxPoints -= 10;
  } else if (keyCode == LEFT) {
    if (maxPoints > 2) maxPoints -= 1;
  } else if (key == ' ') {
    drawEnable = !drawEnable;
    println("Drawing " + (drawEnable ? "Enabled" : "Disabled"));
    return;
  } else if (key == 'a' || key == 'A') {
    showAllPoints = !showAllPoints;
  } else if (key == 'r' || key == 'R') {
    maxPoints = 10;
    showAllPoints = false;
  }
  
  println("Max Points = " + maxPoints);
}