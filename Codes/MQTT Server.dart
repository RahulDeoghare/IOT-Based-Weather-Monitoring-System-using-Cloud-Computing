//..........................................** Smart Weather Monitoring System **.................................................................................................
//...............................................................................................................................................................................

#include <ESP8266WiFi.h> //WiFi library
#include <PubSubClient.h> //publish-subscribe(MQTT)
#include <DHT.h> // DHT sensor library

// Uncomment one of the lines bellow for whatever DHT sensor type you're using!
#define DHTTYPE DHT11   // DHT 11

// My wifi credentials
const char* ssid = "BATMAN";
const char* password = "12345678";

//connects to our MQTT broker
const char* mqtt_server = "18.188.190.213"; //our server IP address

// Initializes the espClient
WiFiClient espClient;
PubSubClient client(espClient);

// DHT Sensor - GPIO 5 = D1 on NodeMCU board
const int DHTPin = 5;

// Initialize DHT sensor.
DHT dht(DHTPin, DHTTYPE);

// Timer variables
long now = millis();
long lastMeasure = 0;

//This functions connects our ESP8266 to our router
void setup_wifi() 
{
  delay(10);
  // We start by connecting to a WiFi network
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) 
  {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.print("WiFi connected - ESP IP address: ");
  Serial.println(WiFi.localIP());
}

// This functions reconnects our ESP8266 to our MQTT broker
void reconnect() 
{
  // Loop until we're reconnected
  while (!client.connected()) 
  {
    Serial.print("Attempting MQTT connection...");
    if (client.connect("","","")) {   //id,id,password (No id & password in our case)
      Serial.println("connected");} 
  }
}

void setup() 
{
  dht.begin();
  Serial.begin(115200);// begins serial communication at 115200 baud rate
  setup_wifi();
  client.setServer(mqtt_server, 1883);// Default port number for Mqtt 
}

void loop() 
{
  if (!client.connected()) 
    reconnect();
    
  if(!client.loop())
    client.connect("ESP8266Client");

  now = millis(); //starts the timer 
  // Publishes new temperature and humidity every 30 seconds
  if (now - lastMeasure > 30000) 
  {
    lastMeasure = now;
    // Read humidity in %
    float h = dht.readHumidity();
    // Read temperature in °C
    float t = dht.readTemperature();

    // Check if any reads failed and exit early (to try again)
    if (isnan(h) || isnan(t)) 
    {
      Serial.println("Failed to read from DHT sensor!");
      return;
    }

    static char temperatureTemp[7]; //char array temperatureTemp 
    dtostrf(t, 6, 2, temperatureTemp);//converts float to string and stores in temperatureTemp array 
    
    static char humidityTemp[7];//char array humidityTemp 
    dtostrf(h, 6, 2, humidityTemp); //converts float to string and stores in humidityTemp array 

    // Publishes Temperature and Humidity values
    client.publish("room/temperature1", temperatureTemp); 
    client.publish("room/humidity1", humidityTemp);

    //Prints values on serial monitor
    Serial.print("Humidity: ");
    Serial.print(h);
    Serial.print("%\t Temperature: ");
    Serial.print(t);
    Serial.println("°C ");

  }
} 
//...............................................................................................................................................................................
//.............................................** END **...........................................................................................................................