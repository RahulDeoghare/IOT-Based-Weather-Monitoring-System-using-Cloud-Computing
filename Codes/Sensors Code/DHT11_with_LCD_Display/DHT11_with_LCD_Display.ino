#include <dht.h>
#include <LiquidCrystal.h>

dht DHT;
#define DHT11_PIN 3
LiquidCrystal lcd(12, 11, 5, 4, 3, 2);

void setup() {
  lcd.begin(16, 2);
  lcd.print("DHT11 Example");
  delay(1000);
  lcd.clear();
}

void loop() {
  int chk = DHT.read11(DHT11_PIN);
  float humidity = DHT.humidity;
  float temperature = DHT.temperature;

  lcd.setCursor(0, 0);
  lcd.print("Temp: ");
  lcd.print(temperature);
  lcd.print((char)223);
  lcd.print("C");

  lcd.setCursor(0, 1);
  lcd.print("Humidity: ");
  lcd.print(humidity);
  lcd.print("%");

  delay(1000);
}