/*
This sketch converts a still image to a google search footprint image
 It creates a new image drawn using the characters returned from a google search of your name.
 

 
 **GOOGLE CUSTOM SEARCH**
 Googe Custom Search:
 https://developers.google.com/custom-search
 Spaces between search terms are encoded as %20
 
 **VIDEO**
 https://github.com/processing/processing-video/issues/199
 width and height must correspond to the camera
 - 640 x 480 - works
 - 1280 x 960 - doesnt work
 - 1920 x 1080 - works and gives the best resolution for this mac
 
 */


PImage img;
PFont f;
String typing = "";
//String [] json;
JSONObject json;
String search_result = "";
boolean enter_pressed = false;

void setup() {

  size(1000, 667);
  img = loadImage("reindeer.jpg");
  image(img, 0, 0);
  f = createFont("Helvetica Neue", 22);
  textFont(f);
}

void draw() {

  if (enter_pressed) {
    createImage();
  } else {
    fill(0);
    rect(0, height - 70, width, height);
    fill(255);
    text("Type name and press enter to start:", 10, height - 30);
    text(typing, (width/2) + 75, height - 30);
  }
}


void createImage() {

  /******* Set image_option value to generate different image types:
   option = 1: posterize filter
   option = 2: greyscale dots
   option = 3: words from google search results sized in proportion to greyscale
   
   int sample changes the sampling size of the pixels
   *******/

  int image_option = 3;

  /* Tuning the image:
   - sample: the number of pixels between each sampled pixels
   - base_text_size: the base text size in pixels
   - text size modulation factor: set to 1 and the text size is constant. Its just the color which varies.
   text size modulation is taken from the greyscale average of the colour. The text size is shrunk and enlarged around the base text size depending on the departure from the
   midpoint of greyscale which is 127
   */


  int sample = 8;
  float base_text_size = 1.5 * sample;
  float text_size_modulation_factor = 50;


  //white background
  fill(255);
  rect(0, 0, width, height);

  //must assign all int values to floats to get correct arithmetic
  float w = width;
  float h = height;
  float img_w = img.width;
  float img_h = img.height;
  float scaleX = w/img_w;
  float scaleY = h/img_h;

  switch (image_option) {

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
    int character_count = 0;
    textAlign(CENTER);
    noStroke();

    for (int y = sample; y < img.height; y+=sample) {
      for (int x = sample; x < img.width; x+=sample) {

        //adjust the scale of the drawn image to fit the window
        float coordX = x * scaleX;
        float coordY = y * scaleY;

        img.loadPixels();

        var c = color(img.get(x, y));
        fill(c);

        //greyscale is a number between 0 and 255
        var greyScale = round(red(c)*0.222 + green(c)*.707 + blue(c)*0.071);
        //fill(greyScale);

        float size_adjust = (greyScale - 127)/text_size_modulation_factor;
        textSize((base_text_size - size_adjust));

        if (character_count < search_result.length()) {
          text(search_result.charAt(character_count), coordX, coordY);
          character_count++;
        } else {
          character_count = 0;
        }
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
      json = loadJSONObject(search_url);
      saveJSONObject(json, "json_data.json");
      //println(json.keys());
      JSONArray items = json.getJSONArray("items");

      for (int i = 0; i < items.size(); i++) {
        JSONObject item = items.getJSONObject(i);

        searchResult(item.getString("link"));
        searchResult(item.getString("htmlSnippet"));
        searchResult(item.getString("snippet"));
        searchResult(item.getString("htmlFormattedUrl"));
        searchResult(item.getString("htmlTitle"));

        JSONObject pagemap = item.getJSONObject("pagemap");
        //println(pagemap.keys());
        JSONArray metatags = pagemap.getJSONArray("metatags");

        for (int j = 0; j < metatags.size(); j++) {
          JSONObject metatag = metatags.getJSONObject(j);
          searchResult(metatag.getString("p:domain_verify "));
          searchResult(metatag.getString("og:image"));
          searchResult(metatag.getString("og:type"));
          searchResult(metatag.getString("og:title"));
          searchResult(metatag.getString("og:description"));
          searchResult(metatag.getString("twitter:title"));
          searchResult(metatag.getString("twitter:description"));
        }
      }
    }

    catch (Exception e) {
      e.printStackTrace();
      json = null;
    }

    if (json == null) {
      println("default to stored json string - TODO");
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

void searchResult(String s) {

  if (!(s == null)) {
    s = s.replaceAll("  ", "");
    search_result = search_result + s;
  }
}
