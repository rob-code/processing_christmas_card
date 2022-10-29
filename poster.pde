/*
This sketch takes a still image from a video and your name.
 It creates a new image drawn using the characters returned from a google search of your name.
 
 NOTES:
 
 **GOOGLE CUSTOM SEARCH**
 Googe Custom Search:
 https://developers.google.com/custom-search
 
 Key:
 AIzaSyA6qGlgjFOpuo1IQLMGjWYyVNoCFa01Wuc
 
 Context:
 96192268198954011
 
 Spaces between search terms are encoded as %20
 
 **VIDEO**
 https://github.com/processing/processing-video/issues/199
 width and height must correspond to the camera
 - 640 x 480 - works
 - 1280 x 960 - doesnt work
 - 1920 x 1080 - works and gives the best resolution for this mac
 
 
 **TODOs**
 - link the words to the image
  
 nice to haves:
 - improve google search by underdstanding search paramaters
 - improve image processing to alter image
 
 */

import processing.video.*;

//video variables
Capture video;
PImage img;

//Search Strings
PFont f;
String typing = "";
String [] json;
String text_result = "";
boolean enter_pressed = false;

void setup() {
  size(1000, 750);
  f = createFont("Helvetica Neue", 22);
  textFont(f);
  fill(250);

  video = new Capture(this, "pipeline:avfvideosrc device-index=0 ! video/x-raw, width=1920, height=1080, framerate=30/1");
  video.start();
}

void draw() {

  if (enter_pressed) {

    createImage();
  } else {

    if (video.available()) {
      video.read();
      image(video, 0, 0, width, height);
    }

    fill(0);
    rect(0, height - 70, width, height);
    fill(255);
    text("Set your pose and type your name. Press enter to start:", 10, height - 30);
    text(typing, (width/2) + 75, height - 30);
  }
}


void createImage() {

  /******* Set option value to generate different image types:
   option = 1: posterize filter
   option = 2: greyscale dots
   option = 3: words from google search results sized in proportion to greyscale 
   
   int sample changes the sampling size of the pixels
   *******/

  int option = 2;
  int sample = 5;

  img = video;

  //white rectangle background
  fill(255);
  rect(0, 0, width, height);

  //must assign all int values to floats to get correct arithmetic
  float w = width;
  float h = height;
  float img_w = img.width;
  float img_h = img.height;
  float scaleX = w/img_w;
  float scaleY = h/img_h;

  switch (option) {

  case 1:
    img.resize(width, 0);
    image(img, 0, 0);
    filter(POSTERIZE, 4);
    break;

  case 2 :
    for (int x = sample; x < img.width; x+=sample) {
      for (int y = sample; y < img.height; y+=sample) {

        //adjust the scale of the drawn image to fit the window
        float coordX = x * scaleX;
        float coordY = y * scaleY;

        img.loadPixels();
        var c = color(img.get(x, y));
        var greyScale = round(red(c)*0.222 + green(c)*.707 + blue(c)*0.071);
        fill(greyScale);
        noStroke();
        ellipse(coordX, coordY, sample, sample);
      }
    }
    break;

  case 3 :
    for (int x = sample; x < img.width; x+=sample) {
      for (int y = sample; y < img.height; y+=sample) {

        //adjust the scale of the drawn image to fit the window
        float coordX = x * scaleX;
        float coordY = y * scaleY;

        img.loadPixels();
        var c = color(img.get(x, y));
        var greyScale = round(red(c)*0.222 + green(c)*.707 + blue(c)*0.071);
        fill(greyScale);
        noStroke();
        
        
       // text_result;
      }
    }



    break;
  }

  noLoop();
}


void keyPressed() {

  if (key == ENTER || key == RETURN ) {

    enter_pressed = !enter_pressed;
    println("search term is = " + typing);
    typing = typing.trim();
    String search_term = typing.replaceAll(" ", "%20");
    String search_url = "https://www.googleapis.com/customsearch/v1?key=AIzaSyA6qGlgjFOpuo1IQLMGjWYyVNoCFa01Wuc&cx=96192268198954011&q=" + search_term;

    try {
      json = loadStrings(search_url);
    }
    catch (Exception e) {
      e.printStackTrace();
      json = null;
    }

    if (json == null) {
      println("default to stored json string - TODO");
    } else {

      for (String s : json) {
        text_result = text_result + s;
        text_result = text_result.replaceAll(" ", "");
      }

      println(text_result);
      println(text_result.length());
    }
  } else if (key == DELETE || key == BACKSPACE ) {
    if ( !(typing.length() == 0)) {
      typing = typing.substring(0, typing.length()-1);
    }
  } else {
    if ( (keyCode >= 65 && keyCode <= 90) || (keyCode >= 48 && keyCode <= 57)) {
      typing = typing + key;
    } else if (keyCode == 32) {
      typing = typing + key;
    }
  }
}
