import matplotlib.pyplot as plt

cycles = []
with open("docs/logging.txt") as openFile:
    for line in openFile:
        strings = line.split()
        for i in range(len(strings)):
            if strings[i] == "TIMER" and strings[i+1] == "END:":
                cycles.append(int(strings[i+2].replace(',', '')))

print("HIGHEST: " + str(max(cycles)))
print("LOWEST: " + str(min(cycles)))
print("AVERAGE: " + str(round(sum(cycles) / len(cycles))))

plt.plot(range(len(cycles)), cycles, label='Cycles over time')
plt.xlabel('frame')
plt.ylabel('cycles')
plt.title('Profiler data')
plt.legend()
plt.show()