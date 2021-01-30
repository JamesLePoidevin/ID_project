import fr.dgac.ivy.*;
import java.util.Dictionary;
import java.util.List;

public class Agent{
    int ID;
    private List<Sensor> Sensors;
    private Ivy bus1;
    private Ivy bus2;
    
    public Agent(int newID) {
        //Setting the new IDs
        this.Sensors = new ArrayList<Sensor>();
        this.ID = newID;
        
        try{
            bus1 = new Ivy("Agent", "", null);
            bus1.start("127.255.255.255");
            
            String s = "Agent :" +this.ID;
            bus2 = new Ivy("Agent", s, null);
            bus2.start("127.255.255.255:2011");
        } catch(IvyException ie) {
            println("error connecting to Sensors");
        }
        
        try{    
            bus1.bindMsg("type=(.*) ID=(.*) lon=(.*) lat=(.*) value=(.*)", new IvyMessageListener()
            {
                public void receive(IvyClient client, String[] args)
                {
                    Sensor Sensortemp = new Sensor(args[0],Integer.parseInt(args[1]),Float.parseFloat(args[2]),Float.parseFloat(args[3]),Float.parseFloat(args[4]));
                    addsensor(Sensortemp);
                    println(Sensortemp);
                }
        } );
        } catch(IvyException ie) {
            println("error connecting to Sensors");
        }
        
        try{
            bus2.bindMsg("Request (.*) : ID=(.*)", new IvyMessageListener() {
                public void receive(IvyClient client, String[] args)
                {
                    if (args[0].equals("values") && ID == Integer.parseInt(args[1])) {
                        send(); 
                    } else if(args[0].equals("JSON")) {
                        sendJSON();
                    }
                }  
            } ); 
        } catch(IvyException e){
            println("error connecting to the server");
        }    
    }
    
    public int getID() {
      return this.ID;
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
        JSONObject  json = new JSONObject();
        json.setInt("ID", this.ID);
        JSONArray listCapteurs = new JSONArray();
        
        int i = 0;
        for(Sensor s : this.Sensors) {
          JSONObject capteur = new JSONObject();;
          capteur.setInt("ID", s.getID());
          capteur.setString("Type", s.getType());
          capteur.setFloat("Longitude", s.getLongitude());
          capteur.setFloat("Latitude", s.getLatitude());
          listCapteurs.setJSONObject(i, capteur);
          i++;
        }
        json.setJSONArray("Capteurs", listCapteurs);
        String s_json = json.toString();
        s_json = s_json.replaceAll("\n","");
        
        try {
            bus2.sendMsg("JSON : " + s_json);
        } catch(IvyException ie) {
            println(ie.getMessage());
        }
    }
    
    public void send() {
        String info = "Message :Agent info-" + this.ID;
        for (Sensor cap : this.Sensors)
            info= info + " Type=" + cap.type + " ID=" + cap.id + " lon=" + cap.lon + " lat=" + cap.lat + " value=" + cap.value + " | ";
        try{
            bus2.sendMsg(info);
        } catch(IvyException ie) {
                println("error sending");
                println(ie.getMessage());
        }
    }
    
    public String toString() {
        return "Agent " + this.ID + "Capteurs : " + this.Sensors.toString();
    }
    
}
