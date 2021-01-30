import fr.dgac.ivy.*;
import java.util.List;

public class Serveur 
{
  private List<Agent> agents;
  protected Ivy bus;

  public Serveur() {
    this.agents = new ArrayList<Agent>();
    this.bus = new Ivy("Serveur", "", null);
    try {
      this.bus.start("127.255.255.255:2011");
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
    //try {    
    //  this.bus.bindMsg("TODO", new IvyMessageListener() {
    //    public void receive(IvyClient client, String[] args) {
    //      //TODO
    //    }
    //  });
    //} catch(IvyException ie) {
    //  println("error connecting to Sensors");
    //}
  }

  public void addAgent(Agent agent) {
    this.agents.add(agent);
  }

  public boolean containsAgent(int id) {
    for (Agent a : this.agents) {
      if (a.getID() == id) {
        return true;
      }
    }
    return false;
  }

  public void requestJson() {
    int x=5;
    try {    
      this.bus.sendMsg("Request JSON : ID=" + x);
    } 
    catch(IvyException ie) {
      println("Error request json agent");
    }
  }

  private void parsingJson(String s) {
    JSONObject json = parseJSONObject(s);              
    int IDAgent = json.getInt("ID");
    if (!containsAgent(IDAgent)) {
      Agent a = new Agent(IDAgent);
      JSONArray listCapteurs = json.getJSONArray("Capteurs");
      for (int i=0; i < listCapteurs.size(); i++) {
        JSONObject infos = listCapteurs.getJSONObject(i);
        Sensor sensor = new Sensor(infos.getInt("ID"), 
          infos.getFloat("Longitude"), 
          infos.getFloat("Latitude"), 
          infos.getString("Type"));
        a.addsensor(sensor);
      }
      addAgent(a);
    }
  }

  public String toString() {
    return "Liste agents : " + this.agents.toString();
  }
}
