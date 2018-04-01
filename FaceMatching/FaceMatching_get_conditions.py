import os
import csv
import numpy as np
import itertools
import subprocess


#See conditions nname below

def register_images(subject_dir, subject_id):
    fmA_infile =os.path.join(subject_dir)
    fmA_outfile = os.path.join(subject_dir, 'model', 'model001','onsets','task002_run001')
    fmB_infile =os.path.join(subject_dir)
    fmB_outfile = os.path.join(subject_dir, 'model', 'model001','onsets','task002_run002')
   
    if not os.path.exists(fmA_outfile):
        print 'Creating: %s folder' % fmA_outfile
        cmd = 'mkdir -p  %s' % str(subject_dir)+'/model/model001/onsets/task002_run001'
        print cmd       
        os.system(cmd)
    if not os.path.exists(fmB_outfile):
        print 'Creating: %s folder' % fmB_outfile
        cmd = 'mkdir -p  %s' % str(subject_dir)+'/model/model001/onsets/task002_run002'
        os.system(cmd)



    fmA_name = str(subject_id)  #raw_input("Please enter subect number for BreathCounting: ")
    #os.system('echo '+BC_infile+'/BreathCount_'+str(session)+'_'+str(BC_name)+'*_events.csv')  
    fmA_file=subprocess.check_output('echo '+fmA_infile+'/'+str(fmA_name)+'*_A_FaceMatching*.csv', shell=True)
    fmB_file=subprocess.check_output('echo '+fmB_infile+'/'+str(fmA_name)+'*_B_FaceMatching*.csv', shell=True)
    #BC_file=subprocess.check_output('echo *'+str(BC_name)+'*.csv', shell=True)
    fmA_file= fmA_file[:-1]
    fmB_file= fmB_file[:-1]

    print 'found file: ',fmA_file
    print 'found file: ',fmB_file


    #looking for run A events
    happy_events=[]
    fear_events=[]
    neutral_events=[]
    objects_events=[]
    
        
    happyA_file= open(str(fmA_outfile)+'/cond001.txt', 'wb')
    happyA=[]
        
    fearA_file=open(str(fmA_outfile)+'/cond002.txt', 'wb')
    fearA=[]  

    neutralA_file=open(str(fmA_outfile)+'/cond003.txt', 'wb')
    neutralA=[]

    objectsA_file=open(str(fmA_outfile)+'/cond004.txt', 'wb')
    objectsA=[]
    
    fixationA_file=open(str(fmA_outfile)+'/fixation.txt', 'wb')
    
    with open(fmA_file, 'rU') as f:
        reader=csv.reader(f)
        my_dataA=map(tuple,reader)
        
        count=0
        fixation_sum=0
        
        for i in range(3,len(my_dataA)): #block_starts:
            
            happyA_write = csv.writer(happyA_file, delimiter=' ', lineterminator='\n')
            fearA_write = csv.writer(fearA_file, delimiter=' ', lineterminator='\n')
            neutralA_write = csv.writer(neutralA_file, delimiter=' ', lineterminator='\n')
            objectsA_write = csv.writer(objectsA_file, delimiter=' ', lineterminator='\n')
            fixationA_write = csv.writer(fixationA_file, delimiter=' ', lineterminator='\n')
            
            
            if 'happy' in my_dataA[i][2]:
                print count,my_dataA[i][2],count*3+fixation_sum,3,1
                count+=1
                happyA_write.writerow((count*3+fixation_sum,3,1))
            elif 'fear' in my_dataA[i][2]:
                print count,my_dataA[i][2],count*3+fixation_sum,3,1
                fearA_write.writerow((count*3+fixation_sum,3,1))
                count+=1
            elif 'neutral' in my_dataA[i][2]:
                print count,my_dataA[i][2],count*3+fixation_sum,3,1
                neutralA_write.writerow((count*3+fixation_sum,3,1))
                count+=1
            elif 'object' in my_dataA[i][2]:
                print count,my_dataA[i][2],count*3+fixation_sum,3,1
                objectsA_write.writerow((count*3+fixation_sum,3,1))
                count+=1
            elif 'fixation'in my_dataA[i][0]:
                print count, my_dataA[i][0],count*3+fixation_sum,18,1
                fixationA_write.writerow((count*3+fixation_sum,18,1))
                fixation_sum+=18
            
            else:
                print count


    #looking for run B events
    happy_events=[]
    fear_events=[]
    neutral_events=[]
    objects_events=[]
    

    happyB_file= open(str(fmB_outfile)+'/cond001.txt', 'wb')
    happyB=[]
        
    fearB_file=open(str(fmB_outfile)+'/cond002.txt', 'wb')
    fearB=[]  

    neutralB_file=open(str(fmB_outfile)+'/cond003.txt', 'wb')
    neutralB=[]

    objectsB_file=open(str(fmB_outfile)+'/cond004.txt', 'wb')
    objectsB=[]
    
    fixationB_file=open(str(fmB_outfile)+'/fixation.txt', 'wb')
    
    with open(fmB_file, 'rU') as f:
        reader=csv.reader(f)
        my_dataB=map(tuple,reader)
        
        countB=0
        fixation_sumB=0
        
        for i in range(3,len(my_dataB)): #block_starts:
            happyB_write = csv.writer(happyB_file, delimiter=' ', lineterminator='\n')
            fearB_write = csv.writer(fearB_file, delimiter=' ', lineterminator='\n')
            neutralB_write = csv.writer(neutralB_file, delimiter=' ', lineterminator='\n')
            objectsB_write = csv.writer(objectsB_file, delimiter=' ', lineterminator='\n')
            fixationB_write = csv.writer(fixationB_file, delimiter=' ', lineterminator='\n')
          
                
            if 'happy' in my_dataB[i][2]:
                print countB,my_dataB[i][2],countB*3+fixation_sumB,3,1
                countB+=1
                happyB_write.writerow((countB*3+fixation_sumB,3,1))
            elif 'fear' in my_dataB[i][2]:
                print countB,my_dataB[i][2],countB*3+fixation_sumB,3,1
                fearB_write.writerow((countB*3+fixation_sumB,3,1))
                countB+=1
            elif 'neutral' in my_dataB[i][2]:
                print countB,my_dataB[i][2],countB*3+fixation_sumB,3,1
                neutralB_write.writerow((countB*3+fixation_sumB,3,1))
                countB+=1
            elif 'object' in my_dataB[i][2]:
                print countB,my_dataB[i][2],countB*3+fixation_sumB,3,1
                objectsB_write.writerow((countB*3+fixation_sumB,3,1))
                countB+=1 
            elif 'fixation'in my_dataB[i][0]:
                print countB, my_dataB[i][0],countB*3+fixation_sumB,18,1
                fixationB_write.writerow((countB*3+fixation_sumB,18,1))
                fixation_sumB+=18       
            
            else:
                print countB
        



    print count
    print "####################"

    print "#####    A     ####"
    print "succesfully created:\n ",happyA_file
    print "succesfully created:\n ",fearA_file
    print "succesfully created:\n ",neutralA_file
    print "succesfully created:\n ",objectsA_file
    print "succesfully created:\n ",fixationA_file
    print "####################"
    print "####################"

    print "#####    B     ####"
    print "succesfully created:\n ",happyB_file
    print "succesfully created:\n ",fearB_file
    print "succesfully created:\n ",neutralB_file
    print "succesfully created:\n ",objectsB_file
    print "succesfully created:\n ",fixationB_file
    print "####################"


if __name__ == "__main__":
    import argparse
    defstr = ' (default %(default)s)'
    parser = argparse.ArgumentParser(prog='FaceMatch_get_conditions_om.py',
                                     description=__doc__)
    parser.add_argument('-dir', dest='subject_dir', required=True,
                        help='BANDA subject dir')
    parser.add_argument('-id', dest='subject_id', required=True,
                        help="subject id")
    
    args = parser.parse_args()
    register_images(args.subject_dir, args.subject_id) 
        
       


