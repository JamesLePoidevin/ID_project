import fr.dgac.ivy.*;
import java.util.Dictionary;
import java.util.List;

public class Agent{
    int ID = 0;
    private List<Capteur> Capteurs = new ArrayList<Capteur>();
    private Ivy bus1;
    private Ivy bus2;
    
    public agent(int newID) {
        //Setting the new IDs
        this.ID = newID;
        
        try{
            bus1 = new Ivy("demo", "Capteur", null);
            bus1.start("localhost:2010");
            
            bus2 = new Ivy("demo", "Serveur", null);
            bus2.start("localhost:2011");
        } catch(IvyException ie) {
            println("error connecting to Capteurs");
        }
        
            try{    
            bus1.bindMsg("type=(.*) ID=(.*) lon=(.*) lat=(.*) value=(.*)", new IvyMessageListener()
            {
                public void receive(IvyClient client, String[] args)
                {
                    Capteur Capteurtemp = new Capteur(Integer.parseInt(args[0]),Integer.parseInt(args[1]),Float.parseFloat(args[2]),Float.parseFloat(args[3]),Float.parseFloat(args[4]));
                    agent1.add(Capteurtemp);
                }
        } );
        } catch(IvyException ie) {
            println("error connecting to Capteurs");
        }
        
        try{
            bus2.bindMsg("(.*) : ID=(.*) (.*)", new IvyMessageListener() {
                publicvoid receive(IvyClient client, String[] args)
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
    
    public void add(Capteur c) {
        boolean found = false;
        for (Capteur cap : this.Capteurs) {
            if (cap.type == c.type && cap.ID == c.ID) {
                cap.value = (cap.value + c.value) / 2;
                found = true;
            }
      }
        if (!found) {
            Capteurs.add(c); 
      }
        
    }
    
    public void send() {
        String info = "Message :Agent info-" + this.ID;
        for (Capteur cap : this.Capteur
        s)
            info= info + "Type=" + cap.type + " ID=" + cap.ID + " lon=" + cap.lon + " lat=" + cap.lat + " value=" + cap.value;
        try{
            bus2.sendMsg(info);
     } catch(IvyException ie) {
            println("error sending");
     }
    }
    
    public void update() {
        
    }
    
}