import sys
inputfile = sys.argv[1]
with open(inputfile) as ipfile:
  cnt = 0
  total = 0
  num = 0
  for line in ipfile:
    if cnt%3 == 0:
      pkgname=line
    elif cnt%3 == 1:
      tmp = line.split(':')
      total+=int(tmp[1])
    else:
      tmp=line.split(':')
      num+=int(tmp[1])
    cnt+=1

with open(inputfile, 'a') as opfile:
  opfile.write("\ntotal number of diff functions = " + str(num))
