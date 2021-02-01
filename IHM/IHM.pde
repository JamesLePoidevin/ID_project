import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*;
import fr.dgac.ivy.*;
import java.util.*;
import java.util.ArrayList;

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
    size(2000, 1000, P2D);
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
