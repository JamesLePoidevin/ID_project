import fr.dgac.ivy.*;

class Capteur {
  private int id;
  private float longitude;
  private float latitude;
  private String type;
  private float value = 0;
  private Ivy bus;

  Capteur(int id_par, float longitude_par, float latitude_par, String type_par) {
    id = id_par;
    longitude = longitude_par;
    latitude = latitude_par;
    type = type_par; 

    String s = "Capteur :" +this.id;
    bus = new Ivy("Capteur", s, null);
    try {
      bus.start("127.255.255.255");
    }
    catch (IvyException ie) // Exception levée
    {
      System.out.println("Error connecting to agent bus");
      println(ie.getMessage());
    }
  }

  //Getters and Setters
  public int getID() {
    return this.id;
  }

  public float getLongitude() {
    return this.longitude;
  }

  public float getLatitude() {
    return this.latitude;
  }

  public String getType() {
    return this.type;
  }

  public float getValue() {
    return this.value;
  }

  public void setValue(float v) {
    this.value = v;
  }

  //Generates new values for each type of sensor
  public float generate_values() {
    float borneMax, borneMin;
    float value;

    if (type.equals("pressure")) { //en Pa
      borneMax = 1013.5; //pression au niveau de la mer
      borneMin = 200; //pression à 12km
    } else if (type.equals("temperature")) { //en degrès Celsius
      borneMax = 40; 
      borneMin = -20;
    } else if (type.equals("humidity")) { //pourcentage d'humidité relative 
      borneMax = 90; 
      borneMin = 70;
    } else {
      borneMax = 0;
      borneMin = 0;
    }
    value = borneMin + (float)Math.random() * (borneMax - borneMin);
    return value;
  }

  //Sends the data to the Agent
  public void send_datas() {
    try {
      bus.sendMsg("type=" + this.type + " ID=" + this.id + " lon=" + this.longitude + " lat=" + this.latitude + " value=" + this.generate_values()); // envoi un message
    } 
    catch (IvyException ie) // Exception levée
    {
      System.out.println("Error sending data");
      println(ie.getMessage());
    }
  }

  public String toString() {
    return "type=" + this.type + " ID=" + this.id + " lon=" + this.longitude + " lat=" + this.latitude + " value=" + this.value;
  }
}
