import serial
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from collections import deque
import argparse

parser = argparse.ArgumentParser("Live Graph of Ambient Light Sensor Data")
parser.add_argument('-p', '--port', type=str, default='/dev/ttyUSB0', help='Serial port to read (default: /dev/ttyUSB0)')
parser.add_argument('-b', '--baud', type=int, default=115200, help='Baud rate (default: 115200)')
parser.add_argument('-s', '--samples', type=int, default=5000, help='Number of samples to show on screen (default: 5000)')
parser.add_argument('-t', '--skip', type=int, default=10, help='Number of samples to skip (default: 10)')
args = parser.parse_args()

# Open the serial port
try:
    ser = serial.Serial(args.port, args.baud, timeout=1)
    print(f"Connected to {args.port}")
except Exception as e:
    print(f"Failed to connect: {e}")
    exit()

y_data = deque([0] * args.samples, maxlen=args.samples)

fig, ax = plt.subplots()
ax.set_title('Live ADC Data Stream')
ax.set_ylabel('ADC Value (0-255)')
ax.set_ylim(-10, 265)

line, = ax.plot(y_data, color='blue')

message_counter = 0
def update_graph(frame):
    global message_counter
    if ser.in_waiting > 0:
        raw_bytes = ser.read(ser.in_waiting)
        
        for byte_val in raw_bytes:
            message_counter += 1

            if message_counter >= args.skip:
                y_data.append(byte_val)
                message_counter = 0
            
        line.set_ydata(y_data)
        
    return line,

ani = animation.FuncAnimation(fig, update_graph, interval=10, blit=True, cache_frame_data=False)

plt.show()
