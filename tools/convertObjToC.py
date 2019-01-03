import pywavefront as pf
import math
import os
import sys

# Set excecution dir to this files dir
exeDir = ''
if getattr(sys, 'frozen', False):
        exeDir = os.path.dirname(sys.executable)
else:
        exeDir = os.path.dirname(os.path.realpath(__file__))
os.chdir(exeDir)
print(os.getcwd())

# Options
inputFileName = "../res/objModel.obj"
outputSrcFileName = "../source/objModel.s"
outputIncFileName = "../include/objModel.h"
applyDirectionalLight = False
directionalLightX = 1
directionalLightY = 1
directionalLightZ = 1
directionalLightR = 1
directionalLightG = 1
directionalLightB = 1
scaleX = 1
scaleY = 1
scaleZ = 1

# Load model
model = pf.Wavefront(inputFileName, create_materials=True, collect_faces=True)
triangles = []

for name, material in model.materials.items():
    # Determin where the data is in the array
    vertexOffset = 0
    positionOffset = 0
    normalOffset = 0
    for string in material.vertex_format.split('_'):
        if string[0] == 'V':
            positionOffset = vertexOffset  
        elif string[0] == 'N':
            normalOffset = vertexOffset
        vertexOffset += int(string[1])

    # Calculate light
    directionalLightLen = math.sqrt(directionalLightX * directionalLightX + directionalLightY * directionalLightY + directionalLightZ * directionalLightZ)
    directionalLightX /= directionalLightLen
    directionalLightY /= directionalLightLen
    directionalLightZ /= directionalLightLen

    # Get vertices
    vertexCount = int(len(material.vertices) / vertexOffset)
    triangleCount = int(vertexCount / 3)
    for triagleIdx in range(triangleCount):
        arrayOffset = triagleIdx * 3 * vertexOffset
        triangle = []

        # Triangle pos1
        triangle.append(round(material.vertices[arrayOffset + positionOffset + 0] * scaleX))
        triangle.append(round(material.vertices[arrayOffset + positionOffset + 1] * scaleY))
        triangle.append(round(material.vertices[arrayOffset + positionOffset + 2] * scaleZ))

        # Triangle pos2
        triangle.append(round(material.vertices[arrayOffset + positionOffset + 0 + vertexOffset] * scaleX))
        triangle.append(round(material.vertices[arrayOffset + positionOffset + 1 + vertexOffset] * scaleY))
        triangle.append(round(material.vertices[arrayOffset + positionOffset + 2 + vertexOffset] * scaleZ))

        # Triangle pos3
        triangle.append(round(material.vertices[arrayOffset + positionOffset + 0 + vertexOffset * 2] * scaleX))
        triangle.append(round(material.vertices[arrayOffset + positionOffset + 1 + vertexOffset * 2] * scaleY))
        triangle.append(round(material.vertices[arrayOffset + positionOffset + 2 + vertexOffset * 2] * scaleZ))

        # Colour
        colourR = material.diffuse[0]
        colourG = material.diffuse[1]
        colourB = material.diffuse[2]

        # Calculate diffuse
        if applyDirectionalLight:
            triangleSide1X = triangle[3] - triangle[0]
            triangleSide1Y = triangle[4] - triangle[1]
            triangleSide1Z = triangle[5] - triangle[2]
            triangleSide2X = triangle[6] - triangle[0]
            triangleSide2Y = triangle[7] - triangle[1]
            triangleSide2Z = triangle[8] - triangle[2]

            normalX = (triangleSide1Y * triangleSide2Z) - (triangleSide1Z * triangleSide2Y)
            normalY = (triangleSide1Z * triangleSide2X) - (triangleSide1X * triangleSide2Z)
            normalZ = (triangleSide1X * triangleSide2Y) - (triangleSide1Y * triangleSide2X)
            normalLen = math.sqrt(normalX * normalX + normalY * normalY + normalZ * normalZ)
            normalX /= normalLen
            normalY /= normalLen
            normalZ /= normalLen

            dotX = normalX * directionalLightX
            dotY = normalY * directionalLightY
            dotZ = normalZ * directionalLightZ
            diffuse = max(dotX + dotY + dotZ, 0.0)

            colourR = max(0.0, min(colourR * diffuse * directionalLightR, 1.0))
            colourG = max(0.0, min(colourG * diffuse * directionalLightG, 1.0))
            colourB = max(0.0, min(colourB * diffuse * directionalLightB, 1.0))

        # Calculate color
        hexColour =  (int(colourB * 31) << 10) 
        hexColour |= (int(colourG * 31) << 5) 
        hexColour |= (int(colourR * 31) << 0)

        # Add colour
        triangle.append(int(hexColour))
        triangles.append(triangle)


# Sort trinagles
def zSort(triangle):
    return ((float(triangle[2]) + float(triangle[5]) + float(triangle[8])) / 3)

for triangle in triangles:
    triangles.sort(key=zSort)

# Format text
f = open(outputSrcFileName, "w+")
f.write("@ Size: %d bytes\n" % (len(triangles) * 10 * 2))
f.write("@       %f kilobytes\n" % ((len(triangles) * 10 * 2) / 1000))
f.write(".data\n.section .ewram\n.align 2\n.global OBJ_MODEL\nOBJ_MODEL:\n")

for triangle in triangles:
    f.write("    .hword ")
    f.write(str(triangle[0]) + ", ")
    f.write(str(triangle[1]) + ", ")
    f.write(str(triangle[2]) + ", ")
    f.write(str(triangle[3]) + ", ")
    f.write(str(triangle[4]) + ", ")
    f.write(str(triangle[5]) + ", ")
    f.write(str(triangle[6]) + ", ")
    f.write(str(triangle[7]) + ", ")
    f.write(str(triangle[8]) + ", ")
    f.write(str(triangle[9]) + "\n")

f.write("    .size OBJ_MODEL, .-OBJ_MODEL")
f.close() 

f = open(outputIncFileName, "w+")
f.write("#pragma once\n")
f.write('#include "./types.h"\n')
f.write('#include "./asm/graphics.h"\n\n')
f.write("#define OBJ_MODEL_SIZE %d\n" % (len(triangles)))
f.write('extern "C" const s16 OBJ_MODEL[OBJ_MODEL_SIZE][10];\n\n')

f.write("void drawObjModel(u32 vramAdress, s32 camX, s32 camY, s32 camZ) {\n")
f.write("    for (int tri = 0; tri < OBJ_MODEL_SIZE; tri++) {\n")
f.write("        drawTriangleClipped3D(vramAdress,   -OBJ_MODEL[tri][2] + camX, OBJ_MODEL[tri][1] + camY, OBJ_MODEL[tri][0] + camZ,\n")
f.write("                                            -OBJ_MODEL[tri][5] + camX, OBJ_MODEL[tri][4] + camY, OBJ_MODEL[tri][3] + camZ,\n")
f.write("                                            -OBJ_MODEL[tri][8] + camX, OBJ_MODEL[tri][7] + camY, OBJ_MODEL[tri][6] + camZ,\n")
f.write("                                            (u32)(&OBJ_MODEL[tri][9]));\n")
f.write("    }\n")
f.write("}\n")
f.close()

print("SUCCES")