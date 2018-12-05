import math

outputFileName = "lutSin.s"
entries = 512
fractionPoint = 12

f = open(outputFileName, "w+")
f.write("@ Size: %d bytes\n" % (entries * 2))
f.write("@       %f kilobytes\n" % (entries / 500))
f.write(".data\n.section .rodata\n.align 2\n.global LUT_SIN\nLUT_SIN:\n")

for i in range(entries):
    theta = i * ((2.0 * math.pi) / entries)
    halfWord = round(math.sin(theta) * (1 << fractionPoint))
    f.write("    .hword %d @ sin(%f) == sin(%f)\n" % (halfWord, theta, theta * (180.0 / math.pi)))

f.write("    .size LUT_SIN, .-LUT_SIN")
f.close() 