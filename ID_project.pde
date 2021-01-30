//import fr.dgac.ivy.*;
Agent agent1;

    //int id1 = 123;
    //float locX1 = 2.3;
    //float locY1 = 4.9;
    //String type1 = "pressure";
    //s1 = new Sensor(id1, locX1, locY1, type1);
    
    int id2 = 456;
    float locX2 = 45.98;
    float locY2 = 456.9;
    String type2 = "temperature";
    Sensor s2 = new Sensor(id2, locX2, locY2, type2);
    
    int id3 = 789;
    float locX3 = 289.38;
    float locY3 = 445645.9;
    String type3 = "humidity";
    Sensor s3 = new Sensor(id3, locX3, locY3, type3);

void setup() {

    
    agent1 = new Agent(1);
    
}

void draw() {
    
    s2.send_datas();
    s3.send_datas();
    //Periodique send of the agent
    try {
        Thread.sleep(6000);
        agent1.prin();
        agent1.send();
        
    } catch(InterruptedException e) {
    
   }
}
