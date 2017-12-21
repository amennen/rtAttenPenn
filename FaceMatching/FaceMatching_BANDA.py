#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This experiment was created using PsychoPy2 Experiment Builder (v1.82.02), Sat Jan  9 02:16:18 2016
If you publish work using this script please cite the relevant PsychoPy publications
  Peirce, JW (2007) PsychoPy - Psychophysics software in Python. Journal of Neuroscience Methods, 162(1-2), 8-13.
  Peirce, JW (2009) Generating stimuli for neuroscience using PsychoPy. Frontiers in Neuroinformatics, 2:10. doi: 10.3389/neuro.11.010.2008
"""

from __future__ import division  # so that 1/3=0.333 instead of 1/3=0
from psychopy import visual, core, data, event, logging, gui
from psychopy.constants import *  # things like STARTED, FINISHED
import numpy as np  # whole numpy lib is available, prepend 'np.'
from numpy import sin, cos, tan, log, log10, pi, average, sqrt, std, deg2rad, rad2deg, linspace, asarray
from numpy.random import random, randint, normal, shuffle
import os  # handy system and path functions


# Python version = 2.7.2
# Platform = Win32
import random
import itertools
from itertools import groupby
import os
import csv


configFile=os.path.abspath( os.path.join(os.path.abspath(__file__), '../..'))
configFile=os.path.join(configFile,'config.csv')
if os.path.exists(configFile):
    with open(configFile, 'rb') as csvfile:
        spamreader = csv.reader(csvfile, delimiter=',', quotechar='|')
        for row in spamreader:
            if row[0]=="output":
                output=row[1]
else:
    # CHANGED FOR THIS FILE!!
    outerpath = '/Users/amennen/Dropbox/rtPennBehavData/facematching/'
    output=os.path.abspath(os.path.join(outerpath,"tfMRI_output"))

    
_thisDir = os.path.dirname(os.path.abspath(__file__))
os.chdir(_thisDir)
expName = 'Resting'

# Collect run mode and participant ID
expInfo = {}
dlg1 = gui.Dlg(title="Participant ID")
dlg1.addField('Participant')
dlg1.addField('Mode', choices=["Scanner", "Practice"])# , "Debug"])
dlg1.addField('Group', choices=["HC", "MDD"])
dlg1.addField('Session', choices=["ABCD","IPAT2","CMRR"])
dlg1.addField('Run', choices= ["AB"]) #,"Practice"])
dlg1.show()
if dlg1.OK:  # then the user pressed OK
    # add the new entries to expInfo
    expInfo['participant'] = dlg1.data[0]
    expInfo['runMode'] = dlg1.data[1]
    expInfo['group'] = dlg1.data[2]
    expInfo['session'] = dlg1.data[3]
    expInfo['run'] = dlg1.data[4]
    expInfo['CB'] = "1" #dlg2.data[2]
    RunMode = expInfo['runMode']
else:
    core.quit() # user pressed cancel

expName = 'FaceMatching'
expInfo['expName'] = expName
expInfo['date'] = data.getDateStr()  # add a simple timestamp

# Data file name stem = absolute path + name; later add .psyexp, .csv, .log, etc
#filename = 'data/'+expInfo['participant']+ os.path.sep + '%s_%s_%s_%s_%s' %(expInfo['participant'],expInfo['session'],expInfo['run'],expName,expInfo['date'])
filename = output + os.sep + expInfo['participant'] + os.sep +'%s_%s_%s_%s_%s_%s' %(expInfo['participant'],expInfo['runMode'],expInfo['session'],expInfo['run'],expInfo['expName'],expInfo['date'])
 

            

if expInfo['runMode']=="Scanner":
    runs=["A","B"]
else:
    runs=["Practice"]

# An ExperimentHandler isn't essential but helps with data saving
thisExp = data.ExperimentHandler(name=expName, version='',
    extraInfo=expInfo, runtimeInfo=None,
    originPath=None,
    savePickle=True, saveWideText=True,
    dataFileName=filename)
#save a log file for detail verbose info
logFile = logging.LogFile(filename+'.log', level=logging.EXP)
logging.console.setLevel(logging.WARNING)  # this outputs to the screen, not a file

endExpNow = False  # flag for 'escape' or other condition => quit the exp

# Start Code - component code to be run before the window creation

# Setup the Window
win = visual.Window(size=(800, 600), fullscr=True, screen=1, allowGUI=False, allowStencil=False,
    monitor='testMonitor', color=[0,0,0], colorSpace='rgb',
    blendMode='avg', useFBO=True,
    )
# store frame rate of monitor if we can measure it successfully
expInfo['frameRate']=win.getActualFrameRate()
if expInfo['frameRate']!=None:
    frameDur = 1.0/round(expInfo['frameRate'])
else:
    frameDur = 1.0/60.0 # couldn't get a reliable measure so guess

# Initialize components for Routine "happy_1"
happy_1Clock = core.Clock()
top = visual.ImageStim(win=win, name='top',
    image='sin', mask=None,
    ori=0, pos=[0, 0.4], size=[0.25, 0.5],
    color=[1,1,1], colorSpace='rgb', opacity=1,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=0.0)
left = visual.ImageStim(win=win, name='left',
    image='sin', mask=None,
    ori=0, pos=[-0.3, -0.2], size=[0.25, 0.5],
    color=[1,1,1], colorSpace='rgb', opacity=1,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=-1.0)
right = visual.ImageStim(win=win, name='right',
    image='sin', mask=None,
    ori=0, pos=[0.3, -0.2], size=[0.25, 0.5],
    color=[1,1,1], colorSpace='rgb', opacity=1,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=-2.0)


# Initialize components for Routine "fixation"
fixationClock = core.Clock()
fixation_text = visual.TextStim(win=win, ori=0, name='fixation_text',
    text=u'+',    font=u'Arial',
    pos=[0, 0], height=0.15, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=0.0)


# Create some handy timers
globalClock = core.Clock()  # to track the time since experiment started
routineTimer = core.CountdownTimer()  # to track time remaining of each (non-slip) routine 


instructions_test = visual.TextStim(win=win, ori=0, name='instructions_test',
    text=u'Instructions:\n\nFind which bottom picture matches the top one. Pictures can be faces, fruits, or vegetables.\n\nPress any button to continue.',    font=u'Arial',
    pos=[0, 0], height=0.1, wrapWidth=1.5,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=0.0)

instructions_test.draw()
win.flip()
event.waitKeys(keyList=["0","1","2","3","4","5","6","7","8","9","space","escape"])

instructions_text_pressI = visual.TextStim(win=win, ori=0, name='instructions_test',
    text=u'If the bottom left matches, press the index finger button. (press it now!)',    font=u'Arial',
    pos=[0, 0], height=0.1, wrapWidth=1.5,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=0.0)
instructions_text_pressI.draw()
win.flip()
event.waitKeys(keyList=["1","9"])

instructions_text_pressM = visual.TextStim(win=win, ori=0, name='instructions_test',
    text=u'If the bottom right matches, press the middle finger button. (press it now!)',    font=u'Arial',
    pos=[0, 0], height=0.1, wrapWidth=1.5,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=0.0)

instructions_text_pressM.draw()
win.flip()
event.waitKeys(keyList=["2","8"])


for r in runs:
    expInfo['run'] = r
    conditionFile='face_matching_stimuli_'+r+'.csv'###CHANGED CONDITION FILE
    """#Write condition file (randomize block file sequence)
    if expInfo['runMode'] == 'Scanner':
        conditionFile=output+'/FaceMatching_all_blocks_list_3x'+r+'.csv'
        block_names=['block_A_happy_1.csv','block_A_fear_1.csv','block_A_neutral_1.csv','block_A_objects_1.csv']
            with open(conditionFile, 'wb') as csvfile:
                writer = csv.DictWriter(csvfile, fieldnames = ["trial_blocks"])
                writer.writeheader()
                blocks =[]  
                for i in range(1,4):
                    random.shuffle(block_names)
                    blocks.append('block_fixation.csv') 
                    blocks = blocks + [x.replace('1',str(i)).replace('A',r) for x in block_names]
                    
                for i in blocks:
                    print>>csvfile, i
    """     
    
    thisExp.nextEntry()
    # the Routine "instructions" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset()


    #------Prepare to start Routine "trigger"-------
    
    msgExpter = visual.TextStim(win,text="Waiting for the experimenter.", pos=(0,0),colorSpace='rgb',color=1,height=0.1,wrapWidth=1.5,depth=0.01)
    msgExpter.draw()
    msgExpter.draw()
    win.flip()
    event.waitKeys(keyList=["q"])
    # Initialize components for Routine "trigger"
    msgMachine = visual.TextStim(win,text="Waiting for the scanner.", pos=(0,0),colorSpace='rgb',color=1,height=0.1,wrapWidth=1.5,depth=0.01)
    msgMachine.draw()
    msgMachine.draw()
    win.flip()
    event.waitKeys(keyList=["=","equal"])
    
    # the Routine "trigger" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset()
    """
    # set up handler to look after randomisation of conditions etc
    blocks = data.TrialHandler(nReps=1, method='sequential', 
       extraInfo=expInfo, originPath=None,
      trialList=data.importConditions(conditionFile),
      seed=None, name='blocks')
        #print data.importConditions(u'blocks/all_blocks_list_3x'+expInfo['run']+'.csv')
    #blocks = data.TrialHandler(nReps=1, method='sequential', 
    #  extraInfo=expInfo, originPath=None,
    # trialList=blocks,
    # seed=None)
     
    thisExp.addLoop(blocks)  # add the loop to the experiment
    thisBlock = blocks.trialList[0]  # so we can initialise stimuli with some values
    for thisBlock in blocks:
        currentLoop = blocks
        # abbreviate parameter names if possible (e.g. rgb = thisBlock.rgb)
        if thisBlock != None:
        for paramName in thisBlock.keys():
           exec(paramName + '= thisBlock.' + paramName)
    """
    # set up handler to look after randomisation of conditions etc
    trials = data.TrialHandler(nReps=1, method='sequential', 
        extraInfo=expInfo, originPath=None,
        trialList=data.importConditions(conditionFile),
        #trialList=data.importConditions("blocks/"+trial_blocks),
        seed=None, name='trials')



    thisExp.addLoop(trials)  # add the loop to the experiment
    thisTrial = trials.trialList[0]  # so we can initialise stimuli with some values
    # abbreviate parameter names if possible (e.g. rgb=thisTrial.rgb)

    if thisTrial != None:
        for paramName in thisTrial.keys():
            exec(paramName + '= thisTrial.' + paramName)
            
    for thisTrial in trials:
        currentLoop = trials
        # abbreviate parameter names if possible (e.g. rgb = thisTrial.rgb)
        if thisTrial != None:
            for paramName in thisTrial.keys():
                exec(paramName + '= thisTrial.' + paramName)
        
        #------Prepare to start Routine "happy_1"-------
        t = 0
        happy_1Clock.reset()  # clock 
        frameN = -1
        routineTimer.add(3.000000)
        # update component parameters for each repeat
        top.setImage(top_image)
        left.setImage(left_image)
        right.setImage(right_image)
        key_resp_trial = event.BuilderKeyResponse()  # create an object of type KeyResponse
        key_resp_trial.status = NOT_STARTED
        # keep track of which components have finished
        happy_1Components = []
        happy_1Components.append(top)
        happy_1Components.append(left)
        happy_1Components.append(right)
        happy_1Components.append(key_resp_trial)
        for thisComponent in happy_1Components:
            if hasattr(thisComponent, 'status'):
                thisComponent.status = NOT_STARTED


        if 'fixation' in top.image:
            print "this roung is fixation" ,top.image
            
            #------Prepare to start Routine "fixation"-------
            t = 0
            fixationClock.reset()  # clock 
            frameN = -1
            routineTimer.add(3.000000)
            # update component parameters for each repeat
            # keep track of which components have finished
            fixationComponents = []
            fixationComponents.append(fixation_text)
            for thisComponent in fixationComponents:
                if hasattr(thisComponent, 'status'):
                    thisComponent.status = NOT_STARTED

            #-------Start Routine "fixation"-------
            continueRoutine = True
            while continueRoutine and routineTimer.getTime() > 0:
                # get current time
                t = fixationClock.getTime()
                frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
                # update/draw components on each frame
            
                # *fixation_text* updates
                if t >= 0.0 and fixation_text.status == NOT_STARTED:
                    # keep track of start time/frame for later
                    fixation_text.tStart = t  # underestimates by a little under one frame
                    fixation_text.frameNStart = frameN  # exact frame index
                    fixation_text.setAutoDraw(True)
                if fixation_text.status == STARTED and t >= (0.0 + (3-win.monitorFramePeriod*0.75)): #most of one frame period left
                    fixation_text.setAutoDraw(False)
            
                # check if all components have finished
                if not continueRoutine:  # a component has requested a forced-end of Routine
                    break
                continueRoutine = False  # will revert to True if at least one component still running
                for thisComponent in fixationComponents:
                    if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                        continueRoutine = True
                        break  # at least one component has not yet finished
            
                # check for quit (the Esc key)
                if endExpNow or event.getKeys(keyList=["escape"]):
                    core.quit()
            
                # refresh the screen
                if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                    win.flip()

            #-------Ending Routine "fixation"-------
            for thisComponent in fixationComponents:
                if hasattr(thisComponent, "setAutoDraw"):
                    thisComponent.setAutoDraw(False)
        else:
            print "image ",top.image
            
            #-------Start Routine "happy_1"-------
            continueRoutine = True
            allPressedKeys=[]
            allPressedKeysTime=[]
            while continueRoutine and routineTimer.getTime() > 0:
                # get current time
                t = happy_1Clock.getTime()
                frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
                # update/draw components on each frame
            
                # *top* updates
                if t >= 0 and top.status == NOT_STARTED:
                    # keep track of start time/frame for later
                    top.tStart = t  # underestimates by a little under one frame
                    top.frameNStart = frameN  # exact frame index
                    top.setAutoDraw(True)
                if top.status == STARTED and t >= (0 + (3-win.monitorFramePeriod*0.75)): #most of one frame period left
                    top.setAutoDraw(False)
            
                # *left* updates
                if t >= 0 and left.status == NOT_STARTED:
                    # keep track of start time/frame for later
                    left.tStart = t  # underestimates by a little under one frame
                    left.frameNStart = frameN  # exact frame index
                    left.setAutoDraw(True)
                if left.status == STARTED and t >= (0 + (3-win.monitorFramePeriod*0.75)): #most of one frame period left
                    left.setAutoDraw(False)
            
                # *right* updates
                if t >= 0 and right.status == NOT_STARTED:
                    # keep track of start time/frame for later
                    right.tStart = t  # underestimates by a little under one frame
                    right.frameNStart = frameN  # exact frame index
                    right.setAutoDraw(True)
                if right.status == STARTED and t >= (0 + (3-win.monitorFramePeriod*0.75)): #most of one frame period left
                    right.setAutoDraw(False)
            
                # *key_resp_trial* updates
                if t >= 0.0 and key_resp_trial.status == NOT_STARTED:
                    # keep track of start time/frame for later
                    key_resp_trial.tStart = t  # underestimates by a little under one frame
                    key_resp_trial.frameNStart = frameN  # exact frame index
                    key_resp_trial.status = STARTED
                    # keyboard checking is just starting
                    key_resp_trial.clock.reset()  # now t=0
                    event.clearEvents(eventType='keyboard')
                if key_resp_trial.status == STARTED and t >= (0.0 + (3-win.monitorFramePeriod*0.75)): #most of one frame period left
                    key_resp_trial.status = STOPPED
                if key_resp_trial.status == STARTED:
                    theseKeys = event.getKeys(keyList=['1', '2','8','9'])
                    
                    # check for quit:
                    if "escape" in theseKeys:
                        endExpNow = True
                    if len(theseKeys) > 0:  # at least one key was pressed
                        key_resp_trial.keys = theseKeys[-1]  # just the last key pressed
                        key_resp_trial.rt = key_resp_trial.clock.getTime()
                    # was this 'correct'?
                    if (key_resp_trial.keys == str(int(corr_ans))) or (key_resp_trial.keys == corr_ans) or (key_resp_trial.keys == str(int(corr_ans_Left))) or (key_resp_trial.keys == corr_ans_Left):
                        key_resp_trial.corr = 1
                    else:
                        key_resp_trial.corr = 0
                        for k in theseKeys:
                            allPressedKeys.append(k)
                            allPressedKeysTime.append(key_resp_trial.clock.getTime())
                  

                # check if all components have finished
                if not continueRoutine:  # a component has requested a forced-end of Routine
                    break
                continueRoutine = False  # will revert to True if at least one component still running
                for thisComponent in happy_1Components:
                    if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                        continueRoutine = True
                        break  # at least one component has not yet finished
            
                # check for quit (the Esc key)
                if endExpNow or event.getKeys(keyList=["escape"]):
                    core.quit()
            
                # refresh the screen
                if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                    win.flip()
            
            #-------Ending Routine "happy_1"-------
            for thisComponent in happy_1Components:
                if hasattr(thisComponent, "setAutoDraw"):
                    thisComponent.setAutoDraw(False)
            # check responses
            if key_resp_trial.keys in ['', [], None]:  # No response was made
               key_resp_trial.keys=None
               # was no response the correct answer?!
               if str(corr_ans).lower() == 'none': key_resp_trial.corr = 1  # correct non-response
               else: key_resp_trial.corr = 0  # failed to respond (incorrectly)
            # store data for trials (TrialHandler)
            trials.addData('key_resp_trial.keys',key_resp_trial.keys)
            trials.addData('key_resp_trial.corr', key_resp_trial.corr)
            if key_resp_trial.keys != None:  # we had a response
                trials.addData('key_resp_trial.rt', key_resp_trial.rt)
                trials.addData("allPressedKeys", str(allPressedKeys).replace(",",":"))
                trials.addData("allPressedKeysTime", str(allPressedKeysTime).replace(",",":"))
            thisExp.nextEntry()

    # completed 1 repeats of 'trials'

    thisExp.nextEntry()
         


# Initialize components for Routine "thanks"
thanks_text = visual.TextStim(win=win, ori=0, name='thanks_text',
    text=u'Thanks!',    font=u'Arial',
    pos=[0, 0], height=0.1, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=0.0)

thanks_text.draw()
win.flip()
event.waitKeys(keyList=["0","1","2","3","4","5","6","7","8","9","space","escape"])

win.close()
core.quit()
