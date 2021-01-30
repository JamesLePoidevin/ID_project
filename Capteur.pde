import fr.dgac.ivy.*;

class Sensor{
  private int id;
  private float lon;
  private float lat;
  private String type;
  private float value = 0;
  private Ivy bus;
  
  protected Sensor(){};
  
  
  protected Sensor(int id_par, float loc_parX, float loc_parY, String type_par){
    id_par = id;
    loc_parX = lon;
    loc_parY = lat;
    type = type_par; 
  }
  
  protected Sensor(String type_par, int id_par, float loc_parX, float loc_parY, float val){
    id_par = id;
    loc_parX = lon;
    loc_parY = lat;
    type = type_par; 
    value = val;
  }
  
  public float generate_values(){
    float borneMax, borneMin;
    if (type.equals("pressure")){ //en Pa
        borneMax = 1013.5; //pression au niveau de la mer
        borneMin = 200; //pression à 12km
    }
    else if(type.equals("temperature")){ //en degrès Celsius
      borneMax = 40; 
      borneMin = -20;
    }
    else if(type.equals("humidity")){ //pourcentage d'humidité relative 
      borneMax = 90; 
      borneMin = 70; 
    }
    else{
      borneMax = 0;
      borneMin = 0;
    }
     float value = borneMin + (float)Math.random() * (borneMax - borneMin);
    return value;
  }
  
    public void send_datas(){
      Ivy bus = new Ivy("demo","Capteur",null);
      try{
        bus.start("127.255.255.255:2010"); // lancement du bus
      }
      catch(IvyException e){
        System.out.println("Erreur "+e);
      }
      
      try{
        bus.sendMsg("type=" + type + " ID=" + id + " lon=" + lon + " lat=" + lat + " value=" + this.generate_values()); // envoi un message
        } catch (IvyException ie) // Exception levée
          {System.out.println("can't send my message !");}
    
  }
}
