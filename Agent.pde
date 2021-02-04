import fr.dgac.ivy.*;

public class Agent {
  private int ID;
  private JSONArray sensors;

  //Ivy bus to receive message from the sensors
  private Ivy busCapteurs;
  //Ivy bus to send to the seveur and receive requests
  private Ivy busServeur;


  public Agent(int newID) {
    //init the list of sensors
    this.sensors = new JSONArray();

    //Setting the new IDs
    this.ID = newID;

    try {
      busCapteurs =new Ivy("Agent", "", null);
      busCapteurs.start("127.255.255.255");

      busCapteurs.bindMsg("type=(.*) ID=(.*) lon=(.*) lat=(.*) value=(.*)", new IvyMessageListener()
      {
        public void receive(IvyClient client, String[] args)
        {
          JSONObject s =getSensor(Integer.parseInt(args[1])); 
          if (s != null) {
            s.setFloat("Value", Float.parseFloat(args[4]));
          }
        }
      } 
      );
    } 
    catch(IvyException ie) {
      println("Error connecting or receiving from sensor bus");
      println(ie.getMessage());
    }

    try {
      String s = "Agent :" + this.ID;
      busServeur =new Ivy("Agent", s, null);
      busServeur.start("127.255.255.255:2011");
      busServeur.bindMsg("Request (.*) : ID=(.*)", new IvyMessageListener() {
        public void receive(IvyClient client, String[] args)
        {
          if (args[0].equals("values") && getID() == Integer.parseInt(args[1])) {
            sendValues();
          } else if (args[0].equals("JSON")) {
            sendJSON();
          }
        }
      } 
      );
    } 
    catch(IvyException e) {
      println("Error connecting or receiving from sensor server");
      println(e.getMessage());
    }
  }

  //Getters
  public int getID() {
    return this.ID;
  }

  public JSONObject getSensor(int id) {
    JSONObject a;
    int nbsensor = this.sensors.size(); 

    for (int i = 0; i < nbsensor; i++) {
      a = this.sensors.getJSONObject(i);
      if (a.getInt("ID") == id) {
        return a;
      }
    }
    return null;
  }

  //adds sensor to the agent
  public void addsensor(Capteur c) {
    JSONObject s;

    if (!this.containsSensor(c.getID())) {
      s = new JSONObject();
      s.setInt("ID", c.getID());
      s.setString("Type", c.getType());
      s.setFloat("Longitude", c.getLongitude());
      s.setFloat("Latitude", c.getLatitude());
      s.setFloat("Value", c.getValue());

      sensors.setJSONObject(sensors.size(), s);
    }
  }

  //Does the Serveur contain the agent
  public boolean containsSensor(int id) {
    int nbAgents = this.sensors.size();

    for (int i=0; i < nbAgents; i++) {
      if (this.sensors.getJSONObject(i).getInt("ID") == id) {
        return true;
      }
    }
    return false;
  }

  //if there is a request from the Serveur for the config JSON then it is sent
  public void sendJSON() {
    String s_json;
    int i = 0;
    JSONObject  json = new JSONObject();

    json.setInt("ID", this.ID);
    json.setJSONArray("Capteurs", this.sensors);
    s_json = json.toString().replaceAll("\n", "");

    try {
      busServeur.sendMsg("JSON : " + s_json);
    } 
    catch(IvyException ie) {
      println("Error sending JSON");
      println(ie.getMessage());
    }
  }

  //if there is a request from the Serveur for the values then it is sent
  public void sendValues() {
    JSONObject cap;
    int nbsensor = this.sensors.size();

    for (int i = 0; i < nbsensor; i++) {
      cap = this.sensors.getJSONObject(i);

      try {
        busServeur.sendMsg("Agent=" + this.getID() + " Capteur=" + cap.getInt("ID") + " Value=" + cap.getFloat("Value"));
      } 
      catch(IvyException ie) {
        println("Error sending values");
        println(ie.getMessage());
      }
    }
  }

  public String toString() {
    return "Agent " + this.ID + " - Capteurs : " + this.sensors;
  }
}
