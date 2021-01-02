import processing.pdf.*;

String IMAGE = "cjjqmo_800.jpg";
float MARGINS = 0.1;
int BLOCKS_W = 96;
boolean OUTLINES = false;
int BLOCKS_H;
int BLOCK_SIZE;
int GREYS;

PImage input;
float ratio;
PImage scaled;

int contrast_min = 10000;
int contrast_max = -10000;
int[] pix = {};

int lines = 0;

PImage scaleImage (String imagePath, int imageWidth, int imageHeight, String mode) {
  PImage input = loadImage(imagePath);
  float inputRatio = (float) input.width / (float) input.height;
  float outputRatio = (float) imageWidth / (float) imageHeight;
  
  int outputWidth = imageWidth;
  int outputHeight = imageHeight;
  
  float outputScaledHeight;
  float outputScaledWidth;
  
  //used for cropping
  int offsetHeight = 0;
  int offsetWidth = 0;
  PImage output;
  
  if (mode == "fit") {
    if (outputRatio <= inputRatio) {
      input.resize(outputWidth, 0);
    } else if (outputRatio > inputRatio) {
      input.resize(0, outputHeight);
    }
    output = input;
  } else if (mode == "fill") {
    if (outputRatio < inputRatio) {
      outputScaledWidth = imageWidth * inputRatio;
      offsetWidth = round( (outputScaledWidth - outputWidth) / 2 );
      input.resize(0, outputHeight);
    } else if (outputRatio > inputRatio) {
      outputScaledHeight = (imageWidth / inputRatio);
      offsetHeight = round( (outputScaledHeight - outputHeight) / 2 );
      input.resize(outputWidth, 0);
    }
    output = input.get(offsetWidth, offsetHeight, outputWidth, outputHeight);
  } else {
    input.resize(outputWidth, outputHeight);
    output = input;
  }
  
  return output;
}

boolean inArray (int[] arr, int val) {
  boolean found = false;
  for (int i = 0; i < arr.length; i++) {
    if (arr[i] == val) {
      found = true;
      break;
    }
  }
  return found;
}

void getContrast () {
  //slow method
  color c;
  int bright;
  for (int x = 0; x < scaled.width; x++) {
    for (int y = 0; y < scaled.height; y++) {
      c = scaled.get(x, y);
      bright = round(brightness(c));
      if (bright > contrast_max) {
        contrast_max = bright;
      }
      if (bright < contrast_min) {
        contrast_min = bright;
      }
    }
  }
}

void preMakeBlocks () {
  for (int i = 0; i < GREYS; i++) {
    
  }
}

void drawBlock (int x, int y, int val) {
  //fill(round(map(val, 0, GREYS, 0, 255)));
  //rect(x * BLOCK_SIZE, y * BLOCK_SIZE, BLOCK_SIZE, BLOCK_SIZE);

  int start_x = x * BLOCK_SIZE + round(MARGINS * width);
  int start_y = y * BLOCK_SIZE + round(MARGINS * height);
  int[] used = new int[GREYS - val];
  int pos = 0;
  boolean found = false;
  //rect(start_x, start_y, BLOCK_SIZE, BLOCK_SIZE);
  if (OUTLINES) {
    line(start_x, start_y, start_x, start_y + BLOCK_SIZE);
    lines++;
    line(start_x, start_y, start_x + BLOCK_SIZE, start_y);
    lines++;
    if (x == scaled.width - 1) {
      line(start_x + BLOCK_SIZE, start_y, start_x + BLOCK_SIZE, start_y + BLOCK_SIZE);
      lines++;
    }
    if (y == scaled.height - 1) {
      line(start_x, start_y + BLOCK_SIZE, start_x + BLOCK_SIZE, start_y + BLOCK_SIZE);
      lines++;
    }
  }
  for (int i = 0; i < GREYS - val; i++) {
    while (!found) {
      pos = round(random(0, GREYS));
      if (!inArray(used, pos)) {
        used[i] = pos;
        found = true;
      }
    }
    found = false;
    line(start_x, start_y + pos, start_x + BLOCK_SIZE, start_y + pos);
    lines++;
  }

}

void drawWithComputer () {
  color c;
  int bright;
  int val;
  for (int x = 0; x < scaled.width; x++) {
    for (int y = 0; y < scaled.height; y++) {
      c = scaled.get(x, y);
      bright = round(brightness(c));
      val = round(map(bright, contrast_min, contrast_max, 0, GREYS));
      drawBlock(x, y, val);
    }
  }
}

void setup () {
	//A3, landscape, 72dpi
	size(1184, 846, PDF, "A001_drawing_with_computers.pdf");
  randomSeed(0);
	background(255);
	input = loadImage(IMAGE);
	ratio = input.width / input.height;
	BLOCKS_H = round(BLOCKS_W * ratio);
  BLOCK_SIZE = floor((width - (width * MARGINS * 2)) / BLOCKS_W);
  GREYS = BLOCK_SIZE;
	scaled = scaleImage(IMAGE, BLOCKS_W, BLOCKS_H, "fit");
  getContrast();
  stroke(0);
  println("BLOCK_SIZE ", BLOCK_SIZE);
}

void draw () {
  drawWithComputer();
  println("LINES ", lines);
	exit();
}