import fr.dgac.ivy.*;
import java.util.Dictionary;
import java.util.List;

public class Agent {
    private int ID;
    private JSONArray sensors;
    
    //Ivy bus to receive message from the sensors
    private Ivy bus1;
    //Ivy bus to send to the seveur and receive requests
    private Ivy bus2;
    
    
    public Agent(int newID) {
        //init the list of sensors
        this.sensors = new JSONArray();
        
        //Setting the new IDs
        this.ID = newID;
        
        try {
            bus1 =new Ivy("Agent", "", null);
            bus1.start("127.255.255.255");
            
            bus1.bindMsg("type=(.*) ID=(.*) lon=(.*) lat=(.*) value=(.*)", new IvyMessageListener()
            {
                public void receive(IvyClient client, String[] args)
                {
                  JSONObject s =getSensor(Integer.parseInt(args[1])); 
                  if (s != null) {
                        s.setFloat("Value",Float.parseFloat(args[4]));
                  }
                }
        } 
          );
        } 
        catch(IvyException ie) {
            println("Error connecting to Ivy bus");
            println(ie.getMessage());
        }
        
        try {
            String s = "Agent :" + this.ID;
            bus2 =new Ivy("Agent", s, null);
            bus2.start("127.255.255.255:2011");
            bus2.bindMsg("Request (.*) : ID=(.*)", new IvyMessageListener() {
                public void receive(IvyClient client, String[] args)
                {
                  if (args[0].equals("values") && getID() == Integer.parseInt(args[1])) {
                        sendValues();
                } elseif (args[0].equals("JSON")) {
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
    
    //Getters
    public int getID() {
        return this.ID;
    }
    
    public JSONObject getSensor(int id) {
        int nbsensor = this.sensors.size(); 
        for (int i = 0; i < nbsensor; i++) {
          JSONObject a = this.sensors.getJSONObject(i);
          if (a.getInt("ID") == id) {
            return a;
          }
        }
        return null;
    }
    
    //adds sensor the the agent
    public void addsensor(Sensor c) {
      if(!this.containsSensor(c.getID())){
        JSONObject s = new JSONObject();
        s.setInt("ID",c.getID());
        s.setString("Type",c.getType());
        s.setFloat("Longitude",c.getLongitude());
        s.setFloat("Latitude",c.getLatitude());
        s.setFloat("Value",c.getValue());
        
        sensors.addJSONObject(sensors.size(),s);
      }
    }
    
    //Does the Serveur contain the agent
    public boolean containsSensor(int id) {
      int nbAgents = this.sensors.size();
      
      for (int i=0 ; i < nbAgents ; i++) {
        if (this.sensors.getJSONObject(i).getInt("ID") == id) {
          return true;
        }
      }
      return false;
    }
    
    //if there is a request from the Serveur for the config JSON then it is sent
    public void sendJSON() {
        JSONObject capteur;
        JSONArray listCapteurs;
        JSONObject  json = new JSONObject();
        String s_json;
        int i = 0;
        
        json.setInt("ID", this.ID);
        listCapteurs = new JSONArray();
        
        int sizesensor = sensors.size();
        for (int j = 0;  j< sizesensor; j++) {
            JSONObject sensor = sensors.getJSONObject(j);
            capteur = new JSONObject();
            capteur.setInt("ID", sensor.getInt("ID"));
            capteur.setString("Type", sensor.getString("Type"));
            capteur.setFloat("Longitude", sensor.getFloat("Longitude"));
            capteur.setFloat("Latitude", sensor.getFloat("Latitude"));
            capteur.setFloat("Value", sensor.getFloat("Value"));
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
    
    //if there is a request from the Serveur for the values then it is sent
    public void sendValues() {
      int nbsensor = this.sensors.size();
      for (int i = 0; i < nbsensor; i++) {
        JSONObject cap = this.sensors.getJSONObject(i);
        try {
          bus2.sendMsg("Agent=" + this.getID() + " Capteur=" + cap.getInt("ID") + " Value=" + cap.getFloat("Value"));
        } 
        catch(IvyException ie) {
          println("Error sending ");
          println(ie.getMessage());
        }
      }
    }
    
    //Sends all the sensors and th ID of the agent to the serveur
    public void send() {
        String info = "Message :Agent info-" + this.ID;
        int nbsensor = this.sensors.size();
        for (int i = 0; i < nbsensor; i++) {
          info = info + this.sensors.getJSONObject(i) + " | ";
          try {
            bus2.sendMsg(info);
          } 
          catch(IvyException ie) {
            println("Error sending ");
            println(ie.getMessage());
          }
        }
    }
    
    public String toString() {
        return "Agent " + this.ID + " - Capteurs : " + this.sensors;
    }
}
