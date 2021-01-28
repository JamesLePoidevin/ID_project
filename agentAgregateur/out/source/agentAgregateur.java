import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import fr.dgac.ivy.*; 
import java.util.Dictionary; 
import java.util.List; 
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

public class agentAgregateur extends PApplet {






public class agent{
    int ID = 0;
    private List<capteur> capteurs = new ArrayList<capteur>();
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
            println("error connecting to capteurs");
        }
        
            try{    
            bus1.bindMsg("type=(.*) ID=(.*) lon=(.*) lat=(.*) value=(.*)", new IvyMessageListener()
            {
                public void receive(IvyClient client, String[] args)
                {
                    capteur capteurtemp = new capteur(Integer.parseInt(args[0]),Integer.parseInt(args[1]),Float.parseFloat(args[2]),Float.parseFloat(args[3]),Float.parseFloat(args[4]));
                    agent1.add(capteurtemp);
                }
        } );
        } catch(IvyException ie) {
            println("error connecting to capteurs");
        }
        
        try{
            bus2.bindMsg("(.*) : ID=(.*) (.*)", new IvyMessageListener() {
                public publicvoid receive(IvyClient client, String[] args)
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
    
    public void add(capteur c) {
        boolean found = false;
        for (capteur cap : this.capteurs) {
            if (cap.type == c.type && cap.ID == c.ID) {
                cap.value = (cap.value + c.value) / 2;
                found = true;
            }
      }
        if (!found) {
            capteurs.add(c); 
      }
        
    }
    
    public void send() {
        String info = "Message :Agent info-" + this.ID;
        for (capteur cap : this.capteurs)
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
public class capteur{
  int ID;
  int type;
  float lon;
  float lat;
  float value;
  
  public capteur(int ID,int type,float lon,float lat,float value){
    this.ID = ID;
    this.type = type;
    this.lon = lon;
    this.lat = lat;
    this.value = value;
  }
  
}



agent agent1;

public void setup() {
    agent1 = new agent(1);
    size(640, 360);
}

public void loop() {
    try {
        Thread.sleep(60000);
    } catch(InterruptedException e) {
        agent1.send();
    }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "agentAgregateur" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
