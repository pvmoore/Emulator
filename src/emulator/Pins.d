module emulator.Pins;

interface Pins {
   bool getPin(string name);
   bool getPin(uint index);
   void setPin(string name);
   void setPin(uint index);
}