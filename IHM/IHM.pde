import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*;
import fr.dgac.ivy.*;
import java.util.*;
import java.util.ArrayList;

UnfoldingMap map;

JSONArray capteurs =  new JSONArray();

int id;
float lon;
float lat;
String type;
float value = 0;

int i = 0;
boolean receving = false;

Ivy bus;

public void setup() {
  size(2000, 1000, P2D);
  noStroke();

  //Creates a map and zooms on Guernsey
  map = new UnfoldingMap(this);
  map.zoomAndPanTo(new Location(49.465691f, - 2.585278f), 13);
  MapUtils.createDefaultEventDispatcher(this, map);

  //Receiving data for the serveur
  try {
    bus = new Ivy("Serveur - Interface Graphique", "ihm", null);
    bus.start("127.255.255.255:2012");

    bus.bindMsg("(.*) : (.*)", new IvyMessageListener() {
      public void receive(IvyClient client, String[] args) {

        println("Value received");
        //if the programme is receiving data then receving equals true
        receving = true;

        //Empties the Sensors list
        capteurs = new JSONArray();

        //Splits into multiple sensors
        String sensorslist[] = args[1].split(" split ");

        //For each sensor
        for (i = 0; i < Integer.parseInt(args[0]); i++) {
          //Splits each word
          String sensorsattribut[] = sensorslist[i].split(" ");

          //Creates the variables with the data in
          JSONObject s = new JSONObject();
          s.setInt("ID", Integer.parseInt(sensorsattribut[3]));
          s.setString("Type", sensorsattribut[1]);
          s.setFloat("Longitude", Float.parseFloat(sensorsattribut[5]));
          s.setFloat("Latitude", Float.parseFloat(sensorsattribut[7]));
          s.setFloat("Value", Float.parseFloat(sensorsattribut[9]));

          capteurs.setJSONObject(capteurs.size(), s);
        }
        // No longer receiving a message
        receving =false;
      }
    }
    );
  } 
  catch(IvyException ie) {
    println("error connecting to Sensors");
  }
}

public void draw() {
  background(255);
  map.draw();


  //Places all the sensors on the map
  if (receving == false) {
    int nbsensor = this.capteurs.size(); 
    for (int i = 0; i < nbsensor; i++) {
      Location capteur1 = new Location(this.capteurs.getJSONObject(i).getFloat("Longitude"), this.capteurs.getJSONObject(i).getFloat("Latitude"));
      ScreenPosition poscapteur1 = map.getScreenPosition(capteur1);
      fill(200, 0, 0, 100);
      ellipse(poscapteur1.x, poscapteur1.y, 20, 20);

      fill(0);
      textSize(23);
      text(this.capteurs.getJSONObject(i).getString("Type") + " : " + String.format("%.3g%n", this.capteurs.getJSONObject(i).getFloat("Value")), poscapteur1.x + 10, poscapteur1.y);
    }
  }
}
