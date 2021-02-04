import fr.dgac.ivy.*;

public class Serveur 
{
  private JSONArray structure;
  private JSONArray capteurs;
  private Ivy busAgent;
  private Ivy busIHM;

  public Serveur() {
    //inits the List of Agents and Sensors
    this.structure = new JSONArray();
    this.capteurs = new JSONArray();

    //Inits the Ivy buses
    this.busAgent = new Ivy("Serveur", "", null);
    this.busIHM = new Ivy("Serveur", "", null);

    try {
      this.busAgent.start("127.255.255.255:2011");
      this.busIHM.start("127.255.255.255:2012");
    } 
    catch (IvyException ie) { // Exception levée 
      System.out.println("Error starting bus ivy");
      println(ie.getMessage());
    }  

    // Reception JSON config
    try {
      this.busAgent.bindMsg("JSON : (.*)", new IvyMessageListener() {
        public void receive(IvyClient client, String[] args) {
          parsingJson(args[0]);
        }
      }
      );
    } 
    catch(IvyException ie) {
      println("Error receiving JSON config");
      println(ie.getMessage());
    }

    // Reception agent datas
    try {    
      this.busAgent.bindMsg("Agent=(.*) Capteur=(.*) Value=(.*)", new IvyMessageListener() {
        public void receive(IvyClient client, String[] args) {
          addValue(Integer.parseInt(args[0]), Integer.parseInt(args[1]), Float.parseFloat(args[2]));
        }
      }
      );
    } 
    catch(IvyException ie) {
      println("Error receiving Agent data");
      println(ie.getMessage());
    }
  }

  //Does the Serveur contain the agent
  public boolean containsAgent(int id) {
    int nbAgents = this.structure.size();

    for (int i=0; i < nbAgents; i++) {
      if (this.structure.getJSONObject(i).getInt("ID") == id) {
        return true;
      }
    }
    return false;
  }

  // Sends a request for JSON configuration to all the agents
  public void requestJson() {
    //The ivy reception does not work if there isn't a variable sent at the same time (We don't understand why)
    int x=5;
    try {    
      this.busAgent.sendMsg("Request JSON : ID=" + x);
    } 
    catch(IvyException ie) {
      println("Error request json agent");
      println(ie.getMessage());
    }
  }

  //Sends a request for values to the agent a
  public void requestValues(Agent a) {
    try {    
      this.busAgent.sendMsg("Request values : ID=" + a.getID());
    } 
    catch(IvyException ie) {
      println("Error request values");
      println(ie.getMessage());
    }
  }

  //parser JSON
  private void parsingJson(String s) {
    JSONObject json = parseJSONObject(s);
    JSONArray listCapteurs;
    int IDAgent = json.getInt("ID");
    int nbAgents;
    int nbCapteurs;

    if (!containsAgent(IDAgent)) {
      nbAgents = this.structure.size();
      nbCapteurs = this.capteurs.size();
      this.structure.setJSONObject(nbAgents, json);
      listCapteurs = json.getJSONArray("Capteurs");

      for (int i=0; i < listCapteurs.size(); i++) {
        this.capteurs.setJSONObject(nbCapteurs, listCapteurs.getJSONObject(i));
        nbCapteurs++;
      }
    }
  }

  // Add the new value to the corresponding sensor
  private void addValue(int idAgent, int idSensor, float value) {
    JSONObject a;
    JSONObject c;
    int nbCapteurs;
    int nbAgents = this.structure.size();

    for (int i=0; i < nbAgents; i++) {
      a = this.structure.getJSONObject(i);

      if (a.getInt("ID") == idAgent) {
        nbCapteurs = a.getJSONArray("Capteurs").size();

        for (int j=0; j < nbCapteurs; j++) {
          c = a.getJSONArray("Capteurs").getJSONObject(j);

          if (c.getInt("ID") == idSensor) {
            c.setFloat("Value", value);
            break;
          }
        }
        break;
      }
    }
  }

  // Makes a list of the sensors 
  private void listCapteur() {
    JSONObject agent;
    JSONArray listCapteurs;
    this.capteurs = new JSONArray();
    int nbAgents = this.structure.size();
    int k = 0;

    for (int i=0; i < nbAgents; i++) {
      agent = this.structure.getJSONObject(i);
      listCapteurs = agent.getJSONArray("Capteurs");

      for (int j=0; j < listCapteurs.size(); j++) {
        this.capteurs.setJSONObject(k, listCapteurs.getJSONObject(j));
        k++;
      }
    }
  }

  // Sends all the sensors information to the HMI
  public void sendIHM() {
    int nbCapteurs;
    String s;
    JSONObject c;

    listCapteur();

    if (capteurs.size() != 0) {
      nbCapteurs = capteurs.size();
      s =  nbCapteurs + " : ";

      for (int i=0; i < nbCapteurs; i++) {
        c = capteurs.getJSONObject(i);
        s = s + "type " + c.getString("Type") + " ID " + c.getInt("ID") + " lon " + c.getFloat("Longitude") + " lat " + c.getFloat("Latitude") + " value " + c.getFloat("Value") + " split ";
      }
      try {
        this.busIHM.sendMsg(s);
      }
      catch(IvyException ie) {
        println("Error sending to IHM");
        println(ie.getMessage());
      }
    }
  }

  public String toString() {
    return this.capteurs.toString();
  }
}
