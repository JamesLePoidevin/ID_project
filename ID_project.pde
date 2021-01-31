Agent agent1, agent2;
Serveur serveur;
Sensor s1,s2,s3,s4;


int i = 0;

void setup() {
  //Sensor(ID,Lon,Lat,Type)
  s1 = new Sensor(123, 49.44383827562527, -2.627365585519504, "pressure");
  s2 = new Sensor(456, 49.44919642459392, -2.6377129898164964, "temperature");
  s3 = new Sensor(789, 49.48611197434781, -2.537480514161824, "humidity");
  s4 = new Sensor(785, 49.463067100549324, -2.57141167924376, "humidity");

  //Created 2 agents and added the sensors
  agent1 = new Agent(1);
  agent1.addsensor(s1);
  agent1.addsensor(s3);

  agent2 = new Agent(2);
  agent2.addsensor(s2);
  agent2.addsensor(s4);

  serveur = new Serveur();
}

void draw() {
  delay(1000);
  
  //serveur requestion the config to the agents
  if (i<1) {
    serveur.requestJson();
    i++;
  }
  
  //Sensors sending the new data to the agents
  s1.send_datas();
  s2.send_datas();
  s3.send_datas();
  s4.send_datas();
  
  //Periodique send of the agent
  try {
    Thread.sleep(6000);
    
    //Agent sends message to serveur
    agent1.send();
    
    //Serveur requesting value to the agent n°1
    serveur.requestValues(agent1);
    
    //Sends data to IHM
    serveur.sendIHM();
  } 
  catch(InterruptedException e) {
    println(e.getMessage());
  }
}
