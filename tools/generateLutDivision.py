maxDenominator = 250 #Value between 0 and 1073741823
outputFileName = "lutDivisions.s"

f = open(outputFileName, "w+")
f.write("@ Size: %d bytes\n" % ((maxDenominator + 1) * 4))
f.write("@       %f kilobytes\n" % ((maxDenominator + 1) / 250))
f.write(".data\n.section .rodata\n.align 2\n.global LUT_DIVISION\nLUT_DIVISION:\n")

i = 0
while i <= maxDenominator:
    if i == 0:
        r = 0
    elif i == 1:
        r = 4294967295
    else:
        r = round((1/i) * 4294967296)
    f.write("    .word %d @ 1 / %d\n" % (r, i))
    i += 1

f.write("    .size LUT_DIVISION, .-LUT_DIVISION")
f.close() 