#include <Wire.h>

#if defined(ESP32)
  #include <WiFi.h>
#elif defined(ESP8266)
  #include <ESP8266WiFi.h>
#endif

#include <Firebase_ESP_Client.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"
#include "HX711.h"

// Firebase and Wi-Fi configuration
#define WIFI_SSID "REALMEE"
#define WIFI_PASSWORD "zalfa12345"
#define API_KEY "AIzaSyA5Clvlr4iYpzz9gwbXzoMETE8xq1O2mYc"
#define DATABASE_URL "https://ecoflow-11-7-default-rtdb.asia-southeast1.firebasedatabase.app/"

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

FirebaseData stream;

// Motor A
int motor1Pin1 = 27;
int motor1Pin2 = 26;
int enable1Pin = 14;

// Setting PWM properties
const int freq = 30000;
const int pwmChannel = 0;
const int resolution = 8;
int dutyCycle = 200;

// Load cell pins
const int LOADCELL_DOUT_PIN = 13;
const int LOADCELL_SCK_PIN = 12;
HX711 scale;

void streamCallback(FirebaseStream data);
void streamTimeoutCallback(bool timeout);

void setup() {
  // sets the pins as outputs:
  pinMode(motor1Pin1, OUTPUT);
  pinMode(motor1Pin2, OUTPUT);
  pinMode(enable1Pin, OUTPUT);
  
  // configure LEDC PWM
  ledcSetup(pwmChannel, freq, resolution);
  ledcAttachPin(enable1Pin, pwmChannel);

  Serial.begin(115200);

  // Connect to Wi-Fi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  // Firebase configuration
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

  // Firebase sign up
  if (Firebase.signUp(&config, &auth, "", "")) {
    Serial.println("Firebase sign-up successful.");
  } else {
    Serial.printf("Firebase sign-up failed. Error message: %s\n", config.signer.signupError.message.c_str());
  }

  config.token_status_callback = tokenStatusCallback;
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  // Start Firebase stream
  if (!Firebase.RTDB.beginStream(&stream, "/angkat")) {
    Serial.printf("Stream begin error, %s\n\n", stream.errorReason().c_str());
  }

  Firebase.RTDB.setStreamCallback(&stream, streamCallback, streamTimeoutCallback);

  // Initialize the HX711 sensor
  scale.begin(LOADCELL_DOUT_PIN, LOADCELL_SCK_PIN);
  scale.set_scale(230); // Set the scale factor
  scale.tare(); // Reset the scale to zero

  // Testing
  Serial.println("Testing DC Motor...");
}

void loop() {
  measureValues();
}

void measureValues() {
  float weight = scale.get_units(10);
  if (weight < 0) weight = 0; // Correct negative weight values
  Serial.print("Weight [g]: ");
  Serial.println(weight);
  float weightkg = weight / 1000.0;
  float weightRounded = round(weightkg * 100.0) / 100.0;

  // Save the formatted string to Firebase
  Firebase.RTDB.setFloat(&fbdo, "/status_sampah/status_penampungan", weightRounded);

  delay(2000);
}

void streamCallback(FirebaseStream data) {
  if (data.dataTypeEnum() == fb_esp_rtdb_data_type_string) {
    String read_data = data.stringData();
    Serial.print("Data received: ");
    Serial.println(read_data);
    if (read_data == "ON") {
      // Move the DC motor forward at maximum speed
      Serial.println("Moving Forward");
      digitalWrite(motor1Pin1, LOW);
      digitalWrite(motor1Pin2, HIGH);
      ledcWrite(pwmChannel, 255); // Set to maximum duty cycle
    } else if (read_data == "OFF") {
      // Ensure the motor is stopped
      Serial.println("Motor stopped by OFF command");
      digitalWrite(motor1Pin1, LOW);
      digitalWrite(motor1Pin2, LOW);
      ledcWrite(pwmChannel, 0); // Set duty cycle to 0 to stop the motor
      delay(5000); // Wait for 5 seconds

      // Move the DC motor backward at maximum speed
      Serial.println("Moving Backward");
      digitalWrite(motor1Pin1, HIGH);
      digitalWrite(motor1Pin2, LOW);
      ledcWrite(pwmChannel, 255); // Set to maximum duty cycle
      delay(18000); // Run motor for 10 seconds
      
      // Stop the DC motor
      Serial.println("Motor stopped");
      digitalWrite(motor1Pin1, LOW);
      digitalWrite(motor1Pin2, LOW);
      ledcWrite(pwmChannel, 0); // Set duty cycle to 0 to stop the motor
    }
  }
}

void streamTimeoutCallback(bool timeout) {
  if (timeout) {
    Serial.println("Stream timeout, resuming...\n");
  }
}