// SPIROGRAPH
// http://en.wikipedia.org/wiki/Spirograph
// also (for inspiration):
// http://ensign.editme.com/t43dances
//
// this processing sketch uses simple OpenGL transformations to create a
// Spirograph-like effect with interlocking circles (called sines).  
// press the spacebar to switch between tracing and
// showing the underlying geometry.
//
// your tasks:
// (1) tweak the code to change the simulation so that it draws something you like.
// hint: you can change the underlying system, the way it gets traced when you hit the space bar,
// or both.  try to change *both*.  :)
// (2) use minim to make the simulation MAKE SOUND.  the full minim docs are here:
// http://code.compartmental.net/minim/
// hint: the website for the docs has three sections (core, ugens, analysis)... look at all three
// another hint: minim isn't super efficient with a large number of things playing at once.
// see if there's a simple way to get an effective sound, or limit the number of shapes
// you're working with.


import ddf.minim.*;
import ddf.minim.ugens.*;

// audio stuff
Minim minim; // this is the audio engine
AudioInput in; // this is the audio input
AudioOutput out;
float theamp; // this is how loud i'm being

PShape s; // this is my cool shape

int NUMSINES = 3; // how many of these things can we do at once?
float[] sines = new float[NUMSINES]; // an array to hold all the current angles
float rad; // an initial radius value for the central sine
int i; // a counter variable

// play with these to get a sense of what's going on:
float fund = .09; // the speed of the central sine
float ratio = .034; // what multiplier for speed is each additional sine?
int alpha = 255; // how opaque is the tracing system

boolean trace = false; // are we tracing?

PShader monjori;


void setup()
{
  size(800, 600, P3D); // OpenGL mode
 //borrowing from shaders class 15
  monjori = loadShader("monjori.glsl");
  monjori.set("resolution", float(width), float(height));   

  rad = height/5.; // compute radius for central circle
  background(255); // clear the screen
  
  // audio in
  minim = new Minim(this); // this starts the audio engine
  in = minim.getLineIn();
  out   = minim.getLineOut(); 
  
 
  for (int i = 0; i<sines.length; i++)
  {
    sines[i] = PI; // start EVERYBODY facing NORTH
  }
}
 
void draw()
{
  doaudiostuff();
  float samp = map(theamp, 0., 1., 1., 20);
  monjori.set("time", millis() / 1000.0);
  //borrowed from G_modify_shape
  s = createShape();
  s.beginShape();
  s.vertex(-50*samp, -50*samp);
  s.vertex(-50, 50);
  s.vertex(50*samp, 50*samp);
  s.vertex(50, -50);
  s.endShape(CLOSE);
  //borrowed from shader
  shader(monjori);
  // This kind of effects are entirely implemented in the
  // fragment shader, they only need a quad covering the  
  // entire view area so every pixel is pushed through the 
  // shader.   
  rect(0, 0, width, height);  
  
  if (!trace) background(255); // clear screen if showing geometry
  if (!trace) {
    stroke(0, 255); // black pen

  }  

  // MAIN ACTION
  pushMatrix(); // start a transformation matrix
  translate(width/2, height/2); // move to middle of screen

  for (i = 0; i<sines.length; i++) // go through all the sines
  {
    float erad = 0; // radius for small "point" within circle... this is the 'pen' when tracing
    // setup tracing
    if (trace) {
      stroke(255, 200, 255*(float(i)/sines.length), alpha); // blue
      fill(155, 255, 255); // also, um, blue
      erad = 10.0*(5.0-float(i)/sines.length); // pen width will be related to which sine
    }
    float radius = rad/(i+1); // radius for circle itself
    rotateZ(sines[i]); // rotate circle
    if (!trace) ellipse(0, 0, radius*1, radius*1); // if we're simulating, draw the sine
    pushMatrix(); // go up one level
    translate(0, radius); // move to sine edge
    if (!trace) ellipse(100, 100, 110, 110); // draw a little circle
    if (trace) ellipse(255, 255, 255, 255); // draw with erad if tracing
    popMatrix(); // go down one level
    translate(0, radius); // move into position for next sine
    sines[i] = (sines[i]+(fund+(fund*i*ratio)))%TWO_PI; // update angle based on fundamental
    
    shape(s, mouseX, mouseY);

  } 
  popMatrix(); // pop down final transformation
}

void keyReleased()
{
  if (key==' ') {
    trace = !trace; 
    background(255);
  }
}
//borrowed from G_modify_shape
void doaudiostuff()
{
  float rawamp = 0.;

  for (int i = 0; i < in.bufferSize () - 1; i++)
  {
    rawamp = rawamp + abs(in.left.get(i)); // add the abs value of the current sample to the amp
  }
  rawamp = rawamp / in.bufferSize();

  theamp = mysmooth(rawamp, theamp, 0.9);

}

// y(n) = a*y(n-1) + (1.0-a)*x(n)
float mysmooth(float x, float y, float a)
{
  return(a*y + (1.0-a)*x);
}

