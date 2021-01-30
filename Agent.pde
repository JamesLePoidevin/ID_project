import fr.dgac.ivy.*;
import java.util.Dictionary;
import java.util.List;

public class Agent{
    int ID = 0;
    private List<Sensor> Sensors = new ArrayList<Sensor>();
    private Ivy bus1;
    private Ivy bus2;
    
    public Agent(int newID) {
        //Setting the new IDs
        this.ID = newID;
        
        try{
            bus1 = new Ivy("Capteur - Agent", "agent", null);
            bus1.start("127.255.255.255");
            
            bus2 = new Ivy("Agent - Serveur", "agent", null);
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
                    agent1.addsensor(Sensortemp);
                    println(Sensortemp.tostring());
                }
        } );
        } catch(IvyException ie) {
            println("error connecting to Sensors");
        }
        
        try{
            bus2.bindMsg("(.*) : ID=(.*) (.*)", new IvyMessageListener() {
                public void receive(IvyClient client, String[] args)
                {
                    if (args[0].equals("Request") && ID == Integer.parseInt(args[1])) {
                        agent1.send(); 
                }
                }  
            } ); 
        } catch(IvyException ie) {
            println("error connecting to the server");
        }
    
    
    }
    
    public void addsensor(Sensor c) {
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
    
    public void send() {
        String info = "Message :Agent info-" + this.ID;
        for (Sensor cap : this.Sensors)
            info= info + "Type=" + cap.type + " ID=" + cap.id + " lon=" + cap.lon + " lat=" + cap.lat + " value=" + cap.value;
        try{
            bus2.sendMsg(info);
    } catch(IvyException ie) {
            println("error sending");
    }
    }
    
    public void prin() {
        println(Sensors);
    }
    
}
