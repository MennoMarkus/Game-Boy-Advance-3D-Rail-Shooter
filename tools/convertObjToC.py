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
inputDir = "..\\res"
outputSrcFileName = "../source/asm/objModel.s"
outputIncFileName = "../include/asm/objModel.h"
applyDirectionalLight = False
directionalLightX = -1
directionalLightY = -1
directionalLightZ = 1
directionalLightR = 1
directionalLightG = 1
directionalLightB = 1
scaleX = 1
scaleY = 1
scaleZ = 1

# Get all obj files
def getFiles(dirName):
    listOfFile = os.listdir(dirName)
    allFiles = list()
    for entry in listOfFile:
        fullPath = os.path.join(dirName, entry)
        if os.path.isdir(fullPath):
            allFiles = allFiles + getFiles(fullPath)
        elif fullPath[-4:] == ".obj":
            allFiles.append(fullPath)    
    return allFiles 

objFiles = getFiles(inputDir)


# Sort trinagles
def zSort(triangle):
    return ((float(triangle[2]) + float(triangle[5]) + float(triangle[8])) / 3)

# Get triangles
objTriangles = {}
for objFileName in objFiles:
    # Load model
    model = pf.Wavefront(objFileName, create_materials=True, collect_faces=True)
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

            # Sort triangle vertices
            if triangle[5] > triangle[2]:
                triangle[0], triangle[3] = triangle[3], triangle[0]
                triangle[1], triangle[4] = triangle[4], triangle[1]
                triangle[2], triangle[5] = triangle[5], triangle[2]
            if triangle[8] > triangle[5]:
                triangle[3], triangle[6] = triangle[6], triangle[3]
                triangle[4], triangle[7] = triangle[7], triangle[4]
                triangle[5], triangle[8] = triangle[8], triangle[5]

            if triangle[5] > triangle[2]:
                triangle[0], triangle[3] = triangle[3], triangle[0]
                triangle[1], triangle[4] = triangle[4], triangle[1]
                triangle[2], triangle[5] = triangle[5], triangle[2]

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

    for triangle in triangles:
        triangles.sort(key=zSort, reverse=True)
    
    objTriangles[os.path.basename(objFileName)] = triangles


# Calculate total size
totalSize = 0
for objFileName, triangles in objTriangles.items():
    totalSize += (len(triangles) * 10 * 2)

# Write assembly data
f = open(outputSrcFileName, "w+")
f.write("@ Total size: %d bytes\n" % totalSize)
f.write("\n")
for objFileName, triangles in objTriangles.items():
    f.write("@ Size: %d bytes\n" % (len(triangles) * 10 * 2))
    objName = (objFileName[:-4]).upper()
    f.write(".data\n.section .iwram\n.align 2\n.global " + objName + "\n" + objName + ":\n")

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

    f.write("    .size " + objName + ", .-" + objName + "\n\n")
f.close() 

# Write header file
f = open(outputIncFileName, "w+")
f.write("#pragma once\n")
f.write('#include "../types.h"\n')
for objFileName, triangles in objTriangles.items():
    objName = (objFileName[:-4]).upper()
    f.write("#define " + objName + "_SIZE %d\n" % (len(triangles)))
    f.write('extern "C" const s16 ' + objName + '[' + objName + '_SIZE][10];\n\n')

print("SUCCES")