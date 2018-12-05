inputFileName = "test.obj"
outputFileName = "test_obj.h"

width = 1
height = 1
depth = 1
xPos = 0
yPos = 0
zPos = 0
objFile = open(inputFileName, 'r')
finalVertex = open(outputFileName, 'w')

vertexList = []
finalVertexList = []

for line in objFile:
	split = line.split()
	#if blank line, skip
	if not len(split):
		continue
	if split[0] == "v":
		vertexList.append(split[1:])
	elif split[0] == "f":
		count=1
		firstSet=[]
		secondSet=[]
		while count<5:
			removeSlash = split[count].split('/')
			if count == 1:
				firstSet.append(vertexList[int(removeSlash[0])-1])
				secondSet.append(vertexList[int(removeSlash[0])-1])
			elif count == 2:
				firstSet.append(vertexList[int(removeSlash[0])-1])
			elif count == 3:
				firstSet.append(vertexList[int(removeSlash[0])-1])
				secondSet.append(vertexList[int(removeSlash[0])-1])
			elif count == 4:
				secondSet.append(vertexList[int(removeSlash[0])-1])

			count+=1
		finalVertexList.append(firstSet)
		finalVertexList.append(secondSet)


def zSort(triangle):
    return ((float(triangle[0][2]) + float(triangle[1][2]) + float(triangle[2][2])) / 3)

for item in finalVertexList:
    finalVertexList.sort(key=zSort)


vertexCount = 0
finalVertex.write('int triangles[' + str(len(finalVertexList)) + '][3][3] = {\n')
for item in finalVertexList:
    finalVertex.write('\t{{')
    finalVertex.write(str(round(float(item[0][0]) * width + xPos))+', ')
    finalVertex.write(str(round(float(item[0][1]) * height + yPos))+', ')
    finalVertex.write(str(round(float(item[0][2]) * depth + zPos)))
    finalVertex.write('}, ')
    finalVertex.write('{')
    finalVertex.write(str(round(float(item[1][0]) * width + xPos))+', ')
    finalVertex.write(str(round(float(item[1][1]) * height + yPos))+', ')
    finalVertex.write(str(round(float(item[1][2]) * depth + zPos)))
    finalVertex.write('}, ')
    finalVertex.write('{')
    finalVertex.write(str(round(float(item[2][0]) * width + xPos))+', ')
    finalVertex.write(str(round(float(item[2][1]) * height + yPos))+', ')
    finalVertex.write(str(round(float(item[2][2]) * depth + zPos)))
    finalVertex.write('}}')
    vertexCount += 1
    if vertexCount != len(finalVertexList):
        finalVertex.write(',\n')
finalVertex.write('\n};')

print ("Total vertices: " + str(vertexCount*3))
print ("Total triangles: " + str(vertexCount))

objFile.close()
finalVertex.close()