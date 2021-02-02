import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import de.fhpotsdam.unfolding.*; 
import de.fhpotsdam.unfolding.geo.*; 
import de.fhpotsdam.unfolding.utils.*; 
import fr.dgac.ivy.*; 
import java.util.*; 
import java.util.ArrayList; 
import fr.dgac.ivy.*; 

import fr.dgac.ivy.*; 
import fr.dgac.ivy.tools.*; 
import gnu.getopt.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class IHM extends PApplet {








UnfoldingMap map;

List<Sensor> capteurs =  new ArrayList<Sensor>();

int id;
float lon;
float lat;
String type;
float value = 0;

int i = 0;
boolean receving = false;

Ivy bus;

List<Float> valuesIHM =  new ArrayList<Float>();

public void setup() {
    
    noStroke();
    
    //Creates a map and zooms on Guernsey
    map = new UnfoldingMap(this);
    map.zoomAndPanTo(new Location(49.465691f, - 2.585278f), 13);
    MapUtils.createDefaultEventDispatcher(this, map);
    
    //Receiving data for the serveur
    try{
      bus = new Ivy("Serveur - Interface Graphique", "ihm", null);
      bus.start("127.255.255.255:2012");
        
      bus.bindMsg("(.*) : (.*)", new IvyMessageListener(){
        public void receive(IvyClient client, String[] args){
          
          println("Value received");
          //if the programme is receiving data then receving equals true
          receving = true;
          
          //Empties the Sensors list
          capteurs.clear();

          //Splits into multiple sensors
          String sensorslist[] = args[1].split(" split ");
          
          //For each sensor
          for (i = 0;i <= Integer.parseInt(args[0])-1;i++) {
            //Splits each word
            String sensorsattribut[] = sensorslist[i].split(" ");
            
            //Creates the variables with the data in
            type = sensorsattribut[1];
            id = Integer.parseInt(sensorsattribut[3]);
            lon = Float.parseFloat(sensorsattribut[5]);
            lat = Float.parseFloat(sensorsattribut[7]);
            value = Float.parseFloat(sensorsattribut[9]);
            
            //Add the sensor to the list of sensors
            capteurs.add(new Sensor(type, id, lon, lat, value));
            
            valuesIHM.add(value);
          }
          // No longer receiving a message
          receving =false;
        }
        
      });
    } catch(IvyException ie) {
      println("error connecting to Sensors");
    }
}

public void draw() {
    background(255);
    map.draw();
    
    //Places all the sensors on the map
    if(receving == false){
      for (Sensor s : capteurs) {
        Location capteur1 = new Location(s.lon, s.lat);
        ScreenPosition poscapteur1 = map.getScreenPosition(capteur1);
        fill(200, 0, 0, 100);
        ellipse(poscapteur1.x,poscapteur1.y , 20, 20);
        
        fill(0);
        textSize(23);
        text(s.type + " : " + String.format("%.3g%n", s.value), poscapteur1.x + 10, poscapteur1.y);     
      }
    }
}
//Copy of the file in the other folder  


class Sensor{
  private int id;
  private float lon;
  private float lat;
  private String type;
  private float value = 0;
  private Ivy bus;
  
  protected Sensor(){};
  
  
  protected Sensor(int id_par, float loc_parX, float loc_parY, String type_par){
    id = id_par;
    lon = loc_parX;
    lat = loc_parY;
    type = type_par; 
    
    String s = "Capteur :" +this.id;
    bus = new Ivy("Capteur - Agent",s,null);
    try{
      bus.start("127.255.255.255");
    }catch (IvyException ie) // Exception levée
          {
            System.out.println("can't send my message !");
          }
  }
  
  protected Sensor(String type_par, int id_par, float loc_parX, float loc_parY, float val){
    id= id_par;
    lon = loc_parX;
    lat = loc_parY;
    type = type_par; 
    value = val;
  }
  
  public float generate_values(){
    float borneMax, borneMin;
    if (type.equals("pressure")){ //en Pa
        borneMax = 1013.5f; //pression au niveau de la mer
        borneMin = 200; //pression à 12km
    }
    else if(type.equals("temperature")){ //en degrès Celsius
      borneMax = 40; 
      borneMin = -20;
    }
    else if(type.equals("humidity")){ //pourcentage d'humidité relative 
      borneMax = 90; 
      borneMin = 70; 
    }
    else{
      borneMax = 0;
      borneMin = 0;
    }
     float value = borneMin + (float)Math.random() * (borneMax - borneMin);
    return value;
  }
  
    public void send_datas(){
      try{
        bus.sendMsg("type=" + this.type + " ID=" + this.id + " lon=" + this.lon + " lat=" + this.lat + " value=" + this.generate_values()); // envoi un message
      } catch (IvyException ie) // Exception levée
          {
            System.out.println("can't send my message !");
          }
    }
    
    public String tostring(){
      return "type= " + this.type + " ID=" + this.id + " lon= " + this.lon + " lat= " + this.lat + " value= " + this.value;
    }
}
  public void settings() {  size(2000, 1000, P2D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "IHM" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
