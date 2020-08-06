#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
A preliminary version of this experiment was created using
PsychoPy2 Experiment Builder (v1.81.03), Tue Jan 20 10:30:57 2015

This script was then further modified by JTM (Jan-Feb 2015). 

If you publish work using this script please cite the relevant PsychoPy publications
  Peirce, JW (2007) PsychoPy - Psychophysics software in Python. Journal of Neuroscience Methods, 162(1-2), 8-13.
  Peirce, JW (2009) Generating stimuli for neuroscience using PsychoPy. Frontiers in Neuroinformatics, 2:10. doi: 10.3389/neuro.11.010.2008
"""

from __future__ import division  # so that 1/3=0.333 instead of 1/3=0
from psychopy import core, data, event, logging, gui
from psychopy.constants import *  # things like STARTED, FINISHED
import numpy as np  # whole numpy lib is available, prepend 'np.'
from numpy import sin, cos, tan, log, log10, pi, average, sqrt, std, deg2rad, rad2deg, linspace, asarray
from numpy.random import random, randint, normal, shuffle
import os  # handy system and path functions
import sys
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
    output='/Users/amennen/resting_output'

    
_thisDir = os.path.dirname(os.path.abspath(__file__))
os.chdir(_thisDir)
expName = 'Resting'

expInfo = {}
# Collect run mode and participant ID

dlg1 = gui.Dlg(title="Participant ID")
dlg1.addField('Participant')
dlg1.addField('Mode', choices=["Scanner", "Practice"])
dlg1.addField('Day',choices=["1","2"])
dlg1.addField('Group', choices=["HC", "MDD"])
dlg1.addField('Session', choices=["ABCD","IPAT2","CMRR"])
dlg1.addField('Run', choices= ["AB", "CD"])

dlg1.show()
if dlg1.OK:  # then the user pressed OK
    # add the new entries to expInfo
    expInfo['participant'] = dlg1.data[0]
    expInfo['runMode'] = dlg1.data[1]
    expInfo['day'] = dlg1.data[2]
    expInfo['group'] = dlg1.data[3]
    expInfo['session'] = dlg1.data[4]
    expInfo['run'] = dlg1.data[5]
    expInfo['CB'] = "1" #dlg2.data[2]
    RunMode = expInfo['runMode']
else:
    core.quit() # user pressed cancel
if expInfo['runMode'] == "Scanner":
	if expInfo["run"] == "AB":
		runs=["A"]
	else:
		runs=["C"]
else:
	runs=["P"]

expInfo['expName'] = expName
expInfo['date'] = data.getDateStr()  # add a simple timestamp

# Data file name stem = absolute path + name; later add .psyexp, .csv, .log, etc
#filename = 'data/'+expInfo['participant']+ os.path.sep + '%s_%s_%s_%s_%s' %(expInfo['participant'],expInfo['session'],expInfo['run'],expName,expInfo['date'])
filename = output + os.sep + expInfo['participant'] + os.sep +'%s_Day%s_%s_%s_%s_%s_%s' %(expInfo['participant'],expInfo['day'],expInfo['runMode'],expInfo['session'],expInfo['run'],expInfo['expName'],expInfo['date'])


# certain import statements were deferred till now because they
# interfere with dialog boxes
from psychopy import visual

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
# Setup the Window  
win = visual.Window(fullscr=True,size=(800, 600), screen=1, allowGUI=False, allowStencil=False,
    monitor='testMonitor', color=[0,0,0], colorSpace='rgb',
    blendMode='avg', useFBO=True, waitBlanking=True
   )
# store frame rate of monitor if we can measure it successfully
expInfo['frameRate']=win.getActualFrameRate()
if expInfo['frameRate']!=None:
    frameDur = 1.0/round(expInfo['frameRate'])
else:
    frameDur = 1.0/60.0 # couldn't get a reliable measure so guess


# Initialize informational messages
instructions_test1 = visual.TextStim(win=win, ori=0, name='instructions_test1',
    text=u'Instructions:\n\nDuring the next scan, we will put up a blank screen and a small plus sign will appear in the center of the screen at some point. You have to keep your eyes open and stay awake during this scan, and view the plus sign while it''s on the center of the screen.\n\nPress your index finger to continue.',    font=u'Arial',
    pos=[0, 0], height=0.1, wrapWidth=1.5,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=0.0)
instructions_test2 = visual.TextStim(win=win, ori=0, name='instructions_test2',
    text=u'You can blink normally, but do your best to keep your eyes open, look at the plus sign, and keep your head still the whole time. After the scan, there will be some questions on the screen with directions on how to answer.\n\nDo you have any questions? \nPlease tell the experimenter YES or NO.',    font=u'Arial',
    pos=[0, 0], height=0.1, wrapWidth=1.5,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=0.0)
msgInstr = visual.TextStim(win,text="Great, let's begin. Please keep your eyes open. This task will last 6 minutes.\n\nPress your index finger to continue.",
    pos=(0,0),alignHoriz='center',colorSpace='rgb',color=1,height=0.1,wrapWidth=1.5,depth=0.01)

msgScanner = visual.TextStim(win,text="Waiting for the scanner.",
    pos=(0,0),colorSpace='rgb',color=1,height=0.1,wrapWidth=1.5,depth=0.01)
msgBlank = visual.TextStim(win,text="",
    pos=(0,0),colorSpace='rgb',color=1,height=0.1,wrapWidth=1.5,depth=0.01)
msgComplete = visual.TextStim(win,text="Task complete.",
    pos=(0,0),colorSpace='rgb',color=1,height=0.1,wrapWidth=1.5,depth=0.01)


#ISI = core.StaticPeriod(win=win, screenHz=expInfo['frameRate'], name='ISI')
Fixation = visual.TextStim(win=win, ori=0, name='Fixation',
    text='+',    font='Arial',
    pos=[0, 0], height=0.15, wrapWidth=None,
    color='white', colorSpace='rgb', opacity=1,
    depth=-1.0)
instructions_test1.draw()
win.flip()
event.waitKeys(keyList=["1","9"])
instructions_test2.draw()
win.flip()
event.waitKeys(keyList=["1","9"])
msgInstr.draw()
win.flip()
event.waitKeys(keyList=["1","9"])


# set the cue positions
# Pre-block messages
# Message 1: waiting for the experimenter
for r in runs:
	expInfo['run'] = r
	# Message 2: waiting for the scanner
	msgScanner.draw()
	win.flip()
	event.waitKeys(keyList=["=","equal", "5", "5%", "%", "=+"])


	Fixation.draw()
	win.flip()
		  
	# check for quit (the Esc key)
	#event.waitKeys(keyList=["escape"])
	if  expInfo['runMode'] == "Scanner":
		core.wait(390.0)
	else:
		core.wait(4)
 
	#msgComplete.draw()	
	#win.flip()
	#event.waitKeys(keyList=["q","space", "escape"])

	#saving questionnaire data
	PossibleAnswers=[]
	PossibleInputs=[]

	#questionaire resting 
	#question #1
	qst1 = visual.TextStim(win,text="Did you find yourself falling asleep or dozing off at any time during this task? \n\nPress index finger button for Yes \nPress middle finger button for No", pos=(0,0),colorSpace='rgb',color=1,height=0.1,wrapWidth=1.5,depth=0.01)
	qst1.draw()	
	win.flip()
	ans1 = event.waitKeys(keyList=["1","2","9","8","space", "escape"])
	PossibleAnswers = (['Yes', 'No'])
	PossibleInputs = (['1','2',"9","8"])
	thisExp.addData('Question','Fall asleep?')
	thisExp.addData('Answer',ans1)
	thisExp.addData('Possible Answers', str(PossibleAnswers).replace(",",":"))
	thisExp.addData('Possible Inputs', str(PossibleInputs).replace(",",":"))
	thisExp.nextEntry()


	#if event.getKeys(keyList=["1"]):
	if ans1 == ['1'] or ans1 == ['9']:
	    qst2= visual.TextStim(win,text="How many times? Press: \n\n- Index finger button for 1 time \n- Middle finger button for 2 times \n- Ring finger button for 3 times \n- Pinky finger button for 4 or more times", pos=(0,0),colorSpace='rgb',color=1,height=0.1,wrapWidth=1.5,depth=0.01)
	    qst2.draw()	
	    win.flip()
	    ans2 = event.waitKeys(keyList=["1","2","3","4","5","0","9","8","7","6","space", "escape"]) 
	    PossibleAnswers = (['1 time', '2 times', '3 times', '4 times'])
	    PossibleInputs = (['1','2','3','4','5',"0","9","8","7","6"])       
	    thisExp.addData('Question','How many times did you fall sleep?')
	    thisExp.addData('Answer',ans2)
	    thisExp.addData('Possible Answers', str(PossibleAnswers).replace(",",":"))
	    thisExp.addData('Possible Inputs', str(PossibleInputs).replace(",",":"))
	    thisExp.nextEntry()

	qst3= visual.TextStim(win,text="Did you find your thoughts drifting/wandering between topics with no specific direction? \n\nPress index finger button for Yes \nPress middle finger button for No ", pos=(0,0),colorSpace='rgb',color=1,height=0.1,wrapWidth=1.5,depth=0.01)
	qst3.draw()	
	win.flip()
	ans3 = event.waitKeys(keyList=["1","2","9","8","space", "escape"]) 
	PossibleAnswers = (['Yes', 'No'])
	PossibleInputs = (['1','2',"9","8"])       
	thisExp.addData('Question','Thoughts drifted?')
	thisExp.addData('Answer',ans3)
	thisExp.addData('Possible Answers', str(PossibleAnswers).replace(",",":"))
	thisExp.addData('Possible Inputs', str(PossibleInputs).replace(",",":"))
	thisExp.nextEntry()


	#if event.getKeys(keyList=["1"]):
	if ans3 == ['1'] or ans3 == ['9']:
	    qst4= visual.TextStim(win,text="How often did you find your thoughts drifting/wandering? Press: \n\n- Index finger button for Almost Never \n- Middle finger button for Sometimes \n- Ring finger button for Often  \n- Pinky finger button for Always ", pos=(0,0),colorSpace='rgb',color=1,height=0.1,wrapWidth=1.5,depth=0.01)
	    qst4.draw()	
	    win.flip()       
	    ans4 = event.waitKeys(keyList=["1","2","3","4","5","0","9","8","7","6","space", "escape"])  
	    PossibleAnswers = (['Almost Never', 'Sometimes', 'Often', 'Always'])
	    PossibleInputs = (['1','2','3','4','5',"0",'9','8',"7","6"])      
	    thisExp.addData('Question','How many times did your thoughts drift?')
	    thisExp.addData('Answer',ans4)
	    thisExp.addData('Possible Answers', str(PossibleAnswers).replace(",",":"))
	    thisExp.addData('Possible Inputs', str(PossibleInputs).replace(",",":"))
	    thisExp.nextEntry()

	
  
  
# completed loop over runs

# Task-complete message


win.close()
core.quit()
