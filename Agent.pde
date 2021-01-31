import fr.dgac.ivy.*;
import java.util.Dictionary;
import java.util.List;

public class Agent {
  private int ID;
  private List<Sensor> Sensors;
  private Ivy bus1;
  private Ivy bus2;

  public Agent(int newID) {
    //Setting the new IDs
    this.Sensors = new ArrayList<Sensor>();
    this.ID = newID;

    try {
      bus1 = new Ivy("Agent", "", null);
      bus1.start("127.255.255.255");

      String s = "Agent :" +this.ID;
      bus2 = new Ivy("Agent", s, null);
      bus2.start("127.255.255.255:2011");
    } 
    catch(IvyException ie) {
      println("Error connecting to Ivy bus");
      println(ie.getMessage());
    }

    // Receive sensors information
    try {    
      bus1.bindMsg("type=(.*) ID=(.*) lon=(.*) lat=(.*) value=(.*)", new IvyMessageListener()
      {
        public void receive(IvyClient client, String[] args)
        {
          Sensor Sensortemp = new Sensor(args[0], Integer.parseInt(args[1]), Float.parseFloat(args[2]), Float.parseFloat(args[3]), Float.parseFloat(args[4]));
          addsensor(Sensortemp);
          println(Sensortemp);
        }
      } 
      );
    } catch(IvyException ie) {
      println("Error reception of sensor values");
      println(ie.getMessage());
    }

    try {
      bus2.bindMsg("Request (.*) : ID=(.*)", new IvyMessageListener() {
        public void receive(IvyClient client, String[] args)
        {
          if (args[0].equals("values") && ID == Integer.parseInt(args[1])) {
            sendValues();
          } else if (args[0].equals("JSON")) {
            sendJSON();
          }
        }
      } 
      );
    } catch(IvyException e) {
      println("Error reception requests from server");
      println(e.getMessage());
    }
  }

  public int getID() {
    return this.ID;
  }
  
  public Sensor getSensor(int id) {
    for (Sensor s : this.Sensors) {
      if (s.getID() == id) {
        return s;
      }
    }
    return null;
  }

  public void addsensor(Sensor c) {
    // TO REFACTOR
    boolean found = false;
    for (Sensor cap : this.Sensors) {
      if (cap.type.equals(c.type) && cap.id == c.id) {
        cap.value = (cap.value + c.value) / 2;
        found = true;
      }
    }
    if (!found) {
      Sensors.add(c);
    }
  }

  public void sendJSON() {
    JSONObject capteur;
    JSONArray listCapteurs;
    JSONObject  json = new JSONObject();
    String s_json;
    int i = 0;
    
    json.setInt("ID", this.ID);
    listCapteurs = new JSONArray();

    for (Sensor s : this.Sensors) {
      capteur = new JSONObject();
      capteur.setInt("ID", s.getID());
      capteur.setString("Type", s.getType());
      capteur.setFloat("Longitude", s.getLongitude());
      capteur.setFloat("Latitude", s.getLatitude());
      listCapteurs.setJSONObject(i, capteur);
      i++;
    }
    json.setJSONArray("Capteurs", listCapteurs);
    s_json = json.toString().replaceAll("\n", "");

    try {
      bus2.sendMsg("JSON : " + s_json);
    } 
    catch(IvyException ie) {
      println(ie.getMessage());
    }
  }

  public void send() {
    String info = "Message :Agent info-" + this.ID;
    for (Sensor cap : this.Sensors)
      info= info + " Type=" + cap.type + " ID=" + cap.id + " lon=" + cap.lon + " lat=" + cap.lat + " value=" + cap.value + " | ";
    try {
      bus2.sendMsg(info);
    } 
    catch(IvyException ie) {
      println("Error sending ");
      println(ie.getMessage());
    }
  }
  
  public void sendValues() {
    for (Sensor cap : this.Sensors) {
      try {
        bus2.sendMsg("Agent=" + this.getID() + " Capteur=" + cap.getID() + " Value=" + cap.getValue());
      } 
      catch(IvyException ie) {
        println("Error sending ");
        println(ie.getMessage());
      }
    }
  }

  public String toString() {
    return "Agent " + this.ID + " - Capteurs : " + this.Sensors.toString();
  }
}
