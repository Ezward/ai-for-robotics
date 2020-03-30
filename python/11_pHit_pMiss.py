#Write code that outputs p after multiplying each entry 
#by pHit or pMiss at the appropriate places. Remember that
#the red cells 1 and 2 are hits and the other green cells
#are misses.


p=[0.2,0.2,0.2,0.2,0.2]
pHit = 0.6
pMiss = 0.2

#Enter code here
c = ['g', 'r', 'r', 'g', 'g']
hit = 'r'

p = [(p[i] * (pHit if c[i] == hit else pMiss)) for i in range(len(p))]

print(p)