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
outputSrcFileName = "../source/asm/objModelGM.s"
outputIncFileName = "../include/asm/objModelGM.h"
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

# Get all gmMod files
def getFiles(dirName):
    listOfFile = os.listdir(dirName)
    allFiles = list()
    for entry in listOfFile:
        fullPath = os.path.join(dirName, entry)
        if os.path.isdir(fullPath):
            allFiles = allFiles + getFiles(fullPath)
        elif fullPath[-6:] == ".gmmod":
            allFiles.append(fullPath)    
    return allFiles 

gmModFiles = getFiles(inputDir)


# Sort trinagles
def zSort(triangle):
    return ((float(triangle[2]) + float(triangle[5]) + float(triangle[8])) / 3)

# Get triangles
gmModTriangles = {}
for gmModFileName in gmModFiles:
    # Load model
    triangles = []

    with open(gmModFileName,"r") as gmModFile:
        triangle = []
        for line in gmModFile:
            vertex = line[2:].split()

            # Get vertex
            if line.startswith("9 "):
                triangle.append(round(float(vertex[0]) * scaleX))
                triangle.append(round(-float(vertex[2]) * scaleX))
                triangle.append(round(float(vertex[1]) * scaleX))
            else:
                continue
            
            # New triangle
            if len(triangle) >= 9:
                # Get color
                colourR = (int(float(vertex[8])) & 255) / 255.0
                colourG = ((int(float(vertex[8])) >> 8) & 255) / 255.0
                colourB = ((int(float(vertex[8])) >> 16) & 255) / 255.0

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
                triangle = []
    
    for triangle in triangles:
        triangles.sort(key=zSort, reverse=True)
    
    gmModTriangles[os.path.basename(gmModFileName)] = triangles


# Calculate total size
totalSize = 0
for gmModFileName, triangles in gmModTriangles.items():
    totalSize += (len(triangles) * 10 * 2)

# Write assembly data
f = open(outputSrcFileName, "w+")
f.write("@ Total size: %d bytes\n" % totalSize)
f.write("\n")
for gmModFileName, triangles in gmModTriangles.items():
    f.write("@ Size: %d bytes\n" % (len(triangles) * 10 * 2))
    gmModName = (gmModFileName[:-6]).upper()
    f.write(".data\n.section .iwram\n.align 2\n.global " + gmModName + "\n" + gmModName + ":\n")

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

    f.write("    .size " + gmModName + ", .-" + gmModName + "\n\n")
f.close() 

# Write header file
f = open(outputIncFileName, "w+")
f.write("#pragma once\n")
f.write('#include "../types.h"\n')
for gmModFileName, triangles in gmModTriangles.items():
    gmModName = (gmModFileName[:-6]).upper()
    f.write("#define " + gmModName + "_SIZE %d\n" % (len(triangles)))
    f.write('extern "C" const s16 ' + gmModName + '[' + gmModName + '_SIZE][10];\n\n')
f.close() 

print("SUCCES")