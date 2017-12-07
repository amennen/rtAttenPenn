import os, random
import glob
import csv


conditions=["happy","fear","neutral"]
folder=["rad","nim"]
gender=["F","M","F","M","F","M"]

left_rigth_F=[1,2]*27
random.shuffle(left_rigth_F)
left_rigth_M=[1,2]*27
random.shuffle(left_rigth_M)
F_order=0
M_order=0
for f in folder:
	for c in conditions:
		os.chdir('/home/vivs/vivi/banda_v6/FaceMatching/')
		F= glob.glob('stimuli/'+c+'/F_'+f+'/'+c+'*jpg')
		print len(F)
		 
		random.shuffle(F)
		F=F[0:18] #3 files in each you use 6 images
		M= glob.glob('stimuli'+os.sep+c+os.sep+'M_'+f+os.sep+c+'*jpg')
		print len(M)
		random.shuffle(M)
		
		M=M[0:18]#3 files in each you use 6 images
		
		gender=['F','M']*3
		random.shuffle(gender)
		run="A" if f=="rad" else "B"
		row_F=0
		row_M=0			
			
		for i in range(1,4):
			with open('/home/vivs/vivi/banda_v6/FaceMatching/blocks/block_'+run+'_'+c+'_'+str(i)+'.csv', 'wb') as csvfile:	
				condWriter = csv.writer(csvfile, delimiter=',',quotechar='|', quoting=csv.QUOTE_MINIMAL)
	    			condWriter.writerow(('top_image','left_image', 'right_image','corr_ans'))
				for g in gender:
					if g=='F':
						if left_rigth_F[F_order]==1:
							condWriter.writerow( (F[row_F],F[row_F],F[row_F+1],'1'))
						else:
							condWriter.writerow( (F[row_F],F[row_F+1],F[row_F],'2'))
						row_F=row_F+2
						F_order+=1
					else:
						if left_rigth_M[M_order]==1:
							condWriter.writerow( (M[row_M],M[row_M],M[row_M+1],'1'))
						else:
							condWriter.writerow( (M[row_M],M[row_M+1],M[row_M],'2'))
						row_M=row_M+2
						M_order+=1
						    				
										
