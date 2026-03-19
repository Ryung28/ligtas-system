import wave
import struct
import math

# Sound parameters
sample_rate = 44100
duration = 2.0  # seconds
frequency = 880.0  # A5 note (piercing)

# Generate a piercing "Bee-Boo" alarm sound
def generate_alarm():
    with wave.open(r'd:\LIGTAS_SYSTEM\mobile\android\app\src\main\res\raw\critical_alarm.wav', 'w') as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(sample_rate)
        
        for i in range(int(sample_rate * duration)):
            # Create a pulsing frequency effect
            freq = frequency if (i // (sample_rate // 2)) % 2 == 0 else frequency * 0.7
            value = int(32767 * 0.5 * math.sin(2.0 * math.pi * freq * (i / sample_rate)))
            data = struct.pack('<h', value)
            f.writeframesraw(data)

if __name__ == "__main__":
    generate_alarm()
    print("Tactical Alarm Generated successfully.")
