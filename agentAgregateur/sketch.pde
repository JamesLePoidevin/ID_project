import fr.dgac.ivy.*;


agent agent1;

void setup() {
    agent1 = new agent(1);
    size(640, 360);
}

void loop() {
    try {
        Thread.sleep(60000);
    } catch(InterruptedException e) {
        agent1.send();
    }
}
