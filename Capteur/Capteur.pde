import fr.dgac.ivy.*;

class Sensor{
  private int id;
  private float localisationX;
  private float localisationY;
  private String type;
  private Ivy bus;
  
  protected Sensor(){};
  protected Sensor(int id_par, float loc_parX, float loc_parY, String type_par){
    id_par = id;
    loc_parX = localisationX;
    loc_parY = localisationY;
    type = type_par; 
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
     println(value);
     return value;
  }
  
    public void send_datas(float value){
      Ivy bus = new Ivy("demo","Capteur",null);
      try{bus.start("127.255.255.255:2010"); // lancement du bus
      } catch(IvyException e){System.out.println("Erreur "+e);}
      try{
        //bus.sendMsg("hey");
        bus.sendMsg("type=" + type + " ID=" + id + " lon=" + localisationX + " lat=" + localisationY + " value=" + value); // envoi un message
        } catch (IvyException ie) // Exception levée
          {System.out.println("can't send my message !");}
     try{    
            bus.bindMsg("type=(.*) ID=(.*) lon=(.*) lat=(.*) value=(.*)", new IvyMessageListener() {
                public void receive(IvyClient client, String[] args)
                {
                    Sensor Capteurtemp = new Sensor(Integer.parseInt(args[0]),Float.parseFloat(args[2]),Float.parseFloat(args[3]),(args[4]));
                  
                }
        } );
        } catch(IvyException ie) {
            println("error connecting to Capteurs");
        }
     
  }
}
