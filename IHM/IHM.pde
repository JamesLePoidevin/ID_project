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

String sensorsattribut[];
String sensorslist[];

final String SEPARATEUR = " | ";
final String SEPARATEURSENSOR = " ";

int i = 0;


public void setup() {
    size(2000, 1000, P2D);
    noStroke();
    
    map = new UnfoldingMap(this);
    map.zoomAndPanTo(new Location(49.465691f, - 2.585278f), 13);
    MapUtils.createDefaultEventDispatcher(this, map);
    
    Ivy bus;
    
    try{
      bus = new Ivy("Serveur - Interface Graphique", "ihm", null);
      bus.start("127.255.255.255:2012");
      println("error connecting to Sensors");
        
      bus.bindMsg("(.*) : (.*)", new IvyMessageListener(){
        public void receive(IvyClient client, String[] args){
        
          sensorslist = args[1].split(SEPARATEUR);
          
          for (i = 0;i <= Integer.parseInt(args[0]);i++) {
            
            sensorsattribut = sensorslist[i].split(SEPARATEURSENSOR);
            
            id = Integer.parseInt(sensorsattribut[3]);
            lon = Float.parseFloat(sensorsattribut[5]);
            lat = Float.parseFloat(sensorsattribut[7]);
            type = sensorsattribut[1];
            value = Float.parseFloat(sensorsattribut[9]);
            
            capteurs.add(new Sensor(type, id, lon, lat, value));
          }
        }
      });
    } catch(IvyException ie) {
      println("error connecting to Sensors");
    }
}

public void draw() {
    background(0);
    map.draw();
    
    //Draws locations on screen positions according to their geo-locations.
    
    //Zoom dependent marker size
    for (Sensor s : capteurs) {
        Location capteur1 = new Location(s.lon, s.lat);
        ScreenPosition poscapteur1 = map.getScreenPosition(capteur1);
        fill(200, 0, 0, 100);
        ellipse(poscapteur1.x,poscapteur1.y , 20, 20);
        
        fill(0);
        textSize(23);
        text(s.type + " : " + s.value, poscapteur1.x + 10, poscapteur1.y);
    }
}
