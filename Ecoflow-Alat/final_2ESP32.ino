#include <HX711_ADC.h>
#include <Arduino.h>
#if defined(ESP32)
  #include <WiFi.h>
#elif defined(ESP8266)
  #include <ESP8266WiFi.h>
#endif
#include <Firebase_ESP_Client.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

// Wi-Fi and Firebase configuration
#define WIFI_SSID "REALMEE"
#define WIFI_PASSWORD "zalfa12345"
#define API_KEY "AIzaSyA5Clvlr4iYpzz9gwbXzoMETE8xq1O2mYc"
#define DATABASE_URL "https://ecoflow-11-7-default-rtdb.asia-southeast1.firebasedatabase.app"

// Firebase Data object
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
FirebaseData stream;

// Water Flow Sensor Pins and Variables
#define LED_BUILTIN 2
#define SENSOR1 34
#define SENSOR2 35
long currentMillis = 0;
long previousMillis = 0;
int interval = 1000;
float calibrationFactor = 4.5;
volatile byte pulseCount1;
byte pulse1Sec1 = 0;
float flowRate1;
unsigned int flowMilliLitres1;
bool waterDetected1 = false;
volatile byte pulseCount2;
byte pulse1Sec2 = 0;
float flowRate2;
unsigned int flowMilliLitres2;
bool waterDetected2 = false;

// Timing variables for status "ON" duration
bool statusOn = false;
unsigned long statusOnTime = 0;
const unsigned long statusOnDuration = 10000; // 10 seconds

// Function Prototypes
void IRAM_ATTR pulseCounter1();
void IRAM_ATTR pulseCounter2();
void updateDatabaseStatus(String status);
void updateDatabaseMappedValue(float mappedValue);

// Map function to convert flowDifference to a mapped value
float mapFlowDifference(int flowDifference) {
  // Define the min and max values for mapping
  float minValue = 0.0;
  float maxValue = 1.8;
  int minFlowDifference = 0;
  int maxFlowDifference = 30;

  // Ensure flowDifference is within the expected range
  if (flowDifference > maxFlowDifference) {
    flowDifference = maxFlowDifference;
  } else if (flowDifference < minFlowDifference) {
    flowDifference = minFlowDifference;
  }

  // Map the flowDifference to the range [minValue, maxValue]
  return minValue + ((float)flowDifference / (maxFlowDifference - minFlowDifference)) * (maxValue - minValue);
}

void setup() {
  // Initialize serial communication
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
  if (Firebase.signUp(&config, &auth, "", "")) {
    Serial.println("Firebase sign-up successful.");
  } else {
    Serial.printf("Firebase sign-up failed. Error message: %s\n", config.signer.signupError.message.c_str());
  }
  config.token_status_callback = tokenStatusCallback;
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  // Set up water flow sensor pins and interrupts
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(SENSOR1, INPUT_PULLUP);
  pinMode(SENSOR2, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(SENSOR1), pulseCounter1, FALLING);
  attachInterrupt(digitalPinToInterrupt(SENSOR2), pulseCounter2, FALLING);

  // Testing
  Serial.println("System setup complete.");
}

void loop() {
  // Water Flow Sensor data processing
  currentMillis = millis();
  if (currentMillis - previousMillis > interval) {
    pulse1Sec1 = pulseCount1;
    pulseCount1 = 0;
    flowRate1 = ((1000.0 / (currentMillis - previousMillis)) * pulse1Sec1) / calibrationFactor;
    flowMilliLitres1 = (flowRate1 / 60) * 1000;
    if (!waterDetected1) {
      flowRate1 = 0.0;
      flowMilliLitres1 = 0;
    }
    waterDetected1 = false;

    pulse1Sec2 = pulseCount2;
    pulseCount2 = 0;
    flowRate2 = ((1000.0 / (currentMillis - previousMillis)) * pulse1Sec2) / calibrationFactor;
    flowMilliLitres2 = (flowRate2 / 60) * 1000;
    if (!waterDetected2) {
      flowRate2 = 0.0;
      flowMilliLitres2 = 0;
    }
    waterDetected2 = false;

    // Print water flow data to serial monitor
    Serial.print("Sensor 1: ");
    Serial.print(flowMilliLitres1);
    Serial.print(" mL/min, ");
    Serial.print("Sensor 2: ");
    Serial.print(flowMilliLitres2);
    Serial.println(" mL/min");

    // Calculate the flow difference between the two sensors
    int flowDifference = abs((int)flowMilliLitres1 - (int)flowMilliLitres2);

    // Get the mapped value based on the flow difference
    float mappedValue = mapFlowDifference(flowDifference);
    Serial.print("Flow difference: ");
    Serial.print(flowDifference);
    Serial.print(", Mapped Value: ");
    Serial.println(mappedValue, 2); // Print mapped value with 2 decimal places

    // Update the mapped value to Firebase in real-time
    updateDatabaseMappedValue(mappedValue);

    // Update the Firebase database based on the flow difference
    if (flowDifference >= 30) {
      if (!statusOn) {
        updateDatabaseStatus("ON");
        statusOn = true;
        statusOnTime = currentMillis;
      }
    } else {
      if (statusOn && (currentMillis - statusOnTime >= statusOnDuration)) {
        updateDatabaseStatus("OFF");
        statusOn = false;
      }
    }

    previousMillis = currentMillis;
  }

  delay(500); // Delay before next iteration
}

void IRAM_ATTR pulseCounter1() {
  pulseCount1++;
  waterDetected1 = true;
}

void IRAM_ATTR pulseCounter2() {
  pulseCount2++;
  waterDetected2 = true;
}

void updateDatabaseStatus(String status) {
  // Update the status
  if (Firebase.RTDB.setString(&fbdo, "/angkat", status)) {
    Serial.print("Database updated to ");
    Serial.println(status);
  } else {
    Serial.print("Failed to update database to ");
    Serial.println(status);
    Serial.println(fbdo.errorReason());
  }
}

void updateDatabaseMappedValue(float mappedValue) {
  // Update the mapped value
  if (Firebase.RTDB.setFloat(&fbdo, "/status_sampah/status_jaring", mappedValue)) {
    Serial.print("Mapped Value updated to ");
    Serial.println(mappedValue);
  } else {
    Serial.print("Failed to update mapped value to ");
    Serial.println(mappedValue);
    Serial.println(fbdo.errorReason());
  }
}