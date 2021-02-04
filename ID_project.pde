Agent agent1, agent2;
Serveur serveur;
Capteur s1, s2, s3, s4;

int k=0;

void setup() {
  //Sensor(ID,Lon,Lat,Type)
  s1 = new Capteur(123, 49.44383827562527, -2.627365585519504, "pressure");
  s2 = new Capteur(456, 49.44919642459392, -2.6377129898164964, "temperature");
  s3 = new Capteur(789, 49.48611197434781, -2.537480514161824, "humidity");
  s4 = new Capteur(785, 49.463067100549324, -2.57141167924376, "humidity");

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
  //serveur requestion the config to the agents
  if (k<2) {
    serveur.requestJson();
    k++;
  }

  //Periodique send of the agent
  delay(6000);

  //Sensors sending the new data to the agents
  s1.send_datas();
  s2.send_datas();
  s3.send_datas();
  s4.send_datas();

  //Serveur requesting value to the agents
  serveur.requestValues(agent1);
  serveur.requestValues(agent2);

  //Sends data to IHM
  serveur.sendIHM();
}
