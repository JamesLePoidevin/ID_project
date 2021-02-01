import fr.dgac.ivy.*;
import java.util.Map;
import java.util.TreeMap;

public class Serveur 
{
  private JSONArray structure;
  private JSONArray capteurs;
  
  protected Ivy bus;
  protected Ivy bus2;

  public Serveur() {
    //inits the List of Agents and Sensors
    this.structure = new JSONArray();
    this.capteurs = new JSONArray();
    
    //Inits the Ivy buses
    this.bus = new Ivy("Serveur", "", null);
    this.bus2 = new Ivy("Serveur", "", null);
    try {
      this.bus.start("127.255.255.255:2011");
      this.bus2.start("127.255.255.255:2012");
    } 
    catch (IvyException ie) { // Exception levée 
      System.out.println("can't send my message !");
    }  

    // Reception JSON config
    try {
      this.bus.bindMsg("JSON : (.*)", new IvyMessageListener() {
        public void receive(IvyClient client, String[] args) {
          parsingJson(args[0]);
        }
      }
      );
    } 
    catch(IvyException ie) {
      println("error connecting to Sensors");
    }

    // Reception des données des agents
    try {    
      this.bus.bindMsg("Agent=(.*) Capteur=(.*) Value=(.*)", new IvyMessageListener() {
        public void receive(IvyClient client, String[] args) {
          addValue(Integer.parseInt(args[0]), Integer.parseInt(args[1]), Float.parseFloat(args[2])); 
        }
      });
    } catch(IvyException ie) {
      println("error connecting to Sensors");
    }
  }
  
  //Does the Serveur contain the agent
  public boolean containsAgent(int id) {
    int nbAgents = this.structure.size();
    
    for (int i=0 ; i < nbAgents ; i++) {
      if (this.structure.getJSONObject(i).getInt("ID") == id) {
        return true;
      }
    }
    return false;
  }
  
  //
  public void requestJson() {
    //The ivy reception does not work if there isn't a varible sent at the same time (We don't understand why)
    int x=5;
    try {    
      this.bus.sendMsg("Request JSON : ID=" + x);
    } 
    catch(IvyException ie) {
      println("Error request json agent");
      
    }
  }
  
  //Sends a request the the agent a
  public void requestValues(Agent a) {
    try {    
      this.bus.sendMsg("Request values : ID=" + a.getID());
    } 
    catch(IvyException ie) {
      println("Error request json agent");
    }
  }
  
  //parser JSON
  private void parsingJson(String s) {
    JSONObject json = parseJSONObject(s);
    int IDAgent = json.getInt("ID");
    
    if (!containsAgent(IDAgent)) {
      int nbAgents = this.structure.size();
      int nbCapteurs = this.capteurs.size();
      this.structure.setJSONObject(nbAgents, json);
      JSONArray listCapteurs = json.getJSONArray("Capteurs");
      
      for(int i=0 ; i < listCapteurs.size() ; i++) {
        this.capteurs.setJSONObject(nbCapteurs, listCapteurs.getJSONObject(i));
        nbCapteurs++;
      }
    }
  }
  
  //
  private void addValue(int idAgent, int idSensor, float value) {
    int nbAgents = this.structure.size();

    for(int i=0 ; i < nbAgents ; i++) {
      JSONObject a = this.structure.getJSONObject(i);
      
      if (a.getInt("ID") == idAgent) {
        int nbCapteurs = a.getJSONArray("Capteurs").size();
        
        for(int j=0 ; j < nbCapteurs ; j++) {
          JSONObject c = a.getJSONArray("Capteurs").getJSONObject(j);
          
          if (c.getInt("ID") == idSensor) {
            c.setFloat("Value", value);
            break;
          }
        }
      break;
      }
    }
  }
  
  private void listCapteur(){
    this.capteurs = new JSONArray();
    int nbAgents = this.structure.size();
    int k = 0;
    for(int i=0 ; i < nbAgents ; i++) {
      JSONObject agent = this.structure.getJSONObject(i);
      JSONArray listCapteurs = agent.getJSONArray("Capteurs");
      
      for(int j=0 ; j < listCapteurs.size() ; j++) {
        this.capteurs.setJSONObject(k, listCapteurs.getJSONObject(j));
        k++;
      }
    }
  }
  
  public void sendIHM(){
    listCapteur();
    if (capteurs.size() != 0) {
      int nbCapteurs = capteurs.size();
      String s =  nbCapteurs + " : ";
      for (int i=0 ; i < nbCapteurs ; i++){
        JSONObject c = capteurs.getJSONObject(i);
        s = s + "type " + c.getString("Type") + " ID " + c.getInt("ID") + " lon " + c.getFloat("Longitude") + " lat " + c.getFloat("Latitude") + " value " + c.getFloat("Value") + " split ";
      }
      try{
        this.bus2.sendMsg(s);
      }catch(IvyException ie) {
        println("error sending to IHM");
      }
    }
  }

  public String toString() {
    return this.capteurs.toString();
  }
}
