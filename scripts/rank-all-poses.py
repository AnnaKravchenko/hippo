import numpy as np
import sys, os
scorefile=sys.argv[1]
#frag=sys.argv[2]

scores=np.loadtxt(scorefile,np.float32)
ranks= (-scores).argsort().argsort()
print("#pose_id #HIPPO_rank")
for line in range(len(ranks)):
	print(line + 1, ranks[line]+1) 

