import ddf.minim.*;
import processing.video.*;

Movie myMovie;

PImage ship;
int base=200;
int x,y, Score=0;
int changeX=-5;
int changeY=-5;
int gameOver=0;
int speed=1; 

boolean isRunning;

AudioPlayer endSoundPlayer;
AudioPlayer flySoundPlayer;
Minim minim;

void setup()
{
  size(1280, 720);
  myMovie = new Movie(this, "reach.mov");
  myMovie.loop();
  y=height-base;
  
  minim            = new Minim(this);
  endSoundPlayer   = minim.loadFile("end.wav");
  flySoundPlayer   = minim.loadFile("sfx_wing.wav");

}

void draw()
{
  
  if(gameOver==0)
  {
  background(myMovie); 

  text("Score"+Score+"00",50,50);
  textSize(30);
  
  PImage lift;
  lift = loadImage("gravity_lift.png");
  image(lift, mouseX,height-base,100, base);
  
  
  PImage helmet;
  helmet = loadImage("chief right.png");
  image(helmet, x, y);
  
  x=x+changeX;
  y=y+changeY;
  if(x<0 | x>width)
  {
    changeX=-changeX;
    playWingSound();
  }
  if(y<0)
  {
    changeY=-changeY;
    playWingSound();
  }
  if(y>height-base)
  {
    
    if(x>mouseX-100 && x<mouseX+100)
    {
      changeY=-changeY++; 
      Score++;
      playWingSound();
    }
    else
    {
      Splash();
    }
  }
  }
  else
  {
    PImage dead;
    dead = loadImage("death.jpg");
    image(dead, 0, 0, width, height);
    size(width, height);
    text("Your Score: "+Score+"00",50,50);
    text("YOU LOSE",width/2,height/2);
    text("CLICK TO PLAY AGAIN",width/2,height/2+20);
    endSoundPlayer.play(); 
  }
}

void playWingSound() {
  flySoundPlayer.rewind();
  flySoundPlayer.play();
}

void endgame() 
{
  endSoundPlayer.play(); 
}
void Splash()
{
  gameOver=1;
}
void mouseClicked()
{
  changeY=-changeY;
  Score=0;
  gameOver=0;

}


void movieEvent(Movie m) {
  m.read();
}
